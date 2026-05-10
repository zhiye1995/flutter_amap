import Foundation
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

class Annotation: MAAnimatedAnnotation {
  let id: String
  let bitmap: Bitmap?

  init(id: String, position: Position, bitmap: Bitmap?, title: String?, snippet: String?) {
    self.id = id
    self.bitmap = bitmap
    super.init()
    self.coordinate = position.coordinate
    if let t = title, !t.isEmpty {
      self.title = t
    }
    if let s = snippet, !s.isEmpty {
      self.subtitle = s
    }
  }
}

extension AMapPrivacyAgreeStatus {
  init(_ agree: Bool) {
    if(agree) {
      self = .didAgree
    } else {
      self = .notAgree
    }
  }
}

extension AMapPrivacyInfoStatus {
  init(_ agree: Bool) {
    if(agree) {
      self = .didContain
    } else {
      self = .notContain
    }
  }
}

extension AMapPrivacyShowStatus {
  init(_ agree: Bool) {
    if(agree) {
      self = .didShow
    } else {
      self = .notShow
    }
  }
}

extension CLLocationCoordinate2D {
  var position: Position {
    return Position(latitude: latitude, longitude: longitude)
  }
}

extension MACoordinateRegion {
  init(_ north: Double, _ east: Double, _ south: Double, _ west: Double) {
    self.init(
      center: CLLocationCoordinate2DMake((north + south) / 2, (east + west) / 2),
      span: MACoordinateSpanMake(north - south, east - west)
    )
  }
}

extension MAMapView {
  var cameraPosition: CameraPosition {
    return CameraPosition(
      position: centerCoordinate.position,
      heading: rotationDegree,
      skew: cameraDegree,
      zoom: zoomLevel
    )
  }

  var position: Position {
    return centerCoordinate.position
  }
}

extension MATouchPoi {
  var poi: Poi {
    return Poi(
      name: name,
      position: coordinate.position
    )
  }
}

extension MAUserLocation {
  var toLocation: Location {
    return Location(
      position: location?.coordinate.position,
      heading: heading?.trueHeading ?? location.course,
      accuracy: max(location.horizontalAccuracy, location.verticalAccuracy)
    )
  }
}

extension Bitmap {
  func toUIImage(registrar: FlutterPluginRegistrar) -> UIImage? {
    var image: UIImage?
    if let asset = self.asset {
      let key = registrar.lookupKey(forAsset: asset)
      if let path = Bundle.main.path(forResource: key, ofType: nil) {
        image = UIImage(contentsOfFile: path)
      }
    }
    if let bytes = self.bytes {
      image = UIImage(data: bytes.data)
    }
    if let effectiveSize = self.size?.cgSize() ?? image?.size {
      let scale = UIScreen.main.scale
      let targetSize = CGSize(width: effectiveSize.width / scale, height: effectiveSize.height / scale)
      let renderer = UIGraphicsImageRenderer(size: targetSize)
      image = renderer.image { _ in
        image?.draw(in: CGRect(origin: .zero, size: targetSize))
      }
    }
    return image
  }
}

extension MapType {
  var mapType: MAMapType {
    return switch(self) {
      case .standard:
        MAMapType.standard
      case .satellite:
        MAMapType.satellite
      case .standardNight:
        MAMapType.standardNight
      case .navi:
        MAMapType.navi
      case .bus:
        MAMapType.bus
      case .naviNight:
        MAMapType.standardNight
    }
  }
}

extension Marker {
  var annotation: Annotation {
    return Annotation(id: id, position: position, bitmap: bitmap, title: title, snippet: snippet)
  }
}

extension Polyline {
  var overlay: MAPolyline {
    var coordinates = points.map { $0.coordinate }
    return MAPolyline(coordinates: &coordinates, count: UInt(points.count))
  }
}

extension Polygon {
  var overlay: MAPolygon {
    var coordinates = points.map { $0.coordinate }
    return MAPolygon(coordinates: &coordinates, count: UInt(points.count))
  }
}

extension Position {
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
}

extension Region {
  var region: MACoordinateRegion {
    return MACoordinateRegion.init(north, east, south, west)
  }
}

extension Size {
  func cgSize() -> CGSize {
    return CGSizeMake(width, height)
  }
}

extension UIColor {
  convenience init(amapColorValue value: Any?) {
    if let number = value as? NSNumber {
      self.init(hex: UInt(truncating: number))
    } else if let value = value as? UInt {
      self.init(hex: value)
    } else if let value = value as? Int {
      self.init(hex: UInt(bitPattern: value))
    } else {
      self.init(hex: 0)
    }
  }

  convenience init(hex: UInt) {
    self.init(
      red: CGFloat((hex & 0x00FF0000) >> 16) / 255,
      green: CGFloat((hex & 0x0000FF00) >> 8) / 255,
      blue: CGFloat(hex & 0x000000FF) / 255,
      alpha: CGFloat((hex & 0xFF000000) >> 24) / 255
    )
  }

  var hex: UInt {
    let ciColor = CIColor(color: self)
    let alpha = UInt(ciColor.alpha)
    let red = UInt(ciColor.red)
    let blue = UInt(ciColor.blue)
    let green = UInt(ciColor.green)
    return alpha << 24 + red << 16 + green << 8 + blue
  }
}

extension UIControlPosition {
  func controlCenter(size: CGSize, bounds: CGRect) -> CGPoint {
    switch self.anchor {
    case .topLeft:
      let anchorPosition = CGVectorMake(size.width / 2, size.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .topCenter:
      let anchorPosition = CGVectorMake(bounds.width / 2, size.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .topRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width / 2 - 1, size.height / 2)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy + self.offset.y)
    case .centerLeft:
      let anchorPosition = CGVectorMake(size.width / 2, bounds.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .center:
      let anchorPosition = CGVectorMake(bounds.width / 2, bounds.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .centerRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width / 2 - 1, bounds.height / 2)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy + self.offset.y)
    case .bottomLeft:
      let anchorPosition = CGVectorMake(size.width / 2, bounds.height - size.height / 2 - 1)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy - self.offset.y)
    case .bottomCenter:
      let anchorPosition = CGVectorMake(bounds.width / 2, bounds.height - size.height / 2 - 1)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy - self.offset.y)
    case .bottomRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width / 2 - 1, bounds.height - size.height / 2 - 1)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy - self.offset.y)
    }
  }

  func controlOrigin(size: CGSize, bounds: CGRect) -> CGPoint {
    switch self.anchor {
    case .topLeft:
      let anchorPosition = CGVectorMake(0, 0)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .topCenter:
      let anchorPosition = CGVectorMake(bounds.width / 2 - size.width / 2, 0)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .topRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width, 0)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy + self.offset.y)
    case .centerLeft:
      let anchorPosition = CGVectorMake(0, bounds.height / 2 - size.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .center:
      let anchorPosition = CGVectorMake(bounds.width / 2 - size.width / 2, bounds.height / 2 - size.height / 2)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy + self.offset.y)
    case .centerRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width, bounds.height / 2 - size.height / 2)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy + self.offset.y)
    case .bottomLeft:
      let anchorPosition = CGVectorMake(0, bounds.height - size.height)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy - self.offset.y)
    case .bottomCenter:
      let anchorPosition = CGVectorMake(bounds.width / 2 - size.width / 2, bounds.height - size.height)
      return CGPointMake(anchorPosition.dx + self.offset.x, anchorPosition.dy - self.offset.y)
    case .bottomRight:
      let anchorPosition = CGVectorMake(bounds.width - size.width, bounds.height - size.height)
      return CGPointMake(anchorPosition.dx - self.offset.x, anchorPosition.dy - self.offset.y)
    }
  }
}

extension UserLocationStyle {
  func toUserLocationRepresentation(registrar: FlutterPluginRegistrar) -> MAUserLocationRepresentation {
    let userLocationRepresentation = MAUserLocationRepresentation()
    if let fillColor = fillColor {
      userLocationRepresentation.fillColor = fillColor
    }
    if let strokeColor = strokeColor {
      userLocationRepresentation.strokeColor = strokeColor
    }
    if let lineWidth = lineWidth {
      userLocationRepresentation.lineWidth = lineWidth
    }
    if let showsAccuracyRing = showsAccuracyRing {
      userLocationRepresentation.showsAccuracyRing = showsAccuracyRing
    }
    if let showsHeadingIndicator = showsHeadingIndicator {
      userLocationRepresentation.showsHeadingIndicator = showsHeadingIndicator
    }
    if let locationDotBgColor = locationDotBgColor {
      userLocationRepresentation.locationDotBgColor = locationDotBgColor
    }
    if let locationDotFillColor = locationDotFillColor {
      userLocationRepresentation.locationDotFillColor = locationDotFillColor
    }
    if let enablePulseAnimation = enablePulseAnimation {
      userLocationRepresentation.enablePulseAnnimation = enablePulseAnimation
    }
    if let image = image {
      userLocationRepresentation.image = image.toUIImage(registrar: registrar)
    }
    return userLocationRepresentation
  }
}

extension UserLocationType {
  var userTrackingMode: MAUserTrackingMode {
    return switch(self) {
      case .locationTypeShow:
        MAUserTrackingMode.none
      case .locationTypeLocate:
        MAUserTrackingMode.follow
      case .locationTypeFollow:
        MAUserTrackingMode.follow
      case .locationTypeMapRotate:
        MAUserTrackingMode.followWithHeading
      case .locationTypeLocationRotate:
        // iOS 无“定位点随设备方向旋转、地图不旋转”的独立模式，回退为居中跟随。
        MAUserTrackingMode.follow
      default:
        // iOS 无 Android 的 no-center 系列，回退为不追踪，避免沿用上一次 follow/heading 状态。
        MAUserTrackingMode.none
    }
  }

  var resetsTrackingAfterFirstLocation: Bool {
    return self == .locationTypeLocate
  }
}
