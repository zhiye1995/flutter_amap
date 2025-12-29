package com.morbit.amap_flutter

import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.model.*
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.util.zip.Deflater

/**
 * 高德导航事件监听器实现
 * 实现 AMapNaviListener 接口，将导航事件转发到 Flutter 层
 */
class AMapNaviListenerImpl : AMapNaviListener {
    companion object {
        private const val TAG = "AMapNaviListenerImpl"
    }

    /** Flutter 事件通道 */
    var eventSink: EventChannel.EventSink? = null
    
    /** 上一次的图标数据，用于去重 */
    private var lastIconData: String = ""

    /**
     * 导航初始化失败回调
     * 当导航引擎初始化失败时触发
     */
    override fun onInitNaviFailure() {
        Log.i(TAG, "onInitNaviFailure: 导航初始化失败")
        sendEvent(mapOf(
            "type" to "initFailure",
            "message" to "导航初始化失败"
        ))
    }

    /**
     * 导航初始化成功回调
     * 当导航引擎初始化成功时触发，此时可以进行路径规划等操作
     */
    override fun onInitNaviSuccess() {
        Log.i(TAG, "onInitNaviSuccess: 导航初始化成功")
        sendEvent(mapOf("type" to "initSuccess"))
    }

    /**
     * 开始导航回调
     * @param type 导航类型：1-GPS导航，2-模拟导航
     */
    override fun onStartNavi(type: Int) {
        val naviTypeName = when (type) {
            1 -> "GPS导航"
            2 -> "模拟导航"
            else -> "未知类型"
        }
        Log.i(TAG, "onStartNavi: type=$type ($naviTypeName)")
        sendEvent(mapOf(
            "type" to "startNavi",
            "naviType" to type
        ))
    }

    /**
     * 路况信息更新回调
     * 当前方路况信息发生变化时触发
     */
    override fun onTrafficStatusUpdate() {
        Log.d(TAG, "onTrafficStatusUpdate: 路况信息更新")
        sendEvent(mapOf("type" to "trafficStatusUpdate"))
    }

    /**
     * 位置变化回调
     * 导航过程中持续回调当前位置信息
     * @param location 当前位置信息，包含经纬度、方向、速度、精度等
     */
    override fun onLocationChange(location: AMapNaviLocation?) {
        location?.let {
            sendEvent(mapOf(
                "type" to "locationChange",
                "latitude" to it.coord.latitude,
                "longitude" to it.coord.longitude,
                "bearing" to it.bearing.toDouble(),
                "speed" to it.speed.toDouble(),
                "accuracy" to it.accuracy.toDouble()
            ))
        }
    }

    /**
     * 获取导航播报文本回调
     * @param type 播报类型
     * @param text 播报文本内容
     */
    override fun onGetNavigationText(type: Int, text: String?) {
        Log.i(TAG, "onGetNavigationText: type=$type, text=$text")
        text?.let {
            sendEvent(mapOf(
                "type" to "navigationText",
                "textType" to type,
                "text" to it
            ))
        }
    }

    /**
     * 获取导航播报文本回调（已弃用）
     * @param text 播报文本
     * @deprecated 请使用 onGetNavigationText(type: Int, text: String?) 方法
     */
    @Deprecated("使用带 type 参数的方法")
    override fun onGetNavigationText(text: String?) {
        // 已弃用，不做处理
    }

    /**
     * 模拟导航结束回调
     * 当模拟导航完成时触发
     */
    override fun onEndEmulatorNavi() {
        Log.i(TAG, "onEndEmulatorNavi: 模拟导航结束")
        sendEvent(mapOf("type" to "endEmulatorNavi"))
    }

    /**
     * 到达目的地回调
     * 当导航到达最终目的地时触发
     */
    override fun onArriveDestination() {
        Log.i(TAG, "onArriveDestination: 到达目的地")
        sendEvent(mapOf("type" to "arriveDestination"))
    }

    /**
     * 路径规划失败回调（已弃用）
     * @param errorCode 错误码
     * @deprecated 请使用 onCalculateRouteFailure(result: AMapCalcRouteResult?) 方法
     */
    @Deprecated("使用 AMapCalcRouteResult 参数的方法")
    override fun onCalculateRouteFailure(errorCode: Int) {
        // 已弃用，不做处理
    }

    /**
     * 偏航重新规划路径回调
     * 当用户偏离导航路线时，自动重新规划路线后触发
     */
    override fun onReCalculateRouteForYaw() {
        Log.i(TAG, "onReCalculateRouteForYaw: 偏航重新规划路径")
        sendEvent(mapOf("type" to "reCalculateRouteForYaw"))
    }

    /**
     * 拥堵重新规划路径回调
     * 当前方道路拥堵，系统自动重新规划路线后触发
     */
    override fun onReCalculateRouteForTrafficJam() {
        Log.i(TAG, "onReCalculateRouteForTrafficJam: 拥堵重新规划路径")
        sendEvent(mapOf("type" to "reCalculateRouteForTrafficJam"))
    }

    /**
     * 到达途经点回调
     * @param wayPointIndex 途经点索引，从0开始
     */
    override fun onArrivedWayPoint(wayPointIndex: Int) {
        Log.i(TAG, "onArrivedWayPoint: 到达途经点 index=$wayPointIndex")
        sendEvent(mapOf(
            "type" to "arrivedWayPoint",
            "wayPointIndex" to wayPointIndex
        ))
    }

    /**
     * GPS开关状态回调
     * @param enabled GPS是否开启
     */
    override fun onGpsOpenStatus(enabled: Boolean) {
        Log.d(TAG, "onGpsOpenStatus: GPS状态 enabled=$enabled")
        sendEvent(mapOf(
            "type" to "gpsOpenStatus",
            "enabled" to enabled
        ))
    }

    /**
     * 导航信息更新回调
     * 导航过程中持续回调，包含转向图标、剩余距离、下一道路名称等信息
     * @param naviInfo 导航信息对象
     */
    override fun onNaviInfoUpdate(naviInfo: NaviInfo?) {
        naviInfo?.let { info ->
            val data = mutableMapOf<String, Any?>(
                "type" to "navInfo",
                "iconType" to info.iconType,
                "curStepRetainDistance" to info.curStepRetainDistance,
                "nextRoadName" to (info.nextRoadName ?: ""),
                "pathRetainDistance" to info.pathRetainDistance,
                "pathRetainTime" to info.pathRetainTime,
                "currentRoadName" to (info.currentRoadName ?: ""),
                "exitDirectionInfo" to (info.exitDirectionInfo ?: ""),
                "curStep" to info.curStep,
                "hasIcon" to (info.iconBitmap != null)
            )

            // 处理转向图标
            info.iconBitmap?.let { bitmap ->
                if (info.iconType > 0) {
                    try {
                        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 100, 100, true)
                        val buffer = ByteBuffer.allocate(scaledBitmap.byteCount)
                        scaledBitmap.copyPixelsToBuffer(buffer)
                        
                        val compressedBytes = compress(buffer.array())
                        val iconData = Base64.encodeToString(compressedBytes, Base64.DEFAULT)
                        
                        // 只在图标变化时发送，避免重复传输
                        if (iconData != lastIconData) {
                            data["iconSize"] = compressedBytes.size
                            data["iconData"] = iconData
                            lastIconData = iconData
                        }
                        
                        buffer.clear()
                        scaledBitmap.recycle()
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing icon bitmap", e)
                    }
                }
            }

            Log.d(TAG, "onNaviInfoUpdate: iconType=${info.iconType}, " +
                    "curStepRetainDistance=${info.curStepRetainDistance}, " +
                    "nextRoadName=${info.nextRoadName}, " +
                    "pathRetainDistance=${info.pathRetainDistance}, " +
                    "pathRetainTime=${info.pathRetainTime}")

            sendEvent(data)
        }
    }

    /**
     * 电子眼信息更新回调
     * @param cameraInfos 电子眼信息数组
     */
    override fun updateCameraInfo(cameraInfos: Array<out AMapNaviCameraInfo>?) {
        cameraInfos?.let { cameras ->
            if (cameras.isNotEmpty()) {
                val cameraList = cameras.map { camera ->
                    mapOf(
                        "cameraType" to camera.cameraType,
                        "cameraDistance" to camera.cameraDistance,
                        "cameraSpeed" to camera.cameraSpeed
                    )
                }
                Log.d(TAG, "updateCameraInfo: 检测到${cameras.size}个电子眼")
                sendEvent(mapOf(
                    "type" to "cameraInfo",
                    "cameras" to cameraList
                ))
            }
        }
    }

    /**
     * 区间测速信息更新回调
     * @param cameraInfo1 区间测速起点信息
     * @param cameraInfo2 区间测速终点信息
     * @param interval 区间距离
     */
    override fun updateIntervalCameraInfo(
        cameraInfo1: AMapNaviCameraInfo?,
        cameraInfo2: AMapNaviCameraInfo?,
        interval: Int
    ) {
        if (cameraInfo1 != null && cameraInfo2 != null) {
            Log.d(TAG, "updateIntervalCameraInfo: 区间测速 interval=$interval")
            sendEvent(mapOf(
                "type" to "intervalCameraInfo",
                "startCamera" to mapOf(
                    "cameraType" to cameraInfo1.cameraType,
                    "cameraDistance" to cameraInfo1.cameraDistance,
                    "cameraSpeed" to cameraInfo1.cameraSpeed
                ),
                "endCamera" to mapOf(
                    "cameraType" to cameraInfo2.cameraType,
                    "cameraDistance" to cameraInfo2.cameraDistance,
                    "cameraSpeed" to cameraInfo2.cameraSpeed
                ),
                "interval" to interval
            ))
        }
    }

    /**
     * 服务区信息更新回调
     * @param serviceAreaInfos 服务区信息数组
     */
    override fun onServiceAreaUpdate(serviceAreaInfos: Array<out AMapServiceAreaInfo>?) {
        serviceAreaInfos?.let { areas ->
            if (areas.isNotEmpty()) {
                val areaList = areas.map { area ->
                    mapOf(
                        "serviceName" to (area.serviceName ?: ""),
                        "serviceDistance" to area.serviceDistance
                    )
                }
                Log.d(TAG, "onServiceAreaUpdate: 检测到${areas.size}个服务区")
                sendEvent(mapOf(
                    "type" to "serviceAreaUpdate",
                    "serviceAreas" to areaList
                ))
            }
        }
    }

    /**
     * 显示路口放大图回调
     * @param cross 路口放大图信息
     */
    override fun showCross(cross: AMapNaviCross?) {
        cross?.let {
            Log.d(TAG, "showCross: 显示路口放大图")
            // 路口放大图包含 Bitmap，需要处理后发送
            try {
                it.bitmap?.let { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
                    val crossData = Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT)
                    sendEvent(mapOf(
                        "type" to "showCross",
                        "crossData" to crossData
                    ))
                    stream.close()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing cross bitmap", e)
            }
        }
    }

    /**
     * 隐藏路口放大图回调
     */
    override fun hideCross() {
        Log.d(TAG, "hideCross: 隐藏路口放大图")
        sendEvent(mapOf("type" to "hideCross"))
    }

    /**
     * 显示3D路口放大图回调
     * @param modelCross 3D路口放大图信息
     */
    override fun showModeCross(modelCross: AMapModelCross?) {
        modelCross?.let {
            Log.d(TAG, "showModeCross: 显示3D路口放大图")
            // 3D路口放大图包含 Bitmap，需要处理后发送
            try {
                it.bitmap?.let { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
                    val crossData = Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT)
                    sendEvent(mapOf(
                        "type" to "showModeCross",
                        "crossData" to crossData
                    ))
                    stream.close()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing model cross bitmap", e)
            }
        }
    }

    /**
     * 隐藏3D路口放大图回调
     */
    override fun hideModeCross() {
        Log.d(TAG, "hideModeCross: 隐藏3D路口放大图")
        sendEvent(mapOf("type" to "hideModeCross"))
    }

    /**
     * 显示车道信息回调（已弃用）
     * @param laneInfos 车道信息数组
     * @param bytes1 背景数据
     * @param bytes2 推荐数据
     * @deprecated 请使用 showLaneInfo(laneInfo: AMapLaneInfo?) 方法
     */
    @Deprecated("使用单个 AMapLaneInfo 参数的方法")
    override fun showLaneInfo(laneInfos: Array<out AMapLaneInfo>?, bytes1: ByteArray?, bytes2: ByteArray?) {
        // 已弃用，不做处理
    }

    /**
     * 显示车道信息回调
     * @param laneInfo 车道信息，包含车道背景和推荐车道
     */
    override fun showLaneInfo(laneInfo: AMapLaneInfo?) {
        laneInfo?.let { info ->
            Log.d(TAG, "showLaneInfo: 显示车道信息")
            try {
                val data = mutableMapOf<String, Any?>(
                    "type" to "showLaneInfo"
                )
                
                // 处理车道背景图
                info.laneBackgroundBitmap?.let { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
                    data["laneBackground"] = Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT)
                    stream.close()
                }
                
                // 处理推荐车道图
                info.laneRecommendBitmap?.let { bitmap ->
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
                    data["laneRecommend"] = Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT)
                    stream.close()
                }
                
                sendEvent(data)
            } catch (e: Exception) {
                Log.e(TAG, "Error processing lane info", e)
            }
        }
    }

    /**
     * 隐藏车道信息回调
     */
    override fun hideLaneInfo() {
        Log.d(TAG, "hideLaneInfo: 隐藏车道信息")
        sendEvent(mapOf("type" to "hideLaneInfo"))
    }

    /**
     * 路径规划成功回调（已弃用）
     * @param routeIds 路径ID数组
     * @deprecated 请使用 onCalculateRouteSuccess(result: AMapCalcRouteResult?) 方法
     */
    @Deprecated("使用 AMapCalcRouteResult 参数的方法")
    override fun onCalculateRouteSuccess(routeIds: IntArray?) {
        // 已弃用，不做处理
    }

    /**
     * 平行路通知回调（已弃用）
     * @param parallelRoadType 平行路类型
     * @deprecated 该方法已弃用
     */
    @Deprecated("该方法已弃用")
    override fun notifyParallelRoad(parallelRoadType: Int) {
        // 已弃用，不做处理
    }

    /**
     * 交通设施信息更新回调（已弃用）
     * @param facilities 交通设施信息数组
     * @deprecated 该方法已弃用
     */
    @Deprecated("该方法已弃用")
    override fun OnUpdateTrafficFacility(facilities: Array<out AMapNaviTrafficFacilityInfo>?) {
        // 已弃用，不做处理
    }

    /**
     * 交通设施信息更新回调（已弃用）
     * @param facility 交通设施信息
     * @deprecated 该方法已弃用
     */
    @Deprecated("该方法已弃用")
    override fun OnUpdateTrafficFacility(facility: AMapNaviTrafficFacilityInfo?) {
        // 已弃用，不做处理
    }

    /**
     * 巡航模式统计信息更新回调（已弃用）
     * @param stat 巡航模式统计信息
     * @deprecated 该方法已弃用
     */
    @Deprecated("该方法已弃用")
    override fun updateAimlessModeStatistics(stat: AimLessModeStat?) {
        // 已弃用，不做处理
    }

    /**
     * 巡航模式拥堵信息更新回调（已弃用）
     * @param info 拥堵信息
     * @deprecated 该方法已弃用
     */
    @Deprecated("该方法已弃用")
    override fun updateAimlessModeCongestionInfo(info: AimLessModeCongestionInfo?) {
        // 已弃用，不做处理
    }

    /**
     * 播放导航提示音回调
     * @param type 提示音类型
     */
    override fun onPlayRing(type: Int) {
        Log.d(TAG, "onPlayRing: 播放提示音 type=$type")
        sendEvent(mapOf(
            "type" to "playRing",
            "ringType" to type
        ))
    }

    /**
     * 路径规划成功回调
     * @param result 路径规划结果，包含路径ID列表和错误信息
     */
    override fun onCalculateRouteSuccess(result: AMapCalcRouteResult?) {
        Log.i(TAG, "onCalculateRouteSuccess: 路径规划成功")
        result?.let { calcResult ->
            sendEvent(mapOf(
                "type" to "calculateRouteSuccess",
                "routeIds" to (calcResult.routeid?.toList() ?: emptyList<Int>()),
                "errorCode" to calcResult.errorCode,
                "errorDescription" to (calcResult.errorDescription ?: "")
            ))
        }
    }

    /**
     * 路径规划失败回调
     * @param result 路径规划结果，包含错误码和错误描述
     */
    override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) {
        Log.i(TAG, "onCalculateRouteFailure: 路径规划失败 errorCode=${result?.errorCode}")
        sendEvent(mapOf(
            "type" to "calculateRouteFailure",
            "errorCode" to (result?.errorCode ?: -1),
            "errorDescription" to (result?.errorDescription ?: "未知错误")
        ))
    }

    /**
     * 导航路线通知回调
     * 包含限行、收费等路线相关的通知信息
     * @param notifyData 通知数据
     */
    override fun onNaviRouteNotify(notifyData: AMapNaviRouteNotifyData?) {
        notifyData?.let { data ->
            Log.d(TAG, "onNaviRouteNotify: 导航路线通知 type=${data.notifyType}")
            sendEvent(mapOf(
                "type" to "naviRouteNotify",
                "notifyType" to data.notifyType,
                "notifyContent" to (data.notifyContent ?: "")
            ))
        }
    }

    /**
     * GPS信号弱回调
     * @param isWeak true表示GPS信号弱，false表示GPS信号恢复正常
     */
    override fun onGpsSignalWeak(isWeak: Boolean) {
        Log.i(TAG, "onGpsSignalWeak: GPS信号${if (isWeak) "弱" else "正常"}")
        sendEvent(mapOf(
            "type" to "gpsSignalWeak",
            "isWeak" to isWeak
        ))
    }

    /**
     * 发送事件到 Flutter 层
     * @param data 事件数据，将通过 EventChannel 发送
     */
    private fun sendEvent(data: Map<String, Any?>) {
        eventSink?.success(data)
    }

    /**
     * 使用 Deflater 压缩数据
     * @param data 原始字节数组
     * @return 压缩后的字节数组
     */
    private fun compress(data: ByteArray): ByteArray {
        val deflater = Deflater()
        deflater.setInput(data)
        deflater.finish()
        
        val outputStream = ByteArrayOutputStream(data.size)
        val buffer = ByteArray(1024)
        
        while (!deflater.finished()) {
            val count = deflater.deflate(buffer)
            outputStream.write(buffer, 0, count)
        }
        
        deflater.end()
        return outputStream.toByteArray()
    }
}
