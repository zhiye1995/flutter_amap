import Flutter
import UIKit
import CoreLocation
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
    private var poiAroundQueryResult: FlutterResult?
    private var poiAroundQueryPage = 1
    private var poiAroundQueryPageSize = 20
    private var poiKeywordResult: FlutterResult?
    private var poiKeywordPage = 1
    private var poiKeywordPageSize = 20
    private var geocodeResult: FlutterResult?
    private var reGeocodeResult: FlutterResult?
    private var reGeocodeLatitude: Double?
    private var reGeocodeLongitude: Double?
    private var reGeocodeRequest: AMapReGeocodeSearchRequest?
    private var routeResult: FlutterResult?
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
        case "searchPOIAroundWithQuery":
            searchPOIAroundWithQuery(call: call, result: result)
        case "searchPOIKeywords":
            searchPOIKeywords(call: call, result: result)
        case "searchGeocode":
            searchGeocode(call: call, result: result)
        case "searchReGeocode":
            searchReGeocode(call: call, result: result)
        case "searchDriveRoute":
            searchDriveRoute(call: call, result: result)
        case "searchWalkRoute":
            searchWalkRoute(call: call, result: result)
        case "searchRideRoute":
            searchRideRoute(call: call, result: result)
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
    
    // MARK: - POI Around Search With Query
    
    private func searchPOIAroundWithQuery(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        guard let latitude = arguments["latitude"] as? Double,
              let longitude = arguments["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "latitude and longitude are required", details: nil))
            return
        }
        
        let keywords = arguments["keywords"] as? String ?? ""
        let types = arguments["types"] as? String ?? ""
        let radius = arguments["radius"] as? Int ?? 1000
        let city = arguments["city"] as? String
        let page = arguments["page"] as? Int ?? 1
        let pageSize = arguments["pageSize"] as? Int ?? 20
        let extensions = arguments["extensions"] as? String ?? "base"
        let children = arguments["children"] as? Bool ?? false
        let sortByDistance = arguments["sortByDistance"] as? Bool ?? true
        
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
        request.keywords = keywords
        request.radius = radius
        request.page = page
        request.offset = pageSize
        request.sortrule = sortByDistance ? 0 : 1
        
        if !types.isEmpty {
            request.types = types
        }
        
        if let city = city, !city.isEmpty {
            request.city = city
        }
        
        var fields: AMapPOISearchShowFieldsType =
            extensions == "all" ? .all : .none
        if children {
            fields.insert(.children)
        }
        request.showFieldsType = fields
        
        self.poiAroundQueryResult = result
        self.poiAroundQueryPage = page
        self.poiAroundQueryPageSize = pageSize
        
        searchAPI?.aMapPOIAroundSearch(request)
    }
    
    // MARK: - POI Keyword Search
    
    private func searchPOIKeywords(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        let keywords = arguments["keywords"] as? String ?? ""
        let types = arguments["types"] as? String ?? ""
        guard !keywords.isEmpty || !types.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "keywords or types is required", details: nil))
            return
        }
        
        let city = arguments["city"] as? String
        let cityLimit = arguments["cityLimit"] as? Bool ?? false
        let page = arguments["page"] as? Int ?? 1
        let pageSize = arguments["pageSize"] as? Int ?? 20
        let latitude = arguments["latitude"] as? Double
        let longitude = arguments["longitude"] as? Double
        let extensions = arguments["extensions"] as? String ?? "base"
        let children = arguments["children"] as? Bool ?? false
        let sortByDistance = arguments["sortByDistance"] as? Bool ?? false
        
        print("[AMapSearchApi] searchPOIKeywords: keywords=\(keywords), types=\(types), city=\(city ?? "nil"), cityLimit=\(cityLimit)")
        
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keywords
        request.page = page
        request.offset = pageSize
        request.cityLimit = cityLimit
        request.sortrule = sortByDistance ? 0 : 1
        
        if !types.isEmpty {
            request.types = types
        }
        
        if let city = city, !city.isEmpty {
            request.city = city
        }
        
        if let lat = latitude, let lng = longitude {
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng))
        }
        
        var fields: AMapPOISearchShowFieldsType =
            extensions == "all" ? .all : .none
        if children {
            fields.insert(.children)
        }
        request.showFieldsType = fields
        
        self.poiKeywordResult = result
        self.poiKeywordPage = page
        self.poiKeywordPageSize = pageSize
        
        searchAPI?.aMapPOIKeywordsSearch(request)
    }
    
    // MARK: - Geocode
    
    private func searchGeocode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        let address = arguments["address"] as? String ?? ""
        guard !address.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "address is required", details: nil))
            return
        }
        let request = AMapGeocodeSearchRequest()
        request.address = address
        if let city = arguments["city"] as? String, !city.isEmpty {
            request.city = city
        }
        if let country = arguments["country"] as? String, !country.isEmpty {
            request.country = country
        }
        self.geocodeResult = result
        searchAPI?.aMapGeocodeSearch(request)
    }
    
    private func searchReGeocode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        guard let latitude = arguments["latitude"] as? Double,
              let longitude = arguments["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "latitude and longitude are required", details: nil))
            return
        }
        let coordinateType = arguments["coordinateType"] as? String ?? "amap"
        let requestCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let searchCoordinate: CLLocationCoordinate2D
        if coordinateType == "gps" {
            searchCoordinate = AMapCoordinateConvert(requestCoordinate, .GPS)
        } else {
            searchCoordinate = requestCoordinate
        }

        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(
            withLatitude: CGFloat(searchCoordinate.latitude),
            longitude: CGFloat(searchCoordinate.longitude)
        )
        request.radius = arguments["radius"] as? Int ?? 1000
        request.requireExtension = (arguments["extensions"] as? String) == "all"
        if let poiTypes = arguments["poiTypes"] as? String, !poiTypes.isEmpty {
            request.poitype = poiTypes
        }
        self.reGeocodeResult = result
        self.reGeocodeLatitude = latitude
        self.reGeocodeLongitude = longitude
        self.reGeocodeRequest = request
        searchAPI?.aMapReGoecodeSearch(request)
    }

    private func clearReGeocodeState() {
        reGeocodeLatitude = nil
        reGeocodeLongitude = nil
        reGeocodeRequest = nil
    }

    private func searchDriveRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let origin = geoPoint(arguments["origin"]),
              let destination = geoPoint(arguments["destination"]) else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "origin and destination are required", details: nil))
            return
        }

        let request = AMapDrivingCalRouteSearchRequest()
        request.origin = origin
        request.destination = destination
        request.strategy = drivingV2Strategy(arguments["strategy"] as? Int)
        if (arguments["extensions"] as? String) == "all" {
            request.showFieldType = drivingShowFieldType()
        }
        if let waypoints = routeGeoPoints(arguments["wayPoints"]), !waypoints.isEmpty {
            request.waypoints = waypoints
        }
        if let avoidPolygons = avoidPolygons(arguments["avoidPolygons"]), !avoidPolygons.isEmpty {
            request.avoidpolygons = avoidPolygons
        }
        if let avoidRoad = arguments["avoidRoad"] as? String, !avoidRoad.isEmpty {
            request.avoidroad = avoidRoad
        }
        if let plate = drivingPlateNumber(arguments), !plate.isEmpty {
            request.plate = plate
        }
        request.setOptionalValue(arguments["carType"], forKey: "cartype")
        request.setOptionalValue(arguments["excludeRoadType"], forKey: "exclude")
        if let ferry = arguments["ferry"] as? Bool {
            request.ferry = ferry ? 0 : 1
        }

        routeResult = result
        searchAPI?.aMapDrivingV2RouteSearch(request)
    }

    private func searchWalkRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let origin = geoPoint(arguments["origin"]),
              let destination = geoPoint(arguments["destination"]) else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "origin and destination are required", details: nil))
            return
        }

        let request = AMapWalkingRouteSearchRequest()
        request.origin = origin
        request.destination = destination
        request.setOptionalValue(arguments["alternativeRoute"], forKey: "alternativeRoute")
        request.setOptionalValue(arguments["indoor"], forKey: "isindoor")
        request.setOptionalValue(arguments["multiPath"], forKey: "multipath")
        routeResult = result
        searchAPI?.aMapWalkingRouteSearch(request)
    }

    private func searchRideRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let origin = geoPoint(arguments["origin"]),
              let destination = geoPoint(arguments["destination"]) else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "origin and destination are required", details: nil))
            return
        }

        let request = AMapRidingRouteSearchRequest()
        request.origin = origin
        request.destination = destination
        request.setOptionalValue(arguments["strategy"], forKey: "strategy")
        routeResult = result
        searchAPI?.aMapRidingRouteSearch(request)
    }

    private func geoPoint(_ value: Any?) -> AMapGeoPoint? {
        guard let map = value as? [String: Any],
              let latitude = map["latitude"] as? Double,
              let longitude = map["longitude"] as? Double else {
            return nil
        }
        return AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
    }

    private func routeGeoPoints(_ value: Any?) -> [AMapGeoPoint]? {
        guard let list = value as? [[String: Any]] else { return nil }
        return list.compactMap { geoPoint($0) }
    }

    private func avoidPolygons(_ value: Any?) -> [AMapGeoPolygon]? {
        guard let list = value as? [[String: Any]] else { return nil }
        return list.compactMap { polygon -> AMapGeoPolygon? in
            guard let points = polygon["points"] as? [[String: Any]] else { return nil }
            let geoPoints = points.compactMap { geoPoint($0) }
            guard geoPoints.count >= 3 else { return nil }
            let geoPolygon = AMapGeoPolygon()
            geoPolygon.points = geoPoints
            return geoPolygon
        }
    }

    private func drivingShowFieldType() -> AMapDrivingRouteShowFieldType {
        let rawValue = AMapDrivingRouteShowFieldType.cost.rawValue
            | AMapDrivingRouteShowFieldType.tmcs.rawValue
            | AMapDrivingRouteShowFieldType.navi.rawValue
            | AMapDrivingRouteShowFieldType.cities.rawValue
            | AMapDrivingRouteShowFieldType.polyline.rawValue
        return AMapDrivingRouteShowFieldType(rawValue: rawValue)!
    }

    private func drivingV2Strategy(_ strategy: Int?) -> Int {
        guard let strategy = strategy else { return 32 }
        if (32...45).contains(strategy) {
            return strategy
        }
        switch strategy {
        case 0:
            return 38
        case 1, 14:
            return 36
        case 4, 12:
            return 33
        case 6, 13:
            return 35
        case 7, 16:
            return 42
        case 8, 17:
            return 41
        case 9, 18:
            return 43
        case 15:
            return 40
        case 19:
            return 34
        case 20:
            return 39
        default:
            return 32
        }
    }

    private func drivingPlateNumber(_ arguments: [String: Any]) -> String? {
        guard let carNumber = arguments["carNumber"] as? String, !carNumber.isEmpty else {
            return nil
        }
        guard let plateProvince = arguments["plateProvince"] as? String, !plateProvince.isEmpty else {
            return carNumber
        }
        return carNumber.hasPrefix(plateProvince) ? carNumber : plateProvince + carNumber
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
            code: request is AMapReGeocodeSearchRequest ? "GEOCODE_ERROR" : (request is AMapRouteSearchBaseRequest ? "ROUTE_ERROR" : "SEARCH_ERROR"),
            message: error?.localizedDescription ?? "Search failed",
            details: nsError.code
        )
        
        if request is AMapInputTipsSearchRequest, let result = inputTipsResult {
            inputTipsResult = nil
            result(flutterError)
        }
        
        if request is AMapPOISearchBaseRequest, let result = poiAroundResult {
            poiAroundResult = nil
            result(flutterError)
        }
        
        if request is AMapPOIAroundSearchRequest, let result = poiAroundQueryResult {
            poiAroundQueryResult = nil
            result(flutterError)
        }
        
        if request is AMapPOIKeywordsSearchRequest, let result = poiKeywordResult {
            poiKeywordResult = nil
            result(flutterError)
        }
        
        if request is AMapGeocodeSearchRequest, let result = geocodeResult {
            geocodeResult = nil
            result(flutterError)
        }
        
        if request is AMapReGeocodeSearchRequest, let result = reGeocodeResult {
            reGeocodeResult = nil
            clearReGeocodeState()
            result(flutterError)
        }

        if request is AMapRouteSearchBaseRequest, let result = routeResult {
            routeResult = nil
            result(flutterError)
        }
        
        if request is AMapWeatherSearchRequest, let result = weatherLiveResult {
            weatherLiveResult = nil
            result(flutterError)
        }
        
        if request is AMapWeatherSearchRequest, let result = weatherForecastResult {
            weatherForecastResult = nil
            result(flutterError)
        }
    }
    
    /// POI 周边搜索回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let result = poiAroundQueryResult, request is AMapPOIAroundSearchRequest {
            poiAroundQueryResult = nil
            let poiList = makePoiList(response?.pois)
            result([
                "items": poiList,
                "page": poiAroundQueryPage,
                "pageSize": poiAroundQueryPageSize,
                "total": response?.count ?? NSNull()
            ])
            return
        }
        
        if let result = poiKeywordResult, request is AMapPOIKeywordsSearchRequest {
            poiKeywordResult = nil
            let poiList = makePoiList(response?.pois)
            result([
                "items": poiList,
                "page": poiKeywordPage,
                "pageSize": poiKeywordPageSize,
                "total": response?.count ?? NSNull()
            ])
            return
        }
        
        guard let result = poiAroundResult else { return }
        poiAroundResult = nil
        
        result(makePoiList(response?.pois))
    }
    
    private func makePoiList(_ pois: [AMapPOI]?) -> [[String: Any?]] {
        guard let pois = pois else { return [] }
        
        return pois.map { poi -> [String: Any?] in
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
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        guard let result = geocodeResult else { return }
        geocodeResult = nil
        let items = (response?.geocodes ?? []).map { geocode -> [String: Any?] in
            return [
                "formattedAddress": geocode.formattedAddress,
                "latitude": geocode.location?.latitude,
                "longitude": geocode.location?.longitude,
                "province": geocode.province,
                "city": geocode.city,
                "district": geocode.district,
                "township": geocode.township,
                "neighborhood": geocode.neighborhood,
                "building": geocode.building,
                "adCode": geocode.adcode,
                "cityCode": geocode.citycode,
                "country": geocode.country,
                "level": geocode.level,
                "raw": [
                    "platform": "ios",
                    "sdkString": "\(geocode)"
                ]
            ]
        }
        result(items)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let result = reGeocodeResult else { return }
        reGeocodeResult = nil
        let requestLatitude = reGeocodeLatitude
        let requestLongitude = reGeocodeLongitude
        clearReGeocodeState()
        guard let geocode = response?.regeocode else {
            result(FlutterError(code: "GEOCODE_ERROR", message: "No re-geocode data returned", details: nil))
            return
        }
        let pois = makePoiList(geocode.pois)
        let requestLocation = request?.location
        let latitude = requestLatitude ?? requestLocation.map { Double($0.latitude) }
        let longitude = requestLongitude ?? requestLocation.map { Double($0.longitude) }
        let roads = (geocode.roads ?? []).compactMap { $0.name }
        let crosses = (geocode.roadinters ?? []).compactMap { roadinter -> String? in
            let names = [roadinter.firstName, roadinter.secondName]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
            return names.isEmpty ? nil : names.joined(separator: " / ")
        }
        let aois = (geocode.aois ?? []).compactMap { $0.name }
        let raw: [String: Any?] = [
            "platform": "ios",
            "sdkString": "\(geocode)"
        ]
        let geocodeData: [String: Any?] = [
            "formattedAddress": geocode.formattedAddress,
            "latitude": latitude,
            "longitude": longitude,
            "province": geocode.addressComponent?.province,
            "city": geocode.addressComponent?.city,
            "district": geocode.addressComponent?.district,
            "township": geocode.addressComponent?.township,
            "neighborhood": geocode.addressComponent?.neighborhood,
            "building": geocode.addressComponent?.building,
            "adCode": geocode.addressComponent?.adcode,
            "cityCode": geocode.addressComponent?.citycode,
            "country": geocode.addressComponent?.country,
            "countryCode": nil,
            "townCode": geocode.addressComponent?.towncode,
            "roads": roads,
            "crosses": crosses,
            "pois": pois,
            "aois": aois,
            "raw": raw
        ]
        result(geocodeData)
    }

    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        guard let result = routeResult else { return }
        routeResult = nil
        guard let route = response?.route else {
            result(FlutterError(code: "ROUTE_ERROR", message: "No route data returned", details: nil))
            return
        }
        let routeType: String
        if request is AMapWalkingRouteSearchRequest {
            routeType = "walk"
        } else if request is AMapRidingRouteSearchRequest {
            routeType = "ride"
        } else {
            routeType = "drive"
        }
        result([
            "type": routeType,
            "origin": request?.origin?.routePointMap(),
            "destination": request?.destination?.routePointMap(),
            "taxiCost": route.taxiCost,
            "paths": (route.paths ?? []).map { $0.routePathMap() },
            "raw": [
                "platform": "ios",
                "count": response?.count ?? 0,
                "sdkString": "\(route)"
            ]
        ])
    }

    private func parsePolyline(_ polyline: String?) -> [[String: Any?]] {
        guard let polyline = polyline, !polyline.isEmpty else { return [] }
        return polyline.split(separator: ";").compactMap { pair in
            let parts = pair.split(separator: ",")
            guard parts.count == 2,
                  let lng = Double(parts[0]),
                  let lat = Double(parts[1]) else {
                return nil
            }
            return ["latitude": lat, "longitude": lng]
        }
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

private extension NSObject {
    func setOptionalValue(_ value: Any?, forKey key: String) {
        guard let value = value else { return }
        if value is NSNull { return }
        if let text = value as? String, text.isEmpty { return }
        guard responds(to: NSSelectorFromString(key)) else { return }
        setValue(value, forKey: key)
    }
}

private extension AMapGeoPoint {
    func routePointMap() -> [String: Any?] {
        return [
            "latitude": Double(latitude),
            "longitude": Double(longitude)
        ]
    }
}

private extension AMapPath {
    func routePathMap() -> [String: Any?] {
        let stepMaps = (steps ?? []).map { $0.routeStepMap() }
        let pathPolyline = parseRoutePolyline(polyline)
        let mergedPolyline = pathPolyline.isEmpty
            ? stepMaps.flatMap { $0["polyline"] as? [[String: Any?]] ?? [] }
            : pathPolyline
        return [
            "distance": distance,
            "duration": duration,
            "strategy": strategy,
            "tolls": tolls,
            "tollDistance": tollDistance,
            "totalTrafficLights": totalTrafficLights,
            "restriction": restriction,
            "polyline": mergedPolyline,
            "steps": stepMaps,
            "raw": [
                "sdkString": "\(self)"
            ]
        ]
    }
}

private extension AMapStep {
    func routeStepMap() -> [String: Any?] {
        return [
            "instruction": instruction,
            "orientation": orientation,
            "road": road,
            "action": action,
            "assistantAction": assistantAction,
            "distance": distance,
            "duration": duration,
            "tolls": tolls,
            "tollDistance": tollDistance,
            "polyline": parseRoutePolyline(polyline),
            "tmcs": (tmcs ?? []).map { $0.routeTmcMap() },
            "raw": [
                "sdkString": "\(self)"
            ]
        ]
    }
}

private extension AMapTMC {
    func routeTmcMap() -> [String: Any?] {
        return [
            "status": status,
            "distance": distance,
            "polyline": parseRoutePolyline(polyline),
            "raw": [
                "sdkString": "\(self)"
            ]
        ]
    }
}

private func parseRoutePolyline(_ polyline: String?) -> [[String: Any?]] {
    guard let polyline = polyline, !polyline.isEmpty else { return [] }
    return polyline.split(separator: ";").compactMap { pair in
        let parts = pair.split(separator: ",")
        guard parts.count == 2,
              let lng = Double(parts[0]),
              let lat = Double(parts[1]) else {
            return nil
        }
        return ["latitude": lat, "longitude": lng]
    }
}

