import Flutter
import QuartzCore
import CoreLocation
import AMapFoundationKit
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

private class SmoothMoveState {
  let marker: Marker
  let points: [Position]
  let durationMs: Int
  var startTime: Date
  var remainingMs: Int
  var pausedPosition: Position?
  var paused: Bool

  init(marker: Marker, points: [Position], durationMs: Int) {
    self.marker = marker
    self.points = points
    self.durationMs = durationMs
    self.startTime = Date()
    self.remainingMs = durationMs
    self.paused = false
  }
}

class _AMapApi: NSObject {
  let registrar: FlutterPluginRegistrar
  let mapView: MAMapView
  let mapInitConfig: MapInitConfig?
  weak var mapViewDelegate: AMapViewDelegate?
  var markers = [String: Annotation]()
  var markerIds = [Int: String]()
  var polylines = [String: MAPolyline]()
  var polylineStyles = [String: Polyline]()
  var navigateArrows = [String: MAPolyline]()
  var navigateArrowStyles = [String: NavigateArrow]()
  var arcs = [String: MAArc]()
  var arcStyles = [String: Arc]()
  var polygons = [String: MAPolygon]()
  var polygonStyles = [String: Polygon]()
  private var markerAnimationTokens = [String: Int]()
  private var smoothMoveStates = [String: SmoothMoveState]()

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
      if let userLocationStyle = userLocationConfig.userLocationStyle {
        mapViewDelegate?.applyUserLocationType(userLocationStyle.userLocationType, animated: false)
        mapView.update(userLocationStyle.toUserLocationRepresentation(registrar: registrar))
      }
      if let showLocation = userLocationConfig.showUserLocation {
        mapView.showsUserLocation = showLocation
        if !showLocation {
          mapView.setUserTrackingMode(.none, animated: false)
        }
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
      cancelMarkerAnimation(markerId: id)
      mapView.removeAnnotation(annotation)
      markers.removeValue(forKey: id)
      markerIds.removeValue(forKey: annotation.hash)
    }
  }

  func startSmoothMoveMarker(marker: Marker, points: [Position], durationMs: Int) {
    guard points.count >= 2 else { return }
    let run: () -> Void = { [weak self] in
      guard let self = self else { return }
      self.stopSmoothMoveMarker(markerId: marker.id)
      let safeDuration = max(1_000, durationMs)
      self.smoothMoveStates[marker.id] = SmoothMoveState(marker: marker, points: points, durationMs: safeDuration)
      let annotation = marker.annotation
      self.markers[marker.id] = annotation
      self.markerIds[annotation.hash] = marker.id
      self.mapView.addAnnotation(annotation)
      self.startSmoothMoveSegment(markerId: marker.id, annotation: annotation, points: points, durationMs: safeDuration)
    }
    if Thread.isMainThread {
      run()
    } else {
      DispatchQueue.main.async(execute: run)
    }
  }

  func stopSmoothMoveMarker(markerId: String) {
    guard let annotation = markers[markerId] else { return }
    if let moveAnimations = annotation.allMoveAnimations() {
      for item in moveAnimations {
        item.cancel()
      }
    }
    mapView.removeAnnotation(annotation)
    markers.removeValue(forKey: markerId)
    markerIds.removeValue(forKey: annotation.hash)
    smoothMoveStates.removeValue(forKey: markerId)
  }

  func pauseSmoothMoveMarker(markerId: String) {
    guard let state = smoothMoveStates[markerId], !state.paused else { return }
    guard let annotation = markers[markerId] else { return }
    let elapsedMs = Int(Date().timeIntervalSince(state.startTime) * 1000)
    state.remainingMs = max(1_000, state.remainingMs - elapsedMs)
    state.pausedPosition = annotation.coordinate.position
    state.paused = true
    if let moveAnimations = annotation.allMoveAnimations() {
      for item in moveAnimations {
        item.cancel()
      }
    }
  }

  func resumeSmoothMoveMarker(markerId: String) {
    guard let state = smoothMoveStates[markerId], state.paused else { return }
    guard let annotation = markers[markerId], let current = state.pausedPosition else { return }
    let remainingPoints = buildRemainingSmoothMovePoints(current: current, points: state.points)
    state.paused = false
    state.pausedPosition = nil
    state.startTime = Date()
    startSmoothMoveSegment(
      markerId: markerId,
      annotation: annotation,
      points: remainingPoints,
      durationMs: state.remainingMs)
  }

  private func startSmoothMoveSegment(markerId: String, annotation: Annotation, points: [Position], durationMs: Int) {
    guard points.count >= 2 else { return }
    var coordinates = points.map { $0.coordinate }
    annotation.coordinate = coordinates[0]
    coordinates.removeFirst()
    let endCoordinate = coordinates[coordinates.count - 1]
    let duration = max(1.0, Double(durationMs) / 1000.0)
    annotation.addMoveAnimation(
      withKeyCoordinates: &coordinates,
      count: UInt(coordinates.count),
      withDuration: duration,
      withName: "flutter_amap_smooth_move") { [weak self, weak annotation] _ in
        guard let self = self, let annotation = annotation else { return }
        annotation.coordinate = endCoordinate
        self.markers[markerId] = annotation
        self.smoothMoveStates.removeValue(forKey: markerId)
      }
  }

  private func buildRemainingSmoothMovePoints(current: Position, points: [Position]) -> [Position] {
    let nearestIndex = points.indices.min { lhs, rhs in
      distance(from: current, to: points[lhs]) < distance(from: current, to: points[rhs])
    } ?? 0
    let startIndex = min(nearestIndex + 1, points.count - 1)
    return [current] + points[startIndex..<points.count]
  }

  private func distance(from start: Position, to end: Position) -> Double {
    let dx = start.longitude - end.longitude
    let dy = start.latitude - end.latitude
    return dx * dx + dy * dy
  }

  func addPolyline(polyline: Polyline) {
    removePolyline(id: polyline.id)
    guard polyline.points.count >= 2 else { return }
    let overlay = polyline.overlay
    polylines[polyline.id] = overlay
    polylineStyles[polyline.id] = polyline
    if polyline.visible {
      mapView.add(overlay)
    }
  }

  func removePolyline(id: String) {
    if let overlay = polylines[id] {
      mapView.remove(overlay)
      polylines.removeValue(forKey: id)
      polylineStyles.removeValue(forKey: id)
    }
  }

  func addNavigateArrow(arrow: NavigateArrow) {
    removeNavigateArrow(id: arrow.id)
    guard arrow.points.count >= 2 else { return }
    let overlay = arrow.overlay
    navigateArrows[arrow.id] = overlay
    navigateArrowStyles[arrow.id] = arrow
    if arrow.visible {
      mapView.add(overlay)
    }
  }

  func removeNavigateArrow(id: String) {
    if let overlay = navigateArrows[id] {
      mapView.remove(overlay)
      navigateArrows.removeValue(forKey: id)
      navigateArrowStyles.removeValue(forKey: id)
    }
  }

  func addArc(arc: Arc) {
    removeArc(id: arc.id)
    let overlay = arc.overlay
    arcs[arc.id] = overlay
    arcStyles[arc.id] = arc
    if arc.visible {
      mapView.add(overlay)
    }
  }

  func removeArc(id: String) {
    if let overlay = arcs[id] {
      mapView.remove(overlay)
      arcs.removeValue(forKey: id)
      arcStyles.removeValue(forKey: id)
    }
  }

  func addPolygon(polygon: Polygon) {
    removePolygon(id: polygon.id)
    guard polygon.points.count >= 3 else { return }
    let overlay = polygon.overlay
    polygons[polygon.id] = overlay
    polygonStyles[polygon.id] = polygon
    if polygon.visible {
      mapView.add(overlay)
    }
  }

  func removePolygon(id: String) {
    if let overlay = polygons[id] {
      mapView.remove(overlay)
      polygons.removeValue(forKey: id)
      polygonStyles.removeValue(forKey: id)
    }
  }

  func polylineStyle(for overlay: MAPolyline) -> Polyline? {
    return polylines.first(where: { $0.value === overlay }).flatMap { polylineStyles[$0.key] }
  }

  func navigateArrowStyle(for overlay: MAPolyline) -> NavigateArrow? {
    return navigateArrows.first(where: { $0.value === overlay }).flatMap { navigateArrowStyles[$0.key] }
  }

  func arcStyle(for overlay: MAArc) -> Arc? {
    return arcs.first(where: { $0.value === overlay }).flatMap { arcStyles[$0.key] }
  }

  func polygonStyle(for overlay: MAPolygon) -> Polygon? {
    return polygons.first(where: { $0.value === overlay }).flatMap { polygonStyles[$0.key] }
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

  /// 与 Dart [MarkerAnimationKind.code] 一致；视觉动画在 annotation 视图上执行，移动动画使用高德 MAAnimatedAnnotation。
  func animateMarker(markerId: String, kind: Int, durationMs: Int) {
    guard let annotation = markers[markerId] else { return }
    let run: () -> Void = { [weak self] in
      guard let self = self else { return }
      self.cancelMarkerAnimation(markerId: markerId)
      let dur = Double(min(10_000, max(200, durationMs))) / 1000.0
      self.markerAnimationTokens[markerId, default: 0] += 1
      let token = self.markerAnimationTokens[markerId] ?? 0
      if kind == 4 {
        self.startMarkerMoveRoundTrip(markerId: markerId, annotation: annotation, duration: dur)
        return
      }
      guard let view = self.mapView.view(for: annotation) else { return }
      let baseTransform = view.transform
      let baseAlpha = view.alpha

      switch kind {
      case 0:
        // 与 Android `ScaleAnimation` + `repeatCount(3)` + `REVERSE` 对齐：总时长 `(3+1)*durationMs`，2 次完整呼吸。
        let pulseTotal = 4 * dur
        UIView.animateKeyframes(
          withDuration: pulseTotal, delay: 0,
          options: [.calculationModeCubic],
          animations: {
            let n = 2
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
          completion: { [weak self] _ in
            guard self?.markerAnimationTokens[markerId] == token else { return }
            view.transform = baseTransform
          })

      case 1:
        // 整周旋转：affine 的 2π 与恒等等价，必须用 layer 的 rotation 动画才能看见效果。
        // 负角与 Android `RotateAnimation(0,360)` 在屏幕上的转向一致（正 `+2π` 与高德 Android 相反）。
        let rot = CABasicAnimation(keyPath: "transform.rotation.z")
        rot.fromValue = 0
        rot.toValue = -Double.pi * 2
        rot.duration = dur
        rot.isRemovedOnCompletion = true
        view.layer.add(rot, forKey: "flutter_amap_marker_rotate")

      case 2:
        // 与 Android `AlphaAnimation` + `durationMs/2` + `repeatCount(5)` + `REVERSE` 对齐：总时长 `6*(durationMs/2)=3*durationMs`，3 次完整脉冲。
        let fadeTotal = 3 * dur
        UIView.animateKeyframes(
          withDuration: fadeTotal, delay: 0,
          options: [.calculationModeLinear],
          animations: {
            let n = 3
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
          completion: { [weak self] _ in
            guard self?.markerAnimationTokens[markerId] == token else { return }
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
          completion: { [weak self] _ in
            guard self?.markerAnimationTokens[markerId] == token else { return }
            view.transform = baseTransform
          })

      case 4:
        break

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

  func cancelMarkerAnimation(markerId: String) {
    guard let annotation = markers[markerId] else { return }
    markerAnimationTokens[markerId, default: 0] += 1
    if let moveAnimations = annotation.allMoveAnimations() {
      for item in moveAnimations {
        item.cancel()
      }
    }
    annotation.coordinate = annotation.coordinate
    if let view = mapView.view(for: annotation) {
      view.layer.removeAllAnimations()
      view.transform = .identity
      view.alpha = 1
    }
  }

  private func startMarkerMoveRoundTrip(markerId: String, annotation: Annotation, duration: Double) {
    let start = annotation.coordinate
    var outward = CLLocationCoordinate2D(
      latitude: start.latitude + 0.00015,
      longitude: start.longitude + 0.00012)
    markerAnimationTokens[markerId, default: 0] += 1
    let token = markerAnimationTokens[markerId] ?? 0
    let half = max(0.2, duration / 2)
    annotation.addMoveAnimation(
      withKeyCoordinates: &outward,
      count: UInt(1),
      withDuration: half,
      withName: "flutter_amap_marker_move_out") { [weak self, weak annotation] isFinished in
        guard let self = self, let annotation = annotation else { return }
        guard isFinished, self.markerAnimationTokens[markerId] == token else { return }
        var inward = start
        annotation.addMoveAnimation(
          withKeyCoordinates: &inward,
          count: UInt(1),
          withDuration: half,
          withName: "flutter_amap_marker_move_back") { [weak self, weak annotation] isFinished in
            guard let self = self, let annotation = annotation else { return }
            guard isFinished, self.markerAnimationTokens[markerId] == token else { return }
            annotation.coordinate = start
          }
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

  func convertCoordinate(position: Position, from: String) -> Position {
    if from == "gps" {
      return AMapCoordinateConvert(position.coordinate, .GPS).position
    }
    return position
  }

  func toScreenLocation(position: Position) -> Size {
    let point = mapView.convert(position.coordinate, toPointTo: mapView)
    return Size(width: Double(point.x), height: Double(point.y))
  }

  func fromScreenLocation(point: Size) -> Position {
    let cgPoint = CGPoint(x: point.width, y: point.height)
    return mapView.convert(cgPoint, toCoordinateFrom: mapView).position
  }

  func calculateLineDistance(start: Position, end: Position) -> Double {
    let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
    let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
    return startLocation.distance(from: endLocation)
  }

  func containsCoordinate(point: Position, polygon: [Position]) -> Bool {
    guard polygon.count >= 3 else { return false }

    var inside = false
    var previous = polygon.count - 1
    for current in polygon.indices {
      let currentPoint = polygon[current]
      let previousPoint = polygon[previous]
      let intersects = ((currentPoint.latitude > point.latitude) != (previousPoint.latitude > point.latitude))
        && (point.longitude < (previousPoint.longitude - currentPoint.longitude)
          * (point.latitude - currentPoint.latitude)
          / (previousPoint.latitude - currentPoint.latitude)
          + currentPoint.longitude)
      if intersects {
        inside.toggle()
      }
      previous = current
    }
    return inside
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
