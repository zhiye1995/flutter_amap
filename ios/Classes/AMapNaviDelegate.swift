import Flutter
import UIKit
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

/// 高德导航事件代理实现
/// 实现 AMapNaviDriveManagerDelegate 和 AMapNaviDriveDataRepresentable 等协议，将导航事件和数据转发到 Flutter 层
/// 
/// 注意：高德SDK有两套回调协议：
/// - AMapNaviDriveManagerDelegate: 事件回调（路径规划成功/失败、TTS字符串、GPS信号弱等）
/// - AMapNaviDriveDataRepresentable: 数据回调（导航信息NaviInfo、定位信息、电子眼信息等）
/// 
/// 使用方式：
/// - 通过 driveManager.delegate = naviDelegate 设置事件代理
/// - 通过 driveManager.addDataRepresentative(naviDelegate) 注册数据代理
class AMapNaviDelegate: NSObject {
    
    /// Flutter 事件通道
    var eventSink: FlutterEventSink?
    
    /// 路线计算成功回调（用于通知 ViewController 显示概览模式）
    var onRouteCalculateSuccess: (() -> Void)?
    
    /// 上一次下发给 Flutter 的转向图标类型，用于去重
    private var lastIconType: Int = Int.min
    
    /// 转向图标 PNG 数据缓存：同一个 iconType 只编码一次
    private var iconPngCache: [Int: FlutterStandardTypedData] = [:]
    
    // MARK: - 发送事件
    
    func sendEvent(_ data: [String: Any?]) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(data)
        }
    }
    
    // MARK: - 辅助方法
    
    /// 将 UIImage 转换为 PNG 数据
    private func imageToPngData(_ image: UIImage?) -> FlutterStandardTypedData? {
        guard let image = image, let pngData = image.pngData() else { return nil }
        return FlutterStandardTypedData(bytes: pngData)
    }
    
    /// 将 AMapNaviPoint 转换为字典
    private func pointToDict(_ point: AMapNaviPoint?) -> [String: Any]? {
        guard let point = point else { return nil }
        return [
            "latitude": point.latitude,
            "longitude": point.longitude
        ]
    }
}

// MARK: - AMapNaviDriveManagerDelegate
extension AMapNaviDelegate: AMapNaviDriveManagerDelegate {
    
    /// 导航初始化失败
    func driveManager(onInitNaviFailure driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onInitNaviFailure: 导航初始化失败")
        sendEvent([
            "type": "initFailure",
            "message": "导航初始化失败"
        ])
    }
    
    /// 导航初始化成功
    func driveManagerIsNaviSoundPlaying(_ driveManager: AMapNaviDriveManager) -> Bool {
        return false
    }
    
    /// 开始导航
    func driveManager(_ driveManager: AMapNaviDriveManager, didStartNavi naviMode: AMapNaviMode) {
        let naviType = naviMode == .GPS ? 1 : 2
        print("[AMapNaviDelegate] onStartNavi: 开始导航 type=\(naviType)")
        sendEvent([
            "type": "startNavi",
            "naviType": naviType
        ])
    }
    
    // 注意：导航信息更新(naviInfo)和位置变化(naviLocation)回调已移至 AMapNaviDriveDataRepresentable 协议
    // 通过 driveManager.addDataRepresentative(self) 注册后，会收到这些数据回调
    
    
    /// 到达目的地
    func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onArriveDestination: 到达目的地")
        sendEvent(["type": "arriveDestination"])
    }
    
    /// GPS 信号状态
    func driveManager(_ driveManager: AMapNaviDriveManager, didChange gpsSignalStrength: AMapNaviGPSSignalStrength) {
        // 新版 SDK 中 noSignal 被移除，使用 weak 判断信号弱
        let isWeak = gpsSignalStrength == .weak
        print("[AMapNaviDelegate] onGpsSignalWeak: GPS信号\(isWeak ? "弱" : "正常")")
        sendEvent([
            "type": "gpsSignalWeak",
            "isWeak": isWeak
        ])
    }
    
    // 注意：路况信息更新(trafficStatus)回调已移至 AMapNaviDriveDataRepresentable 协议
    
    /// 语音播报文本
    func driveManager(_ driveManager: AMapNaviDriveManager, playNaviSound text: String, soundType: AMapNaviSoundType) {
        print("[AMapNaviDelegate] onGetNavigationText: text=\(text)")
        sendEvent([
            "type": "navigationText",
            "textType": soundType.rawValue,
            "text": text
        ])
    }
    
    /// 路径规划成功
    func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onCalculateRouteSuccess: 路径规划成功")
        let routeIds = driveManager.naviRoutes?.keys.map { $0.intValue } ?? []
        sendEvent([
            "type": "calculateRouteSuccess",
            "routeIds": routeIds,
            "errorCode": 0,
            "errorDescription": ""
        ])
        // 通知 ViewController 路线计算成功
        onRouteCalculateSuccess?()
    }
    
    /// 路径规划失败
    func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
        let nsError = error as NSError
        print("[AMapNaviDelegate] onCalculateRouteFailure: errorCode=\(nsError.code)")
        sendEvent([
            "type": "calculateRouteFailure",
            "errorCode": nsError.code,
            "errorDescription": error.localizedDescription
        ])
    }
    
    /// 偏航重新规划路径
    func driveManagerNeedRecalculateRoute(forYaw driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onReCalculateRouteForYaw: 偏航重新规划路径")
        sendEvent(["type": "reCalculateRouteForYaw"])
    }
    
    /// 拥堵重新规划路径
    func driveManagerNeedRecalculateRoute(forTrafficJam driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onReCalculateRouteForTrafficJam: 拥堵重新规划路径")
        sendEvent(["type": "reCalculateRouteForTrafficJam"])
    }
    
    /// 到达途经点
    func driveManager(_ driveManager: AMapNaviDriveManager, didArriveWaypoint wayPointIndex: Int32) {
        print("[AMapNaviDelegate] onArrivedWayPoint: 到达途经点 index=\(wayPointIndex)")
        sendEvent([
            "type": "arrivedWayPoint",
            "wayPointIndex": Int(wayPointIndex)
        ])
    }
    
    // 注意：电子眼信息(cameraInfos)回调已移至 AMapNaviDriveDataRepresentable 协议
    
    // 注意：路口放大图和车道信息回调已移至 AMapNaviDriveDataRepresentable 协议
    
    /// 隐藏路口放大图（Delegate协议中的版本）
    func driveManagerHideCrossImage(_ driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] hideCross: 隐藏路口放大图")
        sendEvent(["type": "hideCross"])
    }
    
    /// 显示车道信息（Delegate协议中的版本，使用图片）
    func driveManager(_ driveManager: AMapNaviDriveManager, showLaneBackInfo laneBackImage: UIImage?, laneSelectImage: UIImage?) {
        print("[AMapNaviDelegate] showLaneInfo: 显示车道信息")
        
        var data: [String: Any?] = [
            "type": "showLaneInfo",
            "raw": ""
        ]
        
        if let bgPngData = imageToPngData(laneBackImage) {
            data["laneBackground"] = bgPngData
        }
        if let selectPngData = imageToPngData(laneSelectImage) {
            data["laneRecommend"] = selectPngData
        }
        
        sendEvent(data)
    }
    
    /// 隐藏车道信息
    func driveManagerHideLaneInfo(_ driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] hideLaneInfo: 隐藏车道信息")
        sendEvent(["type": "hideLaneInfo"])
    }
    
    /// 播放提示音
    func driveManager(_ driveManager: AMapNaviDriveManager, playRingType ringType: AMapNaviRingType) {
        print("[AMapNaviDelegate] onPlayRing: type=\(ringType.rawValue)")
        sendEvent([
            "type": "playRing",
            "ringType": ringType.rawValue
        ])
    }
    
    /// 智能巡航统计（连续行驶距离、连续启用时间等）
    func driveManager(_ driveManager: AMapNaviDriveManager, update cruiseInfo: AMapNaviCruiseInfo?) {
        var payload: [String: Any?] = [
            "type": "cruiseStatistics",
            "cumulativeDistanceMeters": nil as Int?,
            "cumulativeTimeSeconds": nil as Int?,
            "extra": [
                "platform": "ios",
                "callbackName": "updateCruiseInfo"
            ] as [String: Any]
        ]
        guard let info = cruiseInfo else {
            sendEvent(payload)
            return
        }
        let obj = info as NSObject
        var extra: [String: Any] = [
            "platform": "ios",
            "callbackName": "updateCruiseInfo",
            "sdkString": "\(info)"
        ]
        let distKeys = ["cruisingDriveDistance", "cruiseDistance", "totalDistance", "distance", "continuedDistance"]
        let timeKeys = ["cruisingDriveTime", "cruiseTime", "totalTime", "time", "continuedTime"]
        for k in distKeys {
            if obj.responds(to: NSSelectorFromString(k)), let v = obj.value(forKey: k) as? NSNumber {
                payload["cumulativeDistanceMeters"] = v.intValue
                break
            }
        }
        for k in timeKeys {
            if obj.responds(to: NSSelectorFromString(k)), let v = obj.value(forKey: k) as? NSNumber {
                payload["cumulativeTimeSeconds"] = v.intValue
                break
            }
        }
        payload["extra"] = extra
        sendEvent(payload)
    }
    
    /// 智能巡航道路交通设施 / 电子眼（iOS 聚合回调）
    func driveManager(_ driveManager: AMapNaviDriveManager, updateTrafficFacilities trafficFacilities: [AMapNaviTrafficFacilityInfo]?) {
        let list = (trafficFacilities ?? []).map {
            serializeCruiseTrafficFacility($0, source: "unified", callbackName: "updateTrafficFacilities")
        }
        sendEvent([
            "type": "cruiseTrafficFacilities",
            "facilities": list
        ])
    }
    
    /// 智能巡航电子眼独立回调。
    func driveManager(_ driveManager: AMapNaviDriveManager, updateCruiseElecCameraInfos cameraInfos: [AMapNaviTrafficFacilityInfo]?) {
        let list = (cameraInfos ?? []).map {
            serializeCruiseTrafficFacility($0, source: "elecCamera", callbackName: "updateCruiseElecCameraInfos")
        }
        sendEvent([
            "type": "cruiseElecCameraInfo",
            "facilities": list
        ])
    }
    
    /// 智能巡航拥堵信息回调（依赖 iOS Navi SDK 版本和实际场景）。
    func driveManager(_ driveManager: AMapNaviDriveManager, updateCruiseCongestionInfo congestionInfo: AMapNaviCruiseCongestionInfo?) {
        sendEvent(serializeCruiseCongestion(congestionInfo))
    }
    
    private func serializeCruiseTrafficFacility(
        _ info: AMapNaviTrafficFacilityInfo,
        source: String,
        callbackName: String
    ) -> [String: Any?] {
        var m: [String: Any?] = [
            "source": source,
            "callbackName": callbackName,
            "raw": [
                "platform": "ios",
                "callbackName": callbackName,
                "sourceCallback": source,
                "sdkString": "\(info)"
            ]
        ]
        let obj = info as NSObject
        var raw = m["raw"] as? [String: Any] ?? [:]
        if obj.responds(to: NSSelectorFromString("type")),
           let v = obj.value(forKey: "type") {
            if let n = v as? NSNumber {
                m["type"] = n.intValue
                raw["type"] = n.intValue
            } else if let e = v as? NSObject,
                      e.responds(to: NSSelectorFromString("rawValue")),
                      let rv = e.value(forKey: "rawValue") as? NSNumber {
                m["type"] = rv.intValue
                raw["type"] = rv.intValue
            }
        }
        let coordKeys = ["coordinate", "coord", "position"]
        for k in coordKeys where obj.responds(to: NSSelectorFromString(k)) {
            if let p = obj.value(forKey: k) as? AMapNaviPoint {
                m["latitude"] = Double(p.latitude)
                m["longitude"] = Double(p.longitude)
                raw["latitude"] = Double(p.latitude)
                raw["longitude"] = Double(p.longitude)
                break
            }
        }
        let distKeys = ["distance", "remainDistance", "segmentRemainDistance"]
        for k in distKeys where obj.responds(to: NSSelectorFromString(k)) {
            if let v = obj.value(forKey: k) as? NSNumber {
                m["remainDistanceMeters"] = v.intValue
                raw["distance"] = v.intValue
                break
            }
        }
        let spdKeys = ["limitSpeed", "speedLimit"]
        for k in spdKeys where obj.responds(to: NSSelectorFromString(k)) {
            if let v = obj.value(forKey: k) as? NSNumber {
                m["speedLimitKmh"] = v.intValue
                raw["limitSpeed"] = v.intValue
                break
            }
        }
        m["raw"] = raw
        return m
    }
    
    private func serializeCruiseCongestion(_ info: AMapNaviCruiseCongestionInfo?) -> [String: Any?] {
        guard let info = info else {
            return [
                "type": "cruiseCongestion",
                "roadName": nil,
                "lengthMeters": nil,
                "status": nil,
                "estimatedTimeSeconds": nil,
                "links": [],
                "raw": [
                    "platform": "ios",
                    "callbackName": "updateCruiseCongestionInfo"
                ]
            ]
        }
        let obj = info as NSObject
        var raw: [String: Any] = [
            "platform": "ios",
            "callbackName": "updateCruiseCongestionInfo",
            "sdkString": "\(info)"
        ]
        func intValue(_ keys: [String]) -> Int? {
            for key in keys where obj.responds(to: NSSelectorFromString(key)) {
                if let number = obj.value(forKey: key) as? NSNumber {
                    raw[key] = number.intValue
                    return number.intValue
                }
            }
            return nil
        }
        func stringValue(_ keys: [String]) -> String? {
            for key in keys where obj.responds(to: NSSelectorFromString(key)) {
                if let value = obj.value(forKey: key) as? String {
                    raw[key] = value
                    return value
                }
            }
            return nil
        }
        return [
            "type": "cruiseCongestion",
            "roadName": stringValue(["roadName", "name", "description"]),
            "lengthMeters": intValue(["length", "distance"]),
            "status": intValue(["status", "congestionStatus"]),
            "estimatedTimeSeconds": intValue(["time", "estimatedTime", "estimatedTimeSeconds"]),
            "links": [],
            "raw": raw
        ]
    }
}

// MARK: - AMapNaviDriveDataRepresentable
// 数据回调协议，提供导航过程中的实时数据（NaviInfo、定位信息、电子眼信息等）
// 需要通过 driveManager.addDataRepresentative(self) 注册
//
// 注意：Swift 会自动将 ObjC 的方法名转换，例如：
// - driveManager:updateNaviMode: -> driveManager(_:update:) with AMapNaviMode
// - driveManager:updateNaviInfo: -> driveManager(_:update:) with AMapNaviInfo
// 为避免与 AMapNaviDriveManagerDelegate 中的方法冲突，只实现必要的数据回调
extension AMapNaviDelegate: AMapNaviDriveDataRepresentable {
    
    /// 导航模式更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviMode: AMapNaviMode) {
        print("[AMapNaviDelegate-Data] updateNaviMode: \(naviMode.rawValue)")
        sendEvent([
            "type": "naviModeUpdate",
            "naviMode": naviMode.rawValue
        ])
    }
    
    /// 路径ID更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, updateNaviRouteID naviRouteID: Int) {
        print("[AMapNaviDelegate-Data] updateNaviRouteID: \(naviRouteID)")
        sendEvent([
            "type": "naviRouteIDUpdate",
            "routeId": naviRouteID
        ])
    }
    
    /// 路径信息更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviRoute: AMapNaviRoute?) {
        guard let route = naviRoute else { return }
        print("[AMapNaviDelegate-Data] updateNaviRoute: routeLength=\(route.routeLength)")
        sendEvent([
            "type": "naviRouteUpdate",
            "routeLength": route.routeLength,
            "routeTime": route.routeTime,
            "routeTollCost": route.routeTollCost
        ])
    }
    
    /// 导航信息更新回调（核心！包含转向图标、剩余距离、下一路名等）
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviInfo: AMapNaviInfo?) {
        guard let info = naviInfo else { return }
        
        let iconType = Int(info.iconType.rawValue)
        let needIconData = iconType > 0 && iconType != lastIconType
        
        // 构建基础数据（hasIcon 先设为 false，后面根据缓存结果更新）
        var data: [String: Any?] = [
            "type": "navInfo",
            
            // 基础/进度字段
            "pathId": 0,
            "naviType": 0,
            "curStep": info.currentSegmentIndex,
            "curLink": info.currentLinkIndex,
            "curPoint": info.currentPointIndex,
            
            // 道路/转向字段
            "currentRoadName": info.currentRoadName ?? "",
            "nextRoadName": info.nextRoadName ?? "",
            "iconType": info.iconType.rawValue,
            
            // 剩余距离/时间
            "pathRetainDistance": info.routeRemainDistance,
            "pathRetainTime": info.routeRemainTime,
            "curStepRetainDistance": info.segmentRemainDistance,
            "curStepRetainTime": info.segmentRemainTime,
            
            // 其它字段
            "routeRemainLightCount": info.routeRemainTrafficLightCount,
            "currentSpeed": 0,
            
            // 对象字段
            "exitDirectionInfo": nil,
            "notAvoidInfo": nil,
            "toViaInfos": nil,
            
            // 调试
            "raw": "\(info)",
            "hasIcon": false  // 先设为 false，后面根据缓存结果更新
        ]
        
        // 如果 iconType 变化，尝试从缓存获取图标数据
        if needIconData {
            // 在后台队列处理等待逻辑，避免阻塞 SDK 回调
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                var iconPngData: FlutterStandardTypedData? = nil
                
                // 循环等待最多6次，每次5毫秒，共30ms
                for _ in 0..<6 {
                    if let cachedData = self.iconPngCache[iconType] {
                        iconPngData = cachedData
                        break
                    }
                    // 等待5毫秒
                    Thread.sleep(forTimeInterval: 0.005)
                }
                
                // 更新 lastIconType 并添加图标数据
                self.lastIconType = iconType
                if let pngData = iconPngData {
                    data["iconPng"] = pngData
                    data["hasIcon"] = true  // 缓存中找到图标
                }
                
                self.sendEvent(data)
            }
        } else {
            // iconType 没变化，检查缓存中是否有该图标
            if iconType > 0, let _ = iconPngCache[iconType] {
                data["hasIcon"] = true
            }
            sendEvent(data)
        }
    }
    
    /// 自车位置更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviLocation: AMapNaviLocation?) {
        guard let location = naviLocation else { return }
        
        sendEvent([
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
    
    /// 路口放大图显示回调
    func driveManager(_ driveManager: AMapNaviDriveManager, showCross crossImage: UIImage?) {
        guard let image = crossImage else { return }
        print("[AMapNaviDelegate-Data] showCross")
        
        var payload: [String: Any?] = [
            "type": "showCross",
            "raw": ""
        ]
        
        if let pngData = imageToPngData(image) {
            payload["crossData"] = pngData
            payload["dataFormat"] = "bitmap"
        }
        
        sendEvent(payload)
    }
    
    /// 路况信息更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update trafficStatus: [AMapNaviTrafficStatus]?) {
        guard let statuses = trafficStatus, !statuses.isEmpty else { return }
        sendEvent(["type": "trafficStatusUpdate"])
    }
    
    /// 电子眼信息更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update cameraInfos: [AMapNaviCameraInfo]?) {
        guard let cameras = cameraInfos, !cameras.isEmpty else { return }
        
        let cameraList = cameras.map { camera -> [String: Any] in
            return [
                "cameraType": camera.cameraType.rawValue,
                "cameraDistance": camera.distance,
                "cameraSpeed": camera.cameraSpeed
            ]
        }
        
        sendEvent([
            "type": "cameraInfo",
            "cameras": cameraList
        ])
    }
    
    /// 服务区信息更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update serviceAreaInfos: [AMapNaviServiceAreaInfo]?) {
        guard let areas = serviceAreaInfos, !areas.isEmpty else { return }
        
        let areaList = areas.map { area -> [String: Any] in
            return [
                "areaType": area.type, // 0服务区,1收费站,2检查站
                "remainDistance": area.remainDistance,
                "name": area.name ?? ""
            ]
        }
        
        sendEvent([
            "type": "serviceAreaInfo",
            "areas": areaList
        ])
    }
    
    /// 转向图标更新回调 - 只缓存图标数据，在 navInfo 回调中一起发送（和 Android 保持一致）
    func driveManager(_ driveManager: AMapNaviDriveManager, updateTurnIconImage turnIconImage: UIImage?, turn turnIconType: AMapNaviIconType) {
        let iconType = Int(turnIconType.rawValue)
        
        // 检查图标资源是否存在
        let hasImage = turnIconImage != nil
        let imageSize = hasImage ? "\(turnIconImage!.size)" : "nil"
        
        print("[AMapNaviDelegate-Data] updateTurnIconImage: type=\(iconType), hasImage=\(hasImage), size=\(imageSize)")
        
        // 缓存图标数据，每次都重新写入（即使已存在）
        if iconType > 0, let image = turnIconImage, let pngData = imageToPngData(image) {
            let isUpdate = iconPngCache[iconType] != nil
            iconPngCache[iconType] = pngData
            let action = isUpdate ? "更新缓存" : "首次缓存"
            print("[AMapNaviDelegate-Data] ✓ 图标\(action): type=\(iconType), pngSize=\(pngData.data.count) bytes")
        } else {
            if iconType <= 0 {
                print("[AMapNaviDelegate-Data] ✗ iconType 无效: \(iconType)")
            } else if turnIconImage == nil {
                print("[AMapNaviDelegate-Data] ✗ turnIconImage 为 nil")
            } else {
                print("[AMapNaviDelegate-Data] ✗ PNG 转换失败")
            }
        }
    }
}

// MARK: - AMapNaviWalkManagerDelegate
extension AMapNaviDelegate: AMapNaviWalkManagerDelegate {
    
    /// 步行导航初始化失败
    func walkManager(onInitNaviFailure walkManager: AMapNaviWalkManager) {
        print("[AMapNaviDelegate] walkManager onInitNaviFailure")
        sendEvent([
            "type": "initFailure",
            "message": "步行导航初始化失败"
        ])
    }
    
    /// 步行导航开始
    func walkManager(_ walkManager: AMapNaviWalkManager, didStartNavi naviMode: AMapNaviMode) {
        let naviType = naviMode == .GPS ? 1 : 2
        print("[AMapNaviDelegate] walkManager onStartNavi: type=\(naviType)")
        sendEvent([
            "type": "startNavi",
            "naviType": naviType
        ])
    }
    
    /// 步行导航信息更新
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviInfo: AMapNaviInfo?) {
        guard let info = naviInfo else { return }
        
        var data: [String: Any?] = [
            "type": "navInfo",
            "pathId": 0,
            "naviType": 1,
            "curStep": info.currentSegmentIndex,
            "curLink": info.currentLinkIndex,
            "curPoint": info.currentPointIndex,
            "currentRoadName": info.currentRoadName ?? "",
            "nextRoadName": info.nextRoadName ?? "",
            "iconType": info.iconType.rawValue,
            "pathRetainDistance": info.routeRemainDistance,
            "pathRetainTime": info.routeRemainTime,
            "curStepRetainDistance": info.segmentRemainDistance,
            "curStepRetainTime": info.segmentRemainTime,
            "routeRemainLightCount": 0,
            "currentSpeed": 0,
            "exitDirectionInfo": nil,
            "notAvoidInfo": nil,
            "toViaInfos": nil,
            "raw": "\(info)",
            "hasIcon": info.iconType.rawValue > 0
        ]
        
        // 处理转向图标（新版 SDK 移除了 iconImage，只传递 iconType）
        let iconType = Int(info.iconType.rawValue)
        if iconType > 0 && iconType != lastIconType {
            lastIconType = iconType
        }
        
        sendEvent(data)
    }
    
    /// 步行导航位置变化
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviLocation: AMapNaviLocation?) {
        guard let location = naviLocation else { return }
        
        sendEvent([
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
    
    /// 步行导航到达目的地
    func walkManager(onArrivedDestination walkManager: AMapNaviWalkManager) {
        print("[AMapNaviDelegate] walkManager onArriveDestination")
        sendEvent(["type": "arriveDestination"])
    }
    
    /// 步行路径规划成功
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        print("[AMapNaviDelegate] walkManager onCalculateRouteSuccess")
        sendEvent([
            "type": "calculateRouteSuccess",
            "routeIds": [0],
            "errorCode": 0,
            "errorDescription": ""
        ])
        // 通知 ViewController 路线计算成功
        onRouteCalculateSuccess?()
    }
    
    /// 步行路径规划失败
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        let nsError = error as NSError
        print("[AMapNaviDelegate] walkManager onCalculateRouteFailure: \(nsError.code)")
        sendEvent([
            "type": "calculateRouteFailure",
            "errorCode": nsError.code,
            "errorDescription": error.localizedDescription
        ])
    }
    
    /// 步行导航语音播报
    func walkManager(_ walkManager: AMapNaviWalkManager, playNaviSound text: String, soundType: AMapNaviSoundType) {
        sendEvent([
            "type": "navigationText",
            "textType": soundType.rawValue,
            "text": text
        ])
    }
}

// MARK: - AMapNaviRideManagerDelegate
extension AMapNaviDelegate: AMapNaviRideManagerDelegate {
    
    /// 骑行导航初始化失败
    func rideManager(onInitNaviFailure rideManager: AMapNaviRideManager) {
        print("[AMapNaviDelegate] rideManager onInitNaviFailure")
        sendEvent([
            "type": "initFailure",
            "message": "骑行导航初始化失败"
        ])
    }
    
    /// 骑行导航开始
    func rideManager(_ rideManager: AMapNaviRideManager, didStartNavi naviMode: AMapNaviMode) {
        let naviType = naviMode == .GPS ? 1 : 2
        print("[AMapNaviDelegate] rideManager onStartNavi: type=\(naviType)")
        sendEvent([
            "type": "startNavi",
            "naviType": naviType
        ])
    }
    
    /// 骑行导航信息更新
    func rideManager(_ rideManager: AMapNaviRideManager, update naviInfo: AMapNaviInfo?) {
        guard let info = naviInfo else { return }
        
        var data: [String: Any?] = [
            "type": "navInfo",
            "pathId": 0,
            "naviType": 2,
            "curStep": info.currentSegmentIndex,
            "curLink": info.currentLinkIndex,
            "curPoint": info.currentPointIndex,
            "currentRoadName": info.currentRoadName ?? "",
            "nextRoadName": info.nextRoadName ?? "",
            "iconType": info.iconType.rawValue,
            "pathRetainDistance": info.routeRemainDistance,
            "pathRetainTime": info.routeRemainTime,
            "curStepRetainDistance": info.segmentRemainDistance,
            "curStepRetainTime": info.segmentRemainTime,
            "routeRemainLightCount": 0,
            "currentSpeed": 0,
            "exitDirectionInfo": nil,
            "notAvoidInfo": nil,
            "toViaInfos": nil,
            "raw": "\(info)",
            "hasIcon": info.iconType.rawValue > 0
        ]
        
        // 处理转向图标（新版 SDK 移除了 iconImage，只传递 iconType）
        let iconType = Int(info.iconType.rawValue)
        if iconType > 0 && iconType != lastIconType {
            lastIconType = iconType
        }
        
        sendEvent(data)
    }
    
    /// 骑行导航位置变化
    func rideManager(_ rideManager: AMapNaviRideManager, update naviLocation: AMapNaviLocation?) {
        guard let location = naviLocation else { return }
        
        sendEvent([
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
    
    /// 骑行导航到达目的地
    func rideManager(onArrivedDestination rideManager: AMapNaviRideManager) {
        print("[AMapNaviDelegate] rideManager onArriveDestination")
        sendEvent(["type": "arriveDestination"])
    }
    
    /// 骑行路径规划成功
    func rideManager(onCalculateRouteSuccess rideManager: AMapNaviRideManager) {
        print("[AMapNaviDelegate] rideManager onCalculateRouteSuccess")
        sendEvent([
            "type": "calculateRouteSuccess",
            "routeIds": [0],
            "errorCode": 0,
            "errorDescription": ""
        ])
        // 通知 ViewController 路线计算成功
        onRouteCalculateSuccess?()
    }
    
    /// 骑行路径规划失败
    func rideManager(_ rideManager: AMapNaviRideManager, onCalculateRouteFailure error: Error) {
        let nsError = error as NSError
        print("[AMapNaviDelegate] rideManager onCalculateRouteFailure: \(nsError.code)")
        sendEvent([
            "type": "calculateRouteFailure",
            "errorCode": nsError.code,
            "errorDescription": error.localizedDescription
        ])
    }
    
    /// 骑行导航语音播报
    func rideManager(_ rideManager: AMapNaviRideManager, playNaviSound text: String, soundType: AMapNaviSoundType) {
        sendEvent([
            "type": "navigationText",
            "textType": soundType.rawValue,
            "text": text
        ])
    }
}

