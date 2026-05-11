 package com.morbit.amap_flutter

import android.content.Context
import android.util.Log
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItemV2
import com.amap.api.services.geocoder.GeocodeAddress
import com.amap.api.services.geocoder.GeocodeQuery
import com.amap.api.services.geocoder.GeocodeResult
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeAddress
import com.amap.api.services.geocoder.RegeocodeQuery
import com.amap.api.services.geocoder.RegeocodeResult
import com.amap.api.services.help.Inputtips
import com.amap.api.services.help.InputtipsQuery
import com.amap.api.services.help.Tip
import com.amap.api.services.poisearch.PoiResultV2
import com.amap.api.services.poisearch.PoiSearchV2
import com.amap.api.services.weather.LocalDayWeatherForecast
import com.amap.api.services.weather.LocalWeatherForecast
import com.amap.api.services.weather.LocalWeatherForecastResult
import com.amap.api.services.weather.LocalWeatherLive
import com.amap.api.services.weather.LocalWeatherLiveResult
import com.amap.api.services.weather.WeatherSearch
import com.amap.api.services.weather.WeatherSearchQuery
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

                "searchPOIAroundWithQuery" -> {
                    try {
                        searchPOIAroundWithQuery(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchPOIAroundWithQuery error", e)
                        result.error("SEARCH_ERROR", e.message, null)
                    }
                }

                "searchPOIKeywords" -> {
                    try {
                        searchPOIKeywords(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchPOIKeywords error", e)
                        result.error("SEARCH_ERROR", e.message, null)
                    }
                }

                "searchGeocode" -> {
                    try {
                        searchGeocode(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchGeocode error", e)
                        result.error("GEOCODE_ERROR", e.message, null)
                    }
                }

                "searchReGeocode" -> {
                    try {
                        searchReGeocode(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchReGeocode error", e)
                        result.error("GEOCODE_ERROR", e.message, null)
                    }
                }

                "searchWeatherLive" -> {
                    try {
                        searchWeatherLive(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchWeatherLive error", e)
                        result.error("WEATHER_ERROR", e.message, null)
                    }
                }

                "searchWeatherForecast" -> {
                    try {
                        searchWeatherForecast(context, call, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchWeatherForecast error", e)
                        result.error("WEATHER_ERROR", e.message, null)
                    }
                }

                "searchWeatherLiveByLocation" -> {
                    try {
                        searchWeatherLiveByLocation(context, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchWeatherLiveByLocation error", e)
                        result.error("WEATHER_ERROR", e.message, null)
                    }
                }

                "searchWeatherForecastByLocation" -> {
                    try {
                        searchWeatherForecastByLocation(context, result)
                    } catch (e: Exception) {
                        Log.e(TAG, "searchWeatherForecastByLocation error", e)
                        result.error("WEATHER_ERROR", e.message, null)
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

        /**
         * 结构化周边 POI 搜索
         */
        private fun searchPOIAroundWithQuery(context: Context, call: MethodCall, result: MethodChannel.Result) {
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
            val radius = call.argument<Int>("radius") ?: 1000
            val city = call.argument<String>("city") ?: ""
            val page = call.argument<Int>("page") ?: 1
            val pageSize = call.argument<Int>("pageSize") ?: 20
            val extensions = call.argument<String>("extensions") ?: "base"
            val children = call.argument<Boolean>("children") ?: false
            val sortByDistance = call.argument<Boolean>("sortByDistance") ?: true

            val centerPoint = LatLonPoint(latitude, longitude)
            val query = PoiSearchV2.Query(keywords, types, city)
            query.pageSize = pageSize
            query.pageNum = page
            query.setLocation(centerPoint)
            query.setDistanceSort(sortByDistance)
            query.trySetExtensions(extensions)
            query.tryRequireSubPois(children)

            val poiSearch = PoiSearchV2(context, query)
            poiSearch.bound = PoiSearchV2.SearchBound(centerPoint, radius, sortByDistance)
            poiSearch.setOnPoiSearchListener(object : PoiSearchV2.OnPoiSearchListener {
                override fun onPoiSearched(poiResult: PoiResultV2?, resultCode: Int) {
                    if (resultCode == 1000) {
                        val poiList = poiResult?.pois?.map { poi: PoiItemV2 ->
                            poi.toMap(centerPoint)
                        } ?: emptyList()
                        result.success(
                            mapOf(
                                "items" to poiList,
                                "page" to page,
                                "pageSize" to pageSize,
                                "total" to null,
                            ),
                        )
                    } else {
                        Log.e(TAG, "searchPOIAroundWithQuery failed: resultCode=$resultCode")
                        result.error("SEARCH_ERROR", "POI around search failed with code: $resultCode", null)
                    }
                }

                override fun onPoiItemSearched(poiItem: PoiItemV2?, resultCode: Int) {
                    // 单个 POI 详情搜索回调，这里不处理
                }
            })

            poiSearch.searchPOIAsyn()
        }

        /**
         * POI 关键字搜索
         */
        private fun searchPOIKeywords(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val keywords = call.argument<String>("keywords") ?: ""
            val types = call.argument<String>("types") ?: ""
            if (keywords.isEmpty() && types.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "keywords or types is required", null)
                return
            }

            val city = call.argument<String>("city") ?: ""
            val cityLimit = call.argument<Boolean>("cityLimit") ?: false
            val page = call.argument<Int>("page") ?: 1
            val pageSize = call.argument<Int>("pageSize") ?: 20
            val latitude = call.argument<Double>("latitude")
            val longitude = call.argument<Double>("longitude")
            val extensions = call.argument<String>("extensions") ?: "base"
            val children = call.argument<Boolean>("children") ?: false
            val sortByDistance = call.argument<Boolean>("sortByDistance") ?: false

            Log.i(
                TAG,
                "searchPOIKeywords: keywords=$keywords, types=$types, city=$city, " +
                    "cityLimit=$cityLimit, page=$page, pageSize=$pageSize",
            )

            val query = PoiSearchV2.Query(keywords, types, city)
            query.pageSize = pageSize
            query.pageNum = page
            query.setCityLimit(cityLimit)
            query.trySetExtensions(extensions)
            query.tryRequireSubPois(children)

            val searchCenter =
                if (latitude != null && longitude != null) {
                    LatLonPoint(latitude, longitude).also { point ->
                        query.setLocation(point)
                        query.setDistanceSort(sortByDistance)
                    }
                } else {
                    null
                }

            val poiSearch = PoiSearchV2(context, query)
            poiSearch.setOnPoiSearchListener(object : PoiSearchV2.OnPoiSearchListener {
                override fun onPoiSearched(poiResult: PoiResultV2?, resultCode: Int) {
                    if (resultCode == 1000) {
                        val poiList = poiResult?.pois?.map { poi: PoiItemV2 ->
                            poi.toMap(searchCenter)
                        } ?: emptyList()

                        result.success(
                            mapOf(
                                "items" to poiList,
                                "page" to page,
                                "pageSize" to pageSize,
                                "total" to null,
                            ),
                        )
                    } else {
                        Log.e(TAG, "searchPOIKeywords failed: resultCode=$resultCode")
                        result.error("SEARCH_ERROR", "POI keyword search failed with code: $resultCode", null)
                    }
                }

                override fun onPoiItemSearched(poiItem: PoiItemV2?, resultCode: Int) {
                    // 单个 POI 详情搜索回调，这里不处理
                }
            })

            poiSearch.searchPOIAsyn()
        }

        private fun PoiSearchV2.Query.trySetExtensions(extensions: String) {
            runCatching {
                javaClass.getMethod("setExtensions", String::class.java)
                    .invoke(this, extensions)
            }.onFailure {
                Log.i(TAG, "PoiSearchV2.Query.setExtensions is unavailable in current SDK")
            }
        }

        private fun PoiSearchV2.Query.tryRequireSubPois(children: Boolean) {
            runCatching {
                javaClass.getMethod("requireSubPois", Boolean::class.javaPrimitiveType)
                    .invoke(this, children)
            }.onFailure {
                Log.i(TAG, "PoiSearchV2.Query.requireSubPois is unavailable in current SDK")
            }
        }

        private fun PoiItemV2.toMap(center: LatLonPoint?): Map<String, Any?> {
            val distance = if (center != null) {
                latLonPoint?.let { point ->
                    val results = FloatArray(1)
                    android.location.Location.distanceBetween(
                        center.latitude, center.longitude,
                        point.latitude, point.longitude,
                        results,
                    )
                    results[0].toInt()
                }
            } else {
                null
            }

            return mapOf(
                "poiId" to (poiId ?: ""),
                "name" to (title ?: ""),
                "address" to snippet,
                "latitude" to latLonPoint?.latitude,
                "longitude" to latLonPoint?.longitude,
                "typeName" to typeDes,
                "typeCode" to typeCode,
                "cityName" to cityName,
                "cityCode" to cityCode,
                "adName" to adName,
                "adCode" to adCode,
                "distance" to distance,
                "tel" to null,
                "provinceName" to provinceName,
                "provinceCode" to provinceCode,
            )
        }

        private fun searchGeocode(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val address = call.argument<String>("address") ?: ""
            if (address.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "address is required", null)
                return
            }
            val city = call.argument<String>("city") ?: ""
            val search = GeocodeSearch(context)
            search.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
                override fun onGeocodeSearched(geocodeResult: GeocodeResult?, rCode: Int) {
                    if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                        result.success(
                            geocodeResult?.geocodeAddressList?.map { it.toMap() } ?: emptyList<Map<String, Any?>>()
                        )
                    } else {
                        result.error("GEOCODE_ERROR", "Geocode failed with code: $rCode", null)
                    }
                }

                override fun onRegeocodeSearched(regeocodeResult: RegeocodeResult?, rCode: Int) {
                    // Not used here.
                }
            })
            search.getFromLocationNameAsyn(GeocodeQuery(address, city))
        }

        private fun searchReGeocode(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val latitude = call.argument<Double>("latitude") ?: run {
                result.error("INVALID_ARGUMENTS", "latitude is required", null)
                return
            }
            val longitude = call.argument<Double>("longitude") ?: run {
                result.error("INVALID_ARGUMENTS", "longitude is required", null)
                return
            }
            val radius = (call.argument<Int>("radius") ?: 1000).toFloat()
            val extensions = call.argument<String>("extensions") ?: "base"
            val coordinateType = call.argument<String>("coordinateType") ?: "amap"
            val latLonType = if (coordinateType == "gps") GeocodeSearch.GPS else GeocodeSearch.AMAP
            val search = GeocodeSearch(context)
            search.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
                override fun onGeocodeSearched(geocodeResult: GeocodeResult?, rCode: Int) {
                    // Not used here.
                }

                override fun onRegeocodeSearched(regeocodeResult: RegeocodeResult?, rCode: Int) {
                    if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                        result.success(regeocodeResult?.regeocodeAddress?.toMap(latitude, longitude))
                    } else {
                        result.error("GEOCODE_ERROR", "ReGeocode failed with code: $rCode", null)
                    }
                }
            })
            val query = RegeocodeQuery(LatLonPoint(latitude, longitude), radius, latLonType)
            query.extensions = if (extensions == "all") {
                GeocodeSearch.EXTENSIONS_ALL
            } else {
                GeocodeSearch.EXTENSIONS_BASE
            }
            search.getFromLocationAsyn(query)
        }

        private fun GeocodeAddress.toMap(): Map<String, Any?> {
            val point = latLonPoint
            return mapOf(
                "formattedAddress" to formatAddress,
                "latitude" to point?.latitude,
                "longitude" to point?.longitude,
                "province" to province,
                "city" to city,
                "district" to district,
                "township" to township,
                "neighborhood" to neighborhood,
                "building" to building,
                "adCode" to adcode,
                "cityCode" to readStringMember(this, "cityCode", "citycode"),
                "level" to level,
                "raw" to mapOf(
                    "platform" to "android",
                    "sdkString" to toString()
                )
            )
        }

        private fun RegeocodeAddress.toMap(latitude: Double, longitude: Double): Map<String, Any?> {
            return mapOf(
                "formattedAddress" to formatAddress,
                "latitude" to latitude,
                "longitude" to longitude,
                "province" to province,
                "city" to city,
                "district" to district,
                "township" to township,
                "townCode" to towncode,
                "neighborhood" to neighborhood,
                "building" to building,
                "adCode" to adCode,
                "cityCode" to cityCode,
                "country" to country,
                "countryCode" to countryCode,
                "roads" to (roads?.mapNotNull { it.name } ?: emptyList()),
                "crosses" to (crossroads?.mapNotNull { it.name } ?: emptyList()),
                "pois" to (pois?.map { poi ->
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
                        "distance" to null,
                        "tel" to null,
                        "provinceName" to poi.provinceName,
                        "provinceCode" to poi.provinceCode
                    )
                } ?: emptyList()),
                "aois" to (aois?.mapNotNull { it.aoiName } ?: emptyList()),
                "raw" to mapOf(
                    "platform" to "android",
                    "sdkString" to toString()
                )
            )
        }

        private fun readStringMember(target: Any, vararg names: String): String? {
            for (name in names) {
                val cap = name.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
                for (methodName in listOf(name, "get$cap")) {
                    runCatching {
                        val method = target.javaClass.methods.firstOrNull {
                            it.name == methodName && it.parameterCount == 0
                        }
                        val value = method?.invoke(target)
                        if (value != null) return value.toString()
                    }
                }
                runCatching {
                    val field = target.javaClass.declaredFields.firstOrNull { it.name == name }
                    if (field != null) {
                        field.isAccessible = true
                        val value = field.get(target)
                        if (value != null) return value.toString()
                    }
                }
            }
            return null
        }

        /**
         * 查询实时天气
         */
        private fun searchWeatherLive(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val city = call.argument<String>("city") ?: run {
                result.error("INVALID_ARGUMENTS", "city is required", null)
                return
            }

            Log.i(TAG, "searchWeatherLive: city=$city")

            try {
                // 创建天气查询条件，WEATHER_TYPE_LIVE = 1 表示实时天气
                val query = WeatherSearchQuery(city, WeatherSearchQuery.WEATHER_TYPE_LIVE)
                val weatherSearch = WeatherSearch(context)
                
                weatherSearch.setOnWeatherSearchListener(object : WeatherSearch.OnWeatherSearchListener {
                    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult?, rCode: Int) {
                        if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                            val liveResult = weatherLiveResult?.liveResult
                            if (liveResult != null) {
                                val weatherData = mapOf(
                                    "province" to liveResult.province,
                                    "city" to liveResult.city,
                                    "adCode" to liveResult.adCode,
                                    "weather" to liveResult.weather,
                                    "temperature" to liveResult.temperature,
                                    "windDirection" to liveResult.windDirection,
                                    "windPower" to liveResult.windPower,
                                    "humidity" to liveResult.humidity,
                                    "reportTime" to liveResult.reportTime
                                )
                                Log.i(TAG, "searchWeatherLive success: $weatherData")
                                result.success(weatherData)
                            } else {
                                Log.e(TAG, "searchWeatherLive: no result")
                                result.error("WEATHER_ERROR", "No weather data returned", null)
                            }
                        } else {
                            Log.e(TAG, "searchWeatherLive failed: rCode=$rCode")
                            result.error("WEATHER_ERROR", "Weather search failed with code: $rCode", null)
                        }
                    }

                    override fun onWeatherForecastSearched(weatherForecastResult: LocalWeatherForecastResult?, rCode: Int) {
                        // 实时天气查询不会调用此回调
                    }
                })

                weatherSearch.query = query
                weatherSearch.searchWeatherAsyn()
            } catch (e: AMapException) {
                Log.e(TAG, "searchWeatherLive AMapException", e)
                result.error("WEATHER_ERROR", e.message, null)
            }
        }

        /**
         * 查询天气预报
         */
        private fun searchWeatherForecast(context: Context, call: MethodCall, result: MethodChannel.Result) {
            val city = call.argument<String>("city") ?: run {
                result.error("INVALID_ARGUMENTS", "city is required", null)
                return
            }

            Log.i(TAG, "searchWeatherForecast: city=$city")

            try {
                // 创建天气查询条件，WEATHER_TYPE_FORECAST = 2 表示预报天气
                val query = WeatherSearchQuery(city, WeatherSearchQuery.WEATHER_TYPE_FORECAST)
                val weatherSearch = WeatherSearch(context)
                
                weatherSearch.setOnWeatherSearchListener(object : WeatherSearch.OnWeatherSearchListener {
                    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult?, rCode: Int) {
                        // 预报天气查询不会调用此回调
                    }

                    override fun onWeatherForecastSearched(weatherForecastResult: LocalWeatherForecastResult?, rCode: Int) {
                        if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                            val forecastResult = weatherForecastResult?.forecastResult
                            if (forecastResult != null) {
                                // 构建每日预报列表
                                val casts = forecastResult.weatherForecast?.map { dayForecast: LocalDayWeatherForecast ->
                                    mapOf(
                                        "date" to dayForecast.date,
                                        "week" to dayForecast.week,
                                        "dayWeather" to dayForecast.dayWeather,
                                        "nightWeather" to dayForecast.nightWeather,
                                        "dayTemp" to dayForecast.dayTemp,
                                        "nightTemp" to dayForecast.nightTemp,
                                        "dayWind" to dayForecast.dayWindDirection,
                                        "nightWind" to dayForecast.nightWindDirection,
                                        "dayPower" to dayForecast.dayWindPower,
                                        "nightPower" to dayForecast.nightWindPower
                                    )
                                } ?: emptyList()

                                val forecastData = mapOf(
                                    "city" to forecastResult.city,
                                    "adCode" to forecastResult.adCode,
                                    "province" to forecastResult.province,
                                    "reportTime" to forecastResult.reportTime,
                                    "casts" to casts
                                )
                                Log.i(TAG, "searchWeatherForecast success: ${casts.size} days")
                                result.success(forecastData)
                            } else {
                                Log.e(TAG, "searchWeatherForecast: no result")
                                result.error("WEATHER_ERROR", "No weather forecast data returned", null)
                            }
                        } else {
                            Log.e(TAG, "searchWeatherForecast failed: rCode=$rCode")
                            result.error("WEATHER_ERROR", "Weather forecast search failed with code: $rCode", null)
                        }
                    }
                })

                weatherSearch.query = query
                weatherSearch.searchWeatherAsyn()
            } catch (e: AMapException) {
                Log.e(TAG, "searchWeatherForecast AMapException", e)
                result.error("WEATHER_ERROR", e.message, null)
            }
        }

        /**
         * 根据当前定位查询实时天气
         */
        private fun searchWeatherLiveByLocation(context: Context, result: MethodChannel.Result) {
            Log.i(TAG, "searchWeatherLiveByLocation")

            try {
                val locationClient = AMapLocationClient(context)
                val option = AMapLocationClientOption()
                option.isOnceLocation = true  // 单次定位
                option.isNeedAddress = true   // 需要地址信息（包含adcode）
                option.locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                locationClient.setLocationOption(option)

                locationClient.setLocationListener { location ->
                    locationClient.stopLocation()
                    locationClient.onDestroy()

                    if (location.errorCode == 0) {
                        val adCode = location.adCode
                        if (!adCode.isNullOrEmpty()) {
                            Log.i(TAG, "searchWeatherLiveByLocation: got adCode=$adCode")
                            // 用adcode查询天气
                            searchWeatherLiveInternal(context, adCode, result)
                        } else {
                            Log.e(TAG, "searchWeatherLiveByLocation: adCode is empty")
                            result.error("LOCATION_ERROR", "无法获取区域编码", null)
                        }
                    } else {
                        Log.e(TAG, "searchWeatherLiveByLocation: location error ${location.errorCode}: ${location.errorInfo}")
                        result.error("LOCATION_ERROR", location.errorInfo, location.errorCode)
                    }
                }
                locationClient.startLocation()
            } catch (e: Exception) {
                Log.e(TAG, "searchWeatherLiveByLocation Exception", e)
                result.error("LOCATION_ERROR", e.message, null)
            }
        }

        /**
         * 根据当前定位查询天气预报
         */
        private fun searchWeatherForecastByLocation(context: Context, result: MethodChannel.Result) {
            Log.i(TAG, "searchWeatherForecastByLocation")

            try {
                val locationClient = AMapLocationClient(context)
                val option = AMapLocationClientOption()
                option.isOnceLocation = true  // 单次定位
                option.isNeedAddress = true   // 需要地址信息（包含adcode）
                option.locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                locationClient.setLocationOption(option)

                locationClient.setLocationListener { location ->
                    locationClient.stopLocation()
                    locationClient.onDestroy()

                    if (location.errorCode == 0) {
                        val adCode = location.adCode
                        if (!adCode.isNullOrEmpty()) {
                            Log.i(TAG, "searchWeatherForecastByLocation: got adCode=$adCode")
                            // 用adcode查询天气预报
                            searchWeatherForecastInternal(context, adCode, result)
                        } else {
                            Log.e(TAG, "searchWeatherForecastByLocation: adCode is empty")
                            result.error("LOCATION_ERROR", "无法获取区域编码", null)
                        }
                    } else {
                        Log.e(TAG, "searchWeatherForecastByLocation: location error ${location.errorCode}: ${location.errorInfo}")
                        result.error("LOCATION_ERROR", location.errorInfo, location.errorCode)
                    }
                }
                locationClient.startLocation()
            } catch (e: Exception) {
                Log.e(TAG, "searchWeatherForecastByLocation Exception", e)
                result.error("LOCATION_ERROR", e.message, null)
            }
        }

        /**
         * 内部方法：查询实时天气（供定位回调使用）
         */
        private fun searchWeatherLiveInternal(context: Context, city: String, result: MethodChannel.Result) {
            try {
                val query = WeatherSearchQuery(city, WeatherSearchQuery.WEATHER_TYPE_LIVE)
                val weatherSearch = WeatherSearch(context)

                weatherSearch.setOnWeatherSearchListener(object : WeatherSearch.OnWeatherSearchListener {
                    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult?, rCode: Int) {
                        if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                            val liveResult = weatherLiveResult?.liveResult
                            if (liveResult != null) {
                                val weatherData = mapOf(
                                    "province" to liveResult.province,
                                    "city" to liveResult.city,
                                    "adCode" to liveResult.adCode,
                                    "weather" to liveResult.weather,
                                    "temperature" to liveResult.temperature,
                                    "windDirection" to liveResult.windDirection,
                                    "windPower" to liveResult.windPower,
                                    "humidity" to liveResult.humidity,
                                    "reportTime" to liveResult.reportTime
                                )
                                Log.i(TAG, "searchWeatherLiveInternal success: $weatherData")
                                result.success(weatherData)
                            } else {
                                Log.e(TAG, "searchWeatherLiveInternal: no result")
                                result.error("WEATHER_ERROR", "No weather data returned", null)
                            }
                        } else {
                            Log.e(TAG, "searchWeatherLiveInternal failed: rCode=$rCode")
                            result.error("WEATHER_ERROR", "Weather search failed with code: $rCode", null)
                        }
                    }

                    override fun onWeatherForecastSearched(weatherForecastResult: LocalWeatherForecastResult?, rCode: Int) {
                        // 实时天气查询不会调用此回调
                    }
                })

                weatherSearch.query = query
                weatherSearch.searchWeatherAsyn()
            } catch (e: AMapException) {
                Log.e(TAG, "searchWeatherLiveInternal AMapException", e)
                result.error("WEATHER_ERROR", e.message, null)
            }
        }

        /**
         * 内部方法：查询天气预报（供定位回调使用）
         */
        private fun searchWeatherForecastInternal(context: Context, city: String, result: MethodChannel.Result) {
            try {
                val query = WeatherSearchQuery(city, WeatherSearchQuery.WEATHER_TYPE_FORECAST)
                val weatherSearch = WeatherSearch(context)

                weatherSearch.setOnWeatherSearchListener(object : WeatherSearch.OnWeatherSearchListener {
                    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult?, rCode: Int) {
                        // 预报天气查询不会调用此回调
                    }

                    override fun onWeatherForecastSearched(weatherForecastResult: LocalWeatherForecastResult?, rCode: Int) {
                        if (rCode == AMapException.CODE_AMAP_SUCCESS) {
                            val forecastResult = weatherForecastResult?.forecastResult
                            if (forecastResult != null) {
                                val casts = forecastResult.weatherForecast?.map { dayForecast: LocalDayWeatherForecast ->
                                    mapOf(
                                        "date" to dayForecast.date,
                                        "week" to dayForecast.week,
                                        "dayWeather" to dayForecast.dayWeather,
                                        "nightWeather" to dayForecast.nightWeather,
                                        "dayTemp" to dayForecast.dayTemp,
                                        "nightTemp" to dayForecast.nightTemp,
                                        "dayWind" to dayForecast.dayWindDirection,
                                        "nightWind" to dayForecast.nightWindDirection,
                                        "dayPower" to dayForecast.dayWindPower,
                                        "nightPower" to dayForecast.nightWindPower
                                    )
                                } ?: emptyList()

                                val forecastData = mapOf(
                                    "city" to forecastResult.city,
                                    "adCode" to forecastResult.adCode,
                                    "province" to forecastResult.province,
                                    "reportTime" to forecastResult.reportTime,
                                    "casts" to casts
                                )
                                Log.i(TAG, "searchWeatherForecastInternal success: ${casts.size} days")
                                result.success(forecastData)
                            } else {
                                Log.e(TAG, "searchWeatherForecastInternal: no result")
                                result.error("WEATHER_ERROR", "No weather forecast data returned", null)
                            }
                        } else {
                            Log.e(TAG, "searchWeatherForecastInternal failed: rCode=$rCode")
                            result.error("WEATHER_ERROR", "Weather forecast search failed with code: $rCode", null)
                        }
                    }
                })

                weatherSearch.query = query
                weatherSearch.searchWeatherAsyn()
            } catch (e: AMapException) {
                Log.e(TAG, "searchWeatherForecastInternal AMapException", e)
                result.error("WEATHER_ERROR", e.message, null)
            }
        }
    }
}

