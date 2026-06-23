package com.morbit.amap_flutter

import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

class AMapFlutterPlugin : FlutterPlugin, ActivityAware {
  private var lifecycle: Lifecycle? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    binding.platformViewRegistry.registerViewFactory(
      "amap_flutter",
      AMapFactory(binding) { lifecycle },
    )
    AMapSdkApi.setup(binding)
    AMapSearchApi.setup(binding)
    AMapNaviApi.setup(binding, null)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    AMapNaviApi.dispose()
    AMapSearchApi.dispose()
    lifecycle = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    AMapNaviApi.updateActivity(binding.activity)
  }

  override fun onDetachedFromActivity() {
    lifecycle = null
    AMapNaviApi.updateActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
