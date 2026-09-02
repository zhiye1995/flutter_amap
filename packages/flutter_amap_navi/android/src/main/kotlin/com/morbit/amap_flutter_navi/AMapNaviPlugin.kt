package com.morbit.amap_flutter_navi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class AMapNaviPlugin : FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        AMapNaviSdkApi.setup(binding)
        AMapNaviApi.setup(binding, null)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        AMapNaviApi.dispose()
        AMapNaviSdkApi.dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AMapNaviApi.updateActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        AMapNaviApi.updateActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}
