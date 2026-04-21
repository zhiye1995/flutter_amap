import Flutter
import QuartzCore
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

class _AMapApi: NSObject {
  let registrar: FlutterPluginRegistrar
  let mapView: MAMapView
  let mapInitConfig: MapInitConfig?
  var markers = [String: Annotation]()
  var markerIds = [Int: String]()

  init(registrar: FlutterPluginRegistrar, mapView: MAMapView, mapInitConfig: MapInitConfig?) {
    self.registrar = registrar
    self.mapView = mapView
    self.mapInitConfig = mapInitConfig
  }

  func initMap() {
    if let config = mapInitConfig {
      if let type = config.mapType {
        mapView.mapType = type.mapType
      }
      if let cameraPosition = config.cameraPosition {
        if let position = cameraPosition.position {
          mapView.centerCoordinate = position.coordinate
        }
        if let heading = cameraPosition.heading {
          mapView.rotationDegree = heading
        }
        if let skew = cameraPosition.skew {
          mapView.cameraDegree = skew
        }
        if let zoom = cameraPosition.zoom {
          mapView.zoomLevel = zoom
        }
      }
      if let fitPositions = config.fitPositions {
        var north: Double?
        var east: Double?
        var south: Double?
        var west: Double?

        for position in fitPositions {
          if(north == nil || north! < position.latitude) {
            north = position.latitude
          }
          if(east == nil || east! < position.longitude) {
            east = position.longitude
          }
          if(south == nil || south! > position.latitude) {
            south = position.latitude
          }
          if(west == nil || west! > position.longitude) {
            west = position.longitude
          }
        }

        if(north != nil && east != nil && south != nil && west != nil) {
          mapView.setRegion(MACoordinateRegion.init(north!, east!, south!, west!), animated: false)
        }
      }
      if let minZoom = config.minZoom {
        mapView.minZoomLevel = minZoom
      }
      if let maxZoom = config.maxZoom {
        mapView.maxZoomLevel = maxZoom
      }
      if let dragEnable = config.dragEnable {
        mapView.isScrollEnabled = dragEnable
      }
      if let zoomEnable = config.zoomEnable {
        mapView.isZoomEnabled = zoomEnable
      }
      if let tiltEnable = config.tiltEnable {
        mapView.isRotateCameraEnabled = tiltEnable
      }
      if let rotateEnable = config.rotateEnable {
        mapView.isRotateEnabled = rotateEnable
      }
      if let compassControlEnabled = config.compassControlEnabled {
        mapView.showsCompass = compassControlEnabled
      }
      if let scaleControlEnabled = config.scaleControlEnabled {
        mapView.showsScale = scaleControlEnabled
      }
      if let custom = config.customStyleOptions {
        applyCustomStyle(custom)
      }
    }
  }

  private func applyCustomStyle(_ options: CustomStyleOptions) {
    // 离线自定义样式仅作用在标准底图上；若仍为卫星/导航等类型，样式不会正确叠加
    if options.enabled {
      mapView.mapType = MAMapType.standard
    }
    mapView.customMapStyleEnabled = options.enabled
    if options.enabled {
      let styleOption = MAMapCustomStyleOptions()
      styleOption.styleData = options.styleData
      styleOption.styleExtraData = options.styleExtraData
      mapView.setCustomMapStyleOptions(styleOption)
    }
  }

  func updateMapConfig(config: MapUpdateConfig) {
    if let type = config.mapType {
      mapView.mapType = type.mapType
    }
    if let enabled = config.dragEnable {
      mapView.isScrollEnabled = enabled
    }
    if let enabled = config.zoomEnable {
      mapView.isZoomEnabled = enabled
    }
    if let enabled = config.tiltEnable {
      mapView.isRotateCameraEnabled = enabled
    }
    if let enabled = config.rotateEnable {
      mapView.isRotateEnabled = enabled
    }
    if let enabled = config.compassControlEnabled {
      mapView.showsCompass = enabled
    }
    if let enabled = config.scaleControlEnabled {
      mapView.showsScale = enabled
    }
    if let logoPosition = config.logoPosition {
      mapView.logoCenter = logoPosition.controlCenter(size: mapView.logoSize, bounds: mapView.bounds)
    }
    if let compassControlPosition = config.compassControlPosition {
      mapView.compassOrigin = compassControlPosition.controlOrigin(size: mapView.compassSize, bounds: mapView.bounds)
    }
    if let scaleControlPosition = config.scaleControlPosition {
      mapView.scaleOrigin = scaleControlPosition.controlOrigin(size: mapView.scaleSize, bounds: mapView.bounds)
    }
    if let showTraffic = config.showTraffic {
      mapView.isShowTraffic = showTraffic
    }
    if let showBuildings = config.showBuildings {
      mapView.isShowsBuildings = showBuildings
    }
    if let showIndoorMap = config.showIndoorMap {
      mapView.isShowsIndoorMap = showIndoorMap
    }
    if let userLocationConfig = config.userLocationConfig {
      if let showLocation = userLocationConfig.showUserLocation {
        mapView.showsUserLocation = showLocation
      }
      if let userLocationStyle = userLocationConfig.userLocationStyle {
        if let userTrackingMode = userLocationStyle.userLocationType?.userTrackingMode {
          mapView.setUserTrackingMode(userTrackingMode, animated: false)
        }
        mapView.update(userLocationStyle.toUserLocationRepresentation(registrar: registrar))
      }
    }
    if let custom = config.customStyleOptions {
      applyCustomStyle(custom)
    }
    if let minZoom = config.minZoom {
      mapView.minZoomLevel = minZoom
    }
    if let maxZoom = config.maxZoom {
      mapView.maxZoomLevel = maxZoom
    }
  }

  /// MAMapView 无与 Android `AMap.stopAnimation` 完全一致的 API，此处保留空实现以兼容 Dart 调用。
  func stopCameraAnimation() {
  }

  func moveCamera(position: CameraPosition, duration: Int64) {
    let status = MAMapStatus()
    if let it = position.position?.coordinate { status.centerCoordinate = it }
    if let it = position.zoom { status.zoomLevel = it }
    if let it = position.skew { status.cameraDegree = it }
    if let it = position.heading { status.rotationDegree = it }
    mapView.setMapStatus(status, animated: duration > 0)
  }

  func moveCameraToRegion(region: Region, duration: Int64) {
    mapView.setRegion(region.region, animated: duration > 0)
  }

  func moveCameraToRegionWithPosition(positions: [Position?], padding: EdgePadding, duration: Int64) {
    var north: Double?
    var east: Double?
    var south: Double?
    var west: Double?

    for position in positions.filter({ position in position != nil }) {
      if(north == nil || north! < position!.latitude) {
        north = position!.latitude
      }
      if(east == nil || east! < position!.longitude) {
        east = position!.longitude
      }
      if(south == nil || south! > position!.latitude) {
        south = position!.latitude
      }
      if(west == nil || west! > position!.longitude) {
        west = position!.longitude
      }
    }

    if(north != nil && east != nil && south != nil && west != nil) {
      let origin = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: north!, longitude: west!))
      let destination = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: south!, longitude: east!))
      let size = MAMapSize(width: destination.x - origin.x, height: destination.y - origin.y)
      let mapRect = MAMapRect.init(origin: origin, size: size)
      let edgePadding = UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
      mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: false)
    }
  }

  func setRestrictRegion(region: Region) {
    mapView.limitRegion = region.region
  }

  func removeRestrictRegion() {
    mapView.limitRegion = MACoordinateRegion.init()
  }

  func addMarker(marker: Marker) {
    let annotation = marker.annotation
    markers[marker.id] = annotation
    markerIds[annotation.hash] = marker.id
    mapView.addAnnotation(annotation)
  }

  func removeMarker(id: String) {
    if let annotation = markers[id] {
      mapView.removeAnnotation(annotation)
      markers.removeValue(forKey: id)
      markerIds.removeValue(forKey: annotation.hash)
    }
  }

  func showInfoWindow(markerId: String) {
    guard let ann = markers[markerId] else { return }
    let run = { [weak self] in
      guard let self = self else { return }
      self.mapView.selectAnnotation(ann, animated: true)
    }
    if Thread.isMainThread {
      run()
    } else {
      DispatchQueue.main.async(execute: run)
    }
  }

  func hideInfoWindow() {
    let run = { [weak self] in
      guard let self = self else { return }
      if let selected = self.mapView.selectedAnnotations as? [Any] {
        for case let a as MAAnnotation in selected {
          self.mapView.deselectAnnotation(a, animated: true)
        }
      }
    }
    if Thread.isMainThread {
      run()
    } else {
      DispatchQueue.main.async(execute: run)
    }
  }

  /// 与 Dart [MarkerAnimationKind] 下标一致；在 annotation 视图上做 UIView 动画（iOS 无与 Android 同名的 Marker Animation API）。
  func animateMarker(markerId: String, kind: Int, durationMs: Int) {
    guard let annotation = markers[markerId] else { return }
    let run: () -> Void = { [weak self] in
      guard let self = self else { return }
      guard let view = self.mapView.view(for: annotation) else { return }
      view.layer.removeAllAnimations()
      let dur = Double(min(10_000, max(200, durationMs))) / 1000.0
      let baseTransform = view.transform
      let baseAlpha = view.alpha

      switch kind {
      case 0:
        UIView.animateKeyframes(
          withDuration: dur, delay: 0,
          options: [.calculationModeCubic],
          animations: {
            let n = 3
            for i in 0..<n {
              let seg = 1.0 / Double(n)
              UIView.addKeyframe(withRelativeStartTime: Double(i) * seg, relativeDuration: seg * 0.5) {
                view.transform = baseTransform.scaledBy(x: 1.28, y: 1.28)
              }
              UIView.addKeyframe(withRelativeStartTime: Double(i) * seg + seg * 0.5, relativeDuration: seg * 0.5) {
                view.transform = baseTransform
              }
            }
          },
          completion: { _ in
            view.transform = baseTransform
          })

      case 1:
        // 整周旋转：affine 的 2π 与恒等等价，必须用 layer 的 rotation 动画才能看见效果。
        let rot = CABasicAnimation(keyPath: "transform.rotation.z")
        rot.fromValue = 0
        rot.toValue = Double.pi * 2
        rot.duration = dur
        rot.isRemovedOnCompletion = true
        view.layer.add(rot, forKey: "flutter_amap_marker_rotate")

      case 2:
        UIView.animateKeyframes(
          withDuration: dur, delay: 0,
          options: [.calculationModeLinear],
          animations: {
            let n = 5
            for i in 0..<n {
              let seg = 1.0 / Double(n)
              UIView.addKeyframe(withRelativeStartTime: Double(i) * seg, relativeDuration: seg * 0.5) {
                view.alpha = 0.32
              }
              UIView.addKeyframe(withRelativeStartTime: Double(i) * seg + seg * 0.5, relativeDuration: seg * 0.5) {
                view.alpha = baseAlpha
              }
            }
          },
          completion: { _ in
            view.alpha = baseAlpha
          })

      case 3:
        // 生长：从极小缩放到 identity（对齐 Android ScaleAnimation 0→1 语义）。
        view.transform = baseTransform.scaledBy(x: 0.02, y: 0.02)
        UIView.animate(
          withDuration: dur, delay: 0, options: [.curveEaseOut],
          animations: {
            view.transform = baseTransform
          },
          completion: { _ in
            view.transform = baseTransform
          })

      case 4:
        // 移动：经纬度线性插值往返（与 Android TranslateAnimation 两段语义对齐，不改 Flutter 侧 Marker 模型）。
        guard let point = annotation as? MAPointAnnotation else { break }
        let start = point.coordinate
        let end = CLLocationCoordinate2D(
          latitude: start.latitude + 0.00015,
          longitude: start.longitude + 0.00012)
        let n = 16
        for i in 0...n {
          let delay1 = dur / 2 * Double(i) / Double(n)
          DispatchQueue.main.asyncAfter(deadline: .now() + delay1) {
            let t = Double(i) / Double(n)
            point.coordinate = CLLocationCoordinate2D(
              latitude: start.latitude + (end.latitude - start.latitude) * t,
              longitude: start.longitude + (end.longitude - start.longitude) * t)
          }
        }
        for i in 0...n {
          let delay2 = dur / 2 + dur / 2 * Double(i) / Double(n)
          DispatchQueue.main.asyncAfter(deadline: .now() + delay2) {
            let t = Double(i) / Double(n)
            point.coordinate = CLLocationCoordinate2D(
              latitude: end.latitude - (end.latitude - start.latitude) * t,
              longitude: end.longitude - (end.longitude - start.longitude) * t)
          }
        }

      default:
        break
      }
    }

    if Thread.isMainThread {
      run()
    } else {
      DispatchQueue.main.async(execute: run)
    }
  }

  func getMarkerIdByAnnotation(_ annotation: Int) -> String? {
    return markerIds[annotation]
  }

  func getUserLocation() -> Location? {
    return mapView.userLocation?.toLocation
  }

  func getScalePerPixel() -> Double {
    return mapView.metersPerPointForCurrentZoom
  }

  /// 与高德 iOS `takeSnapshotInRect:withCompletionBlock:` 一致：可视区域截图（PNG）。
  func takeMapSnapshot(result: @escaping FlutterResult) {
    let rect = mapView.bounds
    mapView.takeSnapshot(in: rect, withCompletionBlock: { image, _ in
      guard let image = image else {
        result(
          FlutterError(
            code: "SNAPSHOT_FAILED", message: "image is nil", details: nil))
        return
      }
      guard let data = image.pngData() else {
        result(
          FlutterError(
            code: "SNAPSHOT_FAILED", message: "pngData failed", details: nil))
        return
      }
      result(data)
    })
  }

  func start() { }

  func pause() { }

  func resume() { }

  func destroy() { }
}
