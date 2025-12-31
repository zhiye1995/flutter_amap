import Flutter
// `MAMapKit` 通常来自 `AMap3DMap`。
// 但在一些集成方式下（例如仅引入 `AMapNavi`），`MAMapKit` 这个 Swift module 可能不存在，
// 地图相关类型会通过 `AMapNaviKit` 暴露出来；因此这里做条件导入以兼容两种情况。
#if canImport(MAMapKit)
import MAMapKit
#elseif canImport(AMapNaviKit)
import AMapNaviKit
#else
#error("Neither MAMapKit nor AMapNaviKit is available. Please add AMapNavi (recommended) or AMap3DMap to your Pod dependencies.")
#endif

class _AMapSdkApi: NSObject {
  static func setup(registrar: FlutterPluginRegistrar) {
    let initializerChannel = FlutterMethodChannel(name: "plugins.flutter.dev/amap_initializer", binaryMessenger: registrar.messenger())
    initializerChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if(call.method == "agreePrivacy") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let agree = arguments["agree"] as! Bool
        _AMapSdkApi.agreePrivacy(agreePrivacy: agree)
        result(nil)
      } else if(call.method == "setApiKey") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let apiKey = arguments["iosKey"] as! String
        _AMapSdkApi.setApiKey(apiKey: apiKey)
        result(nil)
      }
    })
  }

  static func agreePrivacy(agreePrivacy: Bool) {
    MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.init(agreePrivacy), privacyInfo: AMapPrivacyInfoStatus.init(agreePrivacy))
    MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.init(agreePrivacy))
  }

  static func setApiKey(apiKey: String) {
    AMapServices.shared().apiKey = apiKey
  }
}

