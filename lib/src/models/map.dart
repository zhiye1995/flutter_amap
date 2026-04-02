part of '../../../flutter_amap.dart';

// ==================== 地图相关类型 ====================

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

/// 离线自定义地图样式（iOS / Android），对应高德导出的 style.data / style_extra.data
class CustomStyleOptions {
  CustomStyleOptions(
    this.enabled, {
    this.styleData,
    this.styleExtraData,
  });

  /// 是否启用自定义样式
  bool enabled;

  /// style.data 二进制
  Uint8List? styleData;

  /// style_extra.data 二进制
  Uint8List? styleExtraData;

  List<Object?> encode() {
    return <Object?>[
      enabled,
      styleData,
      styleExtraData,
    ];
  }

  static CustomStyleOptions? decode(List<Object?>? list) {
    if (list == null || list.isEmpty) {
      return null;
    }
    return CustomStyleOptions(
      list[0] as bool,
      styleData: list[1] as Uint8List?,
      styleExtraData: list[2] as Uint8List?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CustomStyleOptions &&
        enabled == other.enabled &&
        listEquals(styleData, other.styleData) &&
        listEquals(styleExtraData, other.styleExtraData);
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        styleData == null ? null : Object.hashAll(styleData!),
        styleExtraData == null ? null : Object.hashAll(styleExtraData!),
      );
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
    this.customStyleOptions,
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

  /// 自定义离线样式（iOS / Android）
  final CustomStyleOptions? customStyleOptions;

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
      customStyleOptions?.encode(),
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
      customStyleOptions: result.length > 31 && result[31] != null
          ? CustomStyleOptions.decode(result[31]! as List<Object?>)
          : null,
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
    CustomStyleOptions? customStyleOptions,
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
      customStyleOptions: customStyleOptions ?? this.customStyleOptions,
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
    this.customStyleOptions,
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

  /// 自定义离线样式（iOS / Android）
  CustomStyleOptions? customStyleOptions;

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
      customStyleOptions?.encode(),
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
      customStyleOptions: result.length > 22 && result[22] != null
          ? CustomStyleOptions.decode(result[22]! as List<Object?>)
          : null,
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
    CustomStyleOptions? customStyleOptions,
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
      customStyleOptions: customStyleOptions ?? this.customStyleOptions,
    );
  }
}

