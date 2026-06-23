package com.morbit.amap_flutter

import android.app.Activity
import android.content.Context
import android.util.Log
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.AmapNaviPage
import com.amap.api.navi.AmapNaviParams
import com.amap.api.navi.AmapNaviType
import com.amap.api.navi.AmapPageType
import com.amap.api.navi.INaviInfoCallback
import com.amap.api.navi.NaviSetting
import com.amap.api.navi.enums.AimLessMode
import com.amap.api.navi.model.AMapCarInfo
import com.amap.api.navi.model.AMapNaviLocation
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Poi
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter ↔ 高德导航 SDK 的 Android 桥接层。
 *
 * 由 [AMapFlutterPlugin] 在 `setup` / `dispose` 时挂载，对应 Dart 侧 [AMapNavi] API。
 *
 * ## 通道
 * - **MethodChannel** `plugins.flutter.dev/amap_navi`：接收 `startNavigation` / `stopNavigation` /
 *   `startCruiseMode` / `stopCruiseMode`
 * - **EventChannel** `plugins.flutter.dev/amap_navi_events`：向 Dart 推送导航/巡航事件
 *
 * ## 两种互斥模式
 * 1. **组件导航**（`startNavigation`）：拉起高德内置路线/导航 UI（[AmapNaviPage]），
 *    引擎事件由 [AMapNaviListenerImpl] 转发，页面 UI 事件由 [NaviInfoCallbackImpl] 处理。
 * 2. **智能巡航**（`startCruiseMode`）：无起终点，调用 `AMapNavi.startAimlessMode`，
 *    事件由 [AimlessModeListenerImpl] 转发。
 *
 * Dart 侧已声明两种模式互斥；原生 `startNavigation` 开头也会先 [stopCruiseModeInternal]。
 *
 * ## 生命周期
 * - [setup] 必须在主线程调用；[dispose] 在插件卸载时必须调用以释放引擎与 Channel。
 * - 全部状态保存在 companion object 静态变量中（单 Engine 单例模型）。
 *
 * ## 会话状态变量
 * | 变量 | 含义 |
 * |------|------|
 * | [aMapNavi] | 导航引擎单例引用 |
 * | [naviComponentActive] | 路线/导航组件 Activity 是否已拉起 |
 * | [cleaningNaviSession] | 防止 [cleanupNaviSession] 重入 |
 * | [naviListenerAttached] | [AMapNaviListener] 是否已 add 到引擎 |
 * | [aimlessListenerAttached] | 巡航监听器是否已 add |
 * | [cruiseAttachedNaviListener] | 巡航启动时是否由本模块附加了 naviListener（停止时需 detach） |
 * | [cruiseActive] | 是否处于 aimless 巡航 |
 *
 * ## 清理路径分工
 * - [cleanupNaviSession]：`stopNavi()` + `AMapNavi.destroy()` + detach listener（重清理）
 * - [clearNaviComponentSessionState]：仅清引用/标志，不 destroy 引擎（轻清理）
 * - [releaseNaviAfterComponentExit]：用户从导航页退出时的收尾，配合
 *   `setNeedDestroyDriveManagerInstanceWhenNaviExit(true)` 由 SDK 自销毁引擎
 */
class AMapNaviApi {
    companion object {
        private const val TAG = "AMapNaviApi"
        private const val NAVI_METHOD_CHANNEL = "plugins.flutter.dev/amap_navi"
        private const val NAVI_EVENT_CHANNEL = "plugins.flutter.dev/amap_navi_events"

        private var registeredMessenger: BinaryMessenger? = null
        private var methodChannel: MethodChannel? = null
        private var eventChannel: EventChannel? = null
        private var naviListener: AMapNaviListenerImpl? = null
        private var aimlessListener: AimlessModeListenerImpl? = null
        private var aMapNavi: AMapNavi? = null
        private var activityRef: Activity? = null
        private var naviListenerAttached: Boolean = false
        private var aimlessListenerAttached: Boolean = false
        private var cruiseAttachedNaviListener: Boolean = false
        private var naviComponentActive: Boolean = false
        private var cleaningNaviSession: Boolean = false
        private var cruiseActive: Boolean = false

        private class NaviNoActivityException(message: String) : IllegalStateException(message)

        /**
         * 注册 MethodChannel / EventChannel，创建导航事件监听器。
         *
         * EventSink 在 `onListen` 时同时赋给 [naviListener] 与 [aimlessListener]，
         * 保证导航与巡航共用同一 Dart 事件流。
         */
        fun setup(binding: FlutterPluginBinding, activity: Activity?) {
            activityRef = activity ?: activityRef

            val messenger = binding.binaryMessenger
            if (registeredMessenger === messenger && methodChannel != null && eventChannel != null) {
                return
            }

            methodChannel?.setMethodCallHandler(null)
            eventChannel?.setStreamHandler(null)
            registeredMessenger = messenger

            methodChannel = MethodChannel(messenger, NAVI_METHOD_CHANNEL)
            methodChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                handleMethodCall(binding.applicationContext, call, result)
            }

            if (naviListener == null) {
                naviListener = AMapNaviListenerImpl()
            }
            eventChannel = EventChannel(messenger, NAVI_EVENT_CHANNEL)
            eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.i(TAG, "EventChannel onListen")
                    naviListener?.eventSink = events
                    aimlessListener?.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    Log.i(TAG, "EventChannel onCancel")
                    naviListener?.eventSink = null
                    aimlessListener?.eventSink = null
                }
            })
        }

        /** Activity 重建时更新引用，用于 [AmapNaviPage.showRouteActivity] 的 Context。 */
        fun updateActivity(activity: Activity?) {
            activityRef = activity
        }

        /**
         * 插件卸载时释放所有资源：先停巡航/导航，再注销 Channel 并复位状态标志。
         */
        fun dispose() {
            stopCruiseModeInternal()
            stopNavigation()
            methodChannel?.setMethodCallHandler(null)
            methodChannel = null
            eventChannel?.setStreamHandler(null)
            eventChannel = null
            registeredMessenger = null
            naviListener = null
            aimlessListener = null
            activityRef = null
            naviListenerAttached = false
            aimlessListenerAttached = false
            cruiseAttachedNaviListener = false
            naviComponentActive = false
            cleaningNaviSession = false
            cruiseActive = false
        }

        private fun handleMethodCall(context: Context, call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "startNavigation" -> {
                    try {
                        startNavigation(context, call)
                        result.success(null)
                    } catch (e: NaviNoActivityException) {
                        Log.w(TAG, "startNavigation requires an attached Activity", e)
                        result.error("NAVI_NO_ACTIVITY", e.message, null)
                    } catch (e: Exception) {
                        Log.e(TAG, "startNavigation error", e)
                        result.error("NAVI_ERROR", e.message, null)
                    }
                }

                "stopNavigation" -> {
                    stopNavigation()
                    result.success(null)
                }

                "startCruiseMode" -> {
                    try {
                        startCruiseMode(context, call)
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e(TAG, "startCruiseMode error", e)
                        result.error("CRUISE_ERROR", e.message, null)
                    }
                }

                "stopCruiseMode" -> {
                    try {
                        stopCruiseModeInternal()
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e(TAG, "stopCruiseMode error", e)
                        result.error("CRUISE_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        /**
         * 启动高德导航组件（路线规划页或导航页）。
         *
         * 参数与 Dart [NaviConfig] 一一对应（经 MethodChannel 传入）：
         * - `naviType`：0=驾车, 1=步行, 2=骑行
         * - `pageType`：0=路线规划页, 1=导航页
         * - `start*` / `end*` / `wayPoints`：起终点与途经点；起点为 null 时 SDK 使用当前位置
         * - `end` 为 null 时 SDK 展示选点页让用户选择终点
         * - `drivingStrategy` / `travelStrategy` / `multipleRoute` / `startNaviDirectly`：算路策略
         * - `carNumber` / `motorcycleCC` / `vehicleInfo`：车辆信息（车牌优先级见 [applyCarInfo]）
         *
         * **注意**：`startAngle` / `endAngle` 已由 Dart 传递，但 Android 端构建 [Poi] 时暂不支持方向角。
         *
         * ### Preflight 清理
         * 若上次导航组件仍标记为 active（用户未正常退出），先 `exitRouteActivity` 再清状态，
         * 避免连续两次启动导航时无法重新算路的问题。
         */
        private fun startNavigation(context: Context, call: MethodCall) {
            val launchActivity = activityRef ?: throw NaviNoActivityException(
                "AMap navigation requires an attached Activity. Ensure the plugin is registered on a foreground FlutterActivity before calling startNavigation."
            )
            stopCruiseModeInternal()
            if (naviComponentActive) {
                Log.w(TAG, "startNavigation requested while previous component is still active")
                requestExitRouteActivity("startNavigation")
                clearNaviComponentSessionState("startNavigation active preflight")
            } else {
                cleanupNaviSession(
                    exitRouteActivity = false,
                    destroyNavi = true,
                    reason = "startNavigation"
                )
            }

            NaviSetting.updatePrivacyShow(context, true, true)
            NaviSetting.updatePrivacyAgree(context, true)

            val carNumber = call.argument<String>("carNumber")
            val motorcycleCC = call.argument<Int>("motorcycleCC")
            val naviTypeIndex = call.argument<Int>("naviType") ?: 0
            val pageTypeIndex = call.argument<Int>("pageType") ?: 0
            val drivingStrategy = call.argument<Int>("drivingStrategy") ?: 10
            val travelStrategy = call.argument<Int>("travelStrategy")
            val multipleRoute = call.argument<Boolean>("multipleRoute") ?: true
            val startNaviDirectly = call.argument<Boolean>("startNaviDirectly")
            @Suppress("UNCHECKED_CAST")
            val vehicleInfo = call.argument<Map<String, Any?>>("vehicleInfo")

            val startLat = call.argument<Double>("startLat")
            val startLng = call.argument<Double>("startLng")
            val startName = call.argument<String>("startName")
            val startPoiId = call.argument<String>("startPoiId")

            val endLat = call.argument<Double>("endLat")
            val endLng = call.argument<Double>("endLng")
            val endName = call.argument<String>("endName")
            val endPoiId = call.argument<String>("endPoiId")

            @Suppress("UNCHECKED_CAST")
            val wayPointsList = call.argument<List<Map<String, Any?>>>("wayPoints")

            aMapNavi = AMapNavi.getInstance(context)
            naviListener?.resetSessionState()

            val carInfo = AMapCarInfo()
            applyCarInfo(carInfo, vehicleInfo)
            // carNumber 参数优先级高于 vehicleInfo.vehicleId（后者已在 applyCarInfo 中写入）
            carNumber?.let { carInfo.carNumber = it }
            motorcycleCC?.let { carInfo.motorcycleCC = it }

            attachNaviListener()

            val start: Poi? = if (startLat != null && startLng != null) {
                Poi(startName ?: "起点", LatLng(startLat, startLng), startPoiId ?: "")
            } else {
                null
            }

            val end: Poi? = if (endLat != null && endLng != null) {
                Poi(endName ?: "终点", LatLng(endLat, endLng), endPoiId ?: "")
            } else {
                null
            }

            val wayPoints: MutableList<Poi> = mutableListOf()
            wayPointsList?.forEach { wayPoint ->
                val lat = (wayPoint["lat"] as? Number)?.toDouble()
                val lng = (wayPoint["lng"] as? Number)?.toDouble()
                val name = wayPoint["name"] as? String ?: "途经点"
                val poiId = wayPoint["poiId"] as? String ?: ""
                if (lat != null && lng != null) {
                    wayPoints.add(Poi(name, LatLng(lat, lng), poiId))
                }
            }

            val naviType = when (naviTypeIndex) {
                0 -> AmapNaviType.DRIVER
                1 -> AmapNaviType.WALK
                2 -> AmapNaviType.RIDE
                else -> AmapNaviType.DRIVER
            }

            val pageType = when (pageTypeIndex) {
                0 -> AmapPageType.ROUTE
                1 -> AmapPageType.NAVI
                else -> AmapPageType.ROUTE
            }

            Log.i(
                TAG, "startNavigation: naviType=$naviType, pageType=$pageType, " +
                        "start=$start, end=$end, wayPoints=${wayPoints.size}"
            )

            val params = AmapNaviParams(
                start,
                wayPoints,
                end,
                naviType,
                pageType
            ).setUseInnerVoice(true)
                .setNeedDestroyDriveManagerInstanceWhenNaviExit(true)
                .setCarInfo(carInfo)
            if (naviType == AmapNaviType.DRIVER) {
                params.tryCall("setMultipleRouteNaviMode", multipleRoute)
                params.tryCall("setRouteStrategy", drivingStrategy)
            } else if (travelStrategy != null) {
                params.tryCall("setRouteStrategy", travelStrategy)
            }
            if (startNaviDirectly != null) {
                params.tryCall("setNeedCalculateRouteWhenPresent", !startNaviDirectly)
            }

            try {
                naviComponentActive = true
                AmapNaviPage.getInstance().showRouteActivity(
                    launchActivity,
                    params,
                    NaviInfoCallbackImpl(),
                    AMapFlutterRouteActivity::class.java
                )
            } catch (e: Exception) {
                cleanupNaviSession(
                    exitRouteActivity = false,
                    destroyNavi = true,
                    reason = "startNavigation showRouteActivity failed"
                )
                throw e
            }
        }

        /**
         * 将 Dart [NaviVehicleInfo] 字段映射到 [AMapCarInfo]。
         *
         * | Dart 字段 | AMapCarInfo | 说明 |
         * |-----------|-------------|------|
         * | vehicleId | carNumber | 车牌号；可被顶层 `carNumber` 参数覆盖 |
         * | isRestriction | setRestriction | 是否避开限行 |
         * | type | setCarType | 0=小客车, 1=货车, 2=客车 |
         * | height | setVehicleHeight | 车高（米），限高规避 |
         * | weight | setVehicleWeight | 车辆总重（吨），限重规避 |
         * | load | setVehicleLoad | 核定载重（吨） |
         * | vehicleLoadSwitch | setVehicleLoadSwitch | 载重开关 |
         * | width | setVehicleWidth | 车宽（米） |
         * | length | setVehicleLength | 车长（米） |
         * | size | setVehicleSize | 0=微型, 1=轻型, 2=中型, 3=重型 |
         * | axisNums | setVehicleAxis | 轴数 |
         * | motorcycleCC | motorcycleCC | 摩托车排量（CC） |
         */
        private fun applyCarInfo(carInfo: AMapCarInfo, info: Map<String, Any?>?) {
            if (info == null) return
            fun doubleValue(key: String) = (info[key] as? Number)?.toDouble()
            fun intValue(key: String) = (info[key] as? Number)?.toInt()
            fun boolValue(key: String) = info[key] as? Boolean
            info["vehicleId"]?.toString()?.takeIf { it.isNotEmpty() }?.let { carInfo.carNumber = it }
            intValue("motorcycleCC")?.let { carInfo.motorcycleCC = it }
            carInfo.trySet("setRestriction", boolValue("isRestriction"))
            carInfo.trySet("setCarType", intValue("type"))
            carInfo.trySet("setVehicleHeight", doubleValue("height"))
            carInfo.trySet("setVehicleWeight", doubleValue("weight"))
            carInfo.trySet("setVehicleLoad", doubleValue("load"))
            carInfo.trySet("setVehicleLoadSwitch", boolValue("vehicleLoadSwitch"))
            carInfo.trySet("setVehicleWidth", doubleValue("width"))
            carInfo.trySet("setVehicleLength", doubleValue("length"))
            carInfo.trySet("setVehicleSize", intValue("size"))
            carInfo.trySet("setVehicleAxis", intValue("axisNums"))
        }

        /**
         * 反射调用 setter，兼容不同版本高德 SDK 的方法签名差异。
         * 调用失败时仅打 Log，调用方无法感知配置是否生效。
         */
        private fun Any.trySet(methodName: String, value: Any?) {
            if (value == null) return
            runCatching {
                val method = javaClass.methods.firstOrNull {
                    it.name == methodName && it.parameterCount == 1
                }
                method?.invoke(this, value)
            }.onFailure {
                Log.i(TAG, "${javaClass.simpleName}.$methodName is unavailable")
            }
        }

        /** 同 [trySet]，用于 [AmapNaviParams] 等无固定 Kotlin API 的配置方法。 */
        private fun Any.tryCall(methodName: String, value: Any?) {
            if (value == null) return
            runCatching {
                val method = javaClass.methods.firstOrNull {
                    it.name == methodName && it.parameterCount == 1
                }
                method?.invoke(this, value)
            }.onFailure {
                Log.i(TAG, "${javaClass.simpleName}.$methodName is unavailable")
            }
        }

        /**
         * 停止导航组件并释放引擎。
         *
         * 若 [naviComponentActive] 为 true，优先 `exitRouteActivity` 关闭 UI；
         * 引擎销毁依赖 [cleanupNaviSession] 或 SDK 在 `onExitPage` 后的自销毁。
         * 与 [NaviInfoCallbackImpl.onExitPage] 分工：后者处理用户主动退出，本方法处理 Dart 侧主动调用。
         */
        private fun stopNavigation() {
            try {
                stopCruiseModeInternal()
                if (naviComponentActive) {
                    val didRequestExit = requestExitRouteActivity("stopNavigation")
                    clearNaviComponentSessionState("stopNavigation")
                    if (!didRequestExit) {
                        cleanupNaviSession(
                            exitRouteActivity = false,
                            destroyNavi = true,
                            reason = "stopNavigation fallback"
                        )
                    }
                } else {
                    cleanupNaviSession(
                        exitRouteActivity = false,
                        destroyNavi = true,
                        reason = "stopNavigation fallback"
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "stopNavigation error", e)
            }
        }

        /**
         * 重清理：可选关闭组件 Activity，可选 stopNavi + destroy 引擎。
         *
         * @param exitRouteActivity 是否调用 `exitRouteActivity`
         * @param destroyNavi 是否 detach listener 并 `AMapNavi.destroy()`
         * @param reason 日志追踪用
         *
         * [cleaningNaviSession] 防止并发/重入调用。
         */
        private fun cleanupNaviSession(
            exitRouteActivity: Boolean,
            destroyNavi: Boolean,
            reason: String
        ) {
            if (cleaningNaviSession) {
                Log.i(TAG, "cleanupNaviSession skipped: already cleaning, reason=$reason")
                return
            }
            cleaningNaviSession = true
            Log.i(
                TAG,
                "cleanupNaviSession: reason=$reason, " +
                        "exitRouteActivity=$exitRouteActivity, destroyNavi=$destroyNavi"
            )

            try {
                if (exitRouteActivity && naviComponentActive) {
                    requestExitRouteActivity(reason)
                }
                if (destroyNavi) {
                    detachNaviListener()
                    try {
                        aMapNavi?.stopNavi()
                    } catch (e: Exception) {
                        Log.e(TAG, "cleanupNaviSession stopNavi error", e)
                    }
                    try {
                        AMapNavi.destroy()
                    } catch (e: Exception) {
                        Log.e(TAG, "cleanupNaviSession destroy error", e)
                    }
                }
            } finally {
                if (destroyNavi || exitRouteActivity) {
                    clearNaviComponentSessionState(reason)
                }
                cleaningNaviSession = false
            }
        }

        /** 请求关闭高德路线/导航组件 Activity。 */
        private fun requestExitRouteActivity(reason: String): Boolean {
            return try {
                Log.i(TAG, "requestExitRouteActivity: reason=$reason")
                AmapNaviPage.getInstance().exitRouteActivity()
                true
            } catch (e: Exception) {
                Log.e(TAG, "requestExitRouteActivity error: reason=$reason", e)
                false
            }
        }

        /**
         * 轻清理：重置引用与标志，不 destroy 引擎。
         *
         * 若 [cruiseActive] 为 true，保留 [aimlessListener] 相关状态，避免打断正在进行的巡航。
         */
        private fun clearNaviComponentSessionState(reason: String) {
            Log.i(TAG, "clearNaviComponentSessionState: reason=$reason")
            aMapNavi = null
            naviComponentActive = false
            naviListenerAttached = false
            if (!cruiseActive) {
                aimlessListener = null
                aimlessListenerAttached = false
                cruiseAttachedNaviListener = false
            }
        }

        /**
         * 用户从导航组件页退出（[NaviInfoCallbackImpl.onExitPage]）时的收尾。
         * 仅清状态，引擎销毁由 `setNeedDestroyDriveManagerInstanceWhenNaviExit(true)` 触发。
         */
        private fun releaseNaviAfterComponentExit(reason: String) {
            Log.i(TAG, "releaseNaviAfterComponentExit: reason=$reason")
            clearNaviComponentSessionState(reason)
        }

        /**
         * 启动智能巡航（无起终点、不算路）。
         *
         * Android 仅使用 `mode` 与 `useInnerVoice`；Dart 传入的
         * `allowsBackgroundLocationUpdates` / `pausesLocationUpdatesAutomatically` 为 iOS 专用，此处忽略。
         *
         * 若引擎上尚未挂载 [AMapNaviListener]，巡航会临时 attach 并在停止时通过
         * [cruiseAttachedNaviListener] 标记后 detach。
         */
        private fun startCruiseMode(context: Context, call: MethodCall) {
            val mode = when (call.argument<Int>("mode") ?: AimLessMode.CAMERA_AND_SPECIALROAD_DETECTED) {
                AimLessMode.CAMERA_DETECTED -> AimLessMode.CAMERA_DETECTED
                AimLessMode.SPECIALROAD_DETECTED -> AimLessMode.SPECIALROAD_DETECTED
                else -> AimLessMode.CAMERA_AND_SPECIALROAD_DETECTED
            }
            val useInnerVoice = call.argument<Boolean>("useInnerVoice") ?: true
            NaviSetting.updatePrivacyShow(context, true, true)
            NaviSetting.updatePrivacyAgree(context, true)

            stopCruiseModeInternal()

            aimlessListener = AimlessModeListenerImpl().also { l ->
                l.eventSink = naviListener?.eventSink
            }

            val ctx = activityRef ?: context
            aMapNavi = AMapNavi.getInstance(ctx)
            aMapNavi?.setUseInnerVoice(useInnerVoice)
            if (!naviListenerAttached) {
                attachNaviListener()
                cruiseAttachedNaviListener = true
            } else {
                cruiseAttachedNaviListener = false
            }
            aimlessListener?.let { listener ->
                if (!aimlessListenerAttached) {
                    aMapNavi?.addAimlessModeListener(listener)
                    aimlessListenerAttached = true
                }
                aMapNavi?.startAimlessMode(mode)
                cruiseActive = true
                Log.i(TAG, "startCruiseMode: mode=$mode, useInnerVoice=$useInnerVoice")
            }
        }

        /** 停止智能巡航，按需移除 aimless 监听器及巡航期间临时附加的 navi 监听器。 */
        private fun stopCruiseModeInternal() {
            if (!cruiseActive && aimlessListener == null) return
            try {
                if (cruiseActive) {
                    aMapNavi?.stopAimlessMode()
                }
                aimlessListener?.let { listener ->
                    if (aimlessListenerAttached) {
                        aMapNavi?.removeAimlessModeListener(listener)
                    }
                }
                if (cruiseAttachedNaviListener) {
                    detachNaviListener()
                }
            } catch (e: Exception) {
                Log.e(TAG, "stopCruiseModeInternal error", e)
            }
            aimlessListener = null
            cruiseActive = false
            aimlessListenerAttached = false
            cruiseAttachedNaviListener = false
            Log.i(TAG, "stopCruiseModeInternal: done")
        }

        /**
         * 将 [AMapNaviListenerImpl] 注册到引擎。
         * 先 remove 再 add，避免重复注册或 stale listener 残留。
         */
        private fun attachNaviListener() {
            val navi = aMapNavi
            if (navi == null) {
                naviListenerAttached = false
                Log.w(TAG, "attachNaviListener skipped: AMapNavi is null")
                return
            }
            naviListener?.let { listener ->
                try {
                    navi.removeAMapNaviListener(listener)
                } catch (e: Exception) {
                    Log.e(TAG, "attachNaviListener remove stale listener error", e)
                }
                navi.addAMapNaviListener(listener)
                naviListenerAttached = true
                Log.i(TAG, "attachNaviListener: attached")
            }
        }

        /** 从引擎移除 [AMapNaviListenerImpl]。 */
        private fun detachNaviListener() {
            if (!naviListenerAttached) {
                return
            }
            try {
                naviListener?.let { listener ->
                    aMapNavi?.removeAMapNaviListener(listener)
                }
            } catch (e: Exception) {
                Log.e(TAG, "detachNaviListener error", e)
            } finally {
                naviListenerAttached = false
            }
        }
    }

    /**
     * 高德导航**组件 UI** 回调（[INaviInfoCallback]）。
     *
     * 与 [AMapNaviListenerImpl]（引擎级 [AMapNaviListener]）分工：
     * - **引擎监听器**：算路、导航信息、转向图标等 → EventChannel 完整事件流
     * - **本类**：组件页面级事件；仅 `navigationText`、`exitPage` 转发到 Flutter，
     *   其余回调（算路成功/失败、到达等）故意只打 Log，避免与引擎监听器重复上报
     */
    private class NaviInfoCallbackImpl : INaviInfoCallback {
        override fun onInitNaviFailure() {
            // 引擎监听器 onInitNaviFailure 已上报 Flutter，此处仅 Log
            Log.i(TAG, "INaviInfoCallback: onInitNaviFailure")
        }

        override fun onGetNavigationText(text: String?) {
            Log.d(TAG, "INaviInfoCallback: onGetNavigationText: $text")
            text?.let {
                naviListener?.eventSink?.success(
                    mapOf(
                        "type" to "navigationText",
                        "text" to it
                    )
                )
            }
        }

        override fun onLocationChange(location: AMapNaviLocation?) {
            // 位置更新由引擎监听器处理
        }

        override fun onArriveDestination(isSuccess: Boolean) {
            Log.i(TAG, "INaviInfoCallback: onArriveDestination: $isSuccess")
        }

        override fun onStartNavi(type: Int) {
            // 引擎监听器 onStartNavi 已上报 Flutter
            Log.i(TAG, "INaviInfoCallback: onStartNavi: $type")
        }

        override fun onCalculateRouteSuccess(routeIds: IntArray?) {
            Log.i(TAG, "INaviInfoCallback: onCalculateRouteSuccess")
        }

        override fun onCalculateRouteFailure(errorCode: Int) {
            Log.i(TAG, "INaviInfoCallback: onCalculateRouteFailure: $errorCode")
        }

        override fun onStopSpeaking() {
            Log.d(TAG, "INaviInfoCallback: onStopSpeaking")
        }

        override fun onReCalculateRoute(type: Int) {
            Log.i(TAG, "INaviInfoCallback: onReCalculateRoute: $type")
        }

        override fun onExitPage(type: Int) {
            Log.i(TAG, "INaviInfoCallback: onExitPage: $type")
            naviListener?.eventSink?.success(
                mapOf(
                    "type" to "exitPage",
                    "exitCode" to type
                )
            )
            releaseNaviAfterComponentExit("onExitPage")
        }

        override fun onStrategyChanged(strategy: Int) {
            Log.d(TAG, "INaviInfoCallback: onStrategyChanged: $strategy")
        }

        override fun onArrivedWayPoint(wayPointIndex: Int) {
            Log.i(TAG, "INaviInfoCallback: onArrivedWayPoint: $wayPointIndex")
        }

        override fun onMapTypeChanged(mapType: Int) {
            Log.d(TAG, "INaviInfoCallback: onMapTypeChanged: $mapType")
        }

        override fun onNaviDirectionChanged(direction: Int) {
            Log.d(TAG, "INaviInfoCallback: onNaviDirectionChanged: $direction")
        }

        override fun onDayAndNightModeChanged(mode: Int) {
            Log.d(TAG, "INaviInfoCallback: onDayAndNightModeChanged: $mode")
        }

        override fun onBroadcastModeChanged(mode: Int) {
            Log.d(TAG, "INaviInfoCallback: onBroadcastModeChanged: $mode")
        }

        override fun onScaleAutoChanged(isAutoScale: Boolean) {
            Log.d(TAG, "INaviInfoCallback: onScaleAutoChanged: $isAutoScale")
        }

        override fun getCustomMiddleView(): android.view.View? = null

        override fun getCustomNaviView(): android.view.View? = null

        override fun getCustomNaviBottomView(): android.view.View? = null
    }
}
