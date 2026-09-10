part of '../../../../flutter_amap_plus.dart';

/// 地图地点选择器配置
class MapPlacePickerConfig {
  const MapPlacePickerConfig({
    this.title,
    this.hintText,
    this.city,
    this.types,
    this.initialPosition,
    this.initialPoi,
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

  /// 初始位置（未提供 [initialPoi] 时使用；均未设置则使用当前定位）。
  final Position? initialPosition;

  /// 初始选中地点，同时回显名称、地址和坐标。
  ///
  /// 优先于 [initialPosition]；用户重新选点前，直接确认返回此地点。
  final PoiItem? initialPoi;

  /// 周边搜索半径（米）
  final int searchRadius;

  /// 搜索防抖延迟
  final Duration debounceDelay;
}
