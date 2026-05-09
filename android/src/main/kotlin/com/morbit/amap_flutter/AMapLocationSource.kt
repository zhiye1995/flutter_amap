package com.morbit.amap_flutter

import android.content.Context
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.maps.LocationSource
import android.location.Location as AndroidLocation

class AMapLocationSource(context: Context) : LocationSource, AMapLocationListener {
  companion object {
    private const val DEFAULT_LOCATION_INTERVAL_MS = 1000L
  }

  private val appContext = context.applicationContext

  /// 声明AMapLocationClient类对象
  private var locationClient: AMapLocationClient?
  private var locationOption: AMapLocationClientOption?
  private var locationChangedListener: LocationSource.OnLocationChangedListener? = null
  private var locationType: UserLocationType = UserLocationType.LOCATION_TYPE_LOCATION_ROTATE
  private var isActive = false

  /**
   * 定位的一些初始化设置
   */
  init {
    /// 初始化定位
    locationClient = AMapLocationClient(context.applicationContext)
    locationOption = buildLocationOption()
    /// 设置定位回调监听
    locationClient?.setLocationListener(this)
    locationClient?.setLocationOption(locationOption)
  }

  fun setLocationType(type: UserLocationType?) {
    val nextType = type ?: UserLocationType.LOCATION_TYPE_LOCATION_ROTATE
    if (locationType == nextType && locationOption != null) {
      return
    }
    locationType = nextType
    locationOption = buildLocationOption()
    locationClient?.setLocationOption(locationOption)
    if (isActive) {
      locationClient?.stopLocation()
      locationClient?.startLocation()
    }
  }

  private fun buildLocationOption(): AMapLocationClientOption {
    return AMapLocationClientOption().apply {
      // 对齐官方 MyLocationStyle：默认高精度、连续定位间隔 1000ms；
      // SHOW / LOCATE 在插件公开语义中为单次模式。
      locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
      interval = DEFAULT_LOCATION_INTERVAL_MS
      isOnceLocation = locationType.isOnceLocationMode()
    }
  }

  override fun activate(onLocationChangedListener: LocationSource.OnLocationChangedListener?) {
    /// 保存地图返回的位置监听器
    locationChangedListener = onLocationChangedListener
    isActive = true
    // 关键修复：deactivate() 可能销毁 client；这里必须能重建
    if (locationClient == null) {
      // 使用 applicationContext，避免泄漏 Activity
      locationClient = AMapLocationClient(appContext)
    }
    if (locationOption == null) {
      locationOption = buildLocationOption()
    }
    locationClient?.setLocationListener(this)
    locationClient?.setLocationOption(locationOption)
    /// 启动定位
    locationClient?.stopLocation()
    locationClient?.startLocation()
  }

  override fun deactivate() {
    //当不需要展示定位点时，需要停止定位并释放相关资源
    locationChangedListener = null
    isActive = false
    locationClient?.stopLocation()
    // 释放资源：地图内部可能在 onPause 等时机调用 deactivate()
    locationClient?.onDestroy()
    locationClient = null
  }

  /**
   * 高德定位SDK位置变化回调
   */
  override fun onLocationChanged(amapLocation: AMapLocation?) {
    if (amapLocation != null && amapLocation.errorCode == 0) {
      //可在其中解析amapLocation获取相应内容。
      val location = AndroidLocation(amapLocation.provider)
      location.latitude = amapLocation.latitude
      location.longitude = amapLocation.longitude
      location.bearing = amapLocation.bearing
      location.accuracy = amapLocation.accuracy
      locationChangedListener?.onLocationChanged(location)
      if (locationType.isOnceLocationMode()) {
        locationClient?.stopLocation()
      }
    }
  }
}
