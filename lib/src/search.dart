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
}

