package com.morbit.amap_flutter

import android.content.Context
import android.util.Log
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.help.Inputtips
import com.amap.api.services.help.InputtipsQuery
import com.amap.api.services.help.Tip
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 高德搜索 API 处理类
 */
class AMapSearchApi {
    companion object {
        private const val TAG = "AMapSearchApi"
        private const val SEARCH_METHOD_CHANNEL = "plugins.flutter.dev/amap_search"

        private var methodChannel: MethodChannel? = null

        fun setup(binding: FlutterPluginBinding) {
            // 设置 MethodChannel
            methodChannel = MethodChannel(binding.binaryMessenger, SEARCH_METHOD_CHANNEL)
            methodChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                handleMethodCall(binding.applicationContext, call, result)
            }
        }

        fun dispose() {
            methodChannel?.setMethodCallHandler(null)
            methodChannel = null
        }

        private fun handleMethodCall(context: Context, call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "requestInputTips" -> {
                    try {
                        requestInputTips(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "requestInputTips error", e)
                        result.error("SEARCH_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        private fun requestInputTips(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val keywords = call.argument<String>("keywords") ?: ""
            val city = call.argument<String>("city") ?: ""
            val cityLimit = call.argument<Boolean>("cityLimit") ?: false
            val types = call.argument<String>("types")
            val latitude = call.argument<Double>("latitude")
            val longitude = call.argument<Double>("longitude")

            Log.i(TAG, "requestInputTips: keywords=$keywords, city=$city, cityLimit=$cityLimit, types=$types")

            // 创建输入提示查询
            val inputQuery = InputtipsQuery(keywords, city)
            inputQuery.cityLimit = cityLimit
            
            // 设置POI类型限制（如果有）
            if (!types.isNullOrEmpty()) {
                inputQuery.type = types
            }

            // 设置搜索中心点（如果有）
            if (latitude != null && longitude != null) {
                inputQuery.location = LatLonPoint(latitude, longitude)
            }

            // 创建 Inputtips 对象并设置监听器
            val inputTips = Inputtips(context, inputQuery)
            inputTips.setInputtipsListener(object : Inputtips.InputtipsListener {
                override fun onGetInputtips(tips: MutableList<Tip>?, resultCode: Int) {
                    if (resultCode == 1000) {
                        // 成功
                        val tipList = tips?.map { tip ->
                            mapOf(
                                "name" to (tip.name ?: ""),
                                "address" to tip.address,
                                "poiId" to tip.poiID,
                                "district" to tip.district,
                                "adcode" to tip.adcode,
                                "typeCode" to tip.typeCode,
                                "latitude" to tip.point?.latitude,
                                "longitude" to tip.point?.longitude
                            )
                        } ?: emptyList()

                        Log.i(TAG, "onGetInputtips success: ${tipList.size} tips")
                        result.success(tipList)
                    } else {
                        // 失败
                        Log.e(TAG, "onGetInputtips failed: resultCode=$resultCode")
                        result.error("SEARCH_ERROR", "Input tips search failed with code: $resultCode", null)
                    }
                }
            })

            // 异步请求输入提示
            inputTips.requestInputtipsAsyn()
        }
    }
}

