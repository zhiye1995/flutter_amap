part of '../../../../flutter_amap.dart';

/// 位置选择器搜索模式。
enum LocationPickerSearchMode {
  /// 优先使用输入提示，点击无坐标提示时再补全坐标。
  inputTips,

  /// 直接使用 POI 关键字搜索，结果都带坐标。
  poiKeywords,

  /// 默认模式，当前等同于 [inputTips]。
  auto,
}

/// 全屏位置选择器配置。
class LocationPickerConfig {
  const LocationPickerConfig({
    this.title,
    this.hintText,
    this.initialKeyword,
    this.city,
    this.cityLimit = false,
    this.types,
    this.location,
    this.includeCurrentLocation = true,
    this.currentLocationText = '我的位置',
    this.currentLocationTimeout = const Duration(seconds: 15),
    this.searchMode = LocationPickerSearchMode.auto,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.pageSize = 20,
  });

  /// 页面标题，用于语义表达；当前页面主要展示搜索框。
  final String? title;

  /// 搜索框提示文字。
  final String? hintText;

  /// 初始搜索关键词。
  final String? initialKeyword;

  /// 搜索城市，可传城市名、citycode 或 adcode。
  final String? city;

  /// 是否限制在 [city] 内搜索。
  final bool cityLimit;

  /// POI 类型限制，多个类型用“|”分隔。
  final String? types;

  /// 搜索中心点，用于输入提示和 POI 搜索排序。
  final Position? location;

  /// 是否显示“我的位置”入口。
  final bool includeCurrentLocation;

  /// “我的位置”入口和返回结果的默认名称。
  final String currentLocationText;

  /// 等待首次定位结果的超时时间。
  final Duration currentLocationTimeout;

  /// 搜索模式。
  final LocationPickerSearchMode searchMode;

  /// 输入防抖延迟。
  final Duration debounceDelay;

  /// POI 关键字搜索每页数量。
  final int pageSize;
}
