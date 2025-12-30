import Flutter
import UIKit
import AMapNaviKit
import AMapFoundationKit
import ObjectiveC

/// 高德导航 API 处理类
class AMapNaviApi: NSObject {
    
    private static let NAVI_METHOD_CHANNEL = "plugins.flutter.dev/amap_navi"
    private static let NAVI_EVENT_CHANNEL = "plugins.flutter.dev/amap_navi_events"
    
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var naviDelegate: AMapNaviDelegate?
    private var naviViewController: AMapNaviViewController?
    
    private weak var registrar: FlutterPluginRegistrar?
    
    // MARK: - Setup
    
    static func setup(registrar: FlutterPluginRegistrar) {
        let instance = AMapNaviApi()
        instance.registrar = registrar
        
        // 设置 MethodChannel
        instance.methodChannel = FlutterMethodChannel(
            name: NAVI_METHOD_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        instance.methodChannel?.setMethodCallHandler { (call, result) in
            instance.handleMethodCall(call: call, result: result)
        }
        
        // 设置 EventChannel
        instance.naviDelegate = AMapNaviDelegate()
        instance.eventChannel = FlutterEventChannel(
            name: NAVI_EVENT_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel?.setStreamHandler(instance)
    }
    
    // MARK: - Method Call Handler
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startNavigation":
            startNavigation(call: call, result: result)
        case "stopNavigation":
            stopNavigation(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Navigation Methods
    
    private func startNavigation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        
        // 隐私合规检查
        updatePrivacy()
        
        // 解析参数
        let carNumber = arguments["carNumber"] as? String
        let naviTypeIndex = arguments["naviType"] as? Int ?? 0
        let pageTypeIndex = arguments["pageType"] as? Int ?? 0
        
        let startLat = arguments["startLat"] as? Double
        let startLng = arguments["startLng"] as? Double
        let startName = arguments["startName"] as? String
        
        let endLat = arguments["endLat"] as? Double
        let endLng = arguments["endLng"] as? Double
        let endName = arguments["endName"] as? String
        
        let wayPointsList = arguments["wayPoints"] as? [[String: Any]]
        
        // 构建起点
        var startPoint: AMapNaviPoint?
        if let lat = startLat, let lng = startLng {
            startPoint = AMapNaviPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng))
        }
        
        // 构建终点
        var endPoint: AMapNaviPoint?
        if let lat = endLat, let lng = endLng {
            endPoint = AMapNaviPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng))
        }
        
        // 构建途经点
        var wayPoints: [AMapNaviPoint] = []
        if let wayPointsList = wayPointsList {
            for wayPoint in wayPointsList {
                if let lat = wayPoint["lat"] as? Double,
                   let lng = wayPoint["lng"] as? Double {
                    if let point = AMapNaviPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng)) {
                        wayPoints.append(point)
                    }
                }
            }
        }
        
        // 导航类型
        let naviType = AMapNaviType(rawValue: naviTypeIndex) ?? .driver
        let pageType = AMapNaviPageType(rawValue: pageTypeIndex) ?? .route
        
        print("[AMapNaviApi] startNavigation: naviType=\(naviType), pageType=\(pageType), start=\(String(describing: startPoint)), end=\(String(describing: endPoint)), wayPoints=\(wayPoints.count)")
        
        // 创建导航视图控制器
        let naviVC = AMapNaviViewController()
        naviVC.naviType = naviType
        naviVC.pageType = pageType
        naviVC.startPoint = startPoint
        naviVC.endPoint = endPoint
        naviVC.wayPoints = wayPoints
        naviVC.carNumber = carNumber
        naviVC.naviDelegate = naviDelegate
        naviVC.modalPresentationStyle = .fullScreen
        
        naviVC.onExit = { [weak self] exitCode in
            self?.naviViewController = nil
        }
        
        naviViewController = naviVC
        
        // 获取当前视图控制器并展示导航页面
        DispatchQueue.main.async { [weak self] in
            guard let topVC = self?.topViewController() else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "无法获取当前视图控制器", details: nil))
                return
            }
            
            if let navigationController = topVC.navigationController {
                navigationController.pushViewController(naviVC, animated: true)
            } else {
                topVC.present(naviVC, animated: true)
            }
            
            result(nil)
        }
    }
    
    private func stopNavigation(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.naviViewController?.stopNavigation()
            
            if let naviVC = self?.naviViewController {
                if let navigationController = naviVC.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    naviVC.dismiss(animated: true)
                }
            }
            
            self?.naviViewController = nil
            
            // 销毁导航管理器
            AMapNaviDriveManager.destroyInstance()
            AMapNaviWalkManager.destroyInstance()
            AMapNaviRideManager.destroyInstance()
            
            result(nil)
        }
    }
    
    // MARK: - Privacy
    
    private func updatePrivacy() {
        // 注意：不同版本 AMapNaviKit 的“隐私合规”API 名称可能不同。
        // 这里用运行时反射方式调用，避免因缺少 API 导致编译失败。
        //
        // 地图侧隐私合规已在 AMapSdkApi.swift 通过 MAMapView.updatePrivacy... 处理；
        // 这里尽力对 NaviKit 做同样处理（如果当前版本提供相应方法）。
        tryUpdatePrivacyIfAvailable(for: AMapNaviDriveManager.self)
        tryUpdatePrivacyIfAvailable(for: AMapNaviWalkManager.self)
        tryUpdatePrivacyIfAvailable(for: AMapNaviRideManager.self)
    }
    
    private func tryUpdatePrivacyIfAvailable(for cls: AnyClass) {
        // 尝试调用隐私合规方法
        // 使用协议扩展方式安全调用，避免 objc_msgSend 的兼容性问题
        
        guard let metaClass = cls as? NSObject.Type else { return }
        
        // class func updatePrivacyShow(_ showStatus: AMapPrivacyShowStatus, privacyInfo: AMapPrivacyInfoStatus)
        let selShow = NSSelectorFromString("updatePrivacyShow:privacyInfo:")
        if metaClass.responds(to: selShow) {
            // 使用 IMP 方式调用类方法
            let method = class_getClassMethod(cls, selShow)
            if let method = method {
                typealias MethodType = @convention(c) (AnyClass, Selector, AMapPrivacyShowStatus, AMapPrivacyInfoStatus) -> Void
                let imp = method_getImplementation(method)
                let function = unsafeBitCast(imp, to: MethodType.self)
                function(cls, selShow, AMapPrivacyShowStatus(true), AMapPrivacyInfoStatus(true))
            }
        }
        
        // class func updatePrivacyAgree(_ agreeStatus: AMapPrivacyAgreeStatus)
        let selAgree = NSSelectorFromString("updatePrivacyAgree:")
        if metaClass.responds(to: selAgree) {
            // 使用 IMP 方式调用类方法
            let method = class_getClassMethod(cls, selAgree)
            if let method = method {
                typealias MethodType = @convention(c) (AnyClass, Selector, AMapPrivacyAgreeStatus) -> Void
                let imp = method_getImplementation(method)
                let function = unsafeBitCast(imp, to: MethodType.self)
                function(cls, selAgree, AMapPrivacyAgreeStatus(true))
            }
        }
    }
    
    // MARK: - Utilities
    
    private func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return topViewController(from: rootViewController)
    }
    
    private func topViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return topViewController(from: presented)
        }
        
        if let navigation = viewController as? UINavigationController,
           let visible = navigation.visibleViewController {
            return topViewController(from: visible)
        }
        
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        
        return viewController
    }
}

// MARK: - FlutterStreamHandler
extension AMapNaviApi: FlutterStreamHandler {
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("[AMapNaviApi] EventChannel onListen")
        naviDelegate?.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("[AMapNaviApi] EventChannel onCancel")
        naviDelegate?.eventSink = nil
        return nil
    }
}

