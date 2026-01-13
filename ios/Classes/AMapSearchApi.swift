import Flutter
import UIKit
import AMapSearchKit
import AMapFoundationKit
import AMapLocationKit

/// 高德搜索 API 处理类
class AMapSearchApi: NSObject {
    
    private static let SEARCH_METHOD_CHANNEL = "plugins.flutter.dev/amap_search"
    /// 静态实例，防止被 ARC 释放
    private static var shared: AMapSearchApi?

    private var methodChannel: FlutterMethodChannel?
    private var searchAPI: AMapSearchAPI?
    private var locationManager: AMapLocationManager?
    
    /// 存储当前搜索回调
    private var inputTipsResult: FlutterResult?
    private var poiAroundResult: FlutterResult?
    private var weatherLiveResult: FlutterResult?
    private var weatherForecastResult: FlutterResult?
    private var weatherLiveByLocationResult: FlutterResult?
    private var weatherForecastByLocationResult: FlutterResult?

    // MARK: - Setup
    
    static func setup(registrar: FlutterPluginRegistrar) {
        let instance = AMapSearchApi()
        // 保持静态引用
        shared = instance
        // 设置 MethodChannel
        instance.methodChannel = FlutterMethodChannel(
            name: SEARCH_METHOD_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        instance.methodChannel?.setMethodCallHandler { (call, result) in
            instance.handleMethodCall(call: call, result: result)
        }
    }
    
    /// 懒加载/确保 SearchAPI 已初始化
    /// 注意：必须在隐私合规设置完成后初始化，否则可能导致功能不可用
    private func ensureSearchAPI() {
        if searchAPI == nil {
            searchAPI = AMapSearchAPI()
            searchAPI?.delegate = self
        }
    }

    // MARK: - Method Call Handler
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // 确保 API 已初始化
        ensureSearchAPI()
        
        switch call.method {
        case "requestInputTips":
            requestInputTips(call: call, result: result)
        case "searchPOIAround":
            searchPOIAround(call: call, result: result)
        case "searchWeatherLive":
            searchWeatherLive(call: call, result: result)
        case "searchWeatherForecast":
            searchWeatherForecast(call: call, result: result)
        case "searchWeatherLiveByLocation":
            searchWeatherLiveByLocation(result: result)
        case "searchWeatherForecastByLocation":
            searchWeatherForecastByLocation(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Input Tips
    
    private func requestInputTips(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        let keywords = arguments["keywords"] as? String ?? ""
        let city = arguments["city"] as? String
        let cityLimit = arguments["cityLimit"] as? Bool ?? false
        let types = arguments["types"] as? String
        let latitude = arguments["latitude"] as? Double
        let longitude = arguments["longitude"] as? Double
        
        print("[AMapSearchApi] requestInputTips: keywords=\(keywords), city=\(city ?? "nil"), cityLimit=\(cityLimit)")
        
        // 创建输入提示请求
        let request = AMapInputTipsSearchRequest()
        request.keywords = keywords
        
        if let city = city, !city.isEmpty {
            request.city = city
        }
        
        request.cityLimit = cityLimit
        
        if let types = types, !types.isEmpty {
            request.types = types
        }
        
        // 设置搜索中心点（如果有）
        if let lat = latitude, let lng = longitude {
            request.location = "\(lng),\(lat)"
        }
        
        // 保存回调
        self.inputTipsResult = result
        
        // 发起搜索
        searchAPI?.aMapInputTipsSearch(request)
    }
    
    // MARK: - POI Around Search
    
    private func searchPOIAround(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        guard let latitude = arguments["latitude"] as? Double,
              let longitude = arguments["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "latitude and longitude are required", details: nil))
            return
        }
        
        let keywords = arguments["keywords"] as? String
        let types = arguments["types"] as? String
        let radius = arguments["radius"] as? Int
        let page = arguments["page"] as? Int ?? 1
        let pageSize = arguments["pageSize"] as? Int ?? 20
        let city = arguments["city"] as? String
        
        // 保存回调
        self.poiAroundResult = result
        
        // 根据参数选择搜索方式：
        // - 无 radius + 有 keywords → 关键字检索 (AMapPOIKeywordsSearchRequest)
        // - 有 radius → 周边 POI 检索 (AMapPOIAroundSearchRequest)
        let hasKeywords = keywords != nil && !keywords!.isEmpty
        
        if  hasKeywords {
            // 使用关键字检索
            print("[AMapSearchApi] searchPOIKeywords: lat=\(latitude), lng=\(longitude), keywords=\(keywords ?? "")")
            
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = keywords
            // 设置 location 用于按距离排序（sortrule=0 时生效）
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            request.page = page
            request.offset = pageSize
            request.sortrule = 0  // 按距离排序
            
            if let types = types, !types.isEmpty {
                request.types = types
            }
            
            if let city = city, !city.isEmpty {
                request.city = city
            }
            
            // 发起关键字搜索
            searchAPI?.aMapPOIKeywordsSearch(request)
        } else {
            // 使用周边 POI 检索
            // AMapPOIAroundSearchRequest radius 查询半径，范围：0-50000，单位：米 [default = 3000]
            print("[AMapSearchApi] searchPOIAround: lat=\(latitude), lng=\(longitude), keywords=\(keywords ?? ""), radius=\(String(describing: radius))")
            
            let request = AMapPOIAroundSearchRequest()
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            request.keywords = keywords ?? ""
            // radius: 传入值则使用传入值，无 radius 时设置为最大值 50000
            request.radius = radius ?? 50000
            request.page = page
            request.offset = pageSize
            request.sortrule = 0  // 按距离排序
            
            if let types = types, !types.isEmpty {
                request.types = types
            }
            
            if let city = city, !city.isEmpty {
                request.city = city
            }
            
            // 发起周边搜索
            searchAPI?.aMapPOIAroundSearch(request)
        }
    }
    
    // MARK: - Weather Live Search
    
    private func searchWeatherLive(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        guard let city = arguments["city"] as? String, !city.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "city is required", details: nil))
            return
        }
        
        print("[AMapSearchApi] searchWeatherLive: city=\(city)")
        
        // 创建天气查询请求
        let request = AMapWeatherSearchRequest()
        request.city = city
        request.type = AMapWeatherType.live  // 实时天气
        
        // 保存回调
        self.weatherLiveResult = result
        
        // 发起天气查询
        searchAPI?.aMapWeatherSearch(request)
    }
    
    // MARK: - Weather Forecast Search
    
    private func searchWeatherForecast(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        guard let city = arguments["city"] as? String, !city.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "city is required", details: nil))
            return
        }
        
        print("[AMapSearchApi] searchWeatherForecast: city=\(city)")
        
        // 创建天气查询请求
        let request = AMapWeatherSearchRequest()
        request.city = city
        request.type = AMapWeatherType.forecast  // 预报天气
        
        // 保存回调
        self.weatherForecastResult = result
        
        // 发起天气查询
        searchAPI?.aMapWeatherSearch(request)
    }
    
    // MARK: - Weather Live Search By Location
    
    private func searchWeatherLiveByLocation(result: @escaping FlutterResult) {
        print("[AMapSearchApi] searchWeatherLiveByLocation")
        
        // 保存回调
        self.weatherLiveByLocationResult = result
        
        // 初始化定位管理器
        locationManager = AMapLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.locationTimeout = 10
        locationManager?.reGeocodeTimeout = 5
        
        // 发起单次定位请求（带逆地理编码）
        locationManager?.requestLocation(withReGeocode: true) { [weak self] location, regeocode, error in
            self?.locationManager?.stopUpdatingLocation()
            self?.locationManager = nil
            
            guard let result = self?.weatherLiveByLocationResult else { return }
            self?.weatherLiveByLocationResult = nil
            
            if let error = error {
                print("[AMapSearchApi] searchWeatherLiveByLocation location error: \(error.localizedDescription)")
                result(FlutterError(code: "LOCATION_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let adcode = regeocode?.adcode, !adcode.isEmpty else {
                print("[AMapSearchApi] searchWeatherLiveByLocation: adcode is empty")
                result(FlutterError(code: "LOCATION_ERROR", message: "无法获取区域编码", details: nil))
                return
            }
            
            print("[AMapSearchApi] searchWeatherLiveByLocation: got adcode=\(adcode)")
            
            // 用 adcode 查询实时天气
            self?.searchWeatherLiveInternal(city: adcode, result: result)
        }
    }
    
    // MARK: - Weather Forecast Search By Location
    
    private func searchWeatherForecastByLocation(result: @escaping FlutterResult) {
        print("[AMapSearchApi] searchWeatherForecastByLocation")
        
        // 保存回调
        self.weatherForecastByLocationResult = result
        
        // 初始化定位管理器
        locationManager = AMapLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.locationTimeout = 10
        locationManager?.reGeocodeTimeout = 5
        
        // 发起单次定位请求（带逆地理编码）
        locationManager?.requestLocation(withReGeocode: true) { [weak self] location, regeocode, error in
            self?.locationManager?.stopUpdatingLocation()
            self?.locationManager = nil
            
            guard let result = self?.weatherForecastByLocationResult else { return }
            self?.weatherForecastByLocationResult = nil
            
            if let error = error {
                print("[AMapSearchApi] searchWeatherForecastByLocation location error: \(error.localizedDescription)")
                result(FlutterError(code: "LOCATION_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let adcode = regeocode?.adcode, !adcode.isEmpty else {
                print("[AMapSearchApi] searchWeatherForecastByLocation: adcode is empty")
                result(FlutterError(code: "LOCATION_ERROR", message: "无法获取区域编码", details: nil))
                return
            }
            
            print("[AMapSearchApi] searchWeatherForecastByLocation: got adcode=\(adcode)")
            
            // 用 adcode 查询天气预报
            self?.searchWeatherForecastInternal(city: adcode, result: result)
        }
    }
    
    // MARK: - Internal Weather Methods
    
    private func searchWeatherLiveInternal(city: String, result: @escaping FlutterResult) {
        // 保存回调 (复用 weatherLiveResult)
        self.weatherLiveResult = result
        
        // 创建天气查询请求
        let request = AMapWeatherSearchRequest()
        request.city = city
        request.type = AMapWeatherType.live
        
        // 发起天气查询
        searchAPI?.aMapWeatherSearch(request)
    }
    
    private func searchWeatherForecastInternal(city: String, result: @escaping FlutterResult) {
        // 保存回调 (复用 weatherForecastResult)
        self.weatherForecastResult = result
        
        // 创建天气查询请求
        let request = AMapWeatherSearchRequest()
        request.city = city
        request.type = AMapWeatherType.forecast
        
        // 发起天气查询
        searchAPI?.aMapWeatherSearch(request)
    }
}

// MARK: - AMapSearchDelegate
extension AMapSearchApi: AMapSearchDelegate {
    
    /// 输入提示搜索回调
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        guard let result = inputTipsResult else { return }
        inputTipsResult = nil
        
        guard let tips = response?.tips else {
            result([])
            return
        }
        
        let tipList = tips.map { tip -> [String: Any?] in
            var latitude: Double? = nil
            var longitude: Double? = nil
            
            // AMapTip 的 location 是 AMapGeoPoint
            if let location = tip.location {
                latitude = Double(location.latitude)
                longitude = Double(location.longitude)
            }
            
            return [
                "name": tip.name ?? "",
                "address": tip.address,
                "poiId": tip.uid,
                "district": tip.district,
                "adcode": tip.adcode,
                "typeCode": tip.typecode,
                "latitude": latitude,
                "longitude": longitude
            ]
        }
        
        print("[AMapSearchApi] onInputTipsSearchDone: \(tipList.count) tips")
        result(tipList)
    }
    
    /// 搜索错误回调
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("[AMapSearchApi] Search error: \(error?.localizedDescription ?? "unknown")")
        
        let nsError = error as NSError
        let flutterError = FlutterError(
            code: "SEARCH_ERROR",
            message: error?.localizedDescription ?? "Search failed",
            details: nsError.code
        )
        
        if let result = inputTipsResult {
            inputTipsResult = nil
            result(flutterError)
        }
        
        if let result = poiAroundResult {
            poiAroundResult = nil
            result(flutterError)
        }
        
        if let result = weatherLiveResult {
            weatherLiveResult = nil
            result(flutterError)
        }
        
        if let result = weatherForecastResult {
            weatherForecastResult = nil
            result(flutterError)
        }
    }
    
    /// POI 周边搜索回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        guard let result = poiAroundResult else { return }
        poiAroundResult = nil
        
        guard let pois = response?.pois else {
            result([])
            return
        }
        
        let poiList = pois.map { poi -> [String: Any?] in
            var latitude: Double? = nil
            var longitude: Double? = nil
            
            if let location = poi.location {
                latitude = Double(location.latitude)
                longitude = Double(location.longitude)
            }
            
            return [
                "poiId": poi.uid ?? "",
                "name": poi.name ?? "",
                "address": poi.address,
                "latitude": latitude,
                "longitude": longitude,
                "typeName": poi.type,
                "typeCode": poi.typecode,
                "cityName": poi.city,
                "cityCode": poi.citycode,
                "adName": poi.district,
                "adCode": poi.adcode,
                "distance": poi.distance,
                "tel": poi.tel,
                "provinceName": poi.province,
                "provinceCode": poi.pcode
            ]
        }
        
        print("[AMapSearchApi] onPOISearchDone: \(poiList.count) POIs")
        result(poiList)
    }
    
    /// 天气查询回调
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        // 判断是实时天气还是预报天气
        if request.type == AMapWeatherType.live {
            // 实时天气
            guard let result = weatherLiveResult else { return }
            weatherLiveResult = nil
            
            guard let lives = response?.lives, let liveWeather = lives.first else {
                result(FlutterError(code: "WEATHER_ERROR", message: "No weather live data returned", details: nil))
                return
            }
            
            let weatherData: [String: Any?] = [
                "city": liveWeather.city,
                "adCode": liveWeather.adcode,
                "province": liveWeather.province,
                "weather": liveWeather.weather,
                "temperature": liveWeather.temperature,
                "windDirection": liveWeather.windDirection,
                "windPower": liveWeather.windPower,
                "humidity": liveWeather.humidity,
                "reportTime": liveWeather.reportTime
            ]
            
            print("[AMapSearchApi] onWeatherSearchDone (live): \(liveWeather.city ?? "")")
            result(weatherData)
            
        } else {
            // 预报天气
            guard let result = weatherForecastResult else { return }
            weatherForecastResult = nil
            
            guard let forecasts = response?.forecasts, let forecast = forecasts.first else {
                result(FlutterError(code: "WEATHER_ERROR", message: "No weather forecast data returned", details: nil))
                return
            }
            
            // 构建每日预报列表
            var casts: [[String: Any?]] = []
            if let weatherCasts = forecast.casts {
                casts = weatherCasts.map { dayForecast -> [String: Any?] in
                    return [
                        "date": dayForecast.date,
                        "week": dayForecast.week,
                        "dayWeather": dayForecast.dayWeather,
                        "nightWeather": dayForecast.nightWeather,
                        "dayTemp": dayForecast.dayTemp,
                        "nightTemp": dayForecast.nightTemp,
                        "dayWind": dayForecast.dayWind,
                        "nightWind": dayForecast.nightWind,
                        "dayPower": dayForecast.dayPower,
                        "nightPower": dayForecast.nightPower
                    ]
                }
            }
            
            let forecastData: [String: Any?] = [
                "city": forecast.city,
                "adCode": forecast.adcode,
                "province": forecast.province,
                "reportTime": forecast.reportTime,
                "casts": casts
            ]
            
            print("[AMapSearchApi] onWeatherSearchDone (forecast): \(forecast.city ?? ""), \(casts.count) days")
            result(forecastData)
        }
    }
}

