import UIKit
import AMapNaviKit

/// 导航类型枚举
enum AMapNaviType: Int {
    case driver = 0
    case walk = 1
    case ride = 2
}

/// 导航页面类型枚举
enum AMapNaviPageType: Int {
    case route = 0  // 路线规划页
    case navi = 1   // 导航页
}

/// 高德导航视图控制器
/// 承载导航地图视图，处理导航页面的生命周期
class AMapNaviViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 导航类型
    var naviType: AMapNaviType = .driver
    
    /// 页面类型
    var pageType: AMapNaviPageType = .route
    
    /// 起点
    var startPoint: AMapNaviPoint?
    
    /// 终点
    var endPoint: AMapNaviPoint?
    
    /// 途经点
    var wayPoints: [AMapNaviPoint] = []
    
    /// 车牌号
    var carNumber: String?
    
    /// 导航代理
    weak var naviDelegate: AMapNaviDelegate?
    
    /// 退出回调
    var onExit: ((Int) -> Void)?
    
    // MARK: - Private Properties
    
    /// 驾车导航管理器
    private var driveManager: AMapNaviDriveManager?
    
    /// 步行导航管理器
    private var walkManager: AMapNaviWalkManager?
    
    /// 骑行导航管理器
    private var rideManager: AMapNaviRideManager?
    
    /// 驾车导航视图
    private var driveView: AMapNaviDriveView?
    
    /// 步行导航视图
    private var walkView: AMapNaviWalkView?
    
    /// 骑行导航视图
    private var rideView: AMapNaviRideView?
    
    /// 是否已开始导航
    private var isNavigating: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupNaviManager()
        setupNaviView()
        
        // 开始路径规划
        calculateRoute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 恢复导航栏
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        stopNavigation()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        // 创建关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.frame = CGRect(x: 16, y: 50, width: 60, height: 40)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)
    }
    
    private func setupNaviManager() {
        switch naviType {
        case .driver:
            setupDriveManager()
        case .walk:
            setupWalkManager()
        case .ride:
            setupRideManager()
        }
    }
    
    private func setupDriveManager() {
        driveManager = AMapNaviDriveManager.sharedInstance()
        driveManager?.delegate = naviDelegate
        
        // 设置车牌号（用于限行）
        if let carNumber = carNumber, !carNumber.isEmpty {
            driveManager?.vehicleInfo = AMapNaviVehicleInfo()
            driveManager?.vehicleInfo?.plateNumber = carNumber
        }
        
        // 发送初始化成功事件
        naviDelegate?.sendEvent(["type": "initSuccess"])
    }
    
    private func setupWalkManager() {
        walkManager = AMapNaviWalkManager.sharedInstance()
        walkManager?.delegate = naviDelegate
        
        naviDelegate?.sendEvent(["type": "initSuccess"])
    }
    
    private func setupRideManager() {
        rideManager = AMapNaviRideManager.sharedInstance()
        rideManager?.delegate = naviDelegate
        
        naviDelegate?.sendEvent(["type": "initSuccess"])
    }
    
    private func setupNaviView() {
        switch naviType {
        case .driver:
            setupDriveView()
        case .walk:
            setupWalkView()
        case .ride:
            setupRideView()
        }
    }
    
    private func setupDriveView() {
        driveView = AMapNaviDriveView(frame: view.bounds)
        driveView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        driveView?.delegate = self
        driveView?.showMoreButton = true
        driveView?.autoZoomMapLevel = true
        
        if let driveView = driveView {
            view.insertSubview(driveView, at: 0)
            driveManager?.addDataRepresentative(driveView)
        }
    }
    
    private func setupWalkView() {
        walkView = AMapNaviWalkView(frame: view.bounds)
        walkView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        walkView?.delegate = self
        
        if let walkView = walkView {
            view.insertSubview(walkView, at: 0)
            walkManager?.addDataRepresentative(walkView)
        }
    }
    
    private func setupRideView() {
        rideView = AMapNaviRideView(frame: view.bounds)
        rideView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rideView?.delegate = self
        
        if let rideView = rideView {
            view.insertSubview(rideView, at: 0)
            rideManager?.addDataRepresentative(rideView)
        }
    }
    
    // MARK: - Navigation
    
    private func calculateRoute() {
        guard let endPoint = endPoint else {
            print("[AMapNaviVC] 终点为空，无法规划路线")
            naviDelegate?.sendEvent([
                "type": "calculateRouteFailure",
                "errorCode": -1,
                "errorDescription": "终点不能为空"
            ])
            return
        }
        
        switch naviType {
        case .driver:
            calculateDriveRoute(endPoint: endPoint)
        case .walk:
            calculateWalkRoute(endPoint: endPoint)
        case .ride:
            calculateRideRoute(endPoint: endPoint)
        }
    }
    
    private func calculateDriveRoute(endPoint: AMapNaviPoint) {
        var startPoints: [AMapNaviPoint] = []
        if let start = startPoint {
            startPoints.append(start)
        }
        
        let wayPointsArray = wayPoints.isEmpty ? nil : wayPoints
        
        driveManager?.calculateDriveRoute(
            withStart: startPoints,
            end: [endPoint],
            wayPoints: wayPointsArray,
            drivingStrategy: .singleDefault
        )
    }
    
    private func calculateWalkRoute(endPoint: AMapNaviPoint) {
        var startPoints: [AMapNaviPoint] = []
        if let start = startPoint {
            startPoints.append(start)
        }
        
        walkManager?.calculateWalkRoute(
            withStart: startPoints,
            end: [endPoint]
        )
    }
    
    private func calculateRideRoute(endPoint: AMapNaviPoint) {
        var startPoints: [AMapNaviPoint] = []
        if let start = startPoint {
            startPoints.append(start)
        }
        
        rideManager?.calculateRideRoute(
            withStart: startPoints,
            end: [endPoint]
        )
    }
    
    /// 开始 GPS 导航
    func startGPSNavigation() {
        guard !isNavigating else { return }
        
        isNavigating = true
        
        switch naviType {
        case .driver:
            driveManager?.startGPSNavi()
        case .walk:
            walkManager?.startGPSNavi()
        case .ride:
            rideManager?.startGPSNavi()
        }
    }
    
    /// 开始模拟导航
    func startEmulatorNavigation() {
        guard !isNavigating else { return }
        
        isNavigating = true
        
        switch naviType {
        case .driver:
            driveManager?.startEmulatorNavi()
        case .walk:
            walkManager?.startEmulatorNavi()
        case .ride:
            rideManager?.startEmulatorNavi()
        }
    }
    
    /// 停止导航
    func stopNavigation() {
        isNavigating = false
        
        switch naviType {
        case .driver:
            driveManager?.stopNavi()
            if let driveView = driveView {
                driveManager?.removeDataRepresentative(driveView)
            }
            driveManager?.delegate = nil
        case .walk:
            walkManager?.stopNavi()
            if let walkView = walkView {
                walkManager?.removeDataRepresentative(walkView)
            }
            walkManager?.delegate = nil
        case .ride:
            rideManager?.stopNavi()
            if let rideView = rideView {
                rideManager?.removeDataRepresentative(rideView)
            }
            rideManager?.delegate = nil
        }
        
        driveView?.removeFromSuperview()
        walkView?.removeFromSuperview()
        rideView?.removeFromSuperview()
        
        driveView = nil
        walkView = nil
        rideView = nil
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        exitNavigation(exitCode: 0)
    }
    
    private func exitNavigation(exitCode: Int) {
        stopNavigation()
        
        // 发送退出事件
        naviDelegate?.sendEvent([
            "type": "exitPage",
            "exitCode": exitCode
        ])
        
        onExit?(exitCode)
        
        // 关闭页面
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - AMapNaviDriveViewDelegate
extension AMapNaviViewController: AMapNaviDriveViewDelegate {
    
    func driveViewCloseButtonClicked(_ driveView: AMapNaviDriveView) {
        exitNavigation(exitCode: 0)
    }
    
    func driveViewMoreButtonClicked(_ driveView: AMapNaviDriveView) {
        // 更多按钮点击
    }
    
    func driveView(_ driveView: AMapNaviDriveView, turnIndicatorView: UIView?, at navigationInfo: AMapNaviInfo?) {
        // 转向指示器
    }
    
    func driveViewDidEnterMain(_ driveView: AMapNaviDriveView) {
        // 进入主导航界面
        if pageType == .navi {
            startGPSNavigation()
        }
    }
}

// MARK: - AMapNaviWalkViewDelegate
extension AMapNaviViewController: AMapNaviWalkViewDelegate {
    
    func walkViewCloseButtonClicked(_ walkView: AMapNaviWalkView) {
        exitNavigation(exitCode: 0)
    }
}

// MARK: - AMapNaviRideViewDelegate
extension AMapNaviViewController: AMapNaviRideViewDelegate {
    
    func rideViewCloseButtonClicked(_ rideView: AMapNaviRideView) {
        exitNavigation(exitCode: 0)
    }
}

