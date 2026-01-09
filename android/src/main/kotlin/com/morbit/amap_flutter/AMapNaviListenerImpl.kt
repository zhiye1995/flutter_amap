package com.morbit.amap_flutter

import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import androidx.core.graphics.drawable.toIcon
import com.amap.api.navi.AMapNaviListener
import com.amap.api.navi.model.*
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream


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

    /**
     * 上一次下发给 Flutter 的转向图标类型，用于去重（减少重复传输）。
     * 说明：Flutter 侧会按 iconType 缓存上一张图标，因此这里不需要每次都下发字节。
     */
    private var lastIconType: Int = Int.MIN_VALUE

    /** 转向图标 PNG 字节缓存：同一个 iconType 只编码一次 */
    private val iconPngCache: MutableMap<Int, ByteArray> = mutableMapOf()

    /**
     * 导航初始化失败回调
     * 当导航引擎初始化失败时触发
     */
    override fun onInitNaviFailure() {
        Log.i(TAG, "onInitNaviFailure: 导航初始化失败")
        sendEvent(
            mapOf(
                "type" to "initFailure",
                "message" to "导航初始化失败"
            )
        )
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
        Log.i(TAG, "onStartNavi 开始导航: type=$type ($naviTypeName)")
        sendEvent(
            mapOf(
                "type" to "startNavi",
                "naviType" to type
            )
        )
    }

    /**
     * 导航信息更新回调
     * 导航过程中持续回调，包含转向图标、剩余距离、下一道路名称等信息
     * @param naviInfo 导航信息对象
     */
    override fun onNaviInfoUpdate(naviInfo: NaviInfo?) {
        /**
        public class NaviInfo {
        protected long pathID;
        protected int mType;
        protected String mCurRoadName;
        protected String mNextRoadName;
        protected int mIcon;
        protected int mRouteRemainDis;
        protected int mRouteRemainTime;
        protected int mSegRemainDis;
        protected int mSegRemainTime;
        protected int mCurSegIndex;
        protected int mCurLinkIndex;
        protected int mCurPointIndex;
        protected int currentSpeed;
        protected AMapNotAvoidInfo notAvoidInfo;
        private Bitmap iconBitmap;
        protected AMapExitDirectionInfo mExitDirectionInfo;
        protected int routeRemainLightCount;
        private AMapNaviToViaInfo[] toViaInfos;
         **/

        // NaviInfo 常用字段说明（基于 SDK 原始类成员变量/Getter；不同版本可能略有差异）：
        // - pathId: 当前导航路线 ID（长整型）。
        // - naviType: 导航类型（含义以 SDK 为准；可能与 onStartNavi 的 1/2 不完全一致）。
        // - currentRoadName/nextRoadName: 当前道路名/下一道路名（可能为空）。
        // - iconType: 转向图标类型（含义/枚举以 SDK 文档为准）。
        // - pathRetainDistance/pathRetainTime: 路线剩余距离（米）/剩余时间（秒）。
        // - curStepRetainDistance/curStepRetainTime: 当前 Step（导航段）剩余距离（米）/剩余时间（秒）。
        // - curStep/curLink/curPoint: 当前 Step 索引 / Link 索引 / Point 索引（用于定位导航进度）。
        // - routeRemainLightCount: 路线剩余红绿灯数量（个；部分版本可能无效或为 0）。
        // - currentSpeed: 当前速度（Deprecated 字段，单位/可用性以 SDK 为准；可能始终为 0）。
        // - exitDirectionInfo: 出口方向信息（可能是对象/字符串；需要转成 Flutter 可编码结构）。
        // - notAvoidInfo: 不可避让信息（对象；需要转成 Flutter 可编码结构）。
        // - toViaInfo: 到途经点信息数组（对象数组；需要转成 List<Map>）。
        // - iconBitmap: 转向图标 Bitmap（本插件会压缩+Base64 后仅在变化时传给 Flutter）。

        @Suppress("DEPRECATION")
        naviInfo?.let { info ->
            val currentRoadName = info.currentRoadName ?: ""
            val nextRoadName = info.nextRoadName ?: ""

            val exitDirectionInfo = exitDirectionInfoToFlutter(info.exitDirectionInfo)
            val notAvoidInfo = notAvoidInfoToFlutter(info.notAvoidInfo)
            val toViaInfos = toViaInfosToFlutter(info.toViaInfo)

            val data = mutableMapOf<String, Any?>(
                "type" to "navInfo",

                // 基础/进度字段
                "pathId" to info.pathId,
                "naviType" to info.naviType,
                "curStep" to info.curStep,
                "curLink" to info.curLink,
                "curPoint" to info.curPoint,

                // 道路/转向字段
                "currentRoadName" to currentRoadName,
                "nextRoadName" to nextRoadName,
                "iconType" to info.iconType,

                // 剩余距离/时间（单位：米/秒）
                "pathRetainDistance" to info.pathRetainDistance,
                "pathRetainTime" to info.pathRetainTime,
                "curStepRetainDistance" to info.curStepRetainDistance,
                "curStepRetainTime" to info.curStepRetainTime,

                // 其它扩展字段
                "routeRemainLightCount" to info.routeRemainLightCount,
                "currentSpeed" to info.currentSpeed,

                // 对象字段：必须先转换成 Flutter 可编码结构（Map/List/String/基础类型）
                "exitDirectionInfo" to exitDirectionInfo,
                "notAvoidInfo" to notAvoidInfo,
                "toViaInfos" to toViaInfos,

                // 调试兜底
                "raw" to info.toString(),

                // 图标是否存在（具体图标数据见 iconPng，仅在 iconType 变化时发送）
                "hasIcon" to (info.iconBitmap != null)
            )

            // 处理转向图标
            info.iconBitmap?.let { bitmap ->
                if (info.iconType > 0) {
                    try {
                        // 只在 iconType 变化时才下发图标字节，避免频繁传输/编码
                        if (info.iconType != lastIconType) {
                            val pngBytes = iconPngCache.getOrPut(info.iconType) {
                                bitmapToPngBytes(bitmap)
                            }
                            data["iconPng"] = pngBytes
                            lastIconType = info.iconType
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing icon bitmap", e)
                    }
                }
            }

            val viaCount = when (toViaInfos) {
                is List<*> -> toViaInfos.size
                null -> 0
                else -> 1
            }

            Log.d(
                TAG,
                "onNaviInfoUpdate 导航信息更新：" +
                        "路线ID=${info.pathId}，导航类型=${info.naviType}，" +
                        "当前路='$currentRoadName'，下一路='$nextRoadName'，" +
                        "转向图标=${info.iconType}，" +
                        "路线剩余=${info.pathRetainDistance}米/${info.pathRetainTime}秒，" +
                        "本段剩余=${info.curStepRetainDistance}米/${info.curStepRetainTime}秒，" +
                        "Step=${info.curStep}，" +
                        "Link=${info.curLink}，" +
                        "Point=${info.curPoint}，" +
                        "剩余红绿灯=${info.routeRemainLightCount}个，" +
                        "不可避让=${notAvoidInfo != null}，" +
                        "途经点信息=${viaCount}条，" +
                        "出口信息=${exitDirectionInfo != null}"
            )

            sendEvent(data)
        }
    }

    /**
     * 位置变化回调
     * 导航过程中持续回调当前位置信息
     * @param location 当前位置信息，包含经纬度、方向、速度、精度等
     */
    override fun onLocationChange(location: AMapNaviLocation?) {
        // AMapNaviLocation（导航定位）常见成员变量解释（不同 SDK 版本字段/Getter 可能略有差异）：
        // private float accuracy;        // 定位精度（单位：米）。数值越小，定位越准确。
        // private double altitude;       // 海拔高度（单位：米）。
        // private float bearing;         // 航向角/方向角（单位：度），通常范围 0~360。
        // private float roadBearing;     // 道路方向角（单位：度），通常为地图匹配后的道路方向。
        // private float speed;           // 速度（单位：km/h；以 SDK 实际回调为准）。
        // private long time;             // 定位时间戳（毫秒）。
        // private int matchStatus;       // 道路匹配状态（是否/如何匹配到道路；具体枚举以 SDK 为准）。
        // private NaviLatLng coord;      // 定位坐标（经纬度）。
        // private int type = -1;         // 定位数据类型（具体含义以 SDK 为准，如 GPS/网络/模拟等）。
        // private int locationType;      // 定位来源类型/定位方式（具体枚举以 SDK 为准）。
        // private int curStepIndex;      // 当前导航 Step（步骤）索引。
        // private int curLinkIndex;      // 当前道路 Link 索引。
        // private int curPointIndex;     // 当前形状点/插值点索引。

        if (location == null) return

        // 说明：这里使用反射方式读取扩展字段，避免因 SDK 版本差异导致编译失败；读不到则为 null。
        val coord = try {
            location.coord
        } catch (_: Throwable) {
            null
        }
        val latitude = try {
            coord?.latitude
        } catch (_: Throwable) {
            null
        }
        val longitude = try {
            coord?.longitude
        } catch (_: Throwable) {
            null
        }

        val accuracy = location.tryGetNumber("accuracy")?.toDouble()
        val altitude = location.tryGetNumber("altitude")?.toDouble()
        val bearing = location.tryGetNumber("bearing")?.toDouble()
        val roadBearing = location.tryGetNumber("roadBearing")?.toDouble()
        val speed = location.tryGetNumber("speed")?.toDouble()
        val time = location.tryGetNumber("time")?.toLong()
        val matchStatus = location.tryGetNumber("matchStatus")?.toInt()
        val locationDataType = location.tryGetNumber("type")?.toInt()
        val locationType = location.tryGetNumber("locationType")?.toInt()
        val curStepIndex = location.tryGetNumber("curStepIndex")?.toInt()
        val curLinkIndex = location.tryGetNumber("curLinkIndex")?.toInt()
        val curPointIndex = location.tryGetNumber("curPointIndex")?.toInt()

//          Log.i(
//              TAG,
//              "onLocationChange 位置变化：" +
//                      "经度=$longitude，纬度=$latitude，" +
//                      "航向角=$bearing，道路方向角=$roadBearing，" +
//                      "速度=$speed（米/秒），精度=$accuracy（米），海拔=$altitude（米），" +
//                      "时间戳=$time，匹配状态=$matchStatus，" +
//                      "定位数据类型=$locationDataType，定位来源类型=$locationType，" +
//                      "当前Step索引=$curStepIndex，当前Link索引=$curLinkIndex，当前Point索引=$curPointIndex"
//          )

        // 事件推送给 Flutter：尽可能携带完整定位信息，便于上层做展示/埋点/问题定位
        sendEvent(
            mapOf(
                "type" to "locationChange",
                "latitude" to latitude,
                "longitude" to longitude,
                "bearing" to bearing,
                "roadBearing" to roadBearing,
                "speed" to speed,
                "accuracy" to accuracy,
                "altitude" to altitude,
                "time" to time,
                "matchStatus" to matchStatus,
                // 注意：事件字段名 type 已被占用，这里用 locationDataType 表示 AMapNaviLocation 的 type 字段
                "locationDataType" to locationDataType,
                "locationType" to locationType,
                "curStepIndex" to curStepIndex,
                "curLinkIndex" to curLinkIndex,
                "curPointIndex" to curPointIndex,
                "raw" to location.toString()
            )
        )
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
     * GPS开关状态回调
     * @param enabled GPS是否开启
     */
    override fun onGpsOpenStatus(enabled: Boolean) {
        Log.d(TAG, "onGpsOpenStatus: GPS状态 enabled=$enabled")
        sendEvent(
            mapOf(
                "type" to "gpsOpenStatus",
                "enabled" to enabled
            )
        )
    }

    /**
     * GPS信号弱回调
     * @param isWeak true表示GPS信号弱，false表示GPS信号恢复正常
     */
    override fun onGpsSignalWeak(isWeak: Boolean) {
        Log.i(TAG, "onGpsSignalWeak: GPS信号${if (isWeak) "弱" else "正常"}")
        sendEvent(
            mapOf(
                "type" to "gpsSignalWeak",
                "isWeak" to isWeak
            )
        )
    }


    /** ======================================================================================================================================================*/


    /**
     * 路况信息更新回调
     * 当前方路况信息发生变化时触发
     */
    override fun onTrafficStatusUpdate() {
        Log.d(TAG, "onTrafficStatusUpdate: 路况信息更新")
        sendEvent(mapOf("type" to "trafficStatusUpdate"))
    }


    /**
     * 获取导航播报文本回调
     * @param type 播报类型
     * @param text 播报文本内容
     */
    override fun onGetNavigationText(type: Int, text: String?) {
        Log.i(TAG, "onGetNavigationText: type=$type, text=$text")
        text?.let {
            sendEvent(
                mapOf(
                    "type" to "navigationText",
                    "textType" to type,
                    "text" to it
                )
            )
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
        sendEvent(
            mapOf(
                "type" to "arrivedWayPoint",
                "wayPointIndex" to wayPointIndex
            )
        )
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
                sendEvent(
                    mapOf(
                        "type" to "cameraInfo",
                        "cameras" to cameraList
                    )
                )
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
            sendEvent(
                mapOf(
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
                )
            )
        }
    }

    /**
     * 服务区信息更新回调
     * @param serviceAreaInfos 服务区信息数组
     */
    override fun onServiceAreaUpdate(serviceAreaInfos: Array<out AMapServiceAreaInfo>?) {
        val areas = serviceAreaInfos?.toList().orEmpty()
        if (areas.isEmpty()) return

        // 不同 AMap SDK 版本里 AMapServiceAreaInfo 的字段/方法差异较大，这里用反射兼容
        val areaList = areas.map { area ->
            val name = area.tryGetString(
                "serviceName",
                "name",
                "poiName",
                "title"
            ) ?: ""
            val distance = area.tryGetNumber(
                "serviceDistance",
                "distance",
                "remainDistance",
                "curPointToServiceAreaDistance"
            )

            mapOf(
                "name" to name,
                "distance" to distance,
                "raw" to area.toString()
            )
        }

        Log.d(TAG, "onServiceAreaUpdate: 检测到${areas.size}个服务区")
        sendEvent(
            mapOf(
                "type" to "serviceAreaUpdate",
                "serviceAreas" to areaList
            )
        )
    }

    /**
     * 显示路口放大图回调
     * @param cross 路口放大图信息
     */
    override fun showCross(cross: AMapNaviCross?) {
        if (cross == null) return
        Log.d(TAG, "showCross: 显示路口放大图")

        // 不同 AMap SDK 版本里 AMapNaviCross 的图片数据字段/方法差异较大，这里用反射兼容
        val imageBytes = cross.tryGetByteArray(
            "bitmap",
            "crossImage",
            "crossImageData",
            "data",
            "bytes"
        )
        val imageBitmap = cross.tryGetBitmap(
            "bitmap",
            "crossBitmap",
            "image",
            "crossImage"
        )

        val payload = mutableMapOf<String, Any?>(
            "type" to "showCross",
            "raw" to cross.toString()
        )

        try {
            when {
                imageBytes != null && imageBytes.isNotEmpty() -> {
                    payload["crossData"] = Base64.encodeToString(imageBytes, Base64.NO_WRAP)
                    payload["dataFormat"] = "bytes"
                }

                imageBitmap != null -> {
                    payload["crossData"] = bitmapToBase64Png(imageBitmap)
                    payload["dataFormat"] = "bitmap"
                }
            }
        } catch (e: Throwable) {
            Log.e(TAG, "Error processing cross image", e)
        }

        sendEvent(payload)
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
        if (modelCross == null) return
        Log.d(TAG, "showModeCross: 显示3D路口放大图")

        // 不同 AMap SDK 版本里 AMapModelCross 的图片数据字段/方法差异较大，这里用反射兼容
        val imageBytes = modelCross.tryGetByteArray(
            "bitmap",
            "modelCrossImage",
            "crossImage",
            "crossImageData",
            "data",
            "bytes"
        )
        val imageBitmap = modelCross.tryGetBitmap(
            "bitmap",
            "modelCrossBitmap",
            "crossBitmap",
            "image",
            "crossImage"
        )

        val payload = mutableMapOf<String, Any?>(
            "type" to "showModeCross",
            "raw" to modelCross.toString()
        )

        try {
            when {
                imageBytes != null && imageBytes.isNotEmpty() -> {
                    payload["crossData"] = Base64.encodeToString(imageBytes, Base64.NO_WRAP)
                    payload["dataFormat"] = "bytes"
                }

                imageBitmap != null -> {
                    payload["crossData"] = bitmapToBase64Png(imageBitmap)
                    payload["dataFormat"] = "bitmap"
                }
            }
        } catch (e: Throwable) {
            Log.e(TAG, "Error processing model cross image", e)
        }

        sendEvent(payload)
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
        if (laneInfo == null) return
        Log.d(TAG, "showLaneInfo: 显示车道信息")

        // 不同 AMap SDK 版本里 AMapLaneInfo 的图片数据字段/方法差异较大，这里用反射兼容
        val backgroundBytes = laneInfo.tryGetByteArray(
            "laneBackground",
            "laneBackgroundInfo",
            "laneBackInfo",
            "background",
            "back"
        )
        val recommendBytes = laneInfo.tryGetByteArray(
            "laneRecommend",
            "laneRecommendInfo",
            "laneFrontInfo",
            "recommend",
            "front"
        )
        val backgroundBitmap = laneInfo.tryGetBitmap(
            "laneBackgroundBitmap",
            "laneBackBitmap",
            "backgroundBitmap",
            "backBitmap"
        )
        val recommendBitmap = laneInfo.tryGetBitmap(
            "laneRecommendBitmap",
            "laneFrontBitmap",
            "recommendBitmap",
            "frontBitmap"
        )

        val data = mutableMapOf<String, Any?>(
            "type" to "showLaneInfo",
            "raw" to laneInfo.toString()
        )

        try {
            when {
                backgroundBytes != null && backgroundBytes.isNotEmpty() ->
                    data["laneBackground"] = Base64.encodeToString(backgroundBytes, Base64.NO_WRAP)

                backgroundBitmap != null ->
                    data["laneBackground"] = bitmapToBase64Png(backgroundBitmap)
            }
            when {
                recommendBytes != null && recommendBytes.isNotEmpty() ->
                    data["laneRecommend"] = Base64.encodeToString(recommendBytes, Base64.NO_WRAP)

                recommendBitmap != null ->
                    data["laneRecommend"] = bitmapToBase64Png(recommendBitmap)
            }
        } catch (e: Throwable) {
            Log.e(TAG, "Error processing lane info", e)
        }

        sendEvent(data)
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
        sendEvent(
            mapOf(
                "type" to "playRing",
                "ringType" to type
            )
        )
    }

    /**
     * 路径规划成功回调
     * @param result 路径规划结果，包含路径ID列表和错误信息
     */
    override fun onCalculateRouteSuccess(result: AMapCalcRouteResult?) {
        Log.i(TAG, "onCalculateRouteSuccess: 路径规划成功")
        result?.let { calcResult ->
            sendEvent(
                mapOf(
                    "type" to "calculateRouteSuccess",
                    "routeIds" to (calcResult.routeid?.toList() ?: emptyList<Int>()),
                    "errorCode" to calcResult.errorCode,
                    "errorDescription" to (calcResult.errorDescription ?: "")
                )
            )
        }
    }

    /**
     * 路径规划失败回调
     * @param result 路径规划结果，包含错误码和错误描述
     */
    override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) {
        Log.i(TAG, "onCalculateRouteFailure: 路径规划失败 errorCode=${result?.errorCode}")
        sendEvent(
            mapOf(
                "type" to "calculateRouteFailure",
                "errorCode" to (result?.errorCode ?: -1),
                "errorDescription" to (result?.errorDescription ?: "未知错误")
            )
        )
    }

    /**
     * 导航路线通知回调
     * 包含限行、收费等路线相关的通知信息
     * @param notifyData 通知数据
     */
    override fun onNaviRouteNotify(notifyData: AMapNaviRouteNotifyData?) {
        if (notifyData == null) return

        // notifyType 在当前版本可用，但 notifyContent 在部分版本不存在，这里用反射兼容
        val notifyType = notifyData.tryGetNumber("notifyType") ?: notifyData.tryGetNumber("type")
        val notifyContent = notifyData.tryGetString(
            "notifyContent",
            "content",
            "text",
            "notifyText",
            "description"
        ) ?: notifyData.toString()

        Log.d(TAG, "onNaviRouteNotify: 导航路线通知 type=$notifyType")
        sendEvent(
            mapOf(
                "type" to "naviRouteNotify",
                "notifyType" to notifyType,
                "notifyContent" to notifyContent
            )
        )
    }

    /**
     * 通过反射调用对象的无参 getter/方法，兼容不同 SDK 版本字段差异
     * @param name 属性名或方法名（支持 \"foo\" / \"getFoo\" / \"isFoo\" 三种形式）
     */
    private fun Any.tryInvokeNoArg(name: String): Any? {
        val candidates = mutableListOf(name)
        if (!name.startsWith("get") && !name.startsWith("is")) {
            val cap = if (name.isNotEmpty()) Character.toUpperCase(name[0]) + name.substring(1) else name
            candidates.add("get$cap")
            candidates.add("is$cap")
        }

        for (methodName in candidates) {
            try {
                val m = this.javaClass.methods.firstOrNull { it.name == methodName && it.parameterTypes.isEmpty() }
                if (m != null) return m.invoke(this)
            } catch (_: Throwable) {
                // ignore
            }
        }
        return null
    }

    /** 反射读取字符串（读不到返回 null） */
    private fun Any.tryGetString(vararg names: String): String? {
        for (n in names) {
            val v = tryInvokeNoArg(n) ?: continue
            when (v) {
                is String -> if (v.isNotBlank()) return v
                else -> {
                    val s = v.toString()
                    if (s.isNotBlank() && s != "null") return s
                }
            }
        }
        return null
    }

    /** 反射读取数值（Int/Long/Float/Double 等，读不到返回 null） */
    private fun Any.tryGetNumber(vararg names: String): Number? {
        for (n in names) {
            val v = tryInvokeNoArg(n) ?: continue
            when (v) {
                is Number -> return v
                is String -> v.toDoubleOrNull()?.let { return it }
            }
        }
        return null
    }

    /** 反射读取 Bitmap（读不到返回 null） */
    private fun Any.tryGetBitmap(vararg names: String): Bitmap? {
        for (n in names) {
            val v = tryInvokeNoArg(n) ?: continue
            if (v is Bitmap) return v
        }
        return null
    }

    /** 反射读取 ByteArray（读不到返回 null） */
    private fun Any.tryGetByteArray(vararg names: String): ByteArray? {
        for (n in names) {
            val v = tryInvokeNoArg(n) ?: continue
            if (v is ByteArray) return v
        }
        return null
    }

    /**
     * Bitmap 转 PNG Base64（不换行，便于 Flutter 端直接解码）
     */
    private fun bitmapToBase64Png(bitmap: Bitmap): String {
        val stream = ByteArrayOutputStream()
        return try {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
        } finally {
            try {
                stream.close()
            } catch (_: Throwable) {
                // ignore
            }
        }
    }

    /** Bitmap 转 PNG 字节（Flutter 侧会收到 Uint8List，可直接 Image.memory 渲染） */
    private fun bitmapToPngBytes(bitmap: Bitmap): ByteArray {
        val stream = ByteArrayOutputStream()
        return try {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } finally {
            try {
                stream.close()
            } catch (_: Throwable) {
                // ignore
            }
        }
    }

    /**
     * 将出口方向信息转换为 Flutter 可编码的数据结构（Map/String/基础类型）。
     * 说明：不同 AMap SDK 版本里 exitDirectionInfo 的类型可能不同（String 或 AMapExitDirectionInfo 对象）。
     */
    private fun exitDirectionInfoToFlutter(exitInfo: Any?): Any? {
        if (exitInfo == null) return null
        if (exitInfo is String) return exitInfo

        // 反射提取一些可能存在的字段（尽力而为），并保底带上 raw
        val raw = exitInfo.toString()
        val text = exitInfo.tryGetString(
            "text",
            "notifyText",
            "content",
            "directionInfo",
            "description",
            "name",
            "exitName"
        )
        val exitName = exitInfo.tryGetString("exitName", "name")
        val directionType = exitInfo.tryGetNumber("directionType", "direction", "type")?.toInt()
        val distance = exitInfo.tryGetNumber("distance", "remainDistance")?.toDouble()

        return mapOf(
            "raw" to raw,
            "text" to text,
            "exitName" to exitName,
            "directionType" to directionType,
            "distance" to distance
        )
    }

    /**
     * 将“不可避让信息”转换为 Flutter 可编码的数据结构（Map/String/基础类型）。
     *
     * 说明：AMapNotAvoidInfo 在不同 SDK 版本里字段可能不同，因此这里用反射尽力提取常见信息，
     * 同时始终携带 raw 字段便于排查。
     */
    private fun notAvoidInfoToFlutter(notAvoidInfo: Any?): Any? {
        if (notAvoidInfo == null) return null
        if (notAvoidInfo is String) return notAvoidInfo

        fun latLngToFlutter(latLng: Any?): Map<String, Any?>? {
            if (latLng == null) return null
            val latitude = when (latLng) {
                is NaviLatLng -> latLng.latitude
                else -> latLng.tryGetNumber("latitude", "lat")?.toDouble()
            }
            val longitude = when (latLng) {
                is NaviLatLng -> latLng.longitude
                else -> latLng.tryGetNumber("longitude", "lng", "lon")?.toDouble()
            }
            if (latitude == null && longitude == null) return null
            return mapOf(
                "latitude" to latitude,
                "longitude" to longitude,
                "raw" to latLng.toString()
            )
        }

        val raw = notAvoidInfo.toString()
        val type = notAvoidInfo.tryGetNumber("type", "notAvoidType")?.toInt()
        val title = notAvoidInfo.tryGetString("title", "name")
        val content = notAvoidInfo.tryGetString("content", "text", "description", "reason")
        val roadName = notAvoidInfo.tryGetString("roadName", "road", "currentRoadName")
        val distance = notAvoidInfo.tryGetNumber("distance", "remainDistance")?.toDouble()
        val time = notAvoidInfo.tryGetNumber("time", "remainTime")?.toDouble()

        val coordAny =
            notAvoidInfo.tryInvokeNoArg("latLng")
                ?: notAvoidInfo.tryInvokeNoArg("coord")
                ?: notAvoidInfo.tryInvokeNoArg("point")
        val coord = latLngToFlutter(coordAny)

        return mapOf(
            "raw" to raw,
            "type" to type,
            "title" to title,
            "content" to content,
            "roadName" to roadName,
            "distance" to distance,
            "time" to time,
            "coord" to coord
        )
    }

    /**
     * 将“到途经点信息数组”转换为 Flutter 可编码的数据结构（List<Map>）。
     *
     * 说明：AMapNaviToViaInfo 的字段在不同 SDK 版本可能不同，因此这里用反射尽力提取：
     * - viaIndex: 途经点索引（第几个途经点）
     * - distance/time: 到该途经点剩余距离/时间
     * - name: 途经点名称（如果有）
     */
    private fun toViaInfosToFlutter(toViaInfos: Any?): Any? {
        if (toViaInfos == null) return null

        fun toViaInfoToFlutter(toViaInfo: Any?): Map<String, Any?>? {
            if (toViaInfo == null) return null

            fun latLngToFlutter(latLng: Any?): Map<String, Any?>? {
                if (latLng == null) return null
                val latitude = when (latLng) {
                    is NaviLatLng -> latLng.latitude
                    else -> latLng.tryGetNumber("latitude", "lat")?.toDouble()
                }
                val longitude = when (latLng) {
                    is NaviLatLng -> latLng.longitude
                    else -> latLng.tryGetNumber("longitude", "lng", "lon")?.toDouble()
                }
                if (latitude == null && longitude == null) return null
                return mapOf(
                    "latitude" to latitude,
                    "longitude" to longitude,
                    "raw" to latLng.toString()
                )
            }

            val raw = toViaInfo.toString()
            val viaIndex = toViaInfo.tryGetNumber("viaIndex", "index", "viaPointIndex")?.toInt()
            val name = toViaInfo.tryGetString("name", "viaName", "poiName", "title")
            val distance = toViaInfo.tryGetNumber("distance", "remainDistance")?.toDouble()
            val time = toViaInfo.tryGetNumber("time", "remainTime")?.toDouble()

            val coordAny =
                toViaInfo.tryInvokeNoArg("latLng")
                    ?: toViaInfo.tryInvokeNoArg("coord")
                    ?: toViaInfo.tryInvokeNoArg("point")
            val coord = latLngToFlutter(coordAny)

            return mapOf(
                "raw" to raw,
                "viaIndex" to viaIndex,
                "name" to name,
                "distance" to distance,
                "time" to time,
                "coord" to coord
            )
        }

        return when (toViaInfos) {
            is Array<*> -> toViaInfos.mapNotNull { toViaInfoToFlutter(it) }
            is Collection<*> -> toViaInfos.mapNotNull { toViaInfoToFlutter(it) }
            else -> listOfNotNull(toViaInfoToFlutter(toViaInfos))
        }
    }

    /**
     * 将任意值转换成 Flutter StandardMessageCodec 支持的类型。
     * 支持：null / bool / num / String / byte[] / List / Map（key 统一转 String）
     * 其它对象：降级为 toString()，避免通道抛 Unsupported value。
     */
    private fun toFlutterEncodable(value: Any?): Any? {
        return when (value) {
            null -> null
            is Boolean -> value
            is String -> value
            is Int -> value
            is Long -> value
            is Double -> value
            is Float -> value.toDouble()
            is Short -> value.toInt()
            is Byte -> value.toInt()
            is ByteArray -> value
            is IntArray -> value.toList()
            is LongArray -> value.toList()
            is DoubleArray -> value.toList()
            is FloatArray -> value.map { it.toDouble() }
            is List<*> -> value.map { toFlutterEncodable(it) }
            is Map<*, *> -> value.entries.associate { (k, v) -> (k?.toString() ?: "") to toFlutterEncodable(v) }
            else -> value.toString()
        }
    }

    /** 清洗事件数据，确保所有 value 都是 Flutter 可编码类型 */
    private fun sanitizeEventMap(data: Map<String, Any?>): Map<String, Any?> {
        return data.mapValues { (_, v) -> toFlutterEncodable(v) }
    }


    /**
     * 发送事件到 Flutter 层
     * @param data 事件数据，将通过 EventChannel 发送
     */
    private fun sendEvent(data: Map<String, Any?>) {
        // 统一做一次数据清洗，避免传入 SDK 对象导致 Flutter 侧解码失败
        eventSink?.success(sanitizeEventMap(data))
    }

}
