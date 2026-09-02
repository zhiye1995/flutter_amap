import Flutter
import UIKit

public class AMapNaviPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        AMapNaviSdkApi.setup(registrar: registrar)
        AMapNaviApi.setup(registrar: registrar)
    }
}
