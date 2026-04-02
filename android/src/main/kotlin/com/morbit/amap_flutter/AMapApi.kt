package com.morbit.amap_flutter

import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLngBounds

class AMapApi(private val amap: AMapFlutter, private val config: MapInitConfig?) {
  private val mapView = amap.view

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
      it.userLocationStyle?.toLocationStyle(amap.binding)?.let { style -> mapView.map.myLocationStyle = style }
      it.showUserLocation?.let { showLocation -> mapView.map.isMyLocationEnabled = showLocation }
    }
    config.customStyleOptions?.let { applyCustomStyle(it) }
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

  fun getUserLocation(): Location? {
    return mapView.map.myLocation?.toLocation()
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
    mapView.onDestroy()
  }
}
