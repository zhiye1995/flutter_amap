package com.morbit.amap_flutter

import android.content.Context
import android.util.Log
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItemV2
import com.amap.api.services.help.Inputtips
import com.amap.api.services.help.InputtipsQuery
import com.amap.api.services.help.Tip
import com.amap.api.services.poisearch.PoiResultV2
import com.amap.api.services.poisearch.PoiSearchV2
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

                "searchPOIAround" -> {
                    try {
                        searchPOIAround(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchPOIAround error", e)
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

        /**
         * 周边 POI 搜索
         */
        private fun searchPOIAround(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val latitude = call.argument<Double>("latitude") ?: run {
                result.error("INVALID_ARGUMENTS", "latitude is required", null)
                return
            }
            val longitude = call.argument<Double>("longitude") ?: run {
                result.error("INVALID_ARGUMENTS", "longitude is required", null)
                return
            }
            val keywords = call.argument<String>("keywords") ?: ""
            val types = call.argument<String>("types") ?: ""
            val radius = call.argument<Int>("radius")
            val page = call.argument<Int>("page") ?: 1
            val pageSize = call.argument<Int>("pageSize") ?: 20
            val city = call.argument<String>("city") ?: ""

            Log.i(TAG, "searchPOIAround: lat=$latitude, lng=$longitude, keywords=$keywords, types=$types, radius=$radius")

            // 创建查询条件
            // 第一个参数表示搜索字符串，第二个参数表示POI类型，第三个参数表示城市
            val query = PoiSearchV2.Query(keywords, types, city)
            query.pageSize = pageSize
            query.pageNum = page

            // 创建 POI 搜索对象
            val poiSearch = PoiSearchV2(context, query)

            // 设置周边搜索的中心点和半径
            val centerPoint = LatLonPoint(latitude, longitude)
            if (radius != null) {
                poiSearch.bound = PoiSearchV2.SearchBound(centerPoint, radius)
            } else {
//                poiSearch.bound = PoiSearchV2.SearchBound(centerPoint)
            }

            // 设置搜索回调
            poiSearch.setOnPoiSearchListener(object : PoiSearchV2.OnPoiSearchListener {
                override fun onPoiSearched(poiResult: PoiResultV2?, resultCode: Int) {
                    if (resultCode == 1000) {
                        // 成功
                        val poiItems = poiResult?.pois
                        val poiList = poiItems?.map { poi: PoiItemV2 ->
                            // 计算距离（如果有坐标）
                            val distance = poi.latLonPoint?.let { point ->
                                val results = FloatArray(1)
                                android.location.Location.distanceBetween(
                                    latitude, longitude,
                                    point.latitude, point.longitude,
                                    results
                                )
                                results[0].toInt()
                            }

                            mapOf(
                                "poiId" to (poi.poiId ?: ""),
                                "name" to (poi.title ?: ""),
                                "address" to poi.snippet,
                                "latitude" to poi.latLonPoint?.latitude,
                                "longitude" to poi.latLonPoint?.longitude,
                                "typeName" to poi.typeDes,
                                "typeCode" to poi.typeCode,
                                "cityName" to poi.cityName,
                                "cityCode" to poi.cityCode,
                                "adName" to poi.adName,
                                "adCode" to poi.adCode,
                                "distance" to distance,
                                "tel" to null,  // PoiItemV2 不包含电话字段
                                "provinceName" to poi.provinceName,
                                "provinceCode" to poi.provinceCode
                            )
                        } ?: emptyList()

                        Log.i(TAG, "onPoiSearched success: ${poiList.size} POIs")
                        result.success(poiList)
                    } else {
                        Log.e(TAG, "onPoiSearched failed: resultCode=$resultCode")
                        result.error("SEARCH_ERROR", "POI search failed with code: $resultCode", null)
                    }
                }

                override fun onPoiItemSearched(poiItem: PoiItemV2?, resultCode: Int) {
                    // 单个 POI 详情搜索回调，这里不处理
                }
            })

            // 发起异步搜索
            poiSearch.searchPOIAsyn()
        }
    }
}

