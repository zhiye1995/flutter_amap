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
    this.cameraPosition,
    this.fitPositions,
    this.minZoom,
    this.maxZoom,
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.logoPosition,
    this.showIndoorMap,
    this.customStyleOptions,
  });

  /// 设置地图类型
  final MapType? mapType;

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

  /// 是否显示指南针控件
  final bool? compassControlEnabled;

  /// 是否显示比例尺控件
  final bool? scaleControlEnabled;

  /// 是否显示缩放控件(Android Only)
  final bool? zoomControlEnabled;

  /// Logo位置锚点(Android Only)
  final UIControlPosition? logoPosition;

  /// 是否自动展示室内地图，默认是false
  final bool? showIndoorMap;

  /// 自定义离线样式（iOS / Android）
  final CustomStyleOptions? customStyleOptions;

  Object encode() {
    return <Object?>[
      mapType?.index,
      cameraPosition?.encode(),
      fitPositions?.map((position) => position.encode()).toList(),
      minZoom,
      maxZoom,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.encode(),
      showIndoorMap,
      customStyleOptions?.encode(),
    ];
  }

  static MapInitConfig decode(List<Object?> result) {
    return MapInitConfig(
      mapType: result[0] as MapType?,
      cameraPosition: result[1] != null
          ? CameraPosition.decode(result[1]! as List<Object?>)
          : null,
      fitPositions: result[2] != null
          ? (result[2] as List)
              .map((position) => Position.decode(position))
              .toList()
          : null,
      minZoom: result[3] as double?,
      maxZoom: result[4] as double?,
      dragEnable: result[5] as bool?,
      zoomEnable: result[6] as bool?,
      tiltEnable: result[7] as bool?,
      rotateEnable: result[8] as bool?,
      compassControlEnabled: result[9] as bool?,
      scaleControlEnabled: result[10] as bool?,
      zoomControlEnabled: result[11] as bool?,
      logoPosition: result[12] != null
          ? UIControlPosition.decode(result[12]! as List<Object?>)
          : null,
      showIndoorMap: result[13] as bool?,
      customStyleOptions: result.length > 14 && result[14] != null
          ? CustomStyleOptions.decode(result[14]! as List<Object?>)
          : null,
    );
  }

  MapInitConfig copyWith({
    MapType? mapType,
    CameraPosition? cameraPosition,
    List<Position>? fitPositions,
    double? minZoom,
    double? maxZoom,
    bool? dragEnable,
    bool? zoomEnable,
    bool? tiltEnable,
    bool? rotateEnable,
    bool? compassControlEnabled,
    bool? scaleControlEnabled,
    bool? zoomControlEnabled,
    UIControlPosition? logoPosition,
    bool? showIndoorMap,
    CustomStyleOptions? customStyleOptions,
  }) {
    return MapInitConfig(
      mapType: mapType ?? this.mapType,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      fitPositions: fitPositions ?? this.fitPositions,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      dragEnable: dragEnable ?? this.dragEnable,
      zoomEnable: zoomEnable ?? this.zoomEnable,
      tiltEnable: tiltEnable ?? this.tiltEnable,
      rotateEnable: rotateEnable ?? this.rotateEnable,
      compassControlEnabled:
          compassControlEnabled ?? this.compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled ?? this.scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled ?? this.zoomControlEnabled,
      logoPosition: logoPosition ?? this.logoPosition,
      showIndoorMap: showIndoorMap ?? this.showIndoorMap,
      customStyleOptions: customStyleOptions ?? this.customStyleOptions,
    );
  }
}

/// 更新地图属性
class MapUpdateConfig {
  MapUpdateConfig({
    this.mapType,
    this.dragEnable,
    this.zoomEnable,
    this.tiltEnable,
    this.rotateEnable,
    this.compassControlEnabled,
    this.scaleControlEnabled,
    this.zoomControlEnabled,
    this.logoPosition,
    this.compassControlPosition,
    this.scaleControlPosition,
    this.zoomControlPosition,
    this.showTraffic,
    this.showBuildings,
    this.showIndoorMap,
    this.userLocationConfig,
    this.customStyleOptions,
    this.minZoom,
    this.maxZoom,
  });

  /// 设置地图类型
  MapType? mapType;

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

  /// 用户定位配置
  UserLocationConfig? userLocationConfig;

  /// 自定义离线样式（iOS / Android）
  CustomStyleOptions? customStyleOptions;

  /// 最小缩放级别（热更新，与 [MapInitConfig.minZoom] 语义一致）
  double? minZoom;

  /// 最大缩放级别（热更新，与 [MapInitConfig.maxZoom] 语义一致）
  double? maxZoom;

  Object encode() {
    return <Object?>[
      mapType?.index,
      dragEnable,
      zoomEnable,
      tiltEnable,
      rotateEnable,
      compassControlEnabled,
      scaleControlEnabled,
      zoomControlEnabled,
      logoPosition?.encode(),
      compassControlPosition?.encode(),
      scaleControlPosition?.encode(),
      zoomControlPosition?.encode(),
      showTraffic,
      showBuildings,
      showIndoorMap,
      userLocationConfig?.encode(),
      customStyleOptions?.encode(),
      minZoom,
      maxZoom,
    ];
  }

  static MapUpdateConfig decode(List<Object?> result) {
    return MapUpdateConfig(
      mapType: result[0] as MapType?,
      dragEnable: result[1] as bool?,
      zoomEnable: result[2] as bool?,
      tiltEnable: result[3] as bool?,
      rotateEnable: result[4] as bool?,
      compassControlEnabled: result[5] as bool?,
      scaleControlEnabled: result[6] as bool?,
      zoomControlEnabled: result[7] as bool?,
      logoPosition: result[8] != null
          ? UIControlPosition.decode(result[8]! as List<Object?>)
          : null,
      compassControlPosition: result[9] != null
          ? UIControlPosition.decode(result[9]! as List<Object?>)
          : null,
      scaleControlPosition: result[10] != null
          ? UIControlPosition.decode(result[10]! as List<Object?>)
          : null,
      zoomControlPosition: result[11] != null
          ? UIControlPosition.decode(result[11]! as List<Object?>)
          : null,
      showTraffic: result[12] as bool?,
      showBuildings: result[13] as bool?,
      showIndoorMap: result[14] as bool?,
      userLocationConfig: result[15] != null
          ? UserLocationConfig.decode(result[15]! as List<Object?>)
          : null,
      customStyleOptions: result.length > 16 && result[16] != null
          ? CustomStyleOptions.decode(result[16]! as List<Object?>)
          : null,
      minZoom: result.length > 17 ? result[17] as double? : null,
      maxZoom: result.length > 18 ? result[18] as double? : null,
    );
  }

  MapUpdateConfig copyWith({
    MapType? mapType,
    bool? dragEnable,
    bool? zoomEnable,
    bool? tiltEnable,
    bool? rotateEnable,
    bool? compassControlEnabled,
    bool? scaleControlEnabled,
    bool? zoomControlEnabled,
    UIControlPosition? logoPosition,
    UIControlPosition? compassControlPosition,
    UIControlPosition? scaleControlPosition,
    UIControlPosition? zoomControlPosition,
    bool? showTraffic,
    bool? showBuildings,
    bool? showIndoorMap,
    UserLocationConfig? userLocationConfig,
    CustomStyleOptions? customStyleOptions,
    double? minZoom,
    double? maxZoom,
  }) {
    return MapUpdateConfig(
      mapType: mapType ?? this.mapType,
      dragEnable: dragEnable ?? this.dragEnable,
      zoomEnable: zoomEnable ?? this.zoomEnable,
      tiltEnable: tiltEnable ?? this.tiltEnable,
      rotateEnable: rotateEnable ?? this.rotateEnable,
      compassControlEnabled:
          compassControlEnabled ?? this.compassControlEnabled,
      scaleControlEnabled: scaleControlEnabled ?? this.scaleControlEnabled,
      zoomControlEnabled: zoomControlEnabled ?? this.zoomControlEnabled,
      logoPosition: logoPosition ?? this.logoPosition,
      compassControlPosition:
          compassControlPosition ?? this.compassControlPosition,
      scaleControlPosition: scaleControlPosition ?? this.scaleControlPosition,
      zoomControlPosition: zoomControlPosition ?? this.zoomControlPosition,
      showTraffic: showTraffic ?? this.showTraffic,
      showBuildings: showBuildings ?? this.showBuildings,
      showIndoorMap: showIndoorMap ?? this.showIndoorMap,
      userLocationConfig: userLocationConfig ?? this.userLocationConfig,
      customStyleOptions: customStyleOptions ?? this.customStyleOptions,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
    );
  }
}
