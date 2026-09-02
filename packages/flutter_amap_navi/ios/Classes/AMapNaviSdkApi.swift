import AMapFoundationKit
import AMapNaviKit
import Flutter
import ObjectiveC

final class AMapNaviSdkApi: NSObject {
    private static let channelName = "plugins.flutter.dev/amap_navi_initializer"

    static func setup(registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler { call, result in
            guard call.method == "initialize" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let arguments = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "导航 SDK 初始化参数无效",
                    details: nil
                ))
                return
            }

            let apiKey = arguments["iosKey"] as? String ?? ""
            let agreePrivacy = arguments["agreePrivacy"] as? Bool ?? false
            AMapServices.shared().apiKey = apiKey
            MAMapView.updatePrivacyShow(
                AMapPrivacyShowStatus(agreePrivacy),
                privacyInfo: AMapPrivacyInfoStatus(agreePrivacy)
            )
            MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus(agreePrivacy))
            updateManagerPrivacy(AMapNaviDriveManager.self, agree: agreePrivacy)
            updateManagerPrivacy(AMapNaviWalkManager.self, agree: agreePrivacy)
            updateManagerPrivacy(AMapNaviRideManager.self, agree: agreePrivacy)
            result(nil)
        }
    }

    private static func updateManagerPrivacy(_ cls: AnyClass, agree: Bool) {
        guard let metaClass = cls as? NSObject.Type else { return }

        let showSelector = NSSelectorFromString("updatePrivacyShow:privacyInfo:")
        if metaClass.responds(to: showSelector),
           let method = class_getClassMethod(cls, showSelector) {
            typealias ShowMethod = @convention(c) (
                AnyClass,
                Selector,
                AMapPrivacyShowStatus,
                AMapPrivacyInfoStatus
            ) -> Void
            let function = unsafeBitCast(method_getImplementation(method), to: ShowMethod.self)
            function(
                cls,
                showSelector,
                AMapPrivacyShowStatus(agree),
                AMapPrivacyInfoStatus(agree)
            )
        }

        let agreeSelector = NSSelectorFromString("updatePrivacyAgree:")
        if metaClass.responds(to: agreeSelector),
           let method = class_getClassMethod(cls, agreeSelector) {
            typealias AgreeMethod = @convention(c) (
                AnyClass,
                Selector,
                AMapPrivacyAgreeStatus
            ) -> Void
            let function = unsafeBitCast(method_getImplementation(method), to: AgreeMethod.self)
            function(cls, agreeSelector, AMapPrivacyAgreeStatus(agree))
        }
    }
}
