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
