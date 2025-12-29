package com.morbit.amap_flutter

import android.app.Activity
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

class AMapFlutterPlugin : FlutterPlugin, ActivityAware {
  private var lifecycle: Lifecycle? = null
  private var pluginBinding: FlutterPluginBinding? = null
  private var activity: Activity? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    pluginBinding = binding
    binding.platformViewRegistry.registerViewFactory(
      "amap_flutter",
      AMapFactory(binding) { lifecycle }
    )
    AMapSdkApi.setup(binding)
    // 导航 API 将在 Activity 可用后初始化
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    AMapNaviApi.dispose()
    pluginBinding = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    activity = binding.activity
    // 初始化导航 API
    pluginBinding?.let { AMapNaviApi.setup(it, activity) }
  }

  override fun onDetachedFromActivity() {
    lifecycle = null
    activity = null
    AMapNaviApi.updateActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
