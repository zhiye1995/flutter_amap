part of '../amap_flutter.dart';

/// 高德地图搜索服务
class AMapSearch {
  AMapSearch._();

  /// 请求输入提示
  ///
  /// [keywords] 搜索关键词
  /// [city] 搜索城市（可选，默认全国）
  /// [cityLimit] 是否限制在当前城市搜索
  /// [types] POI类型限制（多个类型用"|"分隔）
  /// [location] 搜索中心点（用于周边搜索）
  ///
  /// 返回 [InputTip] 列表
  static Future<List<InputTip>> requestInputTips({
    required String keywords,
    String? city,
    bool cityLimit = false,
    String? types,
    Position? location,
  }) {
    return AMapFlutterPlatformInterface.instance.requestInputTips(
      keywords: keywords,
      city: city,
      cityLimit: cityLimit,
      types: types,
      location: location,
    );
  }

  /// 周边 POI 搜索
  ///
  /// [center] 搜索中心点坐标
  /// [keywords] 搜索关键词（可选，为空时搜索附近所有 POI）
  /// [types] POI 类型限制（多个类型用"|"分隔，可选）
  /// [radius] 搜索半径，单位：米，默认 1000，取值范围：0-50000
  /// [page] 页码，默认 1
  /// [pageSize] 每页数量，默认 20
  /// [city] 搜索城市（可选）
  ///
  /// 返回 [PoiItem] 列表
  static Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int radius = 1000,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) {
    return AMapFlutterPlatformInterface.instance.searchPOIAround(
      center: center,
      keywords: keywords,
      types: types,
      radius: radius,
      page: page,
      pageSize: pageSize,
      city: city,
    );
  }
}

