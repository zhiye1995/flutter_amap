package com.morbit.amap_flutter

import android.graphics.Bitmap
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker as AMapMarker
import com.amap.api.maps.model.animation.AlphaAnimation
import com.amap.api.maps.model.animation.Animation
import com.amap.api.maps.model.animation.RotateAnimation
import com.amap.api.maps.model.animation.ScaleAnimation
import com.amap.api.maps.model.animation.TranslateAnimation
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class AMapApi(private val amap: AMapFlutter, private val config: MapInitConfig?) {
  private val mapView = amap.getView()

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
      marker.remove()
      amap.markers.remove(id)
      amap.aMapMarkerIdToDartMarkerId.remove(marker.id)
    }
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

  /// 与高德 [Marker.setAnimation] / [Marker.startAnimation] 对齐；[kind] 与 Dart [MarkerAnimationKind.index] 一致。
  fun animateMarker(markerId: String, kind: Int, durationMs: Int) {
    val marker: AMapMarker = amap.markers[markerId] ?: return
    marker.setAnimation(null)
    val dur = durationMs.toLong().coerceIn(200L, 10_000L)
    if (kind == 4) {
      startMarkerMoveRoundTrip(marker, dur)
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

  /// 官方 Demo「移动」：`TranslateAnimation(LatLng)` 去程 + 返程，结束后 [Marker.setPosition] 回到起点。
  private fun startMarkerMoveRoundTrip(marker: AMapMarker, durMs: Long) {
    val start = marker.position
    val target =
      LatLng(
        start.latitude + 0.00015,
        start.longitude + 0.00012,
      )
    val half = durMs.coerceAtLeast(400L) / 2
    val outward =
      TranslateAnimation(target).apply {
        setDuration(half)
        setAnimationListener(
          object : Animation.AnimationListener {
            override fun onAnimationStart() {}

            override fun onAnimationEnd() {
              val inward =
                TranslateAnimation(start).apply {
                  setDuration(half)
                  setAnimationListener(
                    object : Animation.AnimationListener {
                      override fun onAnimationStart() {}

                      override fun onAnimationEnd() {
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
