package com.morbit.amap_flutter

import android.graphics.Bitmap
import android.graphics.Point
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.CoordinateConverter
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker as AMapMarker
import com.amap.api.maps.model.animation.AlphaAnimation
import com.amap.api.maps.model.animation.Animation
import com.amap.api.maps.model.animation.RotateAnimation
import com.amap.api.maps.model.animation.ScaleAnimation
import com.amap.api.maps.model.animation.TranslateAnimation
import com.amap.api.maps.utils.overlay.SmoothMoveMarker
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class AMapApi(private val amap: AMapFlutter, private val config: MapInitConfig?) {
  private val mapView = amap.getView()
  private val markerAnimationTokens = mutableMapOf<String, Int>()
  private val smoothMoveMarkers = mutableMapOf<String, SmoothMoveMarker>()
  private val smoothMoveStates = mutableMapOf<String, SmoothMoveState>()

  private data class SmoothMoveState(
    val marker: Marker,
    val points: List<Position>,
    val durationMs: Long,
    val startTimeMs: Long,
    var remainingMs: Long,
    var pausedPosition: Position? = null,
    var paused: Boolean = false,
  )

  fun initMap() {
    // 处理仅设置 zoom/tilt/bearing 但不传 position 的情况：
    // Android 的 AMapOptions.camera(...) 初始化阶段要求必须有 target，因此这里只能在地图加载完成后，
    // 使用当前地图中心点作为 target 来补应用相机参数，达到“不改中心点但让 zoom 生效”的效果。
    // 注意：若配置了 fitPositions，则以 fitPositions 的视野为准，不再覆盖。
    if (config?.fitPositions == null) {
      config?.cameraPosition?.let { moveCamera(it, 0) }
    }

    config?.fitPositions?.let { positions ->
      val latLngBoundsBuilder = LatLngBounds.builder()
      positions.forEach { latLngBoundsBuilder.include(it.toPosition()) }
      val latLngBounds = latLngBoundsBuilder.build()
      val cameraUpdate = CameraUpdateFactory.newLatLngBounds(latLngBounds, 0)
      mapView.map.moveCamera(cameraUpdate)
    }
    config?.minZoom?.let { mapView.map.minZoomLevel = it.toFloat() }
    config?.maxZoom?.let { mapView.map.maxZoomLevel = it.toFloat() }
    config?.customStyleOptions?.let { applyCustomStyle(it) }
  }

  private fun applyCustomStyle(opts: CustomStyleOptions) {
    // 离线自定义样式仅作用在标准底图上；若仍为卫星/导航等类型，样式不会正确叠加
    if (opts.enabled) {
      mapView.map.mapType = AMap.MAP_TYPE_NORMAL
    }
    val style = CustomMapStyleOptions()
    style.isEnable = opts.enabled
    opts.styleData?.let { style.styleData = it }
    opts.styleExtraData?.let { style.styleExtraData = it }
    mapView.map.setCustomMapStyle(style)
  }

  fun updateMapConfig(config: MapUpdateConfig) {
    config.mapType?.toMapType()?.let { mapView.map.mapType = it }
    config.dragEnable?.let { mapView.map.uiSettings.isScrollGesturesEnabled = it }
    config.zoomEnable?.let { mapView.map.uiSettings.isZoomGesturesEnabled = it }
    config.tiltEnable?.let { mapView.map.uiSettings.isTiltGesturesEnabled = it }
    config.rotateEnable?.let { mapView.map.uiSettings.isRotateGesturesEnabled = it }
    config.compassControlEnabled?.let { mapView.map.uiSettings.isCompassEnabled = it }
    config.scaleControlEnabled?.let { mapView.map.uiSettings.isScaleControlsEnabled = it }
    config.zoomControlEnabled?.let { mapView.map.uiSettings.isZoomControlsEnabled = it }
    config.logoPosition?.anchor?.toLogoPosition()?.let { mapView.map.uiSettings.logoPosition = it }
    config.zoomControlPosition?.anchor?.toZoomPosition()?.let { mapView.map.uiSettings.zoomPosition = it }
    config.showTraffic?.let { mapView.map.isTrafficEnabled = it }
    config.showBuildings?.let { mapView.map.showBuildings(it) }
    config.showIndoorMap?.let { mapView.map.showIndoorMap(it) }
    config.userLocationConfig?.let {
      it.userLocationButton?.let { showButton -> mapView.map.uiSettings.isMyLocationButtonEnabled = showButton }
      // 必须先设置定位样式，再启用定位，否则 LOCATION_TYPE_LOCATE 等类型的"移动到中心点"动作会丢失
      it.userLocationStyle?.let { styleConfig ->
        amap.locationSource.setLocationStyle(styleConfig)
        mapView.map.myLocationStyle = styleConfig.toLocationStyle(amap.binding)
      }
      it.showUserLocation?.let { showLocation -> mapView.map.isMyLocationEnabled = showLocation }
    }
    config.customStyleOptions?.let { applyCustomStyle(it) }
    config.minZoom?.let { mapView.map.minZoomLevel = it.toFloat() }
    config.maxZoom?.let { mapView.map.maxZoomLevel = it.toFloat() }
  }

  fun moveCamera(position: CameraPosition, duration: Long) {
    // 如果 position.position 为 null，使用当前地图中心来构建 CameraPosition
    val cameraPosition = position.toCameraPosition() ?: run {
      // 当 position 为 null 时，使用当前地图中心
      val currentCenter = mapView.map.cameraPosition.target
      com.amap.api.maps.model.CameraPosition.Builder()
        .target(currentCenter)
        .apply {
          position.zoom?.let { zoom(it.toFloat()) }
          position.skew?.let { tilt(it.toFloat()) }
          position.heading?.let { bearing(it.toFloat()) }
        }
        .build()
    }
    val cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition)
    if (duration > 0) {
      mapView.map.stopAnimation()
      mapView.map.animateCamera(cameraUpdate, duration, null)
    } else {
      mapView.map.moveCamera(cameraUpdate)
    }
  }

  fun moveCameraToRegion(region: Region, duration: Long) {
    val latLngBounds = region.toLatLngBounds()
    val cameraUpdate = CameraUpdateFactory.newLatLngBounds(latLngBounds, 0)
    if (duration > 0) {
      mapView.map.stopAnimation()
      mapView.map.animateCamera(cameraUpdate, duration, null)
    } else {
      mapView.map.moveCamera(cameraUpdate)
    }
  }

  fun moveCameraToRegionWithPosition(positions: List<Position?>, padding: EdgePadding, duration: Long) {
    val latLngBoundsBuilder = LatLngBounds.builder()
    positions.filterNotNull().forEach { latLngBoundsBuilder.include(it.toPosition()) }
    val latLngBounds = latLngBoundsBuilder.build()
    val cameraUpdate = CameraUpdateFactory.newLatLngBoundsRect(
      latLngBounds,
      padding.left.toInt(),
      padding.right.toInt(),
      padding.top.toInt(),
      padding.bottom.toInt(),
    )
    if (duration > 0) {
      mapView.map.stopAnimation()
      mapView.map.animateCamera(cameraUpdate, duration, null)
    } else {
      mapView.map.moveCamera(cameraUpdate)
    }
  }

  fun setRestrictRegion(region: Region) {
    mapView.map.setMapStatusLimits(region.toLatLngBounds())
  }

  fun removeRestrictRegion() {
    mapView.map.setMapStatusLimits(null)
  }

  fun addMarker(marker: Marker) {
    val aMapMarker = mapView.map.addMarker(marker.toMarkerOptions(amap.binding))
    amap.markers[marker.id] = aMapMarker
    amap.aMapMarkerIdToDartMarkerId[aMapMarker.id] = marker.id
  }

  fun removeMarker(id: String) {
    val marker = amap.markers[id]
    if (marker != null) {
      cancelMarkerAnimation(id)
      marker.remove()
      amap.markers.remove(id)
      amap.aMapMarkerIdToDartMarkerId.remove(marker.id)
      markerAnimationTokens.remove(id)
    }
  }

  fun startSmoothMoveMarker(marker: Marker, points: List<Position>, durationMs: Long) {
    if (points.size < 2) return
    stopSmoothMoveMarker(marker.id)
    val safeDuration = durationMs.coerceAtLeast(1_000L)
    smoothMoveStates[marker.id] =
      SmoothMoveState(
        marker = marker,
        points = points,
        durationMs = safeDuration,
        startTimeMs = System.currentTimeMillis(),
        remainingMs = safeDuration,
      )
    startSmoothMoveSegment(marker.id, marker, points, safeDuration)
  }

  fun stopSmoothMoveMarker(markerId: String) {
    smoothMoveMarkers.remove(markerId)?.let {
      it.stopMove()
      try {
        it.marker?.remove()
      } catch (e: Exception) {
        // ignore
      }
      it.destroy()
    }
    smoothMoveStates.remove(markerId)
  }

  fun pauseSmoothMoveMarker(markerId: String) {
    val state = smoothMoveStates[markerId] ?: return
    if (state.paused) return
    val smoothMarker = smoothMoveMarkers[markerId] ?: return
    val current = smoothMarker.position?.toPosition() ?: state.points.first()
    val elapsed = System.currentTimeMillis() - state.startTimeMs
    state.pausedPosition = current
    state.remainingMs = (state.remainingMs - elapsed).coerceAtLeast(1_000L)
    state.paused = true
    smoothMarker.stopMove()
  }

  fun resumeSmoothMoveMarker(markerId: String) {
    val state = smoothMoveStates[markerId] ?: return
    if (!state.paused) return
    val smoothMarker = smoothMoveMarkers[markerId]
    val current = state.pausedPosition ?: state.points.first()
    state.paused = false
    state.pausedPosition = null
    smoothMoveStates[markerId] = state.copy(startTimeMs = System.currentTimeMillis())
    if (smoothMarker != null) {
      smoothMarker.startSmoothMove()
      return
    }
    val remainingPoints = buildRemainingSmoothMovePoints(current, state.points)
    startSmoothMoveSegment(markerId, state.marker.copy(position = current), remainingPoints, state.remainingMs)
  }

  private fun startSmoothMoveSegment(markerId: String, marker: Marker, points: List<Position>, durationMs: Long) {
    if (points.size < 2) return
    val smoothMarker = SmoothMoveMarker(mapView.map)
    marker.bitmap?.toBitmapDescriptor(amap.binding)?.let { smoothMarker.setDescriptor(it) }
    smoothMarker.setPoints(points.map { it.toPosition() })
    smoothMarker.setTotalDuration((durationMs.coerceAtLeast(1_000L) / 1_000L).toInt())
    smoothMarker.setMoveListener(object : SmoothMoveMarker.MoveListener {
      override fun move(distance: Double) {
        if (distance == 0.0) {
          amap.controller.onSmoothMoveMarkerComplete(markerId)
        }
      }
    })
    smoothMoveMarkers[markerId] = smoothMarker
    smoothMarker.startSmoothMove()
  }

  private fun buildRemainingSmoothMovePoints(current: Position, points: List<Position>): List<Position> {
    val nearestIndex =
      points.indices.minByOrNull { index ->
        AMapUtils.calculateLineDistance(current.toPosition(), points[index].toPosition())
      } ?: 0
    return listOf(current) + points.drop((nearestIndex + 1).coerceAtMost(points.size - 1))
  }

  fun addPolyline(polyline: Polyline) {
    removePolyline(polyline.id)
    if (polyline.points.size < 2) return
    amap.polylines[polyline.id] = mapView.map.addPolyline(polyline.toPolylineOptions(amap.binding))
  }

  fun removePolyline(id: String) {
    amap.polylines.remove(id)?.remove()
  }

  fun addNavigateArrow(arrow: NavigateArrow) {
    removeNavigateArrow(arrow.id)
    if (arrow.points.size < 2) return
    amap.navigateArrows[arrow.id] = mapView.map.addNavigateArrow(arrow.toNavigateArrowOptions())
  }

  fun removeNavigateArrow(id: String) {
    amap.navigateArrows.remove(id)?.remove()
  }

  fun addArc(arc: Arc) {
    removeArc(arc.id)
    amap.arcs[arc.id] = mapView.map.addArc(arc.toArcOptions())
  }

  fun removeArc(id: String) {
    amap.arcs.remove(id)?.remove()
  }

  fun addPolygon(polygon: Polygon) {
    removePolygon(polygon.id)
    amap.polygons[polygon.id] = mapView.map.addPolygon(polygon.toPolygonOptions())
  }

  fun removePolygon(id: String) {
    amap.polygons.remove(id)?.remove()
  }

  fun showInfoWindow(markerId: String) {
    val m: AMapMarker = amap.markers[markerId] ?: return
    m.showInfoWindow()
  }

  fun hideInfoWindow() {
    for (m in amap.markers.values) {
      m.hideInfoWindow()
    }
  }

  /// 与高德 [Marker.setAnimation] / [Marker.startAnimation] 对齐；[kind] 与 Dart [MarkerAnimationKind.code] 一致。
  fun animateMarker(markerId: String, kind: Int, durationMs: Int) {
    val marker: AMapMarker = amap.markers[markerId] ?: return
    cancelMarkerAnimation(markerId)
    val dur = durationMs.toLong().coerceIn(200L, 10_000L)
    if (kind == 4) {
      startMarkerMoveRoundTrip(markerId, marker, dur)
      return
    }
    val anim: Animation? =
      when (kind) {
        0 ->
          ScaleAnimation(1f, 1.28f, 1f, 1.28f).apply {
            setDuration(dur)
            setRepeatCount(3)
            setRepeatMode(Animation.REVERSE)
          }
        1 ->
          RotateAnimation(0f, 360f).apply {
            setDuration(dur)
          }
        2 ->
          AlphaAnimation(1f, 0.32f).apply {
            setDuration(dur / 2)
            setRepeatCount(5)
            setRepeatMode(Animation.REVERSE)
          }
        3 ->
          ScaleAnimation(0f, 1f, 0f, 1f).apply {
            setDuration(dur)
            setRepeatCount(0)
          }
        else -> null
      }
    if (anim != null) {
      marker.setAnimation(anim)
      marker.startAnimation()
    }
  }

  fun cancelMarkerAnimation(markerId: String) {
    val marker: AMapMarker = amap.markers[markerId] ?: return
    markerAnimationTokens[markerId] = (markerAnimationTokens[markerId] ?: 0) + 1
    // 高德 Marker 没有显式 stopAnimation；用极短透明度动画覆盖正在播放的动画。
    marker.setAnimation(
      AlphaAnimation(marker.alpha, marker.alpha).apply {
        setDuration(1L)
        setRepeatCount(0)
      },
    )
    marker.startAnimation()
    marker.alpha = 1f
  }

  /// 官方 Demo「移动」：`TranslateAnimation(LatLng)` 去程 + 返程，结束后 [Marker.setPosition] 回到起点。
  private fun startMarkerMoveRoundTrip(markerId: String, marker: AMapMarker, durMs: Long) {
    val start = marker.position
    val target =
      LatLng(
        start.latitude + 0.00015,
        start.longitude + 0.00012,
      )
    val half = durMs.coerceAtLeast(400L) / 2
    markerAnimationTokens[markerId] = (markerAnimationTokens[markerId] ?: 0) + 1
    val token = markerAnimationTokens[markerId]
    val outward =
      TranslateAnimation(target).apply {
        setDuration(half)
        setAnimationListener(
          object : Animation.AnimationListener {
            override fun onAnimationStart() {}

            override fun onAnimationEnd() {
              if (markerAnimationTokens[markerId] != token) return
              val inward =
                TranslateAnimation(start).apply {
                  setDuration(half)
                  setAnimationListener(
                    object : Animation.AnimationListener {
                      override fun onAnimationStart() {}

                      override fun onAnimationEnd() {
                        if (markerAnimationTokens[markerId] != token) return
                        marker.position = start
                      }
                    },
                  )
                }
              marker.setAnimation(inward)
              marker.startAnimation()
            }
          },
        )
      }
    marker.setAnimation(outward)
    marker.startAnimation()
  }

  fun getUserLocation(): Location? {
    return mapView.map.myLocation?.toLocation()
  }

  fun stopCameraAnimation() {
    mapView.map.stopAnimation()
  }

  fun getScalePerPixel(): Double {
    return mapView.map.scalePerPixel.toDouble()
  }

  fun convertCoordinate(position: Position, from: String): Position {
    val sourceType = when (from) {
      "gps" -> CoordinateConverter.CoordType.GPS
      "baidu" -> CoordinateConverter.CoordType.BAIDU
      "mapbar" -> CoordinateConverter.CoordType.MAPBAR
      "mapabc" -> CoordinateConverter.CoordType.MAPABC
      "sosomap" -> CoordinateConverter.CoordType.SOSOMAP
      "aliyun" -> CoordinateConverter.CoordType.ALIYUN
      else -> CoordinateConverter.CoordType.GPS
    }
    return CoordinateConverter(amap.binding.applicationContext)
      .from(sourceType)
      .coord(position.toPosition())
      .convert()
      .toPosition()
  }

  fun toScreenLocation(position: Position): Size {
    val point = mapView.map.projection.toScreenLocation(position.toPosition())
    return Size(point.x.toDouble(), point.y.toDouble())
  }

  fun fromScreenLocation(point: Size): Position {
    return mapView.map.projection.fromScreenLocation(
      Point(point.width.toInt(), point.height.toInt()),
    ).toPosition()
  }

  fun calculateLineDistance(start: Position, end: Position): Double {
    return AMapUtils.calculateLineDistance(
      start.toPosition(),
      end.toPosition(),
    ).toDouble()
  }

  fun containsCoordinate(point: Position, polygon: List<Position>): Boolean {
    if (polygon.size < 3) return false
    var inside = false
    var previous = polygon.lastIndex
    polygon.indices.forEach { current ->
      val currentPoint = polygon[current]
      val previousPoint = polygon[previous]
      val intersects =
        (currentPoint.latitude > point.latitude) != (previousPoint.latitude > point.latitude) &&
          point.longitude < (previousPoint.longitude - currentPoint.longitude) *
          (point.latitude - currentPoint.latitude) /
          (previousPoint.latitude - currentPoint.latitude) +
          currentPoint.longitude
      if (intersects) inside = !inside
      previous = current
    }
    return inside
  }

  /// 与高德 Android Demo「地图截屏」一致：截取当前可视地图区域（PNG）。
  fun takeMapSnapshot(result: MethodChannel.Result) {
    val finished = AtomicBoolean(false)
    mapView.map.getMapScreenShot(
      object : AMap.OnMapScreenShotListener {
        override fun onMapScreenShot(bitmap: Bitmap?) {
          deliver(bitmap)
        }

        override fun onMapScreenShot(bitmap: Bitmap?, status: Int) {
          deliver(bitmap)
        }

        private fun deliver(bitmap: Bitmap?) {
          if (!finished.compareAndSet(false, true)) {
            return
          }
          if (bitmap == null || bitmap.isRecycled) {
            result.error(
              "SNAPSHOT_FAILED",
              "bitmap is null or recycled",
              null,
            )
            return
          }
          try {
            val stream = ByteArrayOutputStream()
            if (!bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)) {
              result.error("SNAPSHOT_FAILED", "PNG compress failed", null)
              return
            }
            result.success(stream.toByteArray())
          } finally {
            bitmap.recycle()
          }
        }
      },
    )
  }

  fun start() {
    mapView.onCreate(null)
  }

  fun pause() {
    mapView.onPause()
  }

  fun resume() {
    mapView.onResume()
  }

  fun destroy() {
    amap.destroyView()
  }
}
