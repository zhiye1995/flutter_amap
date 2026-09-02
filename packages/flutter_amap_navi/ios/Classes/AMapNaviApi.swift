import Flutter
import UIKit
import AMapNaviKit
import AMapFoundationKit

/// 高德导航 API 处理类
class AMapNaviApi: NSObject {
    
    private static let NAVI_METHOD_CHANNEL = "plugins.flutter.dev/amap_navi"
    private static let NAVI_EVENT_CHANNEL = "plugins.flutter.dev/amap_navi_events"
    
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var naviDelegate: AMapNaviDelegate?
    
    /// 组合导航管理器（驾车导航使用）
    private var compositeManager: AMapNaviCompositeManager?
    
    /// 步行导航视图控制器
    private var walkNaviVC: AMapNaviWalkRideViewController?
    
    /// 骑行导航视图控制器
    private var rideNaviVC: AMapNaviWalkRideViewController?
    
    /// 当前导航类型
    private var currentNaviType: AMapNaviType = .driver
    
    /// 智能巡航是否开启（用于 stopNavigation / 互斥）
    private var isCruiseModeActive: Bool = false
    private var cruiseDataRepresentativeAttached: Bool = false
    
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
        case "startCruiseMode":
            startCruiseMode(call: call, result: result)
        case "stopCruiseMode":
            stopCruiseMode(result: result)
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
        
        // 解析参数
        let carNumber = arguments["carNumber"] as? String
        let vehicleInfo = arguments["vehicleInfo"] as? [String: Any]
        let drivingStrategy = arguments["drivingStrategy"] as? Int ?? 10
        let travelStrategy = arguments["travelStrategy"] as? Int
        let multipleRoute = arguments["multipleRoute"] as? Bool ?? true
        let startNaviDirectly = arguments["startNaviDirectly"] as? Bool
        let naviTypeIndex = arguments["naviType"] as? Int ?? 0
        let pageTypeIndex = arguments["pageType"] as? Int ?? 0
        
        let startLat = arguments["startLat"] as? Double
        let startLng = arguments["startLng"] as? Double
        let startName = arguments["startName"] as? String ?? "起点"
        let startPoiId = arguments["startPoiId"] as? String
        let startAngle = arguments["startAngle"] as? Double
        
        let endLat = arguments["endLat"] as? Double
        let endLng = arguments["endLng"] as? Double
        let endName = arguments["endName"] as? String ?? "终点"
        let endPoiId = arguments["endPoiId"] as? String
        let endAngle = arguments["endAngle"] as? Double
        
        let wayPointsList = arguments["wayPoints"] as? [[String: Any]]
        
        // 构建起点
        var startPoint: AMapNaviPoint?
        if let lat = startLat, let lng = startLng {
            startPoint = AMapNaviPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng))
        }
        
        // 构建终点（允许为空，交由导航页选择）
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
        
        // 导航类型和页面类型
        let naviType = AMapNaviType(rawValue: naviTypeIndex) ?? .driver
        let pageType = AMapNaviPageType(rawValue: pageTypeIndex) ?? .route

        // 步行/骑行导航必须要有终点
        if endPoint == nil && (naviType == .walk || naviType == .ride) {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "步行/骑行导航需要终点", details: nil))
            return
        }
        
        // 保存当前导航类型
        self.currentNaviType = naviType
        
        print("[AMapNaviApi] startNavigation: naviType=\(naviTypeIndex), pageType=\(pageType), start=\(String(describing: startPoint)), end=\(String(describing: endPoint)), wayPoints=\(wayPoints.count)")
        
        // 根据导航类型选择不同的导航方式
        switch naviType {
        case .driver:
            // 驾车导航 - 使用 AMapNaviCompositeManager
            startDriveNavigation(
                startPoint: startPoint,
                startName: startName,
                endPoint: endPoint,
                endName: endName,
                wayPoints: wayPoints,
                carNumber: carNumber,
                vehicleInfo: vehicleInfo,
                startPoiId: startPoiId,
                endPoiId: endPoiId,
                startAngle: startAngle,
                endAngle: endAngle,
                drivingStrategy: drivingStrategy,
                multipleRoute: multipleRoute,
                startNaviDirectly: startNaviDirectly,
                pageType: pageType,
                result: result
            )
        case .walk:
            guard let endPoint = endPoint else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "步行/骑行导航需要终点", details: nil))
                return
            }
            // 步行导航 - 使用 AMapNaviWalkManager
            startWalkNavigation(
                startPoint: startPoint,
                endPoint: endPoint,
                endName: endName,
                startPoiId: startPoiId,
                endPoiId: endPoiId,
                startAngle: startAngle,
                endAngle: endAngle,
                travelStrategy: travelStrategy,
                pageType: pageType,
                result: result
            )
        case .ride:
            guard let endPoint = endPoint else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "步行/骑行导航需要终点", details: nil))
                return
            }
            // 骑行导航 - 使用 AMapNaviRideManager
            startRideNavigation(
                startPoint: startPoint,
                endPoint: endPoint,
                endName: endName,
                startPoiId: startPoiId,
                endPoiId: endPoiId,
                startAngle: startAngle,
                endAngle: endAngle,
                travelStrategy: travelStrategy,
                pageType: pageType,
                result: result
            )
        }
    }
    
    // MARK: - 驾车导航
    
    private func startDriveNavigation(
        startPoint: AMapNaviPoint?,
        startName: String,
        endPoint: AMapNaviPoint?,
        endName: String,
        wayPoints: [AMapNaviPoint],
        carNumber: String?,
        vehicleInfo: [String: Any]?,
        startPoiId: String?,
        endPoiId: String?,
        startAngle: Double?,
        endAngle: Double?,
        drivingStrategy: Int,
        multipleRoute: Bool,
        startNaviDirectly: Bool?,
        pageType: AMapNaviPageType,
        result: @escaping FlutterResult
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "INTERNAL_ERROR", message: "内部错误", details: nil))
                return
            }
            
            // 创建组合导航管理器
            self.compositeManager = AMapNaviCompositeManager()
            self.compositeManager?.delegate = self
            
            // 同时设置 AMapNaviDriveManager 的代理来获取导航事件和数据
            // AMapNaviCompositeManager 内部使用了 AMapNaviDriveManager 单例
            // 但 CompositeManagerDelegate 没有导航信息更新（navInfo）回调
            // 
            // 高德SDK有两套回调协议：
            // - AMapNaviDriveManagerDelegate: 事件回调（通过 delegate 设置）
            // - AMapNaviDriveDataRepresentable: 数据回调（通过 addDataRepresentative 注册）
            //
            // 需要同时设置两者才能获取完整的导航信息
            let driveManager = AMapNaviDriveManager.sharedInstance()
            driveManager.delegate = self.naviDelegate
            
            // 注册数据代理以获取 NaviInfo、定位信息、电子眼信息等实时数据
            if let delegate = self.naviDelegate {
                driveManager.addDataRepresentative(delegate)
            }
            
            // 创建导航配置
            let config = AMapNaviCompositeUserConfig()
            
            // 设置起点（如果有）
            if let start = startPoint {
                let _ = config.setRoutePlanPOIType(
                    .start,
                    location: start,
                    name: startName,
                    poiId: startPoiId
                )
            }
            
            // 设置终点（允许为空，交由页面选择）
            if let endPoint = endPoint {
                let _ = config.setRoutePlanPOIType(
                    .end,
                    location: endPoint,
                    name: endName,
                    poiId: endPoiId
                )
            }
            
            // 设置途经点（最多支持3个）
            for (index, wayPoint) in wayPoints.prefix(3).enumerated() {
                let _ = config.setRoutePlanPOIType(
                    .way,
                    location: wayPoint,
                    name: "途经点\(index + 1)",
                    poiId: nil
                )
            }
            
            // 设置车辆信息（如果有车牌号）
            if let carNumber = carNumber, !carNumber.isEmpty {
                let vehicleInfo = AMapNaviVehicleInfo()
                vehicleInfo.vehicleId = carNumber
                config.setVehicleInfo(vehicleInfo)
            }
            if let vehicleInfo = vehicleInfo {
                config.setVehicleInfo(self.makeVehicleInfo(vehicleInfo, fallbackCarNumber: carNumber))
            }
            config.setDrive(
                AMapNaviDrivingStrategy(rawValue: drivingStrategy) ?? AMapNaviDrivingStrategy.motorStrategyMultipleDefault
            )
            
            // 根据页面类型设置是否直接开始导航
            if (startNaviDirectly ?? (pageType == .navi)) && endPoint != nil {
                // 直接导航模式：跳过路线规划页面，直接开始导航
                config.setStartNaviDirectly(true)
            } else {
                // 路线规划模式：显示路线规划页面（终点为空时强制走路线规划）
                config.setStartNaviDirectly(false)
            }
            
            // 设置多路线模式（推荐多条路线）
            config.setMultipleRouteNaviMode(multipleRoute)
            
            // 发送初始化成功事件
            self.naviDelegate?.sendEvent(["type": "initSuccess"])
            
            // 启动组合导航（AMapNaviCompositeManager会自动管理界面展示）
            self.compositeManager?.presentRoutePlanViewController(withOptions: config)
            
            result(nil)
        }
    }
    
    // MARK: - 步行导航
    
    private func startWalkNavigation(
        startPoint: AMapNaviPoint?,
        endPoint: AMapNaviPoint,
        endName: String,
        startPoiId: String?,
        endPoiId: String?,
        startAngle: Double?,
        endAngle: Double?,
        travelStrategy: Int?,
        pageType: AMapNaviPageType,
        result: @escaping FlutterResult
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "INTERNAL_ERROR", message: "内部错误", details: nil))
                return
            }
            
            // 获取步行导航管理器
            let walkManager = AMapNaviWalkManager.sharedInstance()
            walkManager.delegate = self.naviDelegate
            
            // 发送初始化成功事件
            self.naviDelegate?.sendEvent(["type": "initSuccess"])
            
            // 设置路线计算成功回调
            self.naviDelegate?.onRouteCalculateSuccess = { [weak self] in
                guard let self = self else { return }
                self.presentWalkRideNaviVC(naviType: .walk, endName: endName, pageType: pageType)
            }
            
            // 计算步行路线（步行导航只支持单起点单终点）
            print("[AMapNaviApi] 计算步行路线: start=\(String(describing: startPoint)), end=\(endPoint)")
            if let startInfo = self.makePOIInfo(point: startPoint, poiId: startPoiId, angle: startAngle),
               let endInfo = self.makePOIInfo(point: endPoint, poiId: endPoiId, angle: endAngle),
               (startPoiId != nil || endPoiId != nil || travelStrategy != nil) {
                let strategy = AMapNaviTravelStrategy(rawValue: travelStrategy ?? 1000) ?? AMapNaviTravelStrategy.singleDefault
                walkManager.calculateWalkRoute(withStart: startInfo, end: endInfo, strategy: strategy)
            } else if let start = startPoint {
                walkManager.calculateWalkRoute(withStart: [start], end: [endPoint])
            } else {
                // 无起点时使用当前位置
                walkManager.calculateWalkRoute(withEnd: [endPoint])
            }
            
            result(nil)
        }
    }
    
    // MARK: - 骑行导航
    
    private func startRideNavigation(
        startPoint: AMapNaviPoint?,
        endPoint: AMapNaviPoint,
        endName: String,
        startPoiId: String?,
        endPoiId: String?,
        startAngle: Double?,
        endAngle: Double?,
        travelStrategy: Int?,
        pageType: AMapNaviPageType,
        result: @escaping FlutterResult
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "INTERNAL_ERROR", message: "内部错误", details: nil))
                return
            }
            
            // 获取骑行导航管理器
            let rideManager = AMapNaviRideManager.sharedInstance()
            rideManager.delegate = self.naviDelegate
            
            // 发送初始化成功事件
            self.naviDelegate?.sendEvent(["type": "initSuccess"])
            
            // 设置路线计算成功回调
            self.naviDelegate?.onRouteCalculateSuccess = { [weak self] in
                guard let self = self else { return }
                self.presentWalkRideNaviVC(naviType: .ride, endName: endName, pageType: pageType)
            }
            
            // 计算骑行路线（骑行导航只支持单起点单终点）
            print("[AMapNaviApi] 计算骑行路线: start=\(String(describing: startPoint)), end=\(endPoint)")
            if let startInfo = self.makePOIInfo(point: startPoint, poiId: startPoiId, angle: startAngle),
               let endInfo = self.makePOIInfo(point: endPoint, poiId: endPoiId, angle: endAngle),
               (startPoiId != nil || endPoiId != nil || travelStrategy != nil) {
                let strategy = AMapNaviTravelStrategy(rawValue: travelStrategy ?? 1000) ?? AMapNaviTravelStrategy.singleDefault
                rideManager.calculateRideRoute(withStart: startInfo, end: endInfo, strategy: strategy)
            } else if let start = startPoint {
                rideManager.calculateRideRoute(withStart: start, end: endPoint)
            } else {
                // 无起点时使用当前位置
                rideManager.calculateRideRoute(withEnd: endPoint)
            }
            
            result(nil)
        }
    }
    
    // MARK: - 展示步行/骑行导航视图
    
    private func presentWalkRideNaviVC(naviType: AMapNaviType, endName: String, pageType: AMapNaviPageType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 获取当前的 ViewController
            guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
                print("[AMapNaviApi] 无法获取 rootViewController")
                return
            }
            
            // 找到最顶层的 ViewController
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            // 创建步行/骑行导航视图控制器
            let naviVC = AMapNaviWalkRideViewController(
                naviType: naviType,
                endName: endName,
                pageType: pageType,
                naviDelegate: self.naviDelegate
            )
            naviVC.modalPresentationStyle = .fullScreen
            naviVC.onDismiss = { [weak self] in
                self?.handleWalkRideNaviDismiss()
            }
            
            // 保存引用
            if naviType == .walk {
                self.walkNaviVC = naviVC
            } else {
                self.rideNaviVC = naviVC
            }
            
            // 展示导航视图
            topVC.present(naviVC, animated: true)
        }
    }

    private func makePOIInfo(point: AMapNaviPoint?, poiId: String?, angle: Double?) -> AMapNaviPOIInfo? {
        guard point != nil || (poiId != nil && !poiId!.isEmpty) else { return nil }
        let info = AMapNaviPOIInfo()
        info.locPoint = point
        if let poiId = poiId, !poiId.isEmpty {
            info.mid = poiId
        }
        if let angle = angle {
            info.startAngle = angle
        }
        return info
    }

    private func makeVehicleInfo(_ map: [String: Any], fallbackCarNumber: String?) -> AMapNaviVehicleInfo {
        let info = AMapNaviVehicleInfo()
        info.vehicleId = (map["vehicleId"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? fallbackCarNumber
        if let value = map["type"] as? Int { info.type = value }
        if let value = map["size"] as? Int { info.size = value }
        if let value = map["height"] as? Double { info.height = value }
        if let value = map["width"] as? Double { info.width = value }
        if let value = map["length"] as? Double { info.length = value }
        if let value = map["load"] as? Double { info.load = value }
        if let value = map["weight"] as? Double { info.weight = value }
        if let value = map["axisNums"] as? Int { info.axisNums = value }
        return info
    }
    
    // MARK: - 智能巡航
    
    private func startCruiseMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "参数无效", details: nil))
            return
        }
        let modeCode = arguments["mode"] as? Int ?? 3
        let allowsBackgroundLocationUpdates = arguments["allowsBackgroundLocationUpdates"] as? Bool ?? true
        let pausesLocationUpdatesAutomatically = arguments["pausesLocationUpdatesAutomatically"] as? Bool ?? false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "INTERNAL_ERROR", message: "内部错误", details: nil))
                return
            }
            
            if self.compositeManager != nil {
                result(FlutterError(
                    code: "CRUISE_CONFLICT",
                    message: "驾车导航组件已展示，无法同时开启巡航；请先结束导航",
                    details: nil
                ))
                return
            }
            
            let driveManager = AMapNaviDriveManager.sharedInstance()
            driveManager.delegate = self.naviDelegate
            driveManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
            driveManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
            self.attachCruiseDataRepresentative(to: driveManager)
            
            let detected: AMapNaviDetectedMode
            switch modeCode {
            case 1:
                detected = .camera
            case 2:
                detected = .specialRoad
            case 3:
                fallthrough
            default:
                detected = .cameraAndSpecialRoad
            }
            
            driveManager.detectedMode = detected
            self.isCruiseModeActive = true
            
            print("[AMapNaviApi] startCruiseMode modeCode=\(modeCode) detectedMode=\(detected.rawValue)")
            result(nil)
        }
    }
    
    private func stopCruiseMode(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(nil)
                return
            }
            let driveManager = AMapNaviDriveManager.sharedInstance()
            driveManager.detectedMode = .none
            self.detachCruiseDataRepresentative(from: driveManager)
            driveManager.delegate = nil
            self.isCruiseModeActive = false
            print("[AMapNaviApi] stopCruiseMode")
            result(nil)
        }
    }
    
    private func attachCruiseDataRepresentative(to driveManager: AMapNaviDriveManager) {
        guard !cruiseDataRepresentativeAttached, let delegate = naviDelegate else {
            return
        }
        driveManager.addDataRepresentative(delegate)
        cruiseDataRepresentativeAttached = true
    }
    
    private func detachCruiseDataRepresentative(from driveManager: AMapNaviDriveManager) {
        guard cruiseDataRepresentativeAttached, let delegate = naviDelegate else {
            return
        }
        driveManager.removeDataRepresentative(delegate)
        cruiseDataRepresentativeAttached = false
    }
    
    private func handleWalkRideNaviDismiss() {
        // 发送退出事件
        naviDelegate?.sendEvent([
            "type": "exitPage",
            "exitCode": 0
        ])
        
        // 清理资源
        walkNaviVC = nil
        rideNaviVC = nil
        naviDelegate?.onRouteCalculateSuccess = nil
        
        // 清理管理器
        AMapNaviWalkManager.sharedInstance().delegate = nil
        AMapNaviRideManager.sharedInstance().delegate = nil
    }
    
    private func stopNavigation(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(nil)
                return
            }
            
            if self.isCruiseModeActive {
                let driveManager = AMapNaviDriveManager.sharedInstance()
                driveManager.detectedMode = .none
                self.detachCruiseDataRepresentative(from: driveManager)
                driveManager.delegate = nil
                self.isCruiseModeActive = false
            }
            
            // 根据当前导航类型清理对应的资源
            switch self.currentNaviType {
            case .driver:
                // 清理驾车导航
                self.compositeManager?.dismissWith(animated: true)
                self.compositeManager?.delegate = nil
                self.compositeManager = nil
                
                // 清理 DriveManager 的代理和数据代理
                let driveManager = AMapNaviDriveManager.sharedInstance()
                if let delegate = self.naviDelegate {
                    driveManager.removeDataRepresentative(delegate)
                }
                self.cruiseDataRepresentativeAttached = false
                driveManager.delegate = nil
                
            case .walk:
                // 清理步行导航
                self.walkNaviVC?.dismiss(animated: true)
                self.walkNaviVC = nil
                AMapNaviWalkManager.sharedInstance().stopNavi()
                AMapNaviWalkManager.sharedInstance().delegate = nil
                
            case .ride:
                // 清理骑行导航
                self.rideNaviVC?.dismiss(animated: true)
                self.rideNaviVC = nil
                AMapNaviRideManager.sharedInstance().stopNavi()
                AMapNaviRideManager.sharedInstance().delegate = nil
            }
            
            // 清理回调
            self.naviDelegate?.onRouteCalculateSuccess = nil
            
            // 销毁导航管理器
            AMapNaviDriveManager.destroyInstance()
            AMapNaviWalkManager.destroyInstance()
            AMapNaviRideManager.destroyInstance()
            
            result(nil)
        }
    }
    
}

// MARK: - AMapNaviCompositeManagerDelegate
extension AMapNaviApi: AMapNaviCompositeManagerDelegate {
    
    /// 发生错误时回调
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, error: Error) {
        print("[AMapNaviApi] compositeManager error: \(error.localizedDescription)")
        let nsError = error as NSError
        naviDelegate?.sendEvent([
            "type": "error",
            "errorCode": nsError.code,
            "errorDescription": error.localizedDescription
        ])
    }
    
    /// 路线规划成功
    func compositeManager(onCalculateRouteSuccess compositeManager: AMapNaviCompositeManager) {
        print("[AMapNaviApi] onCalculateRouteSuccess")
        let routeIds = compositeManager.naviRouteIDs?.map { $0.intValue } ?? [0]
        naviDelegate?.sendEvent([
            "type": "calculateRouteSuccess",
            "routeIds": routeIds,
            "errorCode": 0,
            "errorDescription": ""
        ])
    }
    
    /// 路线规划成功（带类型）
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, onCalculateRouteSuccessWith type: AMapNaviRoutePlanType) {
        print("[AMapNaviApi] onCalculateRouteSuccessWithType: \(type.rawValue)")
        let routeIds = compositeManager.naviRouteIDs?.map { $0.intValue } ?? [0]
        naviDelegate?.sendEvent([
            "type": "calculateRouteSuccess",
            "routeIds": routeIds,
            "routePlanType": type.rawValue,
            "errorCode": 0,
            "errorDescription": ""
        ])
    }
    
    /// 路线规划失败
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, onCalculateRouteFailure error: Error) {
        print("[AMapNaviApi] onCalculateRouteFailure: \(error.localizedDescription)")
        let nsError = error as NSError
        naviDelegate?.sendEvent([
            "type": "calculateRouteFailure",
            "errorCode": nsError.code,
            "errorDescription": error.localizedDescription
        ])
    }
    
    /// 开始导航
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, didStartNavi naviMode: AMapNaviMode) {
        print("[AMapNaviApi] didStartNavi: \(naviMode.rawValue)")
        let type = naviMode == .GPS ? 1 : 2
        naviDelegate?.sendEvent([
            "type": "startNavi",
            "naviType": type
        ])
    }
    
    /// 到达目的地
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, didArrivedDestination naviMode: AMapNaviMode) {
        print("[AMapNaviApi] didArrivedDestination")
        naviDelegate?.sendEvent(["type": "arriveDestination"])
    }
    
    /// 导航组件页面回退或退出
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, didBackwardAction backwardActionType: AMapNaviCompositeVCBackwardActionType) {
        print("[AMapNaviApi] didBackwardAction: \(backwardActionType.rawValue)")
        
        var exitCode = 0
        switch backwardActionType {
        case .dismiss:
            exitCode = 0  // 退出整个导航组件
        case .naviPop:
            exitCode = 1  // 退出导航界面
        @unknown default:
            exitCode = 0
        }
        
        // 发送退出事件
        naviDelegate?.sendEvent([
            "type": "exitPage",
            "exitCode": exitCode
        ])
        
        // 清理资源
        if backwardActionType == .dismiss {
            self.compositeManager?.delegate = nil
            self.compositeManager = nil
            // 清理 DriveManager 的代理和数据代理
            let driveManager = AMapNaviDriveManager.sharedInstance()
            if let delegate = self.naviDelegate {
                driveManager.removeDataRepresentative(delegate)
            }
            self.cruiseDataRepresentativeAttached = false
            driveManager.delegate = nil
        }
    }
    
    /// 当前位置更新
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, update naviLocation: AMapNaviLocation?) {
        guard let location = naviLocation else { return }
        
        naviDelegate?.sendEvent([
            "type": "locationChange",
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "bearing": location.heading,
            "roadBearing": location.heading,
            "speed": location.speed,
            "accuracy": location.accuracy,
            "altitude": location.altitude,
            "time": Int(Date().timeIntervalSince1970 * 1000),
            "matchStatus": 0,
            "locationDataType": 0,
            "locationType": 0,
            "curStepIndex": location.currentSegmentIndex,
            "curLinkIndex": location.currentLinkIndex,
            "curPointIndex": location.currentPointIndex,
            "raw": "\(location)"
        ])
    }
    
    // 注意：不要实现 compositeManager(_:playNaviSound:soundStringType:) 方法
    // 如果实现了这个方法，SDK会认为你要自定义语音播报，而不是使用内置语音
    // 不实现这个方法，SDK会自动使用内置的TTS语音播报导航指引
    
    /// 到达途经点
    func compositeManager(_ compositeManager: AMapNaviCompositeManager, onArrivedWayPoint wayPointIndex: Int32) {
        print("[AMapNaviApi] onArrivedWayPoint: \(wayPointIndex)")
        naviDelegate?.sendEvent([
            "type": "arrivedWayPoint",
            "wayPointIndex": Int(wayPointIndex)
        ])
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
