import Foundation
import Flutter

/// 地图类型
enum MapType: Int {
  /// 标准地图
  case standard = 0
  /// 卫星地图
  case satellite = 1
  /// 夜景地图
  case standardNight = 2
  /// 导航地图
  case navi = 3
  /// 公交地图
  case bus = 4
  /// 导航夜景地图
  case naviNight = 5
}

/// UI控件位置锚点
enum UIControlAnchor: Int {
  case topLeft = 0
  case topCenter = 1
  case topRight = 2
  case centerLeft = 3
  case center = 4
  case centerRight = 5
  case bottomLeft = 6
  case bottomCenter = 7
  case bottomRight = 8
}

/// 用户定位类型
enum UserLocationType: Int {
  ///只定位一次（Android Only）
  case locationTypeShow = 0
  ///定位一次，且将视角移动到地图中心点
  case locationTypeLocate = 1
  ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
  case locationTypeFollow = 2
  ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
  case locationTypeMapRotate = 3
  ///连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）默认执行此种模式（Android Only）
  case locationTypeLocationRotate = 4
  ///连续定位、蓝点不会移动到地图中心点，定位点依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  case locationTypeLocationRotateNoCenter = 5
  ///连续定位、蓝点不会移动到地图中心点，并且蓝点会跟随设备移动（Android Only）
  case locationTypeFollowNoCenter = 6
  ///连续定位、蓝点不会移动到地图中心点，地图依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  case locationTypeMapRotateNoCenter = 7
}

/// 点标记图标锚点
struct Anchor {
  /// 点标记图标锚点的X坐标
  var x: Double
  /// 点标记图标锚点的Y坐标
  var y: Double

  static func fromList(_ list: [Any?]) -> Anchor {
    let x = list[0] as! Double
    let y = list[1] as! Double
    return Anchor(
      x: x,
      y: y
    )
  }

  func toList() -> [Any?] {
    return [
      x,
      y,
    ]
  }
}

/// 图片信息
struct Bitmap {
  /// 图片资源路径
  var asset: String? = nil
  /// 图片数据
  var bytes: FlutterStandardTypedData? = nil
  /// 图片尺寸
  var size: Size? = nil

  static func fromList(_ list: [Any?]) -> Bitmap {
    let asset: String? = nilOrValue(list[0])
    let bytes: FlutterStandardTypedData? = nilOrValue(list[1])
    let size: Size? = nilOrValue(list[2])
    return Bitmap(
      asset: asset,
      bytes: bytes,
      size: size
    )
  }

  func toList() -> [Any?] {
    return [
      asset,
      bytes,
      size,
    ]
  }
}

/// 地图视野
struct CameraPosition {
  /// 地图视野的位置
  var position: Position? = nil
  /// 地图视野的旋转角度
  var heading: Double? = nil
  /// 地图视野的倾斜角度
  var skew: Double? = nil
  /// 地图视野的缩放级别
  var zoom: Double? = nil

  static func fromList(_ list: [Any?]) -> CameraPosition {
    var position: Position? = nil
    if let positionList: [Any?] = nilOrValue(list[0]) {
      position = Position.fromList(positionList)
    }
    let heading: Double? = nilOrValue(list[1])
    let skew: Double? = nilOrValue(list[2])
    let zoom: Double? = nilOrValue(list[3])
    return CameraPosition(
      position: position,
      heading: heading,
      skew: skew,
      zoom: zoom
    )
  }

  func toList() -> [Any?] {
    return [
      position?.toList(),
      heading,
      skew,
      zoom,
    ]
  }
}

/// 视野边缘宽度
struct EdgePadding {
  /// 左边缘宽度
  var left: Double
  /// 上边缘宽度
  var top: Double
  /// 右边缘宽度
  var right: Double
  /// 下边缘宽度
  var bottom: Double

  static func fromList(_ list: [Any?]) -> EdgePadding {
    let left = list[0] as! Double
    let top = list[1] as! Double
    let right = list[2] as! Double
    let bottom = list[3] as! Double
    return EdgePadding(
      left: left,
      top: top,
      right: right,
      bottom: bottom
    )
  }

  func toList() -> [Any?] {
    return [
      left,
      top,
      right,
      bottom,
    ]
  }
}

/// 定位点
struct Location {
  /// 定位点的位置
  var position: Position? = nil
  /// 定位点的方向
  var heading: Double? = nil
  /// 定位点的精确度
  var accuracy: Double? = nil

  static func fromList(_ list: [Any?]) -> Location {
    var position: Position? = nil
    if let positionList: [Any?] = nilOrValue(list[0]) {
      position = Position.fromList(positionList)
    }
    let heading: Double? = nilOrValue(list[1])
    let accuracy: Double? = nilOrValue(list[2])
    return Location(
      position: position,
      heading: heading,
      accuracy: accuracy
    )
  }

  func toList() -> [Any?] {
    return [
      position?.toList(),
      heading,
      accuracy,
    ]
  }
}

/// 离线自定义地图样式
struct CustomStyleOptions {
  var enabled: Bool
  var styleData: Data?
  var styleExtraData: Data?

  static func fromList(_ list: [Any?]) -> CustomStyleOptions {
    let enabled = list[0] as! Bool
    let styleData = (list[1] as? FlutterStandardTypedData)?.data
    let styleExtraData = (list[2] as? FlutterStandardTypedData)?.data
    return CustomStyleOptions(
      enabled: enabled,
      styleData: styleData,
      styleExtraData: styleExtraData
    )
  }

  func toList() -> [Any?] {
    return [
      enabled,
      styleData.map { FlutterStandardTypedData(bytes: $0) },
      styleExtraData.map { FlutterStandardTypedData(bytes: $0) },
    ]
  }
}

/// 初始化地图属性
struct MapInitConfig {
  var mapType: MapType? = nil
  var cameraPosition: CameraPosition? = nil
  var fitPositions: [Position]? = nil
  var minZoom: Double? = nil
  var maxZoom: Double? = nil
  var dragEnable: Bool? = nil
  var zoomEnable: Bool? = nil
  var tiltEnable: Bool? = nil
  var rotateEnable: Bool? = nil
  var compassControlEnabled: Bool? = nil
  var scaleControlEnabled: Bool? = nil
  var zoomControlEnabled: Bool? = nil
  var logoPosition: UIControlPosition? = nil
  var showIndoorMap: Bool? = nil
  var customStyleOptions: CustomStyleOptions? = nil

  static func fromList(_ list: [Any?]) -> MapInitConfig {
    var mapType: MapType? = nil
    if let type: Int = nilOrValue(list[0]) {
      mapType = MapType(rawValue: type)!
    }
    var cameraPosition: CameraPosition? = nil
    if let cameraPositionList: [Any?] = nilOrValue(list[1]) {
      cameraPosition = CameraPosition.fromList(cameraPositionList)
    }
    var fitPositions: [Position]? = nil
    if let fitPositionsList: [[Any?]] = nilOrValue(list[2]) {
      fitPositions = fitPositionsList.map({ position in Position.fromList(position) })
    }
    let minZoom: Double? = nilOrValue(list[3])
    let maxZoom: Double? = nilOrValue(list[4])
    let dragEnable: Bool? = nilOrValue(list[5])
    let zoomEnable: Bool? = nilOrValue(list[6])
    let tiltEnable: Bool? = nilOrValue(list[7])
    let rotateEnable: Bool? = nilOrValue(list[8])
    let compassControlEnabled: Bool? = nilOrValue(list[9])
    let scaleControlEnabled: Bool? = nilOrValue(list[10])
    let zoomControlEnabled: Bool? = nilOrValue(list[11])
    var logoPosition: UIControlPosition? = nil
    if let logoPositionList: [Any?] = nilOrValue(list[12]) {
      logoPosition = UIControlPosition.fromList(logoPositionList)
    }
    let showIndoorMap: Bool? = nilOrValue(list[13])
    var customStyleOptions: CustomStyleOptions? = nil
    if list.count > 14, let customList: [Any?] = nilOrValue(list[14]) {
      customStyleOptions = CustomStyleOptions.fromList(customList)
    }
    return MapInitConfig(
      mapType: mapType,
      cameraPosition: cameraPosition,
      fitPositions: fitPositions,
      minZoom: minZoom,
      maxZoom: maxZoom,
      dragEnable: dragEnable,
      zoomEnable: zoomEnable,
      tiltEnable: tiltEnable,
      rotateEnable: rotateEnable,
      compassControlEnabled: compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled,
      logoPosition: logoPosition,
      showIndoorMap: showIndoorMap,
      customStyleOptions: customStyleOptions
    )
  }

  func toList() -> [Any?] {
    return [
      mapType?.rawValue,
      cameraPosition?.toList(),
      fitPositions?.map({ position in position.toList() }),
      minZoom,
      maxZoom,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.toList(),
      showIndoorMap,
      customStyleOptions?.toList(),
    ]
  }
}

/// 地图属性配置
struct MapUpdateConfig {
  var mapType: MapType? = nil
  var dragEnable: Bool? = nil
  var zoomEnable: Bool? = nil
  var tiltEnable: Bool? = nil
  var rotateEnable: Bool? = nil
  var compassControlEnabled: Bool? = nil
  var scaleControlEnabled: Bool? = nil
  var zoomControlEnabled: Bool? = nil
  var logoPosition: UIControlPosition? = nil
  var compassControlPosition: UIControlPosition? = nil
  var scaleControlPosition: UIControlPosition? = nil
  var zoomControlPosition: UIControlPosition? = nil
  var showTraffic: Bool? = nil
  var showBuildings: Bool? = nil
  var showIndoorMap: Bool? = nil
  var userLocationConfig: UserLocationConfig? = nil
  var customStyleOptions: CustomStyleOptions? = nil
  var minZoom: Double? = nil
  var maxZoom: Double? = nil

  static func fromList(_ list: [Any?]) -> MapUpdateConfig {
    var mapType: MapType? = nil
    if let type: Int = nilOrValue(list[0]) {
      mapType = MapType(rawValue: type)!
    }
    let dragEnable: Bool? = nilOrValue(list[1])
    let zoomEnable: Bool? = nilOrValue(list[2])
    let tiltEnable: Bool? = nilOrValue(list[3])
    let rotateEnable: Bool? = nilOrValue(list[4])
    let compassControlEnabled: Bool? = nilOrValue(list[5])
    let scaleControlEnabled: Bool? = nilOrValue(list[6])
    let zoomControlEnabled: Bool? = nilOrValue(list[7])
    var logoPosition: UIControlPosition? = nil
    if let logoPositionList: [Any?] = nilOrValue(list[8]) {
      logoPosition = UIControlPosition.fromList(logoPositionList)
    }
    var compassControlPosition: UIControlPosition? = nil
    if let compassControlPositionList: [Any?] = nilOrValue(list[9]) {
      compassControlPosition = UIControlPosition.fromList(compassControlPositionList)
    }
    var scaleControlPosition: UIControlPosition? = nil
    if let scaleControlPositionList: [Any?] = nilOrValue(list[10]) {
      scaleControlPosition = UIControlPosition.fromList(scaleControlPositionList)
    }
    var zoomControlPosition: UIControlPosition? = nil
    if let zoomControlPositionList: [Any?] = nilOrValue(list[11]) {
      zoomControlPosition = UIControlPosition.fromList(zoomControlPositionList)
    }
    let showTraffic: Bool? = nilOrValue(list[12])
    let showBuildings: Bool? = nilOrValue(list[13])
    let showIndoorMap: Bool? = nilOrValue(list[14])
    var userLocationConfig: UserLocationConfig? = nil
    if let userLocationConfigList: [Any?] = nilOrValue(list[15]) {
      userLocationConfig = UserLocationConfig.fromList(userLocationConfigList)
    }
    var customStyleOptions: CustomStyleOptions? = nil
    if list.count > 16, let customList: [Any?] = nilOrValue(list[16]) {
      customStyleOptions = CustomStyleOptions.fromList(customList)
    }
    let minZoom: Double? = list.count > 17 ? nilOrValue(list[17]) : nil
    let maxZoom: Double? = list.count > 18 ? nilOrValue(list[18]) : nil
    return MapUpdateConfig(
      mapType: mapType,
      dragEnable: dragEnable,
      zoomEnable: zoomEnable,
      tiltEnable: tiltEnable,
      rotateEnable: rotateEnable,
      compassControlEnabled: compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled,
      logoPosition: logoPosition,
      compassControlPosition: compassControlPosition,
      scaleControlPosition: scaleControlPosition,
      zoomControlPosition: zoomControlPosition,
      showTraffic: showTraffic,
      showBuildings: showBuildings,
      showIndoorMap: showIndoorMap,
      userLocationConfig: userLocationConfig,
      customStyleOptions: customStyleOptions,
      minZoom: minZoom,
      maxZoom: maxZoom
    )
  }

  func toList() -> [Any?] {
    return [
      mapType?.rawValue,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.toList(),
      compassControlPosition?.toList(),
      scaleControlPosition?.toList(),
      zoomControlPosition?.toList(),
      showTraffic,
      showBuildings,
      showIndoorMap,
      userLocationConfig?.toList(),
      customStyleOptions?.toList(),
      minZoom,
      maxZoom,
    ]
  }
}

/// 标记点配置属性
struct Marker {
  /// 标记点ID
  var id: String
  /// 标记点的位置
  var position: Position
  /// 标记点自定义图标信息
  var bitmap: Bitmap?
  /// InfoWindow 标题（iOS callout）
  var title: String?
  /// InfoWindow 副标题（iOS callout subtitle）
  var snippet: String?

  static func fromList(_ list: [Any?]) -> Marker {
    let id = list[0] as! String
    let position = Position.fromList(list[1] as! [Any?])
    var bitmap: Bitmap? = nil
    if let bitmapList: [Any?] = nilOrValue(list[2]) {
      bitmap = Bitmap.fromList(bitmapList)
    }
    let title: String? = list.count > 3 ? (list[3] as? String) : nil
    let snippet: String? = list.count > 4 ? (list[4] as? String) : nil
    return Marker(
      id: id,
      position: position,
      bitmap: bitmap,
      title: title,
      snippet: snippet
    )
  }

  func toList() -> [Any?] {
    return [
      id,
      position.toList(),
      bitmap?.toList(),
      title,
      snippet,
    ]
  }
}

/// 折线覆盖物配置
struct Polyline {
  var id: String
  var points: [Position]
  var color: UIColor
  var colors: [UIColor]
  var width: Double
  var visible: Bool
  var gradient: Bool
  var geodesic: Bool
  var useTexture: Bool
  var texture: Bitmap?
  var textures: [Bitmap]
  var textureIndexes: [Int]
  var dottedLine: Bool
  var zIndex: Double

  static func fromList(_ list: [Any?]) -> Polyline {
    let id = list[0] as! String
    let points = (list[1] as! [[Any?]]).map { Position.fromList($0) }
    let color = UIColor(amapColorValue: list[2])
    let width = list[3] as! Double
    let visible = list[4] as! Bool
    let colors = list.count > 5
      ? ((list[5] as? [Any?]) ?? []).map { UIColor(amapColorValue: $0) }
      : []
    let gradient = list.count > 6 ? list[6] as! Bool : false
    let geodesic = list.count > 7 ? list[7] as! Bool : false
    let useTexture = list.count > 8 ? list[8] as! Bool : false
    var texture: Bitmap? = nil
    if list.count > 9, let textureList: [Any?] = nilOrValue(list[9]) {
      texture = Bitmap.fromList(textureList)
    }
    let textures = list.count > 10
      ? ((list[10] as? [Any?]) ?? []).map { Bitmap.fromList($0 as! [Any?]) }
      : []
    let textureIndexes = list.count > 11
      ? ((list[11] as? [Any?]) ?? []).map { ($0 as! NSNumber).intValue }
      : []
    let dottedLine = list.count > 12 ? list[12] as! Bool : false
    let zIndex = list.count > 13 ? (list[13] as! NSNumber).doubleValue : 0
    return Polyline(
      id: id,
      points: points,
      color: color,
      colors: colors,
      width: width,
      visible: visible,
      gradient: gradient,
      geodesic: geodesic,
      useTexture: useTexture,
      texture: texture,
      textures: textures,
      textureIndexes: textureIndexes,
      dottedLine: dottedLine,
      zIndex: zIndex
    )
  }

  func toList() -> [Any?] {
    return [
      id,
      points.map { $0.toList() },
      color.hex,
      width,
      visible,
      colors.map { $0.hex },
      gradient,
      geodesic,
      useTexture,
      texture?.toList(),
      textures.map { $0.toList() },
      textureIndexes,
      dottedLine,
      zIndex,
    ]
  }
}

/// 导航箭头覆盖物配置
struct NavigateArrow {
  var id: String
  var points: [Position]
  var color: UIColor
  var sideColor: UIColor
  var width: Double
  var visible: Bool

  static func fromList(_ list: [Any?]) -> NavigateArrow {
    let id = list[0] as! String
    let points = (list[1] as! [[Any?]]).map { Position.fromList($0) }
    let color = UIColor(amapColorValue: list[2])
    let sideColor = UIColor(amapColorValue: list[3])
    let width = list[4] as! Double
    let visible = list[5] as! Bool
    return NavigateArrow(
      id: id,
      points: points,
      color: color,
      sideColor: sideColor,
      width: width,
      visible: visible
    )
  }

  func toList() -> [Any?] {
    return [
      id,
      points.map { $0.toList() },
      color.hex,
      sideColor.hex,
      width,
      visible,
    ]
  }
}

/// 弧线覆盖物配置
struct Arc {
  var id: String
  var start: Position
  var passed: Position
  var end: Position
  var color: UIColor
  var width: Double
  var visible: Bool

  static func fromList(_ list: [Any?]) -> Arc {
    return Arc(
      id: list[0] as! String,
      start: Position.fromList(list[1] as! [Any?]),
      passed: Position.fromList(list[2] as! [Any?]),
      end: Position.fromList(list[3] as! [Any?]),
      color: UIColor(amapColorValue: list[4]),
      width: list[5] as! Double,
      visible: list[6] as! Bool
    )
  }

  func toList() -> [Any?] {
    return [
      id,
      start.toList(),
      passed.toList(),
      end.toList(),
      color.hex,
      width,
      visible,
    ]
  }
}

/// 多边形覆盖物配置
struct Polygon {
  var id: String
  var points: [Position]
  var strokeWidth: Double
  var strokeColor: UIColor
  var fillColor: UIColor
  var visible: Bool

  static func fromList(_ list: [Any?]) -> Polygon {
    let id = list[0] as! String
    let points = (list[1] as! [[Any?]]).map { Position.fromList($0) }
    let strokeWidth = list[2] as! Double
    let strokeColor = UIColor(amapColorValue: list[3])
    let fillColor = UIColor(amapColorValue: list[4])
    let visible = list[5] as! Bool
    return Polygon(
      id: id,
      points: points,
      strokeWidth: strokeWidth,
      strokeColor: strokeColor,
      fillColor: fillColor,
      visible: visible
    )
  }

  func toList() -> [Any?] {
    return [
      id,
      points.map { $0.toList() },
      strokeWidth,
      strokeColor.hex,
      fillColor.hex,
      visible,
    ]
  }
}

/// 地图兴趣点
struct Poi {
  /// 兴趣点的名称
  var name: String
  /// 兴趣点的位置
  var position: Position

  static func fromList(_ list: [Any?]) -> Poi {
    let name = list[0] as! String
    let position = Position.fromList(list[1] as! [Any?])
    return Poi(
      name: name,
      position: position
    )
  }

  func toList() -> [Any?] {
    return [
      name,
      position.toList(),
    ]
  }
}

/// 位置
struct Position {
  /// 位置的纬度
  var latitude: Double
  /// 位置的经度
  var longitude: Double

  static func fromList(_ list: [Any?]) -> Position {
    let latitude = list[0] as! Double
    let longitude = list[1] as! Double
    return Position(
      latitude: latitude,
      longitude: longitude
    )
  }

  func toList() -> [Any?] {
    return [
      latitude,
      longitude,
    ]
  }
}

/// 地图区域
struct Region {
  /// 最北的纬度
  var north: Double
  /// 最东的经度
  var east: Double
  /// 最南的纬度
  var south: Double
  /// 最西的经度
  var west: Double

  static func fromList(_ list: [Any?]) -> Region {
    let north = list[0] as! Double
    let east = list[1] as! Double
    let south = list[2] as! Double
    let west = list[3] as! Double
    return Region(
      north: north,
      east: east,
      south: south,
      west: west
    )
  }

  func toList() -> [Any?] {
    return [
      north,
      east,
      south,
      west,
    ]
  }
}

/// 对象的像素尺寸
struct Size {
  /// 宽度
  var width: Double
  /// 高度
  var height: Double

  static func fromList(_ list: [Any?]) -> Size {
    let width = list[0] as! Double
    let height = list[1] as! Double
    return Size(
      width: width,
      height: height
    )
  }

  func toList() -> [Any?] {
    return [
      width,
      height,
    ]
  }
}

/// UI控件位置偏移
struct UIControlOffset {
  /// X轴方向的位置偏移
  var x: Double
  /// Y轴方向的位置偏移
  var y: Double

  static func fromList(_ list: [Any?]) -> UIControlOffset {
    let x = list[0] as! Double
    let y = list[1] as! Double
    return UIControlOffset(
      x: x,
      y: y
    )
  }

  func toList() -> [Any?] {
    return [
      x,
      y,
    ]
  }
}

/// UI控件位置
struct UIControlPosition {
  /// UI控件位置锚点
  var anchor: UIControlAnchor
  /// UI控件位置偏移
  var offset: UIControlOffset

  static func fromList(_ list: [Any?]) -> UIControlPosition? {
    let anchor = UIControlAnchor(rawValue: list[0] as! Int)!
    let offset = UIControlOffset.fromList(list[1] as! [Any?])
    return UIControlPosition(
      anchor: anchor,
      offset: offset
    )
  }

  func toList() -> [Any?] {
    return [
      anchor.rawValue,
      offset.toList(),
    ]
  }
}

/// 用户定位配置
struct UserLocationConfig {
  var userLocationButton: Bool?
  var showUserLocation: Bool?
  var userLocationStyle: UserLocationStyle?

  static func fromList(_ list: [Any?]) -> UserLocationConfig? {
    let userLocationButton: Bool? = nilOrValue(list[0])
    let showUserLocation: Bool? = nilOrValue(list[1])
    var userLocationStyle: UserLocationStyle? = nil
    if let userLocationStyleList: [Any?] = nilOrValue(list[2]) {
      userLocationStyle = UserLocationStyle.fromList(userLocationStyleList)
    }
    return UserLocationConfig(
      userLocationButton: userLocationButton,
      showUserLocation: showUserLocation,
      userLocationStyle: userLocationStyle
    )
  }

  func toList() -> [Any?] {
    return [
      userLocationButton,
      showUserLocation,
      userLocationStyle?.toList(),
    ]
  }
}

/// 用户定位样式
struct UserLocationStyle {
  var userLocationType: UserLocationType?
  var fillColor: UIColor?
  var strokeColor: UIColor?
  var lineWidth: Double?
  var image: Bitmap?
  var showLocationDot: Bool?
  var anchor: Anchor?
  var showsAccuracyRing: Bool?
  var showsHeadingIndicator: Bool?
  var locationDotBgColor: UIColor?
  var locationDotFillColor: UIColor?
  var enablePulseAnimation: Bool?
  var intervalMs: Int?

  static func fromList(_ list: [Any?]) -> UserLocationStyle? {
    var userLocationType: UserLocationType? = nil
    if let type: Int = nilOrValue(list[0]) {
      userLocationType = UserLocationType(rawValue: type)!
    }
    var fillColor: UIColor? = nil
    if !(list[1] is NSNull) {
      fillColor = UIColor(amapColorValue: list[1])
    }
    var strokeColor: UIColor? = nil
    if !(list[2] is NSNull) {
      strokeColor = UIColor(amapColorValue: list[2])
    }
    let lineWidth: Double? = nilOrValue(list[3])
    var image: Bitmap? = nil
    if let imageList: [Any?] = nilOrValue(list[4]) {
      image = Bitmap.fromList(imageList)
    }
    let showLocationDot: Bool? = list.count > 5 ? nilOrValue(list[5]) : nil
    var anchor: Anchor? = nil
    if list.count > 6, let anchorList: [Any?] = nilOrValue(list[6]) {
      anchor = Anchor.fromList(anchorList)
    }
    let showsAccuracyRing: Bool? = list.count > 7 ? nilOrValue(list[7]) : nil
    let showsHeadingIndicator: Bool? = list.count > 8 ? nilOrValue(list[8]) : nil
    var locationDotBgColor: UIColor? = nil
    if list.count > 9, !(list[9] is NSNull) {
      locationDotBgColor = UIColor(amapColorValue: list[9])
    }
    var locationDotFillColor: UIColor? = nil
    if list.count > 10, !(list[10] is NSNull) {
      locationDotFillColor = UIColor(amapColorValue: list[10])
    }
    let enablePulseAnimation: Bool? = list.count > 11 ? nilOrValue(list[11]) : nil
    let intervalMs: Int? = list.count > 12 ? nilOrValue(list[12]) : nil
    return UserLocationStyle(
      userLocationType: userLocationType,
      fillColor: fillColor,
      strokeColor: strokeColor,
      lineWidth: lineWidth,
      image: image,
      showLocationDot: showLocationDot,
      anchor: anchor,
      showsAccuracyRing: showsAccuracyRing,
      showsHeadingIndicator: showsHeadingIndicator,
      locationDotBgColor: locationDotBgColor,
      locationDotFillColor: locationDotFillColor,
      enablePulseAnimation: enablePulseAnimation,
      intervalMs: intervalMs
    )
  }

  func toList() -> [Any?] {
    return [
      userLocationType?.rawValue,
      fillColor?.hex,
      strokeColor?.hex,
      lineWidth,
      image?.toList(),
      showLocationDot,
      anchor?.toList(),
      showsAccuracyRing,
      showsHeadingIndicator,
      locationDotBgColor?.hex,
      locationDotFillColor?.hex,
      enablePulseAnimation,
      intervalMs,
    ]
  }
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}
