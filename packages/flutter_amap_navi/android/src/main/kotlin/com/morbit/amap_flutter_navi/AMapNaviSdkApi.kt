package com.morbit.amap_flutter_navi

import com.amap.api.maps.MapsInitializer
import com.amap.api.navi.AMapNavi
import com.amap.api.navi.NaviSetting
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodChannel

object AMapNaviSdkApi {
    private const val CHANNEL = "plugins.flutter.dev/amap_navi_initializer"
    private var methodChannel: MethodChannel? = null

    fun setup(binding: FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        val apiKey = call.argument<String>("androidKey").orEmpty()
                        val agreePrivacy = call.argument<Boolean>("agreePrivacy") ?: false
                        MapsInitializer.setApiKey(apiKey)
                        MapsInitializer.updatePrivacyShow(
                            binding.applicationContext,
                            agreePrivacy,
                            agreePrivacy,
                        )
                        MapsInitializer.updatePrivacyAgree(binding.applicationContext, agreePrivacy)
                        NaviSetting.updatePrivacyShow(
                            binding.applicationContext,
                            agreePrivacy,
                            agreePrivacy,
                        )
                        NaviSetting.updatePrivacyAgree(binding.applicationContext, agreePrivacy)
                        result.success(null)
                    }
                    "getSdkVersion" -> result.success(AMapNavi.getVersion())
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }
}
