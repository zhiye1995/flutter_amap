part of '../amap_flutter.dart';

/// 地图类型
enum MapType {
  /// 标准地图
  standard,

  /// 卫星地图
  satellite,

  /// 标准夜景地图
  standardNight,

  /// 导航地图
  navi,

  /// 公交地图
  bus,

  /// 导航夜景地图（iOS only）
  naviNight,
}

/// UI控件位置锚点
enum UIControlAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// 用户定位类型
enum UserLocationType {
  ///只定位一次（Android Only）
  locationTypeShow,

  ///定位一次，且将视角移动到地图中心点
  locationTypeLocate,

  ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
  locationTypeFollow,

  ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
  locationTypeMapRotate,

  ///连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）默认执行此种模式（Android Only）
  locationTypeLocationRotate,

  ///连续定位、蓝点不会移动到地图中心点，定位点依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  locationTypeLocationRotateNoCenter,

  ///连续定位、蓝点不会移动到地图中心点，并且蓝点会跟随设备移动（Android Only）
  locationTypeFollowNoCenter,

  ///连续定位、蓝点不会移动到地图中心点，地图依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  locationTypeMapRotateNoCenter,
}

/// 点标记图标锚点
class Anchor {
  Anchor({
    required this.x,
    required this.y,
  });

  /// 点标记图标锚点的X坐标
  double x;

  /// 点标记图标锚点的Y坐标
  double y;

  Object encode() {
    return <Object?>[
      x,
      y,
    ];
  }

  static Anchor decode(List<Object?> result) {
    return Anchor(
      x: result[0]! as double,
      y: result[1]! as double,
    );
  }

  Anchor copyWith({
    double? x,
    double? y,
  }) {
    return Anchor(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// 高德地图api key
class ApiKey {
  ApiKey({
    required this.iosKey,
    required this.androidKey,
    required this.webKey,
  });

  /// iOS平台的key
  final String iosKey;

  /// Android平台的key
  final String androidKey;

  /// Web平台的key
  final String webKey;

  Object encode() {
    return <Object?>[
      iosKey,
      androidKey,
      webKey,
    ];
  }

  static ApiKey decode(List<Object?> result) {
    return ApiKey(
      iosKey: result[0] as String,
      androidKey: result[1] as String,
      webKey: result[2] as String,
    );
  }

  ApiKey copyWith({
    String? iosKey,
    String? androidKey,
    String? webKey,
  }) {
    return ApiKey(
      iosKey: iosKey ?? this.iosKey,
      androidKey: androidKey ?? this.androidKey,
      webKey: webKey ?? this.webKey,
    );
  }
}

/// 图片信息
class Bitmap {
  Bitmap({
    this.asset,
    this.bytes,
    this.size,
  });

  /// 图片资源路径
  String? asset;

  /// 图片数据
  Uint8List? bytes;

  /// 图片尺寸
  Size? size;

  Object encode() {
    return <Object?>[
      asset,
      bytes,
      size,
    ];
  }

  static Bitmap decode(List<Object?> result) {
    return Bitmap(
      asset: result[0] as String?,
      bytes: result[1] as Uint8List?,
      size: result[2] as Size?,
    );
  }

  Bitmap copyWith({
    String? asset,
    Uint8List? bytes,
    Size? size,
  }) {
    return Bitmap(
      asset: asset ?? this.asset,
      bytes: bytes ?? this.bytes,
      size: size ?? this.size,
    );
  }
}

/// 地图视野
class CameraPosition {
  CameraPosition({
    this.position,
    this.heading,
    this.skew,
    this.zoom,
  });

  /// 只设置缩放级别的便捷构造函数
  CameraPosition.zoom(this.zoom)
      : position = null,
        heading = null,
        skew = null;

  /// 地图视野的位置（可选，不传则不改变当前中心位置）
  Position? position;

  /// 地图视野的旋转角度
  double? heading;

  /// 地图视野的倾斜角度
  double? skew;

  /// 地图视野的缩放级别
  /// | Zoom  | 大致效果     | 典型使用场景  |
  // | ----- | -------- | ------- |
  // | 3–5   | 国家 / 大区级 | 全国视图    |
  // | 6–7   | 省级       | 跨省路线    |
  // | 8–9   | 市级       | 城市整体    |
  // | 10–11 | 区 / 城区   | 城市道路    |
  // | 12–13 | 主干道      | 日常浏览    |
  // | 14–15 | 街道级      | 步行 / 骑行 |
  // | 16    | 路口清晰     | 导航常用    |
  // | 17    | 建筑轮廓     | 车道级     |
  // | 18    | 建筑细节     | 精细导航    |
  // | 19–20 | 极限放大     | 特殊展示    |
  double? zoom;

  Object encode() {
    return <Object?>[
      position?.encode(),
      heading,
      skew,
      zoom,
    ];
  }

  static CameraPosition decode(List<Object?> result) {
    return CameraPosition(
      position: result[0] != null
          ? Position.decode(result[0]! as List<Object?>)
          : null,
      heading: result[1] as double?,
      skew: result[2] as double?,
      zoom: result[3] as double?,
    );
  }

  CameraPosition copyWith({
    Position? position,
    double? heading,
    double? skew,
    double? zoom,
  }) {
    return CameraPosition(
      position: position ?? this.position,
      heading: heading ?? this.heading,
      skew: skew ?? this.skew,
      zoom: zoom ?? this.zoom,
    );
  }
}

/// 视野边缘宽度
class EdgePadding {
  EdgePadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// 左边缘宽度
  double left;

  /// 上边缘宽度
  double top;

  /// 右边缘宽度
  double right;

  /// 下边缘宽度
  double bottom;

  Object encode() {
    return <Object?>[
      left,
      top,
      right,
      bottom,
    ];
  }

  static EdgePadding decode(List<Object?> result) {
    return EdgePadding(
      left: result[0]! as double,
      top: result[1]! as double,
      right: result[2]! as double,
      bottom: result[3]! as double,
    );
  }

  EdgePadding copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgePadding(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}

/// 定位点
class Location {
  Location({
    required this.position,
    this.heading,
    this.accuracy,
  });

  /// 定位点的位置
  Position position;

  /// 定位点的方向
  double? heading;

  /// 定位点的精确度
  double? accuracy;

  Object encode() {
    return <Object?>[
      position.encode(),
      heading,
      accuracy,
    ];
  }

  static Location decode(List<Object?> result) {
    return Location(
      position: Position.decode(result[0]! as List<Object?>),
      heading: result[1] as double?,
      accuracy: result[2] as double?,
    );
  }

  Location copyWith({
    Position? position,
    double? heading,
    double? accuracy,
  }) {
    return Location(
      position: position ?? this.position,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

/// 初始化地图属性
class MapInitConfig {
  MapInitConfig({
    this.mapType,
    this.mapStyle,
    this.cameraPosition,
    this.fitPositions,
    this.minZoom,
    this.maxZoom,
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
    this.jogEnable,
    this.animateEnable,
    this.keyboardEnable,
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.logoPosition,
    this.doubleClickZoom,
    this.scrollWheel,
    this.touchZoom,
    this.touchZoomCenter,
    this.isHotspot,
    this.showBuildingBlock,
    this.showLabel,
    this.showIndoorMap,
    this.defaultCursor,
    this.viewMode,
    this.terrain,
    this.wallColor,
    this.roofColor,
    this.skyColor,
  });

  /// 设置地图类型
  final MapType? mapType;

  /// 设置地图的显示样式(Web Only)
  final String? mapStyle;

  /// 地图视野
  final CameraPosition? cameraPosition;

  /// 地图视野以适应位置
  final List<Position>? fitPositions;

  /// 地图最小缩放等级
  final double? minZoom;

  /// 地图最大缩放等级
  final double? maxZoom;

  /// 地图是否允许拖拽
  final bool? dragEnable;

  /// 地图是否允许缩放
  final bool? zoomEnable;

  /// 地图是否允许俯仰
  final bool? tiltEnable;

  /// 地图是否允许旋转
  final bool? rotateEnable;

  /// 地图是否使用缓动效果，默认为true(Web Only)
  final bool? jogEnable;

  /// 地图平移过程中是否使用动画，默认为true(Web Only)
  final bool? animateEnable;

  /// 地图是否可通过键盘控制，默认为true(Web Only)
  final bool? keyboardEnable;

  /// 是否显示指南针控件
  final bool? compassControlEnabled;

  /// 是否显示比例尺控件
  final bool? scaleControlEnabled;

  /// 是否显示缩放控件(Android Only)
  final bool? zoomControlEnabled;

  /// Logo位置锚点(Android Only)
  final UIControlPosition? logoPosition;

  /// 地图是否可通过双击鼠标放大地图，默认为true(Web Only)
  final bool? doubleClickZoom;

  /// 地图是否可通过鼠标滚轮缩放浏览，默认为true(Web Only)
  final bool? scrollWheel;

  /// 地图在移动终端上是否可通过多点触控缩放浏览地图，默认为true(Web Only)
  final bool? touchZoom;

  /// 手机端双指缩放是否以地图中心为中心，否则以双指中间点为中心，默认为true(Web Only)
  final bool? touchZoomCenter;

  /// 是否开启地图热点和标注的hover效果，PC端默认是true，移动端默认是 false(Web Only)
  final bool? isHotspot;

  /// 是否展示地图3D楼块，默认true(Web Only)
  final bool? showBuildingBlock;

  /// 是否展示地图文字和 POI 信息，默认为true(Web Only)
  final bool? showLabel;

  /// 是否自动展示室内地图，默认是false(Web Only)
  final bool? showIndoorMap;

  /// 地图默认鼠标样式(Web Only)
  final String? defaultCursor;

  /// 初始地图视图模式，默认为2D, 3D 地形图 目前仅支持 v2.1Beta(Web Only)
  final String? viewMode;

  /// 初始地图是否展示地形，默认为false(Web Only)
  final bool? terrain;

  /// 地图楼块的侧面颜色(Web Only)
  final Color? wallColor;

  /// 地图楼块的顶面颜色(Web Only)
  final Color? roofColor;

  /// 天空颜色，3D模式下带有俯仰角时会显示(Web Only)
  final Color? skyColor;

  Object encode() {
    return <Object?>[
      mapType?.index,
      mapStyle,
      cameraPosition?.encode(),
      fitPositions?.map((position) => position.encode()).toList(),
      minZoom,
      maxZoom,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      jogEnable,
      animateEnable,
      keyboardEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.encode(),
      doubleClickZoom,
      scrollWheel,
      touchZoom,
      touchZoomCenter,
      isHotspot,
      showBuildingBlock,
      showLabel,
      showIndoorMap,
      defaultCursor,
      viewMode,
      terrain,
      wallColor?.value,
      roofColor?.value,
      skyColor?.value,
    ];
  }

  static MapInitConfig decode(List<Object?> result) {
    return MapInitConfig(
      mapType: result[0] as MapType?,
      mapStyle: result[1] as String?,
      cameraPosition: result[2] != null ? CameraPosition.decode(result[2]! as List<Object?>) : null,
      fitPositions: result[3] != null
          ? (result[3] as List).map((position) => Position.decode(position)).toList()
          : null,
      minZoom: result[4] as double?,
      maxZoom: result[5] as double?,
      dragEnable: result[6] as bool?,
      zoomEnable: result[7] as bool?,
      tiltEnable: result[8] as bool?,
      rotateEnable: result[9] as bool?,
      jogEnable: result[10] as bool?,
      animateEnable: result[11] as bool?,
      keyboardEnable: result[12] as bool?,
      compassControlEnabled: result[13] as bool?,
      scaleControlEnabled: result[14] as bool?,
      zoomControlEnabled: result[15] as bool?,
      logoPosition:
          result[16] != null ? UIControlPosition.decode(result[16]! as List<Object?>) : null,
      doubleClickZoom: result[17] as bool?,
      scrollWheel: result[18] as bool?,
      touchZoom: result[19] as bool?,
      touchZoomCenter: result[20] as bool?,
      isHotspot: result[21] as bool?,
      showBuildingBlock: result[22] as bool?,
      showLabel: result[23] as bool?,
      showIndoorMap: result[24] as bool?,
      defaultCursor: result[25] as String?,
      viewMode: result[26] as String?,
      terrain: result[27] as bool?,
      wallColor: result[28] != null ? Color(result[28] as int) : null,
      roofColor: result[29] != null ? Color(result[29] as int) : null,
      skyColor: result[30] != null ? Color(result[30] as int) : null,
    );
  }

  MapInitConfig copyWith({
    MapType? mapType,
    String? mapStyle,
    CameraPosition? cameraPosition,
    List<Position>? fitPositions,
    double? minZoom,
    double? maxZoom,
    bool? dragEnable,
    bool? zoomEnable,
    bool? tiltEnable,
    bool? rotateEnable,
    bool? jogEnable,
    bool? animateEnable,
    bool? keyboardEnable,
    bool? compassControlEnabled,
    bool? scaleControlEnabled,
    bool? zoomControlEnabled,
    UIControlPosition? logoPosition,
    bool? doubleClickZoom,
    bool? scrollWheel,
    bool? touchZoom,
    bool? touchZoomCenter,
    bool? isHotspot,
    bool? showBuildingBlock,
    bool? showLabel,
    bool? showIndoorMap,
    String? defaultCursor,
    String? viewMode,
    bool? terrain,
    Color? wallColor,
    Color? roofColor,
    Color? skyColor,
  }) {
    return MapInitConfig(
      mapType: mapType ?? this.mapType,
      mapStyle: mapStyle ?? this.mapStyle,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      fitPositions: fitPositions ?? this.fitPositions,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      dragEnable: dragEnable ?? this.dragEnable,
      zoomEnable: zoomEnable ?? this.zoomEnable,
      tiltEnable: tiltEnable ?? this.tiltEnable,
      rotateEnable: rotateEnable ?? this.rotateEnable,
      jogEnable: jogEnable ?? this.jogEnable,
      animateEnable: animateEnable ?? this.animateEnable,
      keyboardEnable: keyboardEnable ?? this.keyboardEnable,
      compassControlEnabled: compassControlEnabled ?? this.compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled ?? this.scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled ?? this.zoomControlEnabled,
      logoPosition: logoPosition ?? this.logoPosition,
      doubleClickZoom: doubleClickZoom ?? this.doubleClickZoom,
      scrollWheel: scrollWheel ?? this.scrollWheel,
      touchZoom: touchZoom ?? this.touchZoom,
      touchZoomCenter: touchZoomCenter ?? this.touchZoomCenter,
      isHotspot: isHotspot ?? this.isHotspot,
      showBuildingBlock: showBuildingBlock ?? this.showBuildingBlock,
      showLabel: showLabel ?? this.showLabel,
      showIndoorMap: showIndoorMap ?? this.showIndoorMap,
      defaultCursor: defaultCursor ?? this.defaultCursor,
      viewMode: viewMode ?? this.viewMode,
      terrain: terrain ?? this.terrain,
      wallColor: wallColor ?? this.wallColor,
      roofColor: roofColor ?? this.roofColor,
      skyColor: skyColor ?? this.skyColor,
    );
  }
}

/// 更新地图属性
class MapUpdateConfig {
  MapUpdateConfig({
    this.mapType,
    this.mapStyle,
    this.mapFeatures,
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.hawkEyeControlEnabled,
    this.mapTypeControlEnabled,
    this.logoPosition,
    this.compassControlPosition,
    this.scaleControlPosition,
    this.zoomControlPosition,
    this.showTraffic,
    this.showBuildings,
    this.showIndoorMap,
    this.showSatelliteLayer,
    this.showRoadNetLayer,
    this.userLocationConfig,
  });

  /// 设置地图类型
  MapType? mapType;

  /// 设置地图的显示样式
  String? mapStyle;

  /// 地图显示要素(Web Only)
  List<String>? mapFeatures;

  /// 地图是否允许拖拽
  bool? dragEnable;

  /// 地图是否允许缩放
  bool? zoomEnable;

  /// 地图是否允许俯仰
  bool? tiltEnable;

  /// 地图是否允许旋转
  bool? rotateEnable;

  /// 是否显示指南针控件
  bool? compassControlEnabled;

  /// 是否显示比例尺控件
  bool? scaleControlEnabled;

  /// 是否显示缩放控件(iOS not support)
  bool? zoomControlEnabled;

  /// 是否显示鹰眼控件(Web Only)
  bool? hawkEyeControlEnabled;

  /// 是否显示地图类型控件(Web Only)
  bool? mapTypeControlEnabled;

  /// Logo位置
  UIControlPosition? logoPosition;

  /// 指南针控件位置
  UIControlPosition? compassControlPosition;

  /// 比例尺控件位置
  UIControlPosition? scaleControlPosition;

  /// 缩放控件位置
  UIControlPosition? zoomControlPosition;

  /// 是否显示实时路况
  bool? showTraffic;

  /// 是否显示楼块
  bool? showBuildings;

  /// 是否显示室内图
  bool? showIndoorMap;

  /// 是否显示卫星图层(Web Only)
  bool? showSatelliteLayer;

  /// 是否显示路网图层(Web Only)
  bool? showRoadNetLayer;

  /// 用户定位配置
  UserLocationConfig? userLocationConfig;

  Object encode() {
    return <Object?>[
      mapType?.index,
      mapStyle,
      mapFeatures,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      hawkEyeControlEnabled,
      mapTypeControlEnabled,
      logoPosition?.encode(),
      compassControlPosition?.encode(),
      scaleControlPosition?.encode(),
      zoomControlPosition?.encode(),
      showTraffic,
      showBuildings,
      showIndoorMap,
      showSatelliteLayer,
      showRoadNetLayer,
      userLocationConfig?.encode(),
    ];
  }

  static MapUpdateConfig decode(List<Object?> result) {
    return MapUpdateConfig(
      mapType: result[0] as MapType?,
      mapStyle: result[1] as String?,
      mapFeatures: result[2] as List<String>?,
      dragEnable: result[3] as bool?,
      zoomEnable: result[4] as bool?,
      tiltEnable: result[5] as bool?,
      rotateEnable: result[6] as bool?,
      compassControlEnabled: result[7] as bool?,
      scaleControlEnabled: result[8] as bool?,
      zoomControlEnabled: result[9] as bool?,
      hawkEyeControlEnabled: result[10] as bool?,
      mapTypeControlEnabled: result[11] as bool?,
      logoPosition:
          result[12] != null ? UIControlPosition.decode(result[12]! as List<Object?>) : null,
      compassControlPosition:
          result[13] != null ? UIControlPosition.decode(result[13]! as List<Object?>) : null,
      scaleControlPosition:
          result[14] != null ? UIControlPosition.decode(result[14]! as List<Object?>) : null,
      zoomControlPosition:
          result[15] != null ? UIControlPosition.decode(result[15]! as List<Object?>) : null,
      showTraffic: result[16] as bool?,
      showBuildings: result[17] as bool?,
      showIndoorMap: result[18] as bool?,
      showSatelliteLayer: result[19] as bool?,
      showRoadNetLayer: result[20] as bool?,
      userLocationConfig:
          result[21] != null ? UserLocationConfig.decode(result[21]! as List<Object?>) : null,
    );
  }

  MapUpdateConfig copyWith({
    MapType? mapType,
    String? mapStyle,
    List<String>? mapFeatures,
    bool? dragEnable,
    bool? zoomEnable,
    bool? tiltEnable,
    bool? rotateEnable,
    bool? compassControlEnabled,
    bool? scaleControlEnabled,
    bool? zoomControlEnabled,
    bool? hawkEyeControlEnabled,
    bool? mapTypeControlEnabled,
    UIControlPosition? logoPosition,
    UIControlPosition? compassControlPosition,
    UIControlPosition? scaleControlPosition,
    UIControlPosition? zoomControlPosition,
    bool? showTraffic,
    bool? showBuildings,
    bool? showIndoorMap,
    bool? showSatelliteLayer,
    bool? showRoadNetLayer,
    UserLocationConfig? userLocationConfig,
  }) {
    return MapUpdateConfig(
      mapType: mapType ?? this.mapType,
      mapStyle: mapStyle ?? this.mapStyle,
      mapFeatures: mapFeatures ?? this.mapFeatures,
      dragEnable: dragEnable ?? this.dragEnable,
      zoomEnable: zoomEnable ?? this.zoomEnable,
      tiltEnable: tiltEnable ?? this.tiltEnable,
      rotateEnable: rotateEnable ?? this.rotateEnable,
      compassControlEnabled: compassControlEnabled ?? this.compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled ?? this.scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled ?? this.zoomControlEnabled,
      hawkEyeControlEnabled: hawkEyeControlEnabled ?? this.hawkEyeControlEnabled,
      mapTypeControlEnabled: mapTypeControlEnabled ?? this.mapTypeControlEnabled,
      logoPosition: logoPosition ?? this.logoPosition,
      compassControlPosition: compassControlPosition ?? this.compassControlPosition,
      scaleControlPosition: scaleControlPosition ?? this.scaleControlPosition,
      zoomControlPosition: zoomControlPosition ?? this.zoomControlPosition,
      showTraffic: showTraffic ?? this.showTraffic,
      showBuildings: showBuildings ?? this.showBuildings,
      showIndoorMap: showIndoorMap ?? this.showIndoorMap,
      showSatelliteLayer: showSatelliteLayer ?? this.showSatelliteLayer,
      showRoadNetLayer: showRoadNetLayer ?? this.showRoadNetLayer,
      userLocationConfig: userLocationConfig ?? this.userLocationConfig,
    );
  }
}

/// 标记点配置属性
class Marker {
  Marker({
    required this.id,
    required this.position,
    this.bitmap,
  });

  /// 标记点ID
  String id;

  /// 标记点的位置
  Position position;

  /// 标记点自定义图标信息
  Bitmap? bitmap;

  Object encode() {
    return <Object?>[
      id,
      position.encode(),
      bitmap?.encode(),
    ];
  }

  static Marker decode(List<Object?> result) {
    return Marker(
      id: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
      bitmap: result[2] != null ? Bitmap.decode(result[2]! as List<Object?>) : null,
    );
  }

  Marker copyWith({
    String? id,
    Position? position,
    Bitmap? bitmap,
  }) {
    return Marker(
      id: id ?? this.id,
      position: position ?? this.position,
      bitmap: bitmap ?? this.bitmap,
    );
  }
}

/// 地图兴趣点
class Poi {
  Poi({
    required this.name,
    required this.position,
  });

  /// 兴趣点的名称
  String name;

  /// 兴趣点的位置
  Position position;

  Object encode() {
    return <Object?>[
      name,
      position.encode(),
    ];
  }

  static Poi decode(List<Object?> result) {
    return Poi(
      name: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
    );
  }

  Poi copyWith({
    String? name,
    Position? position,
  }) {
    return Poi(
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }
}

/// 位置
class Position {
  Position({
    required double latitude,
    required double longitude,
  })  : latitude = latitude < -90.0 ? -90.0 : (latitude > 90.0 ? 90.0 : latitude),
        longitude =
        longitude >= -180 && longitude < 180 ? longitude : (longitude + 180.0) % 360.0 - 180.0;

  /// 位置的纬度
  double latitude;

  /// 位置的经度
  double longitude;

  Object encode() {
    return <Object?>[
      latitude,
      longitude,
    ];
  }

  static Position decode(List<Object?> result) {
    assert(result.length == 2);
    return Position(
      latitude: result[0]! as double,
      longitude: result[1]! as double,
    );
  }

  Position copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// 地图区域
class Region {
  Region({
    required this.north,
    required this.east,
    required this.south,
    required this.west,
  });

  /// 最北的纬度
  double north;

  /// 最东的经度
  double east;

  /// 最南的纬度
  double south;

  /// 最西的经度
  double west;

  Object encode() {
    return <Object?>[
      north,
      east,
      south,
      west,
    ];
  }

  static Region decode(List<Object?> result) {
    return Region(
      north: result[0]! as double,
      east: result[1]! as double,
      south: result[2]! as double,
      west: result[3]! as double,
    );
  }

  Region copyWith({
    double? north,
    double? east,
    double? south,
    double? west,
  }) {
    return Region(
      north: north ?? this.north,
      east: east ?? this.east,
      south: south ?? this.south,
      west: west ?? this.west,
    );
  }
}

/// 对象的像素尺寸
class Size {
  Size({
    required this.width,
    required this.height,
  });

  double width;
  double height;

  Object encode() {
    return <Object?>[
      width,
      height,
    ];
  }

  static Size decode(List<Object?> result) {
    return Size(
      width: result[0]! as double,
      height: result[1]! as double,
    );
  }

  Size copyWith({
    double? width,
    double? height,
  }) {
    return Size(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// UI控件位置偏移
class UIControlOffset {
  UIControlOffset({
    required this.x,
    required this.y,
  });

  /// X轴方向的位置偏移
  double x;

  /// Y轴方向的位置偏移
  double y;

  Object encode() {
    return <Object?>[
      x,
      y,
    ];
  }

  static UIControlOffset decode(List<Object?> result) {
    return UIControlOffset(
      x: result[0]! as double,
      y: result[1]! as double,
    );
  }

  UIControlOffset copyWith({
    double? x,
    double? y,
  }) {
    return UIControlOffset(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// UI控件位置
class UIControlPosition {
  UIControlPosition({
    required this.anchor,
    required this.offset,
  });

  /// UI控件位置锚点
  UIControlAnchor anchor;

  /// UI控件位置偏移
  UIControlOffset offset;

  Object encode() {
    return <Object?>[
      anchor.index,
      offset.encode(),
    ];
  }

  static UIControlPosition decode(List<Object?> result) {
    return UIControlPosition(
      anchor: result[0] as UIControlAnchor,
      offset: UIControlOffset.decode(result[1]! as List<Object?>),
    );
  }

  UIControlPosition copyWith({
    UIControlAnchor? anchor,
    UIControlOffset? offset,
  }) {
    return UIControlPosition(
      anchor: anchor ?? this.anchor,
      offset: offset ?? this.offset,
    );
  }
}

/// 用户定位配置
class UserLocationConfig {
  UserLocationConfig({
    this.userLocationButton,
    this.showUserLocation,
    this.userLocationStyle,
  });

  final bool? userLocationButton;
  final bool? showUserLocation;
  final UserLocationStyle? userLocationStyle;

  Object encode() {
    return <Object?>[
      userLocationButton,
      showUserLocation,
      userLocationStyle?.encode(),
    ];
  }

  static UserLocationConfig decode(List<Object?> result) {
    return UserLocationConfig(
      userLocationButton: result[0] as bool?,
      showUserLocation: result[1] as bool?,
      userLocationStyle:
          result[2] != null ? UserLocationStyle.decode(result[2]! as List<Object?>) : null,
    );
  }

  UserLocationConfig copyWith({
    bool? userLocationButton,
    bool? showUserLocation,
    UserLocationStyle? userLocationStyle,
  }) {
    return UserLocationConfig(
      userLocationButton: userLocationButton ?? this.userLocationButton,
      showUserLocation: showUserLocation ?? this.showUserLocation,
      userLocationStyle: userLocationStyle ?? this.userLocationStyle,
    );
  }
}

/// 用户定位样式
class UserLocationStyle {
  UserLocationStyle({
    this.userLocationType,
    this.fillColor,
    this.strokeColor,
    this.lineWidth,
    this.image,
  });

  /// 用户定位类型
  final UserLocationType? userLocationType;

  /// 精度圈的填充颜色
  final Color? fillColor;

  /// 精度圈的边线颜色
  final Color? strokeColor;

  /// 精度圈的边线宽度
  final double? lineWidth;

  /// 定位图标以替代蓝色原点
  final Bitmap? image;

  Object encode() {
    return <Object?>[
      userLocationType?.index,
      fillColor?.value,
      strokeColor?.value,
      lineWidth,
      image?.encode(),
    ];
  }

  static UserLocationStyle decode(List<Object?> result) {
    return UserLocationStyle(
      userLocationType: result[0] as UserLocationType?,
      fillColor: result[1] != null ? Color(result[1] as int) : null,
      strokeColor: result[2] != null ? Color(result[2] as int) : null,
      lineWidth: result[3] as double?,
      image: result[4] != null ? Bitmap.decode(result[4]! as List<Object?>) : null,
    );
  }

  UserLocationStyle copyWith({
    UserLocationType? userLocationType,
    Color? fillColor,
    Color? strokeColor,
    double? lineWidth,
    Bitmap? image,
  }) {
    return UserLocationStyle(
      userLocationType: userLocationType ?? this.userLocationType,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      lineWidth: lineWidth ?? this.lineWidth,
      image: image ?? this.image,
    );
  }
}

// ==================== 导航相关类型 ====================

/// 导航类型
enum NaviType {
  /// 驾车导航
  driver,

  /// 步行导航
  walk,

  /// 骑行导航
  ride,
}

/// 导航页面类型
enum NaviPageType {
  /// 路线规划页面
  route,

  /// 导航页面
  navi,
}

/// 导航途经点/终点
class NaviPoint {
  NaviPoint({
    required this.position,
    this.name,
  });

  /// 坐标位置
  final Position position;

  /// 地点名称
  final String? name;

  Object encode() {
    return <Object?>[
      position.encode(),
      name,
    ];
  }

  static NaviPoint decode(List<Object?> result) {
    return NaviPoint(
      position: Position.decode(result[0]! as List<Object?>),
      name: result[1] as String?,
    );
  }

  NaviPoint copyWith({
    Position? position,
    String? name,
  }) {
    return NaviPoint(
      position: position ?? this.position,
      name: name ?? this.name,
    );
  }
}

/// 导航配置
class NaviConfig {
  NaviConfig({
    this.carNumber,
    this.motorcycleCC,
    this.naviType = NaviType.driver,
    this.pageType = NaviPageType.route,
    this.start,
    this.end,
    this.wayPoints,
  });

  /// 车牌号（用于限行规避）
  final String? carNumber;

  /// 摩托车排量（cc）
  final int? motorcycleCC;

  /// 导航类型
  final NaviType naviType;

  /// 导航页面类型
  final NaviPageType pageType;

  /// 起点（不传则默认为当前位置）
  final NaviPoint? start;

  /// 终点（不传则显示路线规划页让用户选择）
  final NaviPoint? end;

  /// 途经点列表
  final List<NaviPoint>? wayPoints;

  Object encode() {
    return <Object?>[
      carNumber,
      motorcycleCC,
      naviType.index,
      pageType.index,
      start?.encode(),
      end?.encode(),
      wayPoints?.map((e) => e.encode()).toList(),
    ];
  }

  static NaviConfig decode(List<Object?> result) {
    return NaviConfig(
      carNumber: result[0] as String?,
      motorcycleCC: result[1] as int?,
      naviType: NaviType.values[result[2] as int],
      pageType: NaviPageType.values[result[3] as int],
      start: result[4] != null ? NaviPoint.decode(result[4]! as List<Object?>) : null,
      end: result[5] != null ? NaviPoint.decode(result[5]! as List<Object?>) : null,
      wayPoints: result[6] != null
          ? (result[6] as List).map((e) => NaviPoint.decode(e as List<Object?>)).toList()
          : null,
    );
  }

  NaviConfig copyWith({
    String? carNumber,
    int? motorcycleCC,
    NaviType? naviType,
    NaviPageType? pageType,
    NaviPoint? start,
    NaviPoint? end,
    List<NaviPoint>? wayPoints,
  }) {
    return NaviConfig(
      carNumber: carNumber ?? this.carNumber,
      motorcycleCC: motorcycleCC ?? this.motorcycleCC,
      naviType: naviType ?? this.naviType,
      pageType: pageType ?? this.pageType,
      start: start ?? this.start,
      end: end ?? this.end,
      wayPoints: wayPoints ?? this.wayPoints,
    );
  }
}

/// 导航引导信息
class NaviInfo {
  NaviInfo({
    required this.iconType,
    required this.curStepRetainDistance,
    required this.nextRoadName,
    required this.pathRetainDistance,
    required this.pathRetainTime,
    this.iconPng,
    this.hasIcon,
    this.pathId,
    this.naviType,
    this.curStep,
    this.curLink,
    this.curPoint,
    this.currentRoadName,
    this.curStepRetainTime,
    this.routeRemainLightCount,
    this.currentSpeed,
    this.exitDirectionInfo,
    this.notAvoidInfo,
    this.toViaInfos,
    this.raw,
  });

  /// 转向图标类型    https://a.amap.com/lbs/static/unzip/Android_Navi_Doc/com/amap/api/navi/enums/IconType.html
  final int iconType;

  /// 当前路段剩余距离（米）
  final int curStepRetainDistance;

  /// 当前路段剩余时间（秒）
  final int? curStepRetainTime;

  /// 下一路段名称
  final String nextRoadName;

  /// 当前道路名称
  final String? currentRoadName;

  /// 整体路径剩余距离（米）
  final int pathRetainDistance;

  /// 整体路径剩余时间（秒）
  final int pathRetainTime;

  /// 转向图标 PNG 字节（Android 端下发 byte[]，Flutter 侧收到 Uint8List，可直接 Image.memory 渲染）
  /// 说明：Android 端通常只在 iconType 变化时下发；Dart 侧会按 iconType 做一次缓存补全。
  final Uint8List? iconPng;

  /// 是否存在转向图标（bitmap 不为 null）
  final bool? hasIcon;

  /// 当前导航路线 ID（Android: pathId）
  final int? pathId;

  /// 导航类型（Android: naviType，具体枚举含义以 SDK 为准）
  final int? naviType;

  /// 当前 Step / Link / Point 索引
  final int? curStep;
  final int? curLink;
  final int? curPoint;

  /// 路线剩余红绿灯数量（个）
  final int? routeRemainLightCount;

  /// 当前速度（Deprecated 字段，可能无效；单位以 SDK 为准）
  final int? currentSpeed;

  /// 出口方向信息（可能来自 SDK 对象或字符串；Android 端已转成 Map/String）
  final NaviExitDirectionInfo? exitDirectionInfo;

  /// 不可避让信息（Android 端已转成 Map）
  final NaviNotAvoidInfo? notAvoidInfo;

  /// 到途经点信息列表（Android 端已转成 List<Map>）
  final List<NaviToViaInfo>? toViaInfos;

  /// SDK 原始 toString()（排查问题用）
  final String? raw;

  Object encode() {
    return <Object?>[
      iconType,
      curStepRetainDistance,
      nextRoadName,
      pathRetainDistance,
      pathRetainTime,
      iconPng,
    ];
  }

  static NaviInfo decode(List<Object?> result) {
    return NaviInfo(
      iconType: result[0]! as int,
      curStepRetainDistance: result[1]! as int,
      nextRoadName: result[2]! as String,
      pathRetainDistance: result[3]! as int,
      pathRetainTime: result[4]! as int,
      iconPng: result[5] as Uint8List?,
    );
  }

  /// 从 Map 解码（用于 EventChannel）
  static NaviInfo decodeFromMap(Map<String, dynamic> map) {
    int asInt(dynamic v, [int defaultValue = 0]) =>
        (v as num?)?.toInt() ?? defaultValue;
    String asString(dynamic v, [String defaultValue = '']) =>
        v as String? ?? defaultValue;

    final Object? exitDirectionAny = map['exitDirectionInfo'];
    final Object? notAvoidAny = map['notAvoidInfo'];
    final Object? toViaInfosAny = map['toViaInfos'];

    final int iconType = asInt(map['iconType']);

    Uint8List? asUint8List(dynamic v) {
      if (v == null) return null;
      if (v is Uint8List) return v;
      // 极少数情况下可能被解成 List<int>
      if (v is List) {
        return Uint8List.fromList(v.cast<int>());
      }
      return null;
    }

    // Android 端 iconPng 可能仅在 iconType 变化时下发；这里按 iconType 缓存上一张图标，确保 UI 可持续展示
    final Uint8List? iconPng = asUint8List(map['iconPng']);
    if (iconPng != null && iconPng.isNotEmpty) {
      _iconPngCache[iconType] = iconPng;
    }

    return NaviInfo(
      iconType: iconType,
      curStepRetainDistance: asInt(map['curStepRetainDistance']),
      nextRoadName: asString(map['nextRoadName']),
      pathRetainDistance: asInt(map['pathRetainDistance']),
      pathRetainTime: asInt(map['pathRetainTime']),
      iconPng: iconPng ?? _iconPngCache[iconType],
      hasIcon: map['hasIcon'] as bool?,
      pathId: (map['pathId'] as num?)?.toInt(),
      naviType: (map['naviType'] as num?)?.toInt(),
      curStep: (map['curStep'] as num?)?.toInt(),
      curLink: (map['curLink'] as num?)?.toInt(),
      curPoint: (map['curPoint'] as num?)?.toInt(),
      currentRoadName: map['currentRoadName'] as String?,
      curStepRetainTime: (map['curStepRetainTime'] as num?)?.toInt(),
      routeRemainLightCount: (map['routeRemainLightCount'] as num?)?.toInt(),
      currentSpeed: (map['currentSpeed'] as num?)?.toInt(),
      exitDirectionInfo: NaviExitDirectionInfo.decodeFromAny(exitDirectionAny),
      notAvoidInfo: NaviNotAvoidInfo.decodeFromAny(notAvoidAny),
      toViaInfos: NaviToViaInfo.decodeListFromAny(toViaInfosAny),
      raw: map['raw'] as String?,
    );
  }

  NaviInfo copyWith({
    int? iconType,
    int? curStepRetainDistance,
    int? curStepRetainTime,
    String? nextRoadName,
    String? currentRoadName,
    int? pathRetainDistance,
    int? pathRetainTime,
    Uint8List? iconPng,
    bool? hasIcon,
    int? pathId,
    int? naviType,
    int? curStep,
    int? curLink,
    int? curPoint,
    int? routeRemainLightCount,
    int? currentSpeed,
    NaviExitDirectionInfo? exitDirectionInfo,
    NaviNotAvoidInfo? notAvoidInfo,
    List<NaviToViaInfo>? toViaInfos,
    String? raw,
  }) {
    return NaviInfo(
      iconType: iconType ?? this.iconType,
      curStepRetainDistance: curStepRetainDistance ?? this.curStepRetainDistance,
      curStepRetainTime: curStepRetainTime ?? this.curStepRetainTime,
      nextRoadName: nextRoadName ?? this.nextRoadName,
      currentRoadName: currentRoadName ?? this.currentRoadName,
      pathRetainDistance: pathRetainDistance ?? this.pathRetainDistance,
      pathRetainTime: pathRetainTime ?? this.pathRetainTime,
      iconPng: iconPng ?? this.iconPng,
      hasIcon: hasIcon ?? this.hasIcon,
      pathId: pathId ?? this.pathId,
      naviType: naviType ?? this.naviType,
      curStep: curStep ?? this.curStep,
      curLink: curLink ?? this.curLink,
      curPoint: curPoint ?? this.curPoint,
      routeRemainLightCount: routeRemainLightCount ?? this.routeRemainLightCount,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      exitDirectionInfo: exitDirectionInfo ?? this.exitDirectionInfo,
      notAvoidInfo: notAvoidInfo ?? this.notAvoidInfo,
      toViaInfos: toViaInfos ?? this.toViaInfos,
      raw: raw ?? this.raw,
    );
  }

  // ==================== 内部缓存（用于“只在变化时下发 iconPng”） ====================

  static final Map<int, Uint8List> _iconPngCache = <int, Uint8List>{};
}

/// 出口方向信息（来自 Android 端 exitDirectionInfoToFlutter）
class NaviExitDirectionInfo {
  const NaviExitDirectionInfo({
    required this.raw,
    this.text,
    this.exitName,
    this.directionType,
    this.distance,
  });

  /// 原始信息（toString 或原始字符串）
  final String raw;

  /// 可读文本（如果 Android 端能提取到）
  final String? text;

  /// 出口名称（如果有）
  final String? exitName;

  /// 方向类型/枚举（具体含义以 SDK 为准）
  final int? directionType;

  /// 距离（单位以 SDK 为准，通常为米）
  final double? distance;

  static NaviExitDirectionInfo? decodeFromAny(Object? value) {
    if (value == null) return null;
    if (value is String) {
      return NaviExitDirectionInfo(raw: value, text: value);
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return NaviExitDirectionInfo(
        raw: map['raw'] as String? ?? map.toString(),
        text: map['text'] as String?,
        exitName: map['exitName'] as String?,
        directionType: (map['directionType'] as num?)?.toInt(),
        distance: (map['distance'] as num?)?.toDouble(),
      );
    }
    return NaviExitDirectionInfo(raw: value.toString());
  }
}

/// 不可避让信息（来自 Android 端 notAvoidInfoToFlutter）
class NaviNotAvoidInfo {
  const NaviNotAvoidInfo({
    required this.raw,
    this.type,
    this.title,
    this.content,
    this.roadName,
    this.distance,
    this.time,
    this.coord,
  });

  final String raw;
  final int? type;
  final String? title;
  final String? content;
  final String? roadName;
  final double? distance;
  final double? time;
  final Position? coord;

  static NaviNotAvoidInfo? decodeFromAny(Object? value) {
    if (value == null) return null;
    if (value is String) return NaviNotAvoidInfo(raw: value, content: value);
    if (value is! Map) return NaviNotAvoidInfo(raw: value.toString());

    final map = Map<String, dynamic>.from(value);
    final coordAny = map['coord'];
    Position? coord;
    if (coordAny is Map) {
      final c = Map<String, dynamic>.from(coordAny);
      coord = Position(
        latitude: (c['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (c['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return NaviNotAvoidInfo(
      raw: map['raw'] as String? ?? map.toString(),
      type: (map['type'] as num?)?.toInt(),
      title: map['title'] as String?,
      content: map['content'] as String?,
      roadName: map['roadName'] as String?,
      distance: (map['distance'] as num?)?.toDouble(),
      time: (map['time'] as num?)?.toDouble(),
      coord: coord,
    );
  }
}

/// 到途经点信息（来自 Android 端 toViaInfosToFlutter）
class NaviToViaInfo {
  const NaviToViaInfo({
    required this.raw,
    this.viaIndex,
    this.name,
    this.distance,
    this.time,
    this.coord,
  });

  final String raw;
  final int? viaIndex;
  final String? name;
  final double? distance;
  final double? time;
  final Position? coord;

  static NaviToViaInfo? decodeFromAny(Object? value) {
    if (value == null) return null;
    if (value is String) return NaviToViaInfo(raw: value, name: value);
    if (value is! Map) return NaviToViaInfo(raw: value.toString());

    final map = Map<String, dynamic>.from(value);
    final coordAny = map['coord'];
    Position? coord;
    if (coordAny is Map) {
      final c = Map<String, dynamic>.from(coordAny);
      coord = Position(
        latitude: (c['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (c['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return NaviToViaInfo(
      raw: map['raw'] as String? ?? map.toString(),
      viaIndex: (map['viaIndex'] as num?)?.toInt(),
      name: map['name'] as String?,
      distance: (map['distance'] as num?)?.toDouble(),
      time: (map['time'] as num?)?.toDouble(),
      coord: coord,
    );
  }

  static List<NaviToViaInfo>? decodeListFromAny(Object? value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((e) => NaviToViaInfo.decodeFromAny(e as Object?))
          .whereType<NaviToViaInfo>()
          .toList();
    }
    final single = NaviToViaInfo.decodeFromAny(value);
    return single == null ? null : <NaviToViaInfo>[single];
  }
}

/// 导航定位信息
class NaviLocation {
  NaviLocation({
    required this.position,
    this.bearing,
    this.roadBearing,
    this.speed,
    this.accuracy,
    this.altitude,
    this.time,
    this.matchStatus,
    this.locationDataType,
    this.locationType,
    this.curStepIndex,
    this.curLinkIndex,
    this.curPointIndex,
    this.raw,
  });

  /// 坐标位置
  final Position position;

  /// 方向角度
  final double? bearing;

  /// 道路方向角（地图匹配后的道路方向；单位以 SDK 为准，通常为度）
  final double? roadBearing;

  /// 速度（km/h，来自高德原生回调）
  final double? speed;

  /// 定位精度
  final double? accuracy;

  /// 海拔高度（单位：米）
  final double? altitude;

  /// 定位时间戳（毫秒）
  final int? time;

  /// 道路匹配状态（枚举含义以 SDK 为准）
  final int? matchStatus;

  /// AMapNaviLocation 的 type 字段（注意：事件字段名 type 已被占用，所以这里命名为 locationDataType）
  final int? locationDataType;

  /// 定位来源类型/定位方式（枚举含义以 SDK 为准）
  final int? locationType;

  /// 当前导航 Step/Link/Point 索引（用于定位导航进度）
  final int? curStepIndex;
  final int? curLinkIndex;
  final int? curPointIndex;

  /// SDK 原始 toString()（排查问题用）
  final String? raw;

  Object encode() {
    return <Object?>[
      position.encode(),
      bearing,
      roadBearing,
      speed,
      accuracy,
      altitude,
      time,
      matchStatus,
      locationDataType,
      locationType,
      curStepIndex,
      curLinkIndex,
      curPointIndex,
      raw,
    ];
  }

  static NaviLocation decode(List<Object?> result) {
    // 兼容历史版本：旧结构可能只有 [position, bearing, speed, accuracy]
    Object? at(int index) => index < result.length ? result[index] : null;
    return NaviLocation(
      position: Position.decode(result[0]! as List<Object?>),
      bearing: at(1) as double?,
      roadBearing: at(2) as double?,
      speed: at(3) as double?,
      accuracy: at(4) as double?,
      altitude: at(5) as double?,
      time: at(6) as int?,
      matchStatus: at(7) as int?,
      locationDataType: at(8) as int?,
      locationType: at(9) as int?,
      curStepIndex: at(10) as int?,
      curLinkIndex: at(11) as int?,
      curPointIndex: at(12) as int?,
      raw: at(13) as String?,
    );
  }

  /// 从 Map 解码（用于 EventChannel）
  static NaviLocation decodeFromMap(Map<String, dynamic> map) {
    return NaviLocation(
      position: Position(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      bearing: (map['bearing'] as num?)?.toDouble(),
      roadBearing: (map['roadBearing'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      time: (map['time'] as num?)?.toInt(),
      matchStatus: (map['matchStatus'] as num?)?.toInt(),
      locationDataType: (map['locationDataType'] as num?)?.toInt(),
      locationType: (map['locationType'] as num?)?.toInt(),
      curStepIndex: (map['curStepIndex'] as num?)?.toInt(),
      curLinkIndex: (map['curLinkIndex'] as num?)?.toInt(),
      curPointIndex: (map['curPointIndex'] as num?)?.toInt(),
      raw: map['raw'] as String?,
    );
  }

  NaviLocation copyWith({
    Position? position,
    double? bearing,
    double? roadBearing,
    double? speed,
    double? accuracy,
    double? altitude,
    int? time,
    int? matchStatus,
    int? locationDataType,
    int? locationType,
    int? curStepIndex,
    int? curLinkIndex,
    int? curPointIndex,
    String? raw,
  }) {
    return NaviLocation(
      position: position ?? this.position,
      bearing: bearing ?? this.bearing,
      roadBearing: roadBearing ?? this.roadBearing,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      time: time ?? this.time,
      matchStatus: matchStatus ?? this.matchStatus,
      locationDataType: locationDataType ?? this.locationDataType,
      locationType: locationType ?? this.locationType,
      curStepIndex: curStepIndex ?? this.curStepIndex,
      curLinkIndex: curLinkIndex ?? this.curLinkIndex,
      curPointIndex: curPointIndex ?? this.curPointIndex,
      raw: raw ?? this.raw,
    );
  }
}

// ==================== 搜索相关类型 ====================

/// 输入提示结果项
class InputTip {
  InputTip({
    required this.name,
    this.address,
    this.position,
    this.poiId,
    this.district,
    this.adcode,
    this.typeCode,
  });

  /// 名称
  final String name;

  /// 地址
  final String? address;

  /// 位置坐标（可能为空，如输入提示未返回坐标）
  final Position? position;

  /// POI ID
  final String? poiId;

  /// 所属区域
  final String? district;

  /// 区域编码
  final String? adcode;

  /// POI类型编码
  final String? typeCode;

  Object encode() {
    return <Object?>[
      name,
      address,
      position?.encode(),
      poiId,
      district,
      adcode,
      typeCode,
    ];
  }

  static InputTip decode(List<Object?> result) {
    return InputTip(
      name: result[0]! as String,
      address: result[1] as String?,
      position: result[2] != null ? Position.decode(result[2]! as List<Object?>) : null,
      poiId: result[3] as String?,
      district: result[4] as String?,
      adcode: result[5] as String?,
      typeCode: result[6] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static InputTip decodeFromMap(Map<String, dynamic> map) {
    Position? position;
    final lat = map['latitude'] as num?;
    final lng = map['longitude'] as num?;
    if (lat != null && lng != null) {
      position = Position(latitude: lat.toDouble(), longitude: lng.toDouble());
    }

    return InputTip(
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      position: position,
      poiId: map['poiId'] as String?,
      district: map['district'] as String?,
      adcode: map['adcode'] as String?,
      typeCode: map['typeCode'] as String?,
    );
  }

  InputTip copyWith({
    String? name,
    String? address,
    Position? position,
    String? poiId,
    String? district,
    String? adcode,
    String? typeCode,
  }) {
    return InputTip(
      name: name ?? this.name,
      address: address ?? this.address,
      position: position ?? this.position,
      poiId: poiId ?? this.poiId,
      district: district ?? this.district,
      adcode: adcode ?? this.adcode,
      typeCode: typeCode ?? this.typeCode,
    );
  }

  @override
  String toString() {
    return 'InputTip(name: $name, address: $address, position: $position, poiId: $poiId, district: $district, adcode: $adcode)';
  }
}

/// 搜索配置
class SearchConfig {
  SearchConfig({
    required this.keywords,
    this.city,
    this.cityLimit = false,
    this.types,
    this.location,
  });

  /// 搜索关键词
  final String keywords;

  /// 搜索城市（可选，默认全国）
  final String? city;

  /// 是否限制在当前城市搜索
  final bool cityLimit;

  /// POI类型限制（多个类型用"|"分隔）
  final String? types;

  /// 搜索中心点（用于周边搜索）
  final Position? location;

  Object encode() {
    return <Object?>[
      keywords,
      city,
      cityLimit,
      types,
      location?.encode(),
    ];
  }

  static SearchConfig decode(List<Object?> result) {
    return SearchConfig(
      keywords: result[0]! as String,
      city: result[1] as String?,
      cityLimit: result[2] as bool? ?? false,
      types: result[3] as String?,
      location: result[4] != null ? Position.decode(result[4]! as List<Object?>) : null,
    );
  }

  SearchConfig copyWith({
    String? keywords,
    String? city,
    bool? cityLimit,
    String? types,
    Position? location,
  }) {
    return SearchConfig(
      keywords: keywords ?? this.keywords,
      city: city ?? this.city,
      cityLimit: cityLimit ?? this.cityLimit,
      types: types ?? this.types,
      location: location ?? this.location,
    );
  }
}

/// POI 搜索结果项
class PoiItem {
  PoiItem({
    required this.poiId,
    required this.name,
    this.address,
    required this.position,
    this.typeName,
    this.typeCode,
    this.cityName,
    this.cityCode,
    this.adName,
    this.adCode,
    this.distance,
    this.tel,
    this.provinceName,
    this.provinceCode,
  });

  /// POI ID
  final String poiId;

  /// 名称
  final String name;

  /// 地址
  final String? address;

  /// 位置坐标
  final Position position;

  /// POI 类型名称
  final String? typeName;

  /// POI 类型编码
  final String? typeCode;

  /// 城市名称
  final String? cityName;

  /// 城市编码
  final String? cityCode;

  /// 区域名称
  final String? adName;

  /// 区域编码
  final String? adCode;

  /// 距离搜索中心点的距离（米）
  final int? distance;

  /// 电话
  final String? tel;

  /// 省份名称
  final String? provinceName;

  /// 省份编码
  final String? provinceCode;

  Object encode() {
    return <Object?>[
      poiId,
      name,
      address,
      position.encode(),
      typeName,
      typeCode,
      cityName,
      cityCode,
      adName,
      adCode,
      distance,
      tel,
      provinceName,
      provinceCode,
    ];
  }

  static PoiItem decode(List<Object?> result) {
    return PoiItem(
      poiId: result[0]! as String,
      name: result[1]! as String,
      address: result[2] as String?,
      position: Position.decode(result[3]! as List<Object?>),
      typeName: result[4] as String?,
      typeCode: result[5] as String?,
      cityName: result[6] as String?,
      cityCode: result[7] as String?,
      adName: result[8] as String?,
      adCode: result[9] as String?,
      distance: result[10] as int?,
      tel: result[11] as String?,
      provinceName: result[12] as String?,
      provinceCode: result[13] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static PoiItem decodeFromMap(Map<String, dynamic> map) {
    Position? position;
    final lat = map['latitude'] as num?;
    final lng = map['longitude'] as num?;
    if (lat != null && lng != null) {
      position = Position(latitude: lat.toDouble(), longitude: lng.toDouble());
    }

    return PoiItem(
      poiId: map['poiId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      position: position ?? Position(latitude: 0, longitude: 0),
      typeName: map['typeName'] as String?,
      typeCode: map['typeCode'] as String?,
      cityName: map['cityName'] as String?,
      cityCode: map['cityCode'] as String?,
      adName: map['adName'] as String?,
      adCode: map['adCode'] as String?,
      distance: (map['distance'] as num?)?.toInt(),
      tel: map['tel'] as String?,
      provinceName: map['provinceName'] as String?,
      provinceCode: map['provinceCode'] as String?,
    );
  }

  PoiItem copyWith({
    String? poiId,
    String? name,
    String? address,
    Position? position,
    String? typeName,
    String? typeCode,
    String? cityName,
    String? cityCode,
    String? adName,
    String? adCode,
    int? distance,
    String? tel,
    String? provinceName,
    String? provinceCode,
  }) {
    return PoiItem(
      poiId: poiId ?? this.poiId,
      name: name ?? this.name,
      address: address ?? this.address,
      position: position ?? this.position,
      typeName: typeName ?? this.typeName,
      typeCode: typeCode ?? this.typeCode,
      cityName: cityName ?? this.cityName,
      cityCode: cityCode ?? this.cityCode,
      adName: adName ?? this.adName,
      adCode: adCode ?? this.adCode,
      distance: distance ?? this.distance,
      tel: tel ?? this.tel,
      provinceName: provinceName ?? this.provinceName,
      provinceCode: provinceCode ?? this.provinceCode,
    );
  }

  @override
  String toString() {
    return 'PoiItem(poiId: $poiId, name: $name, address: $address, position: $position, distance: $distance)';
  }
}

// ==================== 天气相关类型 ====================

/// 天气查询类型
enum WeatherType {
  /// 实时天气
  live,

  /// 预报天气
  forecast,
}

/// 实时天气信息
class LocalWeatherLive {
  LocalWeatherLive({
    this.city,
    this.adCode,
    this.province,
    this.weather,
    this.temperature,
    this.windDirection,
    this.windPower,
    this.humidity,
    this.reportTime,
  });

  /// 城市名称
  final String? city;

  /// 区域编码
  final String? adCode;

  /// 省份名称
  final String? province;

  /// 天气现象
  final String? weather;

  /// 实时温度（单位：摄氏度）
  final String? temperature;

  /// 风向
  final String? windDirection;

  /// 风力等级
  final String? windPower;

  /// 空气湿度（百分比）
  final String? humidity;

  /// 数据发布时间
  final String? reportTime;

  Object encode() {
    return <Object?>[
      city,
      adCode,
      province,
      weather,
      temperature,
      windDirection,
      windPower,
      humidity,
      reportTime,
    ];
  }

  static LocalWeatherLive decode(List<Object?> result) {
    return LocalWeatherLive(
      city: result[0] as String?,
      adCode: result[1] as String?,
      province: result[2] as String?,
      weather: result[3] as String?,
      temperature: result[4] as String?,
      windDirection: result[5] as String?,
      windPower: result[6] as String?,
      humidity: result[7] as String?,
      reportTime: result[8] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalWeatherLive decodeFromMap(Map<String, dynamic> map) {
    return LocalWeatherLive(
      city: map['city'] as String?,
      adCode: map['adCode'] as String?,
      province: map['province'] as String?,
      weather: map['weather'] as String?,
      temperature: map['temperature'] as String?,
      windDirection: map['windDirection'] as String?,
      windPower: map['windPower'] as String?,
      humidity: map['humidity'] as String?,
      reportTime: map['reportTime'] as String?,
    );
  }

  LocalWeatherLive copyWith({
    String? city,
    String? adCode,
    String? province,
    String? weather,
    String? temperature,
    String? windDirection,
    String? windPower,
    String? humidity,
    String? reportTime,
  }) {
    return LocalWeatherLive(
      city: city ?? this.city,
      adCode: adCode ?? this.adCode,
      province: province ?? this.province,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      windDirection: windDirection ?? this.windDirection,
      windPower: windPower ?? this.windPower,
      humidity: humidity ?? this.humidity,
      reportTime: reportTime ?? this.reportTime,
    );
  }

  @override
  String toString() {
    return 'LocalWeatherLive(city: $city, weather: $weather, temperature: $temperature°C, humidity: $humidity%)';
  }
}

/// 每日天气预报
class LocalDayWeatherForecast {
  LocalDayWeatherForecast({
    this.date,
    this.week,
    this.dayWeather,
    this.nightWeather,
    this.dayTemp,
    this.nightTemp,
    this.dayWind,
    this.nightWind,
    this.dayPower,
    this.nightPower,
  });

  /// 日期（格式：yyyy-MM-dd）
  final String? date;

  /// 星期几（1-7，1为周一）
  final String? week;

  /// 白天天气现象
  final String? dayWeather;

  /// 夜间天气现象
  final String? nightWeather;

  /// 白天温度（单位：摄氏度）
  final String? dayTemp;

  /// 夜间温度（单位：摄氏度）
  final String? nightTemp;

  /// 白天风向
  final String? dayWind;

  /// 夜间风向
  final String? nightWind;

  /// 白天风力等级
  final String? dayPower;

  /// 夜间风力等级
  final String? nightPower;

  Object encode() {
    return <Object?>[
      date,
      week,
      dayWeather,
      nightWeather,
      dayTemp,
      nightTemp,
      dayWind,
      nightWind,
      dayPower,
      nightPower,
    ];
  }

  static LocalDayWeatherForecast decode(List<Object?> result) {
    return LocalDayWeatherForecast(
      date: result[0] as String?,
      week: result[1] as String?,
      dayWeather: result[2] as String?,
      nightWeather: result[3] as String?,
      dayTemp: result[4] as String?,
      nightTemp: result[5] as String?,
      dayWind: result[6] as String?,
      nightWind: result[7] as String?,
      dayPower: result[8] as String?,
      nightPower: result[9] as String?,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalDayWeatherForecast decodeFromMap(Map<String, dynamic> map) {
    return LocalDayWeatherForecast(
      date: map['date'] as String?,
      week: map['week'] as String?,
      dayWeather: map['dayWeather'] as String?,
      nightWeather: map['nightWeather'] as String?,
      dayTemp: map['dayTemp'] as String?,
      nightTemp: map['nightTemp'] as String?,
      dayWind: map['dayWind'] as String?,
      nightWind: map['nightWind'] as String?,
      dayPower: map['dayPower'] as String?,
      nightPower: map['nightPower'] as String?,
    );
  }

  LocalDayWeatherForecast copyWith({
    String? date,
    String? week,
    String? dayWeather,
    String? nightWeather,
    String? dayTemp,
    String? nightTemp,
    String? dayWind,
    String? nightWind,
    String? dayPower,
    String? nightPower,
  }) {
    return LocalDayWeatherForecast(
      date: date ?? this.date,
      week: week ?? this.week,
      dayWeather: dayWeather ?? this.dayWeather,
      nightWeather: nightWeather ?? this.nightWeather,
      dayTemp: dayTemp ?? this.dayTemp,
      nightTemp: nightTemp ?? this.nightTemp,
      dayWind: dayWind ?? this.dayWind,
      nightWind: nightWind ?? this.nightWind,
      dayPower: dayPower ?? this.dayPower,
      nightPower: nightPower ?? this.nightPower,
    );
  }

  /// 获取星期几的中文名称
  String get weekName {
    switch (week) {
      case '1':
        return '周一';
      case '2':
        return '周二';
      case '3':
        return '周三';
      case '4':
        return '周四';
      case '5':
        return '周五';
      case '6':
        return '周六';
      case '7':
        return '周日';
      default:
        return '未知';
    }
  }

  @override
  String toString() {
    return 'LocalDayWeatherForecast(date: $date, week: $weekName, dayWeather: $dayWeather, dayTemp: $dayTemp°C, nightTemp: $nightTemp°C)';
  }
}

/// 天气预报信息
class LocalWeatherForecast {
  LocalWeatherForecast({
    this.city,
    this.adCode,
    this.province,
    this.reportTime,
    this.casts,
  });

  /// 城市名称
  final String? city;

  /// 区域编码
  final String? adCode;

  /// 省份名称
  final String? province;

  /// 数据发布时间
  final String? reportTime;

  /// 天气预报列表（未来几天）
  final List<LocalDayWeatherForecast>? casts;

  Object encode() {
    return <Object?>[
      city,
      adCode,
      province,
      reportTime,
      casts?.map((e) => e.encode()).toList(),
    ];
  }

  static LocalWeatherForecast decode(List<Object?> result) {
    return LocalWeatherForecast(
      city: result[0] as String?,
      adCode: result[1] as String?,
      province: result[2] as String?,
      reportTime: result[3] as String?,
      casts: result[4] != null
          ? (result[4] as List).map((e) => LocalDayWeatherForecast.decode(e as List<Object?>)).toList()
          : null,
    );
  }

  /// 从 Map 解码（用于 MethodChannel 返回）
  static LocalWeatherForecast decodeFromMap(Map<String, dynamic> map) {
    List<LocalDayWeatherForecast>? casts;
    if (map['casts'] != null) {
      casts = (map['casts'] as List).map((item) {
        return LocalDayWeatherForecast.decodeFromMap(Map<String, dynamic>.from(item as Map));
      }).toList();
    }

    return LocalWeatherForecast(
      city: map['city'] as String?,
      adCode: map['adCode'] as String?,
      province: map['province'] as String?,
      reportTime: map['reportTime'] as String?,
      casts: casts,
    );
  }

  LocalWeatherForecast copyWith({
    String? city,
    String? adCode,
    String? province,
    String? reportTime,
    List<LocalDayWeatherForecast>? casts,
  }) {
    return LocalWeatherForecast(
      city: city ?? this.city,
      adCode: adCode ?? this.adCode,
      province: province ?? this.province,
      reportTime: reportTime ?? this.reportTime,
      casts: casts ?? this.casts,
    );
  }

  @override
  String toString() {
    return 'LocalWeatherForecast(city: $city, reportTime: $reportTime, casts: ${casts?.length ?? 0} days)';
  }
}