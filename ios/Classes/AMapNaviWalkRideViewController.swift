import UIKit
import AMapNaviKit

/// 步行/骑行导航视图控制器
/// 用于展示步行和骑行的导航界面，因为两者 UI 相似所以共用一个类
class AMapNaviWalkRideViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 导航类型（步行/骑行）
    private let naviType: AMapNaviType
    
    /// 终点名称
    private let endName: String
    
    /// 页面类型（路线规划/直接导航）
    private let pageType: AMapNaviPageType
    
    /// 导航代理
    private weak var naviDelegate: AMapNaviDelegate?
    
    /// 退出回调
    var onDismiss: (() -> Void)?
    
    /// 地图视图
    private var mapView: MAMapView!
    
    /// 导航管理视图（用于在地图上绘制路线）
    private var driveView: MAMapView { return mapView }
    
    /// 是否正在导航中
    private var isNavigating: Bool = false
    
    /// 路线折线
    private var routePolyline: MAPolyline?
    
    // MARK: - UI Components
    
    /// 顶部信息栏
    private lazy var topInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 导航类型标签
    private lazy var naviTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 终点名称标签
    private lazy var destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 剩余距离标签
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 剩余时间标签
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 关闭按钮
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    /// 底部按钮栏
    private lazy var bottomButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 开始导航按钮
    private lazy var startNaviButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始导航", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startNaviTapped), for: .touchUpInside)
        return button
    }()
    
    /// 转向图标视图
    private lazy var turnIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    /// 下一路段名称标签
    private lazy var nextRoadLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    /// 当前路段剩余距离标签
    private lazy var stepDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Init
    
    init(naviType: AMapNaviType, endName: String, pageType: AMapNaviPageType, naviDelegate: AMapNaviDelegate?) {
        self.naviType = naviType
        self.endName = endName
        self.pageType = pageType
        self.naviDelegate = naviDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        displayRoute()
        
        // 如果是直接导航模式，直接开始导航
        if pageType == .navi {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNaviTapped()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            stopNavigation()
            onDismiss?()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置导航类型标签
        naviTypeLabel.text = naviType == .walk ? "步行" : "骑行"
        destinationLabel.text = "前往 \(endName)"
        
        // 添加子视图
        view.addSubview(topInfoView)
        topInfoView.addSubview(closeButton)
        topInfoView.addSubview(naviTypeLabel)
        topInfoView.addSubview(destinationLabel)
        topInfoView.addSubview(distanceLabel)
        topInfoView.addSubview(timeLabel)
        topInfoView.addSubview(turnIconView)
        topInfoView.addSubview(nextRoadLabel)
        topInfoView.addSubview(stepDistanceLabel)
        
        view.addSubview(bottomButtonView)
        bottomButtonView.addSubview(startNaviButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 顶部信息栏
            topInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topInfoView.heightAnchor.constraint(equalToConstant: 120),
            
            // 关闭按钮
            closeButton.topAnchor.constraint(equalTo: topInfoView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: topInfoView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 导航类型标签
            naviTypeLabel.topAnchor.constraint(equalTo: topInfoView.topAnchor, constant: 12),
            naviTypeLabel.leadingAnchor.constraint(equalTo: topInfoView.leadingAnchor, constant: 16),
            
            // 终点名称
            destinationLabel.topAnchor.constraint(equalTo: naviTypeLabel.bottomAnchor, constant: 8),
            destinationLabel.leadingAnchor.constraint(equalTo: topInfoView.leadingAnchor, constant: 16),
            destinationLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            // 剩余距离
            distanceLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 8),
            distanceLabel.leadingAnchor.constraint(equalTo: topInfoView.leadingAnchor, constant: 16),
            
            // 剩余时间
            timeLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 16),
            
            // 转向图标
            turnIconView.topAnchor.constraint(equalTo: topInfoView.topAnchor, constant: 12),
            turnIconView.leadingAnchor.constraint(equalTo: topInfoView.leadingAnchor, constant: 16),
            turnIconView.widthAnchor.constraint(equalToConstant: 48),
            turnIconView.heightAnchor.constraint(equalToConstant: 48),
            
            // 下一路段名称
            nextRoadLabel.centerYAnchor.constraint(equalTo: turnIconView.centerYAnchor),
            nextRoadLabel.leadingAnchor.constraint(equalTo: turnIconView.trailingAnchor, constant: 12),
            nextRoadLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            // 当前路段剩余距离
            stepDistanceLabel.topAnchor.constraint(equalTo: turnIconView.bottomAnchor, constant: 8),
            stepDistanceLabel.leadingAnchor.constraint(equalTo: topInfoView.leadingAnchor, constant: 16),
            
            // 底部按钮栏
            bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 80),
            
            // 开始导航按钮
            startNaviButton.centerXAnchor.constraint(equalTo: bottomButtonView.centerXAnchor),
            startNaviButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
            startNaviButton.widthAnchor.constraint(equalTo: bottomButtonView.widthAnchor, constant: -32),
            startNaviButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupMapView() {
        // 创建地图视图
        mapView = MAMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsCompass = true
        mapView.showsScale = true
        
        view.insertSubview(mapView, at: 0)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topInfoView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor)
        ])
    }
    
    // MARK: - Route Display
    
    private func displayRoute() {
        // 获取路线信息
        var route: AMapNaviRoute?
        
        if naviType == .walk {
            route = AMapNaviWalkManager.sharedInstance().naviRoute
        } else {
            route = AMapNaviRideManager.sharedInstance().naviRoute
        }
        
        guard let naviRoute = route else {
            print("[AMapNaviWalkRideVC] 无法获取路线信息")
            return
        }
        
        // 更新距离和时间信息
        updateRouteInfo(route: naviRoute)
        
        // 绘制路线
        drawRoute(route: naviRoute)
    }
    
    private func updateRouteInfo(route: AMapNaviRoute) {
        // 格式化距离
        let distance = route.routeLength
        let distanceStr = distance >= 1000 ? String(format: "%.1f公里", Double(distance) / 1000.0) : "\(distance)米"
        distanceLabel.text = "全程 \(distanceStr)"
        
        // 格式化时间
        let time = route.routeTime
        let timeStr: String
        if time >= 3600 {
            let hours = time / 3600
            let minutes = (time % 3600) / 60
            timeStr = "\(hours)小时\(minutes)分钟"
        } else if time >= 60 {
            timeStr = "\(time / 60)分钟"
        } else {
            timeStr = "\(time)秒"
        }
        timeLabel.text = "约 \(timeStr)"
    }
    
    private func drawRoute(route: AMapNaviRoute) {
        // 获取路线坐标点
        let routeCoords = route.routeCoordinates
        guard !routeCoords.isEmpty else {
            print("[AMapNaviWalkRideVC] 路线坐标为空")
            return
        }
        
        // 转换为 CLLocationCoordinate2D 数组
        var coords: [CLLocationCoordinate2D] = []
        for point in routeCoords {
            coords.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(point.latitude), longitude: CLLocationDegrees(point.longitude)))
        }
        
        // 移除旧的折线
        if let oldPolyline = routePolyline {
            mapView.remove(oldPolyline)
        }
        
        // 创建新的折线
        let polyline = MAPolyline(coordinates: &coords, count: UInt(coords.count))
        routePolyline = polyline
        mapView.add(polyline)
        
        // 添加起点和终点标注
        if let startCoord = coords.first {
            let startAnnotation = MAPointAnnotation()
            startAnnotation.coordinate = startCoord
            startAnnotation.title = "起点"
            mapView.addAnnotation(startAnnotation)
        }
        
        if let endCoord = coords.last {
            let endAnnotation = MAPointAnnotation()
            endAnnotation.coordinate = endCoord
            endAnnotation.title = endName
            mapView.addAnnotation(endAnnotation)
        }
        
        // 调整地图显示范围
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    // MARK: - Navigation Control
    
    @objc private func startNaviTapped() {
        isNavigating = true
        
        // 更新 UI 为导航模式
        updateUIForNavigation(true)
        
        // 开始导航
        if naviType == .walk {
            AMapNaviWalkManager.sharedInstance().startGPSNavi()
        } else {
            AMapNaviRideManager.sharedInstance().startGPSNavi()
        }
        
        // 设置地图跟随模式
        mapView.userTrackingMode = .followWithHeading
        mapView.setZoomLevel(17, animated: true)
        
        // 发送开始导航事件
        naviDelegate?.sendEvent([
            "type": "startNavi",
            "naviType": 1  // GPS 导航
        ])
    }
    
    @objc private func closeTapped() {
        stopNavigation()
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
    
    private func stopNavigation() {
        if naviType == .walk {
            AMapNaviWalkManager.sharedInstance().stopNavi()
        } else {
            AMapNaviRideManager.sharedInstance().stopNavi()
        }
        isNavigating = false
    }
    
    private func updateUIForNavigation(_ navigating: Bool) {
        if navigating {
            // 导航模式：显示转向信息，隐藏路线概览信息
            naviTypeLabel.isHidden = true
            destinationLabel.isHidden = true
            distanceLabel.isHidden = false
            timeLabel.isHidden = false
            turnIconView.isHidden = false
            nextRoadLabel.isHidden = false
            stepDistanceLabel.isHidden = false
            
            startNaviButton.setTitle("结束导航", for: .normal)
            startNaviButton.backgroundColor = .systemRed
            startNaviButton.removeTarget(self, action: #selector(startNaviTapped), for: .touchUpInside)
            startNaviButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        } else {
            // 路线规划模式：显示路线概览信息
            naviTypeLabel.isHidden = false
            destinationLabel.isHidden = false
            distanceLabel.isHidden = false
            timeLabel.isHidden = false
            turnIconView.isHidden = true
            nextRoadLabel.isHidden = true
            stepDistanceLabel.isHidden = true
            
            startNaviButton.setTitle("开始导航", for: .normal)
            startNaviButton.backgroundColor = .systemBlue
            startNaviButton.removeTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            startNaviButton.addTarget(self, action: #selector(startNaviTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - Update Navigation Info
    
    func updateNaviInfo(_ info: AMapNaviInfo) {
        // 更新剩余距离和时间
        let distance = info.routeRemainDistance
        let distanceStr = distance >= 1000 ? String(format: "%.1f公里", Double(distance) / 1000.0) : "\(distance)米"
        distanceLabel.text = "剩余 \(distanceStr)"
        
        let time = info.routeRemainTime
        let timeStr: String
        if time >= 3600 {
            let hours = time / 3600
            let minutes = (time % 3600) / 60
            timeStr = "\(hours)小时\(minutes)分钟"
        } else if time >= 60 {
            timeStr = "\(time / 60)分钟"
        } else {
            timeStr = "\(time)秒"
        }
        timeLabel.text = "约 \(timeStr)"
        
        // 更新下一路段信息
        nextRoadLabel.text = info.nextRoadName ?? ""
        
        // 更新当前路段剩余距离
        let stepDistance = info.segmentRemainDistance
        let stepDistanceStr = stepDistance >= 1000 ? String(format: "%.1f公里", Double(stepDistance) / 1000.0) : "\(stepDistance)米"
        stepDistanceLabel.text = stepDistanceStr
        
        // 更新转向图标
        updateTurnIcon(iconType: info.iconType)
    }
    
    private func updateTurnIcon(iconType: AMapNaviIconType) {
        // 根据转向类型设置图标
        let iconName: String
        switch iconType {
        case .straight:
            iconName = "arrow.up"
        case .left:
            iconName = "arrow.turn.up.left"
        case .right:
            iconName = "arrow.turn.up.right"
        case .leftFront:
            iconName = "arrow.up.left"
        case .rightFront:
            iconName = "arrow.up.right"
        case .leftBack:
            iconName = "arrow.uturn.left"
        case .rightBack:
            iconName = "arrow.uturn.right"
        case .leftAndAround:
            iconName = "arrow.uturn.left"
        case .uTurnRight:
            iconName = "arrow.uturn.right"
        case .arrivedWayPoint:
            iconName = "mappin.circle"
        case .arrivedServiceArea:
            iconName = "car.fill"
        case .enterRoundabout:
            iconName = "arrow.triangle.2.circlepath"
        case .outRoundabout:
            iconName = "arrow.up.right.circle"
        case .arrivedDestination:
            iconName = "flag.checkered"
        case .arrivedTunnel:
            iconName = "tunnel.fill"
        case .arrivedTollGate:
            iconName = "dollarsign.circle"
        case .crosswalk:
            iconName = "figure.walk"
        case .flyover:
            iconName = "arrow.up.forward"
        case .underpass:
            iconName = "arrow.down.forward"
        case .stair, .staircase:
            iconName = "stairs"
        case .lift:
            iconName = "arrow.up.arrow.down"
        case .bridge:
            iconName = "figure.walk"
        default:
            iconName = "arrow.up"
        }
        
        turnIconView.image = UIImage(systemName: iconName)
        turnIconView.tintColor = .systemBlue
    }
}

// MARK: - MAMapViewDelegate
extension AMapNaviWalkRideViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if let polyline = overlay as? MAPolyline {
            let renderer = MAPolylineRenderer(polyline: polyline)
            renderer?.lineWidth = 8.0
            renderer?.strokeColor = naviType == .walk ? UIColor.systemGreen : UIColor.systemOrange
            return renderer
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAUserLocation {
            return nil
        }
        
        guard let pointAnnotation = annotation as? MAPointAnnotation else {
            return nil
        }
        
        let identifier = "PointAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MAPinAnnotationView
        
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.canShowCallout = true
        
        // 根据标题设置不同的颜色
        if pointAnnotation.title == "起点" {
            annotationView?.pinColor = .green
        } else {
            annotationView?.pinColor = .red
        }
        
        return annotationView
    }
}

