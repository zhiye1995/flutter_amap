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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


/**
 * 高德导航 API 处理类
 */
class AMapNaviApi {
    companion object {
        private const val TAG = "AMapNaviApi"
        private const val NAVI_METHOD_CHANNEL = "plugins.flutter.dev/amap_navi"
        private const val NAVI_EVENT_CHANNEL = "plugins.flutter.dev/amap_navi_events"

        private var methodChannel: MethodChannel? = null
        private var eventChannel: EventChannel? = null
        private var naviListener: AMapNaviListenerImpl? = null
        private var aimlessListener: AimlessModeListenerImpl? = null
        private var aMapNavi: AMapNavi? = null
        private var activityRef: Activity? = null
        private var naviListenerAttached: Boolean = false
        private var aimlessListenerAttached: Boolean = false
        private var cruiseAttachedNaviListener: Boolean = false

        /** 当前是否处于智能巡航（用于 stopNavigation 前先 stopAimlessMode） */
        private var cruiseActive: Boolean = false

        fun setup(binding: FlutterPluginBinding, activity: Activity?) {
            activityRef = activity

            // 设置 MethodChannel
            methodChannel = MethodChannel(binding.binaryMessenger, NAVI_METHOD_CHANNEL)
            methodChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                handleMethodCall(binding.applicationContext, call, result)
            }

            // 设置 EventChannel
            naviListener = AMapNaviListenerImpl()
            eventChannel = EventChannel(binding.binaryMessenger, NAVI_EVENT_CHANNEL)
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

        fun updateActivity(activity: Activity?) {
            activityRef = activity
        }

        fun dispose() {
            stopCruiseModeInternal()
            stopNavigation()
            methodChannel?.setMethodCallHandler(null)
            methodChannel = null
            eventChannel?.setStreamHandler(null)
            eventChannel = null
            naviListener = null
            aimlessListener = null
            activityRef = null
            naviListenerAttached = false
            aimlessListenerAttached = false
            cruiseAttachedNaviListener = false
        }

        private fun handleMethodCall(context: Context, call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "startNavigation" -> {
                    try {
                        startNavigation(context, call)
                        result.success(null)
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

        private fun startNavigation(context: Context, call: MethodCall) {
            // 隐私合规检查
            NaviSetting.updatePrivacyShow(context, true, true)
            NaviSetting.updatePrivacyAgree(context, true)

            // 获取参数
            val carNumber = call.argument<String>("carNumber")
            val motorcycleCC = call.argument<Int>("motorcycleCC")
            val naviTypeIndex = call.argument<Int>("naviType") ?: 0
            val pageTypeIndex = call.argument<Int>("pageType") ?: 0

            val startLat = call.argument<Double>("startLat")
            val startLng = call.argument<Double>("startLng")
            val startName = call.argument<String>("startName")

            val endLat = call.argument<Double>("endLat")
            val endLng = call.argument<Double>("endLng")
            val endName = call.argument<String>("endName")

            @Suppress("UNCHECKED_CAST")
            val wayPointsList = call.argument<List<Map<String, Any?>>>("wayPoints")

            // 初始化 AMapNavi
            aMapNavi = AMapNavi.getInstance(context)
            aMapNavi?.setUseInnerVoice(true)

            // 设置车辆信息
            val carInfo = AMapCarInfo()
            // AMapCarInfo 参数详解：
            //    mCarNumber:           车牌号码，用于计算限行路段，格式如"京A12345"
            //    isRestriction:        是否避开限行路段，true-避开，false-不避开，默认true
            //    mCarType:             车辆类型，0-小客车，1-货车，2-客车，用于计算货车限行等
            //    mVehicleHeight:       车辆高度（单位：米），用于避开限高路段，如桥梁涵洞
            //    mVehicleWeight:       车辆总重（单位：吨），用于避开限重路段和桥梁
            //    mVehicleLoad:         车辆核定载重（单位：吨），货车规划时的核定装载质量
            //    mVehicleLoadSwitch:   载重开关，是否启用载重限制计算，true-启用，false-不启用
            //    mVehicleWidth:        车辆宽度（单位：米），用于避开限宽路段
            //    mVehicleLength:       车辆长度（单位：米），用于判断是否能通过狭窄路段
            //    mVehicleSize:         车辆大小类型，0-微型车，1-轻型车，2-中型车，3-重型车
            //    mVehicleAxis:         车辆轴数，用于计算货车通行费和限行规则
            //    mMotorcycleCC:        摩托车排量（单位：CC），如125、250，用于摩托车限行判断
            carNumber?.let { carInfo.carNumber = it }
            motorcycleCC?.let { carInfo.motorcycleCC = it }
            aMapNavi?.setCarInfo(carInfo)

            // 添加导航监听器
            attachNaviListener()

            // 构建起点
            val start: Poi? = if (startLat != null && startLng != null) {
                Poi(startName ?: "起点", LatLng(startLat, startLng), "")
            } else {
                null
            }

            // 构建终点
            val end: Poi? = if (endLat != null && endLng != null) {
                Poi(endName ?: "终点", LatLng(endLat, endLng), "")
            } else {
                null
            }

            // 构建途经点
            val wayPoints: MutableList<Poi> = mutableListOf()
            wayPointsList?.forEach { wayPoint ->
                val lat = (wayPoint["lat"] as? Number)?.toDouble()
                val lng = (wayPoint["lng"] as? Number)?.toDouble()
                val name = wayPoint["name"] as? String ?: "途经点"
                if (lat != null && lng != null) {
                    wayPoints.add(Poi(name, LatLng(lat, lng), ""))
                }
            }

            // 导航类型映射
            // public enum AmapNaviType { DRIVER, WALK, RIDE, MOTORCYCLE}
            val naviType = when (naviTypeIndex) {
                0 -> AmapNaviType.DRIVER  // 驾车
                1 -> AmapNaviType.WALK    // 步行
                2 -> AmapNaviType.RIDE    // 骑行
                else -> AmapNaviType.DRIVER
            }

            // 页面类型映射
            val pageType = when (pageTypeIndex) {
                0 -> AmapPageType.ROUTE  // 路线规划页
                1 -> AmapPageType.NAVI   // 导航页
                else -> AmapPageType.ROUTE
            }

            Log.i(
                TAG, "startNavigation: naviType=$naviType, pageType=$pageType, " +
                        "start=$start, end=$end, wayPoints=${wayPoints.size}"
            )

            // 构建导航参数
            val params = AmapNaviParams(
                start,
                wayPoints,
                end,
                naviType,
                pageType
            ).setUseInnerVoice(true)

            // 启动导航页面
            val launchContext: Context = activityRef ?: context
            AmapNaviPage.getInstance().showRouteActivity(
                launchContext,
                params,
                NaviInfoCallbackImpl(),
                AMapFlutterRouteActivity::class.java
            )
        }

        private fun stopNavigation() {
            try {
                stopCruiseModeInternal()
                detachNaviListener()
                AmapNaviPage.getInstance().exitRouteActivity()
                AMapNavi.destroy()
                aMapNavi = null
                aimlessListenerAttached = false
            } catch (e: Exception) {
                Log.e(TAG, "stopNavigation error", e)
            }
        }

        private fun startCruiseMode(context: Context, call: MethodCall) {
            val mode = when (call.argument<Int>("mode") ?: AimLessMode.CAMERA_AND_SPECIALROAD_DETECTED) {
                AimLessMode.CAMERA_DETECTED -> AimLessMode.CAMERA_DETECTED
                AimLessMode.SPECIALROAD_DETECTED -> AimLessMode.SPECIALROAD_DETECTED
                else -> AimLessMode.CAMERA_AND_SPECIALROAD_DETECTED
            }
            NaviSetting.updatePrivacyShow(context, true, true)
            NaviSetting.updatePrivacyAgree(context, true)

            stopCruiseModeInternal()

            aimlessListener = AimlessModeListenerImpl().also { l ->
                l.eventSink = naviListener?.eventSink
            }

            val ctx = activityRef ?: context
            aMapNavi = AMapNavi.getInstance(ctx)
            aMapNavi?.setUseInnerVoice(true)
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
                Log.i(TAG, "startCruiseMode: mode=$mode")
            }
        }

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

        private fun attachNaviListener() {
            if (naviListenerAttached) return
            naviListener?.let { listener ->
                aMapNavi?.addAMapNaviListener(listener)
                naviListenerAttached = true
            }
        }

        private fun detachNaviListener() {
            if (!naviListenerAttached) return
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
     * 导航页面回调实现
     */
    private class NaviInfoCallbackImpl : INaviInfoCallback {
        override fun onInitNaviFailure() {
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
//            Log.d(TAG, "INaviInfoCallback: onLocationChange")
        }

        override fun onArriveDestination(isSuccess: Boolean) {
            Log.i(TAG, "INaviInfoCallback: onArriveDestination: $isSuccess")
        }

        override fun onStartNavi(type: Int) {
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

