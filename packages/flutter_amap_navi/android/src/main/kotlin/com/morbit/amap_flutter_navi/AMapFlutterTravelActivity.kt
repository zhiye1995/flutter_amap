package com.morbit.amap_flutter_navi

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.amap.api.maps.MapView
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import com.amap.api.navi.*
import com.amap.api.navi.enums.TravelStrategy
import com.amap.api.navi.model.*
import io.flutter.plugin.common.MethodCall
import java.lang.ref.WeakReference
import kotlin.math.ceil

internal fun calculateTravelRoute(
    engine: AMapNavi,
    isWalk: Boolean,
    start: NaviPoi?,
    wayPoints: List<NaviPoi>,
    end: NaviPoi,
    strategy: TravelStrategy,
): Boolean = if (isWalk) {
    engine.calculateWalkRoute(start, wayPoints, end, strategy)
} else {
    engine.calculateRideRoute(start, wayPoints, end, strategy)
}

/** 骑步行使用专用算路 API；AmapNaviPage 的驾车组件不能用于骑步行。 */
@Suppress("DEPRECATION")
class AMapFlutterTravelActivity : Activity(), AMapNaviViewListener {
    companion object {
        private var active: WeakReference<AMapFlutterTravelActivity>? = null

        fun launch(activity: Activity, call: MethodCall) {
            val intent = Intent(activity, AMapFlutterTravelActivity::class.java)
            for (key in listOf("naviType", "pageType", "travelStrategy")) {
                call.argument<Int>(key)?.let { intent.putExtra(key, it) }
            }
            for (key in listOf("startLat", "startLng", "endLat", "endLng")) {
                call.argument<Double>(key)?.let { intent.putExtra(key, it) }
            }
            for (key in listOf("startName", "startPoiId", "endName", "endPoiId")) {
                call.argument<String>(key)?.let { intent.putExtra(key, it) }
            }
            val points = call.argument<List<Map<String, Any?>>>("wayPoints").orEmpty().mapNotNull { point ->
                val lat = (point["lat"] as? Number)?.toDouble() ?: return@mapNotNull null
                val lng = (point["lng"] as? Number)?.toDouble() ?: return@mapNotNull null
                NaviPoi(point["name"] as? String ?: "途经点", LatLng(lat, lng), point["poiId"] as? String ?: "")
            }
            intent.putParcelableArrayListExtra("wayPoints", ArrayList(points))
            activity.startActivity(intent)
        }

        fun closeActive(): Boolean {
            val activity = active?.get() ?: return false
            activity.release()
            activity.finish()
            return true
        }
    }

    private var navi: AMapNavi? = null
    private var naviView: AMapNaviView? = null
    private var previewView: MapView? = null
    private lateinit var root: LinearLayout
    private lateinit var status: TextView
    private lateinit var action: Button
    private lateinit var alternatives: LinearLayout
    private var pending = false
    private var released = false
    private var navigating = false
    private var routeReady = false
    private var preview: Polyline? = null
    private val isWalk get() = intent.getIntExtra("naviType", 1) == 1
    private val modeName get() = if (isWalk) "步行" else "骑行"

    // 通用监听器仍由 AMapNaviApi 转发给 Dart，这里只处理本页的算路结果。
    private val routeListener = object : AMapNaviListener by AMapNaviListenerImpl() {
        override fun onCalculateRouteSuccess(routeIds: IntArray?) = routeSuccess(routeIds)
        override fun onCalculateRouteSuccess(result: AMapCalcRouteResult?) = routeSuccess(result?.routeid)
        override fun onCalculateRouteFailure(errorCode: Int) = routeFailure("错误码 $errorCode")
        override fun onCalculateRouteFailure(result: AMapCalcRouteResult?) =
            routeFailure(result?.errorDescription ?: "错误码 ${result?.errorCode}")
        override fun onInitNaviFailure() = routeFailure("导航引擎初始化失败")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        active = WeakReference(this)
        root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            fitsSystemWindows = true
        }
        val header = LinearLayout(this).apply { gravity = Gravity.CENTER_VERTICAL }
        header.addView(Button(this).apply { text = "返回"; setOnClickListener { finish() } })
        header.addView(TextView(this).apply {
            text = "${modeName}路线规划"; textSize = 20f; setTextColor(Color.BLACK)
        })
        root.addView(header)
        status = TextView(this).apply { textSize = 17f; setPadding(24, 16, 24, 16) }
        alternatives = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        action = Button(this).apply {
            text = "正在规划${modeName}路线…"; isEnabled = false
            setOnClickListener { if (routeReady) startTravelNavigation() else calculateRoute() }
        }
        setContentView(root)
        try {
            navi = AMapNavi.getInstance(applicationContext).also {
                // 高德要求在创建骑步行 AMapNaviView 之前设置此模式。
                it.setIsNaviTravelView(true)
                it.setUseInnerVoice(true)
                it.addAMapNaviListener(routeListener)
            }
            val view = MapView(this)
            previewView = view
            root.addView(view, LinearLayout.LayoutParams(-1, 0, 1f))
            root.addView(status)
            root.addView(alternatives)
            root.addView(action)
            view.onCreate(savedInstanceState)
            view.map.setOnMapLoadedListener { if (!released && !pending && !routeReady) calculateRoute() }
        } catch (error: Exception) {
            Log.e("AMapTravel", "Cannot initialize travel navigation", error)
            status.text = "无法打开${modeName}导航：${error.message}"
            if (status.parent == null) root.addView(status)
        }
    }

    private fun point(prefix: String): NaviPoi? {
        if (!intent.hasExtra("${prefix}Lat") || !intent.hasExtra("${prefix}Lng")) return null
        return NaviPoi(intent.getStringExtra("${prefix}Name") ?: prefix,
            LatLng(intent.getDoubleExtra("${prefix}Lat", 0.0), intent.getDoubleExtra("${prefix}Lng", 0.0)),
            intent.getStringExtra("${prefix}PoiId") ?: "")
    }

    private fun calculateRoute() {
        val engine = navi ?: return
        val end = point("end") ?: return routeFailure("缺少终点")
        pending = true
        routeReady = false
        action.isEnabled = false
        status.text = "正在规划${modeName}路线…"
        alternatives.removeAllViews()
        val start = point("start")
        val strategy = TravelStrategy.values().firstOrNull {
            it.value == intent.getIntExtra("travelStrategy", TravelStrategy.SINGLE.value)
        } ?: return routeFailure("不支持的骑步行算路策略")
        val wayPoints = intent.getParcelableArrayListExtra<NaviPoi>("wayPoints").orEmpty()
        try {
            val accepted = calculateTravelRoute(engine, isWalk, start, wayPoints, end, strategy)
            Log.i("AMapTravel", "calculate ${if (isWalk) "WALK" else "RIDE"}, accepted=$accepted")
            if (!accepted) routeFailure("算路请求未被接受")
        } catch (error: Exception) {
            routeFailure(error.message ?: "算路异常")
        }
    }

    private fun routeSuccess(ids: IntArray?) {
        if (released || !pending) return
        pending = false
        val engine = navi ?: return
        val routes = engine.naviPaths.orEmpty()
        val routeIds = ids?.toList()?.filter { routes.containsKey(it) } ?: routes.keys.toList()
        if (routeIds.isEmpty()) return routeFailure("未返回${modeName}路线")
        alternatives.removeAllViews()
        if (routeIds.size > 1) routeIds.forEachIndexed { index, id ->
            alternatives.addView(Button(this).apply {
                text = "方案 ${index + 1}"
                setOnClickListener { selectRoute(id) }
            }, LinearLayout.LayoutParams(0, -2, 1f))
        }
        selectRoute(routeIds.first())
        if (intent.getIntExtra("pageType", 0) == 1) startTravelNavigation()
    }

    private fun selectRoute(id: Int) {
        val engine = navi ?: return
        if (!engine.selectRouteId(id)) return routeFailure("无法选择路线")
        val path = engine.naviPaths?.get(id) ?: return routeFailure("路线不可用")
        val map = previewView?.map ?: return
        map.clear()
        val coordinates = path.coordList.orEmpty().map { LatLng(it.latitude, it.longitude) }
        if (coordinates.isEmpty()) return routeFailure("路线没有坐标")
        preview = map.addPolyline(PolylineOptions().addAll(coordinates).width(14f)
            .color(if (isWalk) Color.rgb(32, 164, 100) else Color.rgb(30, 130, 220)))
        map.addMarker(MarkerOptions().position(coordinates.first()).title("起点"))
        map.addMarker(MarkerOptions().position(coordinates.last()).title("终点"))
        map.moveCamera(CameraUpdateFactory.newLatLngBounds(path.boundsForPath, 80))
        status.text = "$modeName · %.1f 公里 · 约 %d 分钟".format(path.allLength / 1000.0,
            ceil(path.allTime / 60.0).toInt())
        routeReady = true
        action.text = "开始${modeName}导航"
        action.isEnabled = true
        Log.i("AMapTravel", "route ready: mode=$modeName engine=${engine.engineType}, distance=${path.allLength}, seconds=${path.allTime}")
    }

    private fun routeFailure(message: String) {
        if (released) return
        pending = false
        routeReady = false
        if (!::status.isInitialized) return
        status.text = "${modeName}路径规划失败：$message"
        action.text = "重试"
        action.isEnabled = true
        Log.e("AMapTravel", "route failure: $modeName $message")
    }

    private fun startTravelNavigation() {
        if (!routeReady || navigating) return
        val options = AMapNaviViewOptions().apply {
            setAMapNaviType(if (isWalk) AmapNaviType.WALK else AmapNaviType.RIDE)
            setAutoDrawRoute(true)
        }
        val view = AMapNaviView(this, options)
        naviView = view
        previewView?.visibility = View.GONE
        root.addView(view, 1, LinearLayout.LayoutParams(-1, 0, 1f))
        view.setAMapNaviViewListener(this)
        view.onCreate(null)
        view.onResume()
        if (navi?.startNavi(com.amap.api.navi.enums.NaviType.GPS) != true) {
            root.removeView(view)
            view.onPause()
            view.onDestroy()
            naviView = null
            previewView?.visibility = View.VISIBLE
            routeFailure("无法启动导航")
            return
        }
        previewView?.let { root.removeView(it); it.onPause(); it.onDestroy() }
        previewView = null
        navigating = true
        alternatives.visibility = View.GONE
        action.visibility = View.GONE
        status.visibility = View.GONE
    }

    override fun onResume() { super.onResume(); previewView?.onResume(); naviView?.onResume() }
    override fun onPause() { previewView?.onPause(); naviView?.onPause(); super.onPause() }
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState); previewView?.onSaveInstanceState(outState); naviView?.onSaveInstanceState(outState)
    }
    private fun release() {
        if (released) return
        released = true
        active = null
        navi?.removeAMapNaviListener(routeListener)
        navi?.stopNavi()
        previewView?.onDestroy()
        previewView = null
        naviView?.onDestroy()
        naviView = null
        navi?.setIsNaviTravelView(false)
        AMapNaviApi.onTravelActivityClosed()
        navi = null
    }
    override fun onDestroy() { release(); super.onDestroy() }
    override fun onNaviCancel() { finish() }
    override fun onNaviBackClick(): Boolean { finish(); return true }
    override fun onAMapNaviViewExit() { finish() }
    override fun onNaviSetting() {}
    override fun onNaviMapMode(mode: Int) {}
    override fun onNaviTurnClick() {}
    override fun onNextRoadClick() {}
    override fun onScanViewButtonClick() {}
    override fun onLockMap(locked: Boolean) {}
    override fun onNaviViewLoaded() {}
    override fun onMapTypeChanged(type: Int) {}
    override fun onNaviViewShowMode(mode: Int) {}
    override fun onStopSpeaking() {}
    override fun onViewTypeChanged(type: AmapPageType?) {}
    override fun onStrategyChanged(strategy: Int) {}
    override fun onBroadcastModeChanged(mode: Int) {}
    override fun onDayAndNightModeChanged(mode: Int) {}
    override fun onScaleAutoChanged(enabled: Boolean) {}
    override fun onListenToVoiceDuringCallChanged(enabled: Boolean) {}
    override fun onControlMusicVolumeModeChanged(mode: Int) {}
    override fun onEagleChanged(enabled: Boolean) {}
    override fun onNaviRouteHighlightChange(pathId: Long, routeId: Int) {}
}
