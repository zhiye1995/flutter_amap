part of '../../../flutter_amap.dart';
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
    this.poiId,
    this.startAngle,
  });

  /// 坐标位置
  final Position position;

  /// 地点名称
  final String? name;

  /// 高德 POI ID。导航 SDK 推荐优先使用 POIInfo 算路。
  final String? poiId;

  /// 起点方向角，0 为正北顺时针增加；仅部分官方 POIInfo 算路接口生效。
  final double? startAngle;

  Object encode() {
    return <Object?>[
      position.encode(),
      name,
      poiId,
      startAngle,
    ];
  }

  static NaviPoint decode(List<Object?> result) {
    return NaviPoint(
      position: Position.decode(result[0]! as List<Object?>),
      name: result[1] as String?,
      poiId: result.length > 2 ? result[2] as String? : null,
      startAngle: result.length > 3 ? result[3] as double? : null,
    );
  }

  NaviPoint copyWith({
    Position? position,
    String? name,
    String? poiId,
    double? startAngle,
  }) {
    return NaviPoint(
      position: position ?? this.position,
      name: name ?? this.name,
      poiId: poiId ?? this.poiId,
      startAngle: startAngle ?? this.startAngle,
    );
  }
}

/// 导航车辆信息。
class NaviVehicleInfo {
  NaviVehicleInfo({
    this.vehicleId,
    this.type,
    this.size,
    this.height,
    this.width,
    this.length,
    this.load,
    this.weight,
    this.axisNums,
    this.vehicleLoadSwitch,
    this.isRestriction,
    this.motorcycleCC,
  });

  final String? vehicleId;
  final int? type;
  final int? size;
  final double? height;
  final double? width;
  final double? length;
  final double? load;
  final double? weight;
  final int? axisNums;
  final bool? vehicleLoadSwitch;
  final bool? isRestriction;
  final int? motorcycleCC;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vehicleId': vehicleId ?? '',
      'type': type,
      'size': size,
      'height': height,
      'width': width,
      'length': length,
      'load': load,
      'weight': weight,
      'axisNums': axisNums,
      'vehicleLoadSwitch': vehicleLoadSwitch,
      'isRestriction': isRestriction,
      'motorcycleCC': motorcycleCC,
    };
  }

  Object encode() {
    return <Object?>[
      vehicleId,
      type,
      size,
      height,
      width,
      length,
      load,
      weight,
      axisNums,
      vehicleLoadSwitch,
      isRestriction,
      motorcycleCC,
    ];
  }

  static NaviVehicleInfo decode(List<Object?> result) {
    Object? at(int index) => index < result.length ? result[index] : null;
    return NaviVehicleInfo(
      vehicleId: at(0) as String?,
      type: at(1) as int?,
      size: at(2) as int?,
      height: at(3) as double?,
      width: at(4) as double?,
      length: at(5) as double?,
      load: at(6) as double?,
      weight: at(7) as double?,
      axisNums: at(8) as int?,
      vehicleLoadSwitch: at(9) as bool?,
      isRestriction: at(10) as bool?,
      motorcycleCC: at(11) as int?,
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
    this.drivingStrategy = 10,
    this.travelStrategy,
    this.multipleRoute = true,
    this.startNaviDirectly,
    this.vehicleInfo,
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

  /// 驾车策略。导航 SDK 官方支持 0-20。
  final int drivingStrategy;

  /// 步行/骑行策略，具体枚举值以当前导航 SDK 为准。
  final int? travelStrategy;

  /// 是否启用多路线模式。
  final bool multipleRoute;

  /// 是否直接开始导航。为空时按 [pageType] 自动推导。
  final bool? startNaviDirectly;

  /// 完整车辆信息；传入后优先于 [carNumber]/[motorcycleCC]。
  final NaviVehicleInfo? vehicleInfo;

  Object encode() {
    return <Object?>[
      carNumber,
      motorcycleCC,
      naviType.index,
      pageType.index,
      start?.encode(),
      end?.encode(),
      wayPoints?.map((e) => e.encode()).toList(),
      drivingStrategy,
      travelStrategy,
      multipleRoute,
      startNaviDirectly,
      vehicleInfo?.encode(),
    ];
  }

  static NaviConfig decode(List<Object?> result) {
    Object? at(int index) => index < result.length ? result[index] : null;
    return NaviConfig(
      carNumber: at(0) as String?,
      motorcycleCC: at(1) as int?,
      naviType: NaviType.values[at(2) as int? ?? 0],
      pageType: NaviPageType.values[at(3) as int? ?? 0],
      start: at(4) != null ? NaviPoint.decode(at(4)! as List<Object?>) : null,
      end: at(5) != null ? NaviPoint.decode(at(5)! as List<Object?>) : null,
      wayPoints: at(6) != null
          ? (at(6) as List)
              .map((e) => NaviPoint.decode(e as List<Object?>))
              .toList()
          : null,
      drivingStrategy: at(7) as int? ?? 10,
      travelStrategy: at(8) as int?,
      multipleRoute: at(9) as bool? ?? true,
      startNaviDirectly: at(10) as bool?,
      vehicleInfo: at(11) != null
          ? NaviVehicleInfo.decode(at(11)! as List<Object?>)
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
    int? drivingStrategy,
    int? travelStrategy,
    bool? multipleRoute,
    bool? startNaviDirectly,
    NaviVehicleInfo? vehicleInfo,
  }) {
    return NaviConfig(
      carNumber: carNumber ?? this.carNumber,
      motorcycleCC: motorcycleCC ?? this.motorcycleCC,
      naviType: naviType ?? this.naviType,
      pageType: pageType ?? this.pageType,
      start: start ?? this.start,
      end: end ?? this.end,
      wayPoints: wayPoints ?? this.wayPoints,
      drivingStrategy: drivingStrategy ?? this.drivingStrategy,
      travelStrategy: travelStrategy ?? this.travelStrategy,
      multipleRoute: multipleRoute ?? this.multipleRoute,
      startNaviDirectly: startNaviDirectly ?? this.startNaviDirectly,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
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
    this.icon,
    this.isIconFromNative = false,
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

  /// 有对应静态资源的 iconType 集合
  static const Set<int> _availableAssetIconTypes = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
    39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
    // 53, 54,
    65, 66,
  };

  /// iconType -> iconPng 缓存（原生端传的图标数据，持续更新）
  static final Map<int, Uint8List> _iconPngCache = <int, Uint8List>{};

  /// 预加载的静态资源图标缓存（iconType -> Uint8List）
  static final Map<int, Uint8List> _assetIconCache = <int, Uint8List>{};

  /// 预加载所有静态资源图标（由 AMapFlutter.init() 调用）
  static Future<void> preloadAssetIcons() async {
    for (final iconType in _availableAssetIconTypes) {
      try {
        final data = await rootBundle.load(
          'packages/flutter_amap/assets/navigation/$iconType.png',
        );
        _assetIconCache[iconType] = data.buffer.asUint8List();
      } catch (_) {
        // 资源不存在，跳过
      }
    }
  }

  /// 转向图标类型    https://a.amap.com/lbs/static/unzip/Android_Navi_Doc/com/amap/api/navi/enums/IconType.html
  /// https://a.amap.com/lbs/static/unzip/iOS_Navi_Doc/_a_map_navi_common_obj_8h.html#a33282f5b6d3214a54512f568f025cadc
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

  /// 转向图标数据（PNG 格式的 Uint8List，可用于 Image.memory() 渲染）
  /// 优先使用原生端下发的 PNG 数据，如果没有则使用预加载的静态资源
  final Uint8List? icon;

  /// 图标是否来自原生端（用于区分是原生下发还是静态资源）
  final bool isIconFromNative;

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
      null, // icon 不参与序列化
    ];
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

    final Uint8List? iconPng = asUint8List(map['iconPng']);

    // 如果原生传了 iconPng，更新缓存
    if (iconPng != null && iconPng.isNotEmpty) {
      _iconPngCache[iconType] = iconPng;
    }

    // 构建图标数据：优先原生 PNG，其次运行时缓存，最后预加载的静态资源
    Uint8List? icon;
    bool isIconFromNative = false;
    final Uint8List? effectiveIconPng = (iconPng != null && iconPng.isNotEmpty)
        ? iconPng
        : _iconPngCache[iconType];

    if (effectiveIconPng != null && effectiveIconPng.isNotEmpty) {
      icon = effectiveIconPng;
      isIconFromNative = true;
    } else if (_assetIconCache.containsKey(iconType)) {
      icon = _assetIconCache[iconType];
      isIconFromNative = false;
    }

    return NaviInfo(
      iconType: iconType,
      curStepRetainDistance: asInt(map['curStepRetainDistance']),
      nextRoadName: asString(map['nextRoadName']),
      pathRetainDistance: asInt(map['pathRetainDistance']),
      pathRetainTime: asInt(map['pathRetainTime']),
      icon: icon,
      isIconFromNative: isIconFromNative,
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
    Uint8List? icon,
    bool? isIconFromNative,
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
      curStepRetainDistance:
          curStepRetainDistance ?? this.curStepRetainDistance,
      curStepRetainTime: curStepRetainTime ?? this.curStepRetainTime,
      nextRoadName: nextRoadName ?? this.nextRoadName,
      currentRoadName: currentRoadName ?? this.currentRoadName,
      pathRetainDistance: pathRetainDistance ?? this.pathRetainDistance,
      pathRetainTime: pathRetainTime ?? this.pathRetainTime,
      icon: icon ?? this.icon,
      isIconFromNative: isIconFromNative ?? this.isIconFromNative,
      pathId: pathId ?? this.pathId,
      naviType: naviType ?? this.naviType,
      curStep: curStep ?? this.curStep,
      curLink: curLink ?? this.curLink,
      curPoint: curPoint ?? this.curPoint,
      routeRemainLightCount:
          routeRemainLightCount ?? this.routeRemainLightCount,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      exitDirectionInfo: exitDirectionInfo ?? this.exitDirectionInfo,
      notAvoidInfo: notAvoidInfo ?? this.notAvoidInfo,
      toViaInfos: toViaInfos ?? this.toViaInfos,
      raw: raw ?? this.raw,
    );
  }
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

// ==================== 智能巡航（无路线巡航） ====================

/// 巡航播报类型，与高德 Android `startAimlessMode(int)` / iOS `AMapNaviDetectedMode` 对齐。
enum CruiseBroadcastMode {
  /// 仅电子眼（Android: 1）
  elecCameraOnly(1),

  /// 仅特殊路段（Android: 2）
  specialRoadOnly(2),

  /// 电子眼 + 特殊路段（Android: 3）
  both(3);

  const CruiseBroadcastMode(this.code);

  /// 传给原生的模式码（1/2/3）
  final int code;
}

/// 智能巡航配置。
class CruiseConfig {
  CruiseConfig({
    required this.mode,
    this.useInnerVoice = true,
    this.allowsBackgroundLocationUpdates = true,
    this.pausesLocationUpdatesAutomatically = false,
  });

  /// 巡航播报/检测模式。
  final CruiseBroadcastMode mode;

  /// 是否使用原生内置语音播报（Android 映射 `setUseInnerVoice`）。
  final bool useInnerVoice;

  /// iOS 是否允许后台定位更新。
  final bool allowsBackgroundLocationUpdates;

  /// iOS 是否允许系统自动暂停定位。
  final bool pausesLocationUpdatesAutomatically;

  Object encode() {
    return <Object?>[
      mode.code,
      useInnerVoice,
      allowsBackgroundLocationUpdates,
      pausesLocationUpdatesAutomatically,
    ];
  }

  static CruiseConfig decode(List<Object?> result) {
    final modeCode = result[0] as int? ?? CruiseBroadcastMode.both.code;
    return CruiseConfig(
      mode: CruiseBroadcastMode.values.firstWhere(
        (mode) => mode.code == modeCode,
        orElse: () => CruiseBroadcastMode.both,
      ),
      useInnerVoice: result[1] as bool? ?? true,
      allowsBackgroundLocationUpdates: result[2] as bool? ?? true,
      pausesLocationUpdatesAutomatically: result[3] as bool? ?? false,
    );
  }

  CruiseConfig copyWith({
    CruiseBroadcastMode? mode,
    bool? useInnerVoice,
    bool? allowsBackgroundLocationUpdates,
    bool? pausesLocationUpdatesAutomatically,
  }) {
    return CruiseConfig(
      mode: mode ?? this.mode,
      useInnerVoice: useInnerVoice ?? this.useInnerVoice,
      allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates ??
          this.allowsBackgroundLocationUpdates,
      pausesLocationUpdatesAutomatically: pausesLocationUpdatesAutomatically ??
          this.pausesLocationUpdatesAutomatically,
    );
  }
}

/// 巡航设施数据来源（用于对齐 Android 双回调与 iOS 聚合回调）
enum CruiseTrafficFacilitySource {
  /// Android `onUpdateTrafficFacility`
  specialRoad,

  /// Android `onUpdateAimlessModeElecCameraInfo`
  elecCamera,

  /// iOS `updateTrafficFacilities:`（未区分设施/电子眼）
  unified,
}

/// 巡航道路上的设施或电子眼条目
class CruiseTrafficFacilityItem {
  CruiseTrafficFacilityItem({
    required this.source,
    this.type,
    this.latitude,
    this.longitude,
    this.remainDistanceMeters,
    this.speedLimitKmh,
    this.raw,
  });

  final CruiseTrafficFacilitySource source;

  /// 设施类型（含义以高德 SDK 为准）
  final int? type;

  final double? latitude;
  final double? longitude;

  /// 距设施剩余距离（米）
  final int? remainDistanceMeters;

  /// 限速（km/h）；原生 SDK 返回 0 时表示本条设施未提供有效限速。
  final int? speedLimitKmh;

  /// 原生侧附加字段
  final Map<String, dynamic>? raw;

  static CruiseTrafficFacilitySource _decodeSource(Object? v) {
    final s = v?.toString() ?? '';
    switch (s) {
      case 'specialRoad':
        return CruiseTrafficFacilitySource.specialRoad;
      case 'elecCamera':
        return CruiseTrafficFacilitySource.elecCamera;
      case 'unified':
      default:
        return CruiseTrafficFacilitySource.unified;
    }
  }

  static CruiseTrafficFacilityItem decodeFromMap(Map<String, dynamic> map) {
    int? asInt(dynamic x) => (x as num?)?.toInt();
    double? asDouble(dynamic x) => (x as num?)?.toDouble();
    final rawMap = map['raw'];
    return CruiseTrafficFacilityItem(
      source: _decodeSource(map['source']),
      type: asInt(map['type']),
      latitude: asDouble(map['latitude']),
      longitude: asDouble(map['longitude']),
      remainDistanceMeters: asInt(map['remainDistanceMeters']),
      speedLimitKmh: asInt(map['speedLimitKmh']),
      raw: rawMap is Map ? Map<String, dynamic>.from(rawMap) : null,
    );
  }
}

/// 巡航统计（连续行驶距离、连续启用时间等；双端字段不完全一致时放入 [extra]）
class CruiseStatisticsInfo {
  CruiseStatisticsInfo({
    this.cumulativeDistanceMeters,
    this.cumulativeTimeSeconds,
    this.extra,
  });

  /// 连续行驶/轨迹距离（米）
  final int? cumulativeDistanceMeters;

  /// 连续运行时间（秒）
  final int? cumulativeTimeSeconds;

  final Map<String, dynamic>? extra;

  static CruiseStatisticsInfo decodeFromMap(Map<String, dynamic> map) {
    int? asInt(dynamic x) => (x as num?)?.toInt();
    final Object? ex = map['extra'];
    return CruiseStatisticsInfo(
      cumulativeDistanceMeters: asInt(map['cumulativeDistanceMeters']),
      cumulativeTimeSeconds: asInt(map['cumulativeTimeSeconds']),
      extra: ex is Map ? Map<String, dynamic>.from(ex) : null,
    );
  }
}

/// 巡航拥堵路段 link（当前仅 Android 巡航回调提供）
class CruiseCongestionLink {
  CruiseCongestionLink({
    this.status,
    this.coords = const <Position>[],
    this.raw,
  });

  /// 拥堵状态，取值含义与高德 `AMapTrafficStatus.getStatus()` 一致。
  final int? status;

  /// 拥堵 link 的形状点集合。
  final List<Position> coords;

  final Map<String, dynamic>? raw;

  static CruiseCongestionLink decodeFromMap(Map<String, dynamic> map) {
    int? asInt(dynamic x) => (x as num?)?.toInt();
    double? asDouble(dynamic x) => (x as num?)?.toDouble();
    final rawCoords = map['coords'] as List?;
    final coords = <Position>[];
    if (rawCoords != null) {
      for (final e in rawCoords) {
        if (e is Map) {
          final lat = asDouble(e['latitude']);
          final lng = asDouble(e['longitude']);
          if (lat != null && lng != null) {
            coords.add(Position(latitude: lat, longitude: lng));
          }
        }
      }
    }
    final rawMap = map['raw'];
    return CruiseCongestionLink(
      status: asInt(map['status']),
      coords: coords,
      raw: rawMap is Map ? Map<String, dynamic>.from(rawMap) : null,
    );
  }
}

/// 巡航拥堵信息（当前仅 Android 巡航回调提供；iOS 官方巡航页未给出对等回调）
class CruiseCongestionInfo {
  CruiseCongestionInfo({
    this.roadName,
    this.lengthMeters,
    this.status,
    this.estimatedTimeSeconds,
    this.links = const <CruiseCongestionLink>[],
    this.raw,
  });

  /// 拥堵区域道路名称。
  final String? roadName;

  /// 拥堵区域路径长度（米）。
  final int? lengthMeters;

  /// 拥堵区域整体状态，取值含义与高德 `AMapTrafficStatus.getStatus()` 一致。
  final int? status;

  /// 预计通过拥堵区域时间（秒）。
  final int? estimatedTimeSeconds;

  /// 拥堵路段 link 详情。
  final List<CruiseCongestionLink> links;

  /// 原生侧附加字段，保留用于诊断和兼容旧调用。
  final Map<String, dynamic>? raw;

  static CruiseCongestionInfo decodeFromMap(Map<String, dynamic> map) {
    int? asInt(dynamic x) => (x as num?)?.toInt();
    final rawLinks = map['links'] as List?;
    final links = <CruiseCongestionLink>[];
    if (rawLinks != null) {
      for (final e in rawLinks) {
        if (e is Map) {
          links.add(
              CruiseCongestionLink.decodeFromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    final Object? r = map['raw'] ?? map;
    final raw = r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{};
    return CruiseCongestionInfo(
      roadName: map['roadName'] as String? ??
          raw['roadName'] as String? ??
          raw['description'] as String?,
      lengthMeters: asInt(map['lengthMeters'] ?? raw['length']),
      status: asInt(map['status'] ?? raw['congestionStatus']),
      estimatedTimeSeconds: asInt(map['estimatedTimeSeconds'] ?? raw['time']),
      links: links,
      raw: raw,
    );
  }
}
