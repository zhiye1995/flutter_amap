import Flutter
// 地图独立集成使用 MAMapKit；地图与导航联合集成时复用 AMapNaviKit 内含的地图能力。
#if canImport(MAMapKit)
import MAMapKit
#elseif canImport(AMapNaviKit)
import AMapNaviKit
#else
#error("Neither MAMapKit nor AMapNaviKit is available. Check flutter_amap's iOS SDK configuration.")
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

