part of '../flutter_amap.dart';

/// 高德地图搜索服务
class AMapSearch {
  AMapSearch._();

  /// 请求输入提示
  ///
  /// [keywords] 搜索关键词 keywords 必需查询关键字 规则： 多个关键字用“|”分割
  /// 若不指定city，并且搜索的为泛词（例如“美食”）的情况下，
  /// 返回的内容为城市列表以及此城市内有多少结果符合要求。
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
  /// [radius] 搜索半径，单位：米，取值范围：0-50000（可选，不传时使用平台默认值）
  /// [page] 页码，默认 1
  /// [pageSize] 每页数量，默认 20
  /// [city] 搜索城市（可选）
  ///
  /// 返回 [PoiItem] 列表
  static Future<List<PoiItem>> searchPOIAround({
    required Position center,
    String? keywords,
    String? types,
    int? radius,
    int page = 1,
    int pageSize = 20,
    String? city,
  }) async {
    final items = await AMapFlutterPlatformInterface.instance.searchPOIAround(
      center: center,
      keywords: keywords,
      types: types,
      radius: radius,
      page: page,
      pageSize: pageSize,
      city: city,
    );

    // 按距离从小到大排序；distance 为空的放最后
    items.sort((a, b) {
      final da = a.distance;
      final db = b.distance;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return items;
  }

  /// 查询实时天气
  ///
  /// [city] 城市名称或区域编码（adcode），如"北京市"或"110000"
  ///
  /// 返回 [LocalWeatherLive] 实时天气信息
  static Future<LocalWeatherLive> searchWeatherLive({
    required String city,
  }) {
    return AMapFlutterPlatformInterface.instance.searchWeatherLive(
      city: city,
    );
  }

  /// 查询天气预报
  ///
  /// [city] 城市名称或区域编码（adcode），如"北京市"或"110000"
  ///
  /// 返回 [LocalWeatherForecast] 天气预报信息（包含未来几天预报）
  static Future<LocalWeatherForecast> searchWeatherForecast({
    required String city,
  }) {
    return AMapFlutterPlatformInterface.instance.searchWeatherForecast(
      city: city,
    );
  }

  /// 根据当前定位查询实时天气
  ///
  /// 内部自动获取定位信息，提取adcode后查询天气
  /// 需要确保已获取定位权限
  ///
  /// 返回 [LocalWeatherLive] 实时天气信息
  static Future<LocalWeatherLive> searchWeatherLiveByLocation() {
    return AMapFlutterPlatformInterface.instance.searchWeatherLiveByLocation();
  }

  /// 根据当前定位查询天气预报
  ///
  /// 内部自动获取定位信息，提取adcode后查询天气预报
  /// 需要确保已获取定位权限
  ///
  /// 返回 [LocalWeatherForecast] 天气预报信息（包含未来几天预报）
  static Future<LocalWeatherForecast> searchWeatherForecastByLocation() {
    return AMapFlutterPlatformInterface.instance.searchWeatherForecastByLocation();
  }
}
