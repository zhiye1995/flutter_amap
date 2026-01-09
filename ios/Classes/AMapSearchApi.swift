import Flutter
import UIKit
import AMapSearchKit
import AMapFoundationKit

/// 高德搜索 API 处理类
class AMapSearchApi: NSObject {
    
    private static let SEARCH_METHOD_CHANNEL = "plugins.flutter.dev/amap_search"
    /// 静态实例，防止被 ARC 释放
    private static var shared: AMapSearchApi?

    private var methodChannel: FlutterMethodChannel?
    private var searchAPI: AMapSearchAPI?
    
    /// 存储当前搜索回调
    private var inputTipsResult: FlutterResult?

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
        
        if let result = inputTipsResult {
            inputTipsResult = nil
            let nsError = error as NSError
            result(FlutterError(
                code: "SEARCH_ERROR",
                message: error?.localizedDescription ?? "Search failed",
                details: nsError.code
            ))
        }
    }
}

