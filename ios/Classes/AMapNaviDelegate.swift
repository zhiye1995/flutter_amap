import Flutter
import UIKit
import AMapNaviKit

/// 高德导航事件代理实现
/// 实现 AMapNaviDriveManagerDelegate 等协议，将导航事件转发到 Flutter 层
class AMapNaviDelegate: NSObject {
    
    /// Flutter 事件通道
    var eventSink: FlutterEventSink?
    
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
    
    /// 导航信息更新
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviInfo: AMapNaviInfo?) {
        guard let info = naviInfo else { return }
        
        var data: [String: Any?] = [
            "type": "navInfo",
            
            // 基础/进度字段
            "pathId": 0, // iOS SDK 可能没有直接的 pathId
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
            
            // 对象字段（iOS 端可能没有对应字段）
            "exitDirectionInfo": nil,
            "notAvoidInfo": nil,
            "toViaInfos": nil,
            
            // 调试兜底
            "raw": "\(info)",
            
            // 图标是否存在
            "hasIcon": info.iconImage != nil
        ]
        
        // 处理转向图标
        if let iconImage = info.iconImage, info.iconType.rawValue > 0 {
            let iconType = Int(info.iconType.rawValue)
            if iconType != lastIconType {
                if let cachedPng = iconPngCache[iconType] {
                    data["iconPng"] = cachedPng
                } else if let pngData = imageToPngData(iconImage) {
                    iconPngCache[iconType] = pngData
                    data["iconPng"] = pngData
                }
                lastIconType = iconType
            }
        }
        
        sendEvent(data)
    }
    
    /// 位置变化
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviLocation: AMapNaviLocation?) {
        guard let location = naviLocation else { return }
        
        sendEvent([
            "type": "locationChange",
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "bearing": location.heading,
            "roadBearing": location.heading, // iOS 可能没有单独的道路方向
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
    
    /// 到达目的地
    func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] onArriveDestination: 到达目的地")
        sendEvent(["type": "arriveDestination"])
    }
    
    /// GPS 信号状态
    func driveManager(_ driveManager: AMapNaviDriveManager, didChange gpsSignalStrength: AMapNaviGPSSignalStrength) {
        let isWeak = gpsSignalStrength == .weak || gpsSignalStrength == .noSignal
        print("[AMapNaviDelegate] onGpsSignalWeak: GPS信号\(isWeak ? "弱" : "正常")")
        sendEvent([
            "type": "gpsSignalWeak",
            "isWeak": isWeak
        ])
    }
    
    /// 路况信息更新
    func driveManager(_ driveManager: AMapNaviDriveManager, updateTrafficStatus trafficStatus: [AMapNaviTrafficStatus]?) {
        sendEvent(["type": "trafficStatusUpdate"])
    }
    
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
    
    /// 电子眼信息
    func driveManager(_ driveManager: AMapNaviDriveManager, update cameraInfos: [AMapNaviCameraInfo]?) {
        guard let cameras = cameraInfos, !cameras.isEmpty else { return }
        
        let cameraList = cameras.map { camera -> [String: Any] in
            return [
                "cameraType": camera.cameraType.rawValue,
                "cameraDistance": camera.distance,
                "cameraSpeed": camera.limitedSpeed
            ]
        }
        
        sendEvent([
            "type": "cameraInfo",
            "cameras": cameraList
        ])
    }
    
    /// 显示路口放大图
    func driveManager(_ driveManager: AMapNaviDriveManager, showCross crossImage: UIImage?) {
        guard let image = crossImage else { return }
        print("[AMapNaviDelegate] showCross: 显示路口放大图")
        
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
    
    /// 隐藏路口放大图
    func driveManagerHideCrossImage(_ driveManager: AMapNaviDriveManager) {
        print("[AMapNaviDelegate] hideCross: 隐藏路口放大图")
        sendEvent(["type": "hideCross"])
    }
    
    /// 显示车道信息
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
            "hasIcon": info.iconImage != nil
        ]
        
        if let iconImage = info.iconImage, info.iconType.rawValue > 0 {
            let iconType = Int(info.iconType.rawValue)
            if iconType != lastIconType {
                if let pngData = imageToPngData(iconImage) {
                    data["iconPng"] = pngData
                }
                lastIconType = iconType
            }
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
            "hasIcon": info.iconImage != nil
        ]
        
        if let iconImage = info.iconImage, info.iconType.rawValue > 0 {
            let iconType = Int(info.iconType.rawValue)
            if iconType != lastIconType {
                if let pngData = imageToPngData(iconImage) {
                    data["iconPng"] = pngData
                }
                lastIconType = iconType
            }
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

