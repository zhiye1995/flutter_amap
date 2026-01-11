package com.morbit.amap_flutter

import android.content.Context
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.maps.LocationSource
import android.location.Location as AndroidLocation

class AMapLocationSource(context: Context) : LocationSource, AMapLocationListener {
  private val appContext = context.applicationContext

  /// 声明AMapLocationClient类对象
  private var locationClient: AMapLocationClient?
  private var locationOption: AMapLocationClientOption?
  private var locationChangedListener: LocationSource.OnLocationChangedListener? = null

  /**
   * 定位的一些初始化设置
   */
  init {
    /// 初始化定位
    locationClient = AMapLocationClient(context.applicationContext)
    locationOption = AMapLocationClientOption().apply {
      // 对齐官方 Demo：默认使用高精度，避免首定位过慢/不稳定
      locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
      // 这里不强制单次定位：因为 FOLLOW / ROTATE 等模式需要持续定位更新
      // interval = 2000L // 如需降低频率可开启（>=2000ms）
    }
    /// 设置定位回调监听
    locationClient?.setLocationListener(this)
    locationClient?.setLocationOption(locationOption)
  }

  override fun activate(onLocationChangedListener: LocationSource.OnLocationChangedListener?) {
    /// 保存地图返回的位置监听器
    locationChangedListener = onLocationChangedListener
    // 关键修复：deactivate() 可能销毁 client；这里必须能重建
    if (locationClient == null) {
      // 使用 applicationContext，避免泄漏 Activity
      locationClient = AMapLocationClient(appContext)
    }
    if (locationOption == null) {
      locationOption = AMapLocationClientOption().apply {
        locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
      }
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
    locationClient?.stopLocation()
    // 释放资源：地图内部可能在 onPause 等时机调用 deactivate()
    locationClient?.onDestroy()
    locationClient = null
  }

  /**
   * 腾讯定位SDK位置变化回调
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
    }
  }
}