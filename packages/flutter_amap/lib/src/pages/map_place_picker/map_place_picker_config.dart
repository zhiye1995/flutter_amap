part of '../../../../flutter_amap.dart';

/// 地图地点选择器配置
class MapPlacePickerConfig {
  const MapPlacePickerConfig({
    this.title,
    this.hintText,
    this.city,
    this.types,
    this.initialPosition,
    this.searchRadius = 1000,
    this.debounceDelay = const Duration(milliseconds: 500),
  });

  /// 标题（显示在顶部栏中间，可为空）
  final String? title;

  /// 搜索框提示文字
  final String? hintText;

  /// 搜索城市
  final String? city;

  /// POI 类型限制
  final String? types;

  /// 初始位置（如果不设置则使用当前定位）
  final Position? initialPosition;

  /// 周边搜索半径（米）
  final int searchRadius;

  /// 搜索防抖延迟
  final Duration debounceDelay;
}
