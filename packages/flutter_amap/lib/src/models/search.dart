part of '../../../flutter_amap.dart';
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
      position: result[2] != null
          ? Position.decode(result[2]! as List<Object?>)
          : null,
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
      location: result[4] != null
          ? Position.decode(result[4]! as List<Object?>)
          : null,
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

/// POI 关键字搜索扩展信息范围。
enum PoiSearchExtensions {
  /// 只返回基础数据。
  base('base'),

  /// 返回更多扩展数据，具体字段由原生 SDK 决定。
  all('all');

  const PoiSearchExtensions(this.value);

  final String value;
}

/// POI 关键字搜索查询参数。
class PoiKeywordSearchQuery {
  PoiKeywordSearchQuery({
    required this.keywords,
    this.types,
    this.city,
    this.cityLimit = false,
    this.page = 1,
    this.pageSize = 20,
    this.location,
    this.extensions = PoiSearchExtensions.base,
    this.children = false,
    this.sortByDistance = false,
  });

  /// 查询关键字，多个关键字用“|”分割。
  final String keywords;

  /// POI 类型，多个类型用“|”分割，可传类型名称或类型编码。
  final String? types;

  /// 查询城市，可传城市名、citycode 或 adcode。为空时由平台按 SDK 默认处理。
  final String? city;

  /// 是否严格限制在 [city] 内搜索。
  final bool cityLimit;

  /// 当前页码，从 1 开始。
  final int page;

  /// 每页数量。Android SDK 通常支持 1-30，iOS SDK 通常支持 1-25。
  final int pageSize;

  /// 可选中心点。配合 [sortByDistance] 时用于按距离排序，并计算返回项距离。
  final Position? location;

  /// 扩展信息范围。
  final PoiSearchExtensions extensions;

  /// 是否请求子 POI/父子关系。
  final bool children;

  /// 是否按 [location] 距离排序。未提供 [location] 时平台会退回综合排序。
  final bool sortByDistance;

  Object encode() {
    return <Object?>[
      keywords,
      types,
      city,
      cityLimit,
      page,
      pageSize,
      location?.encode(),
      extensions.value,
      children,
      sortByDistance,
    ];
  }

  static PoiKeywordSearchQuery decode(List<Object?> result) {
    return PoiKeywordSearchQuery(
      keywords: result[0]! as String,
      types: result[1] as String?,
      city: result[2] as String?,
      cityLimit: result[3] as bool? ?? false,
      page: result[4] as int? ?? 1,
      pageSize: result[5] as int? ?? 20,
      location: result[6] != null
          ? Position.decode(result[6]! as List<Object?>)
          : null,
      extensions: PoiSearchExtensions.values.firstWhere(
        (value) => value.value == result[7],
        orElse: () => PoiSearchExtensions.base,
      ),
      children: result[8] as bool? ?? false,
      sortByDistance: result[9] as bool? ?? false,
    );
  }

  PoiKeywordSearchQuery copyWith({
    String? keywords,
    String? types,
    String? city,
    bool? cityLimit,
    int? page,
    int? pageSize,
    Position? location,
    PoiSearchExtensions? extensions,
    bool? children,
    bool? sortByDistance,
  }) {
    return PoiKeywordSearchQuery(
      keywords: keywords ?? this.keywords,
      types: types ?? this.types,
      city: city ?? this.city,
      cityLimit: cityLimit ?? this.cityLimit,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      location: location ?? this.location,
      extensions: extensions ?? this.extensions,
      children: children ?? this.children,
      sortByDistance: sortByDistance ?? this.sortByDistance,
    );
  }
}

/// POI 周边搜索查询参数。
class PoiAroundSearchQuery {
  PoiAroundSearchQuery({
    required this.center,
    this.keywords,
    this.types,
    this.radius = 1000,
    this.city,
    this.page = 1,
    this.pageSize = 20,
    this.extensions = PoiSearchExtensions.base,
    this.children = false,
    this.sortByDistance = true,
  });

  /// 周边搜索中心点。
  final Position center;

  /// 查询关键字，多个关键字用“|”分割。为空时按类型/半径检索周边 POI。
  final String? keywords;

  /// POI 类型，多个类型用“|”分割，可传类型名称或类型编码。
  final String? types;

  /// 搜索半径，单位米。高德 SDK 通常支持 0-50000。
  final int radius;

  /// 查询城市，可传城市名、citycode 或 adcode。
  final String? city;

  /// 当前页码，从 1 开始。
  final int page;

  /// 每页数量。Android SDK 通常支持 1-30，iOS SDK 通常支持 1-25。
  final int pageSize;

  /// 扩展信息范围。
  final PoiSearchExtensions extensions;

  /// 是否请求子 POI/父子关系。
  final bool children;

  /// 是否按距离排序。
  final bool sortByDistance;

  Object encode() {
    return <Object?>[
      center.encode(),
      keywords,
      types,
      radius,
      city,
      page,
      pageSize,
      extensions.value,
      children,
      sortByDistance,
    ];
  }

  static PoiAroundSearchQuery decode(List<Object?> result) {
    return PoiAroundSearchQuery(
      center: Position.decode(result[0]! as List<Object?>),
      keywords: result[1] as String?,
      types: result[2] as String?,
      radius: result[3] as int? ?? 1000,
      city: result[4] as String?,
      page: result[5] as int? ?? 1,
      pageSize: result[6] as int? ?? 20,
      extensions: PoiSearchExtensions.values.firstWhere(
        (value) => value.value == result[7],
        orElse: () => PoiSearchExtensions.base,
      ),
      children: result[8] as bool? ?? false,
      sortByDistance: result[9] as bool? ?? true,
    );
  }
}

/// POI 搜索结果。
class PoiSearchResult {
  PoiSearchResult({
    required this.items,
    required this.page,
    required this.pageSize,
    this.total,
  });

  /// 当前页 POI 列表。
  final List<PoiItem> items;

  /// 当前页码。
  final int page;

  /// 每页数量。
  final int pageSize;

  /// 总结果数。部分平台或 SDK 版本可能不返回。
  final int? total;

  Object encode() {
    return <Object?>[
      items.map((item) => item.encode()).toList(),
      page,
      pageSize,
      total,
    ];
  }

  static PoiSearchResult decode(List<Object?> result) {
    return PoiSearchResult(
      items: (result[0]! as List<Object?>)
          .map((item) => PoiItem.decode(item! as List<Object?>))
          .toList(),
      page: result[1]! as int,
      pageSize: result[2]! as int,
      total: result[3] as int?,
    );
  }

  static PoiSearchResult decodeFromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? const <dynamic>[];
    return PoiSearchResult(
      items: rawItems
          .map((item) =>
              PoiItem.decodeFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? rawItems.length,
      total: (map['total'] as num?)?.toInt(),
    );
  }
}

/// 逆地理编码扩展信息范围。
enum ReGeocodeExtensions {
  /// 只返回基础地址数据。
  base('base'),

  /// 返回 POI、道路、交叉路口、AOI 等扩展数据（取决于平台 SDK）。
  all('all');

  const ReGeocodeExtensions(this.value);

  final String value;
}

/// 逆地理编码坐标类型。
enum ReGeocodeCoordinateType {
  /// 高德坐标系。
  amap('amap'),

  /// GPS 原始坐标系。
  gps('gps');

  const ReGeocodeCoordinateType(this.value);

  final String value;
}

/// 地理编码查询参数。
class GeocodeQuery {
  GeocodeQuery({
    required this.address,
    this.city,
    this.country,
  });

  /// 地址名称。
  final String address;

  /// 查询城市，可传城市名、citycode 或 adcode。
  final String? city;

  /// 查询国家，iOS 海外场景支持；Android 侧会忽略。
  final String? country;
}

/// 逆地理编码查询参数。
class ReGeocodeQuery {
  ReGeocodeQuery({
    required this.position,
    this.radius = 1000,
    this.extensions = ReGeocodeExtensions.base,
    this.coordinateType = ReGeocodeCoordinateType.amap,
    this.poiTypes,
  });

  /// 查询坐标。
  final Position position;

  /// 查询半径，单位米。高德官方示例常用 200，iOS SDK 默认 1000。
  final int radius;

  /// 是否返回扩展信息。[ReGeocodeExtensions.all] 会请求 POI、道路、
  /// 交叉路口、AOI 等数据，具体字段取决于平台 SDK 版本。
  final ReGeocodeExtensions extensions;

  /// 坐标类型。Android 直接传给原生逆地理编码查询，iOS 会在查询前把
  /// GPS 坐标转换为高德坐标。
  final ReGeocodeCoordinateType coordinateType;

  /// 扩展 POI 类型过滤，多个 typecode 用“|”分割。
  /// 通常配合 [ReGeocodeExtensions.all] 使用。
  final String? poiTypes;
}

/// 地理编码结果。
class GeocodeResult {
  GeocodeResult({
    required this.formattedAddress,
    required this.position,
    this.province,
    this.city,
    this.district,
    this.township,
    this.neighborhood,
    this.building,
    this.adCode,
    this.cityCode,
    this.country,
    this.level,
    this.raw,
  });

  final String formattedAddress;
  final Position position;
  final String? province;
  final String? city;
  final String? district;
  final String? township;
  final String? neighborhood;
  final String? building;
  final String? adCode;
  final String? cityCode;
  final String? country;
  final String? level;
  final Map<String, dynamic>? raw;

  static GeocodeResult decodeFromMap(Map<String, dynamic> map) {
    final lat = (map['latitude'] as num?)?.toDouble() ?? 0;
    final lng = (map['longitude'] as num?)?.toDouble() ?? 0;
    final raw = map['raw'];
    return GeocodeResult(
      formattedAddress: map['formattedAddress'] as String? ?? '',
      position: Position(latitude: lat, longitude: lng),
      province: map['province'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      township: map['township'] as String?,
      neighborhood: map['neighborhood'] as String?,
      building: map['building'] as String?,
      adCode: map['adCode'] as String?,
      cityCode: map['cityCode'] as String?,
      country: map['country'] as String?,
      level: map['level'] as String?,
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

/// 逆地理编码结果。
class ReGeocodeResult {
  ReGeocodeResult({
    required this.formattedAddress,
    this.position,
    this.province,
    this.city,
    this.district,
    this.township,
    this.neighborhood,
    this.building,
    this.adCode,
    this.cityCode,
    this.country,
    this.countryCode,
    this.townCode,
    this.roads = const <String>[],
    this.crosses = const <String>[],
    this.pois = const <PoiItem>[],
    this.aois = const <String>[],
    this.raw,
  });

  final String formattedAddress;
  final Position? position;
  final String? province;
  final String? city;
  final String? district;
  final String? township;
  final String? neighborhood;
  final String? building;
  final String? adCode;
  final String? cityCode;
  final String? country;
  final String? countryCode;
  final String? townCode;
  final List<String> roads;
  final List<String> crosses;
  final List<PoiItem> pois;
  final List<String> aois;
  final Map<String, dynamic>? raw;

  static ReGeocodeResult decodeFromMap(Map<String, dynamic> map) {
    Position? position;
    final lat = (map['latitude'] as num?)?.toDouble();
    final lng = (map['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      position = Position(latitude: lat, longitude: lng);
    }
    final rawPois = map['pois'] as List<dynamic>? ?? const <dynamic>[];
    final raw = map['raw'];
    return ReGeocodeResult(
      formattedAddress: map['formattedAddress'] as String? ?? '',
      position: position,
      province: map['province'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      township: map['township'] as String?,
      neighborhood: map['neighborhood'] as String?,
      building: map['building'] as String?,
      adCode: map['adCode'] as String?,
      cityCode: map['cityCode'] as String?,
      country: map['country'] as String?,
      countryCode: map['countryCode'] as String?,
      townCode: map['townCode'] as String?,
      roads: (map['roads'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      crosses: (map['crosses'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      pois: rawPois
          .map((item) =>
              PoiItem.decodeFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      aois: (map['aois'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

/// 路线规划类型。
enum RoutePlanType {
  drive('drive'),
  walk('walk'),
  ride('ride');

  const RoutePlanType(this.value);

  final String value;
}

/// 路线规划扩展信息范围。
enum RoutePlanExtensions {
  base('base'),
  all('all');

  const RoutePlanExtensions(this.value);

  final String value;
}

/// 路线规划坐标点，可携带名称和 POI ID。
class RoutePoint {
  RoutePoint({
    required this.position,
    this.name,
    this.poiId,
  });

  final Position position;
  final String? name;
  final String? poiId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': position.latitude,
      'longitude': position.longitude,
      'name': name ?? '',
      'poiId': poiId ?? '',
    };
  }

  static RoutePoint decodeFromMap(Map<String, dynamic> map) {
    return RoutePoint(
      position: Position(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      name: map['name'] as String?,
      poiId: map['poiId'] as String?,
    );
  }
}

/// 驾车避让区域。
class RouteAvoidPolygon {
  RouteAvoidPolygon(this.points);

  final List<Position> points;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'points': points
          .map((point) => <String, dynamic>{
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
    };
  }
}

/// 驾车路径规划策略。
///
/// 对齐高德导航 SDK `PathPlanningStrategy` 的 0-20 策略 ID。原生通道仍然
/// 传 [id]，Dart API 使用枚举避免页面和业务代码里散落魔法数字。
enum PathPlanningStrategy {
  drivingDefault(
    0,
    'DRIVING_DEFAULT',
    '速度优先',
    '速度优先，不考虑当时路况，返回耗时最短的路线，但是此路线不一定距离最短',
    false,
  ),
  drivingSaveMoney(
    1,
    'DRIVING_SAVE_MONEY',
    '费用优先',
    '费用优先，不走收费路段，且耗时最少的路线',
    false,
  ),
  drivingShortestDistance(
    2,
    'DRIVING_SHORTEST_DISTANCE',
    '距离优先',
    '距离优先，不考虑路况，仅走距离最短的路线，但是可能存在穿越小路/小区的情况',
    false,
  ),
  drivingNoExpressWays(
    3,
    'DRIVING_NO_EXPRESS_WAYS',
    '不走快速路',
    '速度优先，不走快速路，例如京通快速路（建议使用 13）',
    false,
  ),
  drivingAvoidCongestion(
    4,
    'DRIVING_AVOID_CONGESTION',
    '躲避拥堵',
    '躲避拥堵，但是可能会存在绕路的情况，耗时可能较长',
    false,
  ),
  drivingMultiplePrioritySpeedCostDistance(
    5,
    'DRIVING_MULTIPLE_PRIORITY_SPEED_COST_DISTANCE',
    '多策略',
    '同时使用速度优先、费用优先、距离优先三个策略计算路径，通常返回一到三条路线',
    true,
  ),
  drivingSingleRouteAvoidHighspeed(
    6,
    'DRIVING_SINGLE_ROUTE_AVOID_HIGHSPEED',
    '不走高速',
    '速度优先，不走高速，但是不排除走其余收费路段',
    false,
  ),
  drivingSingleRouteAvoidHighspeedCost(
    7,
    'DRIVING_SINGLE_ROUTE_AVOID_HIGHSPEED_COST',
    '不走高速且避免收费',
    '费用优先，不走高速且避免所有收费路段',
    false,
  ),
  drivingSingleRouteAvoidCongestionCost(
    8,
    'DRIVING_SINGLE_ROUTE_AVOID_CONGESTION_COST',
    '躲避拥堵和收费',
    '躲避拥堵和收费，可能存在走高速的情况，并且考虑路况不走拥堵路线',
    false,
  ),
  drivingSingleRouteAvoidHighspeedCostCongestion(
    9,
    'DRIVING_SINGLE_ROUTE_AVOID_HIGHSPEED_COST_CONGESTION',
    '躲避拥堵收费且不走高速',
    '躲避拥堵和收费，不走高速',
    false,
  ),
  drivingMultipleRoutesDefault(
    10,
    'DRIVING_MULTIPLE_ROUTES_DEFAULT',
    '高德默认多路线',
    '返回结果会躲避拥堵，路程较短，尽量缩短时间，与高德地图默认策略一致',
    true,
  ),
  drivingMultipleShortestTimeDistance(
    11,
    'DRIVING_MULTIPLE_SHORTEST_TIME_DISTANCE',
    '时间/距离/避堵',
    '返回三个结果包含：时间最短、距离最短、躲避拥堵（建议使用 10）',
    true,
  ),
  drivingMultipleRoutesAvoidCongestion(
    12,
    'DRIVING_MULTIPLE_ROUTES_AVOID_CONGESTION',
    '躲避拥堵多路线',
    '返回的结果考虑路况，尽量躲避拥堵，与高德地图“躲避拥堵”策略一致',
    true,
  ),
  drivingMultipleRoutesAvoidHighspeed(
    13,
    'DRIVING_MULTIPLE_ROUTES_AVOID_HIGHSPEED',
    '不走高速多路线',
    '返回的结果不走高速，与高德地图“不走高速”策略一致',
    true,
  ),
  drivingMultipleRoutesAvoidCost(
    14,
    'DRIVING_MULTIPLE_ROUTES_AVOID_COST',
    '避免收费多路线',
    '返回的结果尽可能规划收费较低甚至免费的路径，与高德地图“避免收费”策略一致',
    true,
  ),
  drivingMultipleRoutesAvoidHighspeedCongestion(
    15,
    'DRIVING_MULTIPLE_ROUTES_AVOID_HIGHSPEED_CONGESTION',
    '躲避拥堵且不走高速',
    '返回的结果考虑路况，尽量躲避拥堵，并且不走高速',
    true,
  ),
  drivingMultipleRoutesAvoidHighspeedCost(
    16,
    'DRIVING_MULTIPLE_ROUTES_AVOID_HIGHTSPEED_COST',
    '避免收费且不走高速',
    '返回的结果尽量不走高速，并且尽量规划收费较低甚至免费的路径',
    true,
  ),
  drivingMultipleRoutesAvoidCostCongestion(
    17,
    'DRIVING_MULTIPLE_ROUTES_AVOID_COST_CONGESTION',
    '躲避拥堵且避免收费',
    '返回路径规划结果会尽量躲避拥堵，并且规划收费较低甚至免费的路径',
    true,
  ),
  drivingMultipleRoutesAvoidHighspeedCostCongestion(
    18,
    'DRIVING_MULTIPLE_ROUTES_AVOID_HIGHSPEED_COST_CONGESTION',
    '躲避拥堵收费且不走高速',
    '返回的结果尽量躲避拥堵，规划收费较低甚至免费的路径，并且尽量不走高速路',
    true,
  ),
  drivingMultipleRoutesPriorityHighspeed(
    19,
    'DRIVING_MULTIPLE_ROUTES_PRIORITY_HIGHSPEED',
    '高速优先',
    '返回的结果会优先选择高速路，与高德地图“高速优先”策略一致',
    true,
  ),
  drivingMultipleRoutesPriorityHighspeedAvoidCongestion(
    20,
    'DRIVING_MULTIPLE_ROUTES_PRIORITY_HIGHSPEED_AVOID_CONGESTION',
    '高速优先且躲避拥堵',
    '返回的结果会优先考虑高速路，并且会考虑路况躲避拥堵',
    true,
  );

  const PathPlanningStrategy(
    this.id,
    this.constantName,
    this.label,
    this.description,
    this.multipleRoute,
  );

  final int id;
  final String constantName;
  final String label;
  final String description;

  /// 是否为可能返回多条路径的策略。
  final bool multipleRoute;

  String get displayName => '$id $label';

  static PathPlanningStrategy fromValue(Object? value) {
    if (value is PathPlanningStrategy) return value;
    if (value is num) {
      return values.firstWhere(
        (strategy) => strategy.id == value.toInt(),
        orElse: () => drivingMultipleRoutesDefault,
      );
    }
    return drivingMultipleRoutesDefault;
  }
}

abstract class RoutePlanQuery {
  RoutePlanQuery({
    required this.type,
    required this.origin,
    required this.destination,
  });

  final RoutePlanType type;
  final RoutePoint origin;
  final RoutePoint destination;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.value,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'originLatitude': origin.position.latitude,
      'originLongitude': origin.position.longitude,
      'destinationLatitude': destination.position.latitude,
      'destinationLongitude': destination.position.longitude,
      'originName': origin.name ?? '',
      'destinationName': destination.name ?? '',
      'originPoiId': origin.poiId ?? '',
      'destinationPoiId': destination.poiId ?? '',
    };
  }
}

/// 驾车路线规划查询。
class DriveRouteQuery extends RoutePlanQuery {
  DriveRouteQuery({
    required super.origin,
    required super.destination,
    Object strategy = PathPlanningStrategy.drivingMultipleRoutesDefault,
    this.wayPoints = const <RoutePoint>[],
    this.avoidPolygons = const <RouteAvoidPolygon>[],
    this.avoidRoad,
    this.extensions = RoutePlanExtensions.all,
    this.carType,
    this.carNumber,
    this.plateProvince,
    this.excludeRoadType,
    this.ferry,
  })  : strategy = PathPlanningStrategy.fromValue(strategy),
        super(type: RoutePlanType.drive);

  /// 驾车策略。官方地图 SDK 支持 0-20。
  final PathPlanningStrategy strategy;

  /// 途经点。地图 SDK 驾车最多支持 6 个，导航 SDK 最多 16 个。
  final List<RoutePoint> wayPoints;

  /// 避让区域。官方最多 32 个区域，每个区域最多 16 个点。
  final List<RouteAvoidPolygon> avoidPolygons;

  /// 避让道路，仅支持一条；和避让区域同时存在时官方以避让道路为准。
  final String? avoidRoad;
  final RoutePlanExtensions extensions;
  final int? carType;
  final String? carNumber;
  final String? plateProvince;
  final int? excludeRoadType;
  final bool? ferry;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'strategy': strategy.id,
      'wayPoints': wayPoints.map((point) => point.toMap()).toList(),
      'avoidPolygons': avoidPolygons.map((polygon) => polygon.toMap()).toList(),
      'avoidRoad': avoidRoad ?? '',
      'extensions': extensions.value,
      'carType': carType,
      'carNumber': carNumber ?? '',
      'plateProvince': plateProvince ?? '',
      'excludeRoadType': excludeRoadType,
      'ferry': ferry,
    };
  }
}

/// 步行路线规划查询。
class WalkRouteQuery extends RoutePlanQuery {
  WalkRouteQuery({
    required super.origin,
    required super.destination,
    this.mode = 0,
    this.alternativeRoute,
    this.indoor,
    this.multiPath,
    this.extensions = RoutePlanExtensions.all,
  }) : super(type: RoutePlanType.walk);

  /// Android: RouteSearch.WALK_DEFAULT / WALK_MULTI_PATH。
  final int mode;

  /// iOS 可选多方案参数，具体支持取决于 SDK 版本。
  final int? alternativeRoute;
  final bool? indoor;
  final bool? multiPath;
  final RoutePlanExtensions extensions;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'mode': mode,
      'alternativeRoute': alternativeRoute,
      'indoor': indoor,
      'multiPath': multiPath,
      'extensions': extensions.value,
    };
  }
}

/// 骑行路线规划查询。
class RideRouteQuery extends RoutePlanQuery {
  RideRouteQuery({
    required super.origin,
    required super.destination,
    this.mode = 0,
    this.strategy,
    this.extensions = RoutePlanExtensions.all,
  }) : super(type: RoutePlanType.ride);

  /// Android RideRouteQuery mode。
  final int mode;

  /// iOS 或导航 SDK 旅行策略，具体支持取决于 SDK 版本。
  final int? strategy;
  final RoutePlanExtensions extensions;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'mode': mode,
      'strategy': strategy,
      'extensions': extensions.value,
    };
  }
}

class RoutePlanResult {
  RoutePlanResult({
    required this.type,
    this.origin,
    this.destination,
    this.taxiCost,
    this.paths = const <RoutePath>[],
    this.raw,
  });

  final RoutePlanType type;
  final RoutePoint? origin;
  final RoutePoint? destination;
  final double? taxiCost;
  final List<RoutePath> paths;
  final Map<String, dynamic>? raw;

  static RoutePlanResult empty({required RoutePlanType type}) {
    return RoutePlanResult(type: type);
  }

  static RoutePlanResult decodeFromMap(Map<String, dynamic> map) {
    final typeValue = map['type'] as String? ?? RoutePlanType.drive.value;
    final rawPaths = map['paths'] as List<dynamic>? ?? const <dynamic>[];
    final raw = map['raw'];
    RoutePoint? decodePoint(Object? value) {
      if (value is Map) {
        return RoutePoint.decodeFromMap(Map<String, dynamic>.from(value));
      }
      return null;
    }

    return RoutePlanResult(
      type: RoutePlanType.values.firstWhere(
        (value) => value.value == typeValue,
        orElse: () => RoutePlanType.drive,
      ),
      origin: decodePoint(map['origin']),
      destination: decodePoint(map['destination']),
      taxiCost: (map['taxiCost'] as num?)?.toDouble(),
      paths: rawPaths
          .map((item) =>
              RoutePath.decodeFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

class RoutePath {
  RoutePath({
    this.distance,
    this.duration,
    this.strategy,
    this.tolls,
    this.tollDistance,
    this.totalTrafficLights,
    this.restriction,
    this.polyline = const <Position>[],
    this.steps = const <RouteStep>[],
    this.raw,
  });

  final double? distance;
  final double? duration;
  final String? strategy;
  final double? tolls;
  final double? tollDistance;
  final int? totalTrafficLights;
  final int? restriction;
  final List<Position> polyline;
  final List<RouteStep> steps;
  final Map<String, dynamic>? raw;

  static RoutePath decodeFromMap(Map<String, dynamic> map) {
    final rawSteps = map['steps'] as List<dynamic>? ?? const <dynamic>[];
    final rawPolyline = map['polyline'] as List<dynamic>? ?? const <dynamic>[];
    final raw = map['raw'];
    return RoutePath(
      distance: (map['distance'] as num?)?.toDouble(),
      duration: (map['duration'] as num?)?.toDouble(),
      strategy: map['strategy'] as String?,
      tolls: (map['tolls'] as num?)?.toDouble(),
      tollDistance: (map['tollDistance'] as num?)?.toDouble(),
      totalTrafficLights: (map['totalTrafficLights'] as num?)?.toInt(),
      restriction: (map['restriction'] as num?)?.toInt(),
      polyline:
          rawPolyline.map(_positionFromAny).whereType<Position>().toList(),
      steps: rawSteps
          .map((item) =>
              RouteStep.decodeFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

class RouteStep {
  RouteStep({
    this.instruction,
    this.orientation,
    this.road,
    this.action,
    this.assistantAction,
    this.distance,
    this.duration,
    this.tolls,
    this.tollDistance,
    this.polyline = const <Position>[],
    this.tmcs = const <RouteTmc>[],
    this.raw,
  });

  final String? instruction;
  final String? orientation;
  final String? road;
  final String? action;
  final String? assistantAction;
  final double? distance;
  final double? duration;
  final double? tolls;
  final double? tollDistance;
  final List<Position> polyline;
  final List<RouteTmc> tmcs;
  final Map<String, dynamic>? raw;

  static RouteStep decodeFromMap(Map<String, dynamic> map) {
    final rawPolyline = map['polyline'] as List<dynamic>? ?? const <dynamic>[];
    final rawTmcs = map['tmcs'] as List<dynamic>? ?? const <dynamic>[];
    final raw = map['raw'];
    return RouteStep(
      instruction: map['instruction'] as String?,
      orientation: map['orientation'] as String?,
      road: map['road'] as String?,
      action: map['action'] as String?,
      assistantAction: map['assistantAction'] as String?,
      distance: (map['distance'] as num?)?.toDouble(),
      duration: (map['duration'] as num?)?.toDouble(),
      tolls: (map['tolls'] as num?)?.toDouble(),
      tollDistance: (map['tollDistance'] as num?)?.toDouble(),
      polyline:
          rawPolyline.map(_positionFromAny).whereType<Position>().toList(),
      tmcs: rawTmcs
          .map((item) =>
              RouteTmc.decodeFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

class RouteTmc {
  RouteTmc({
    this.status,
    this.distance,
    this.polyline = const <Position>[],
    this.raw,
  });

  final String? status;
  final double? distance;
  final List<Position> polyline;
  final Map<String, dynamic>? raw;

  static RouteTmc decodeFromMap(Map<String, dynamic> map) {
    final rawPolyline = map['polyline'] as List<dynamic>? ?? const <dynamic>[];
    final raw = map['raw'];
    return RouteTmc(
      status: map['status'] as String?,
      distance: (map['distance'] as num?)?.toDouble(),
      polyline:
          rawPolyline.map(_positionFromAny).whereType<Position>().toList(),
      raw: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}

Position? _positionFromAny(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final lat = (map['latitude'] as num?)?.toDouble();
    final lng = (map['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      return Position(latitude: lat, longitude: lng);
    }
  }
  return null;
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
