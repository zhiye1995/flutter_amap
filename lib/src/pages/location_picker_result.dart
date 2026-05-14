part of '../../../flutter_amap.dart';

/// 位置选择来源。
enum LocationPickerResultSource {
  /// 来自 POI 搜索结果。
  poi,

  /// 来自输入提示结果。
  inputTip,

  /// 来自设备当前位置。
  currentLocation,

  /// 来自纯坐标或逆地理编码结果。
  coordinate,
}

/// 全屏位置选择器返回结果。
class LocationPickerResult {
  const LocationPickerResult({
    required this.position,
    this.name,
    this.address,
    this.poiId,
    this.poi,
    this.inputTip,
    this.reGeocode,
    this.source = LocationPickerResultSource.coordinate,
  });

  /// 选择结果坐标。调用方可始终依赖该字段。
  final Position position;

  /// 展示名称，例如 POI 名称或“我的位置”。
  final String? name;

  /// 展示地址。
  final String? address;

  /// 高德 POI ID。
  final String? poiId;

  /// 原始 POI 对象。
  final PoiItem? poi;

  /// 原始输入提示对象。
  final InputTip? inputTip;

  /// 当前位置或纯坐标补充的逆地理编码信息。
  final ReGeocodeResult? reGeocode;

  /// 结果来源。
  final LocationPickerResultSource source;

  /// 从 POI 构造选择结果。
  factory LocationPickerResult.fromPoi(PoiItem poi) {
    return LocationPickerResult(
      position: poi.position,
      name: _locationPickerEmptyToNull(poi.name),
      address: _locationPickerEmptyToNull(poi.address),
      poiId: _locationPickerEmptyToNull(poi.poiId),
      poi: poi,
      source: LocationPickerResultSource.poi,
    );
  }

  /// 从输入提示构造选择结果。
  factory LocationPickerResult.fromInputTip(
    InputTip inputTip, {
    required Position position,
    PoiItem? poi,
  }) {
    return LocationPickerResult(
      position: position,
      name: _locationPickerEmptyToNull(inputTip.name) ??
          _locationPickerEmptyToNull(poi?.name),
      address: _locationPickerEmptyToNull(inputTip.address) ??
          _locationPickerEmptyToNull(poi?.address),
      poiId: _locationPickerEmptyToNull(inputTip.poiId) ??
          _locationPickerEmptyToNull(poi?.poiId),
      poi: poi,
      inputTip: inputTip,
      source: LocationPickerResultSource.inputTip,
    );
  }

  /// 从当前位置构造选择结果。
  factory LocationPickerResult.fromCurrentLocation({
    required Position position,
    required String name,
    ReGeocodeResult? reGeocode,
  }) {
    final poi =
        reGeocode?.pois.isNotEmpty == true ? reGeocode!.pois.first : null;
    return LocationPickerResult(
      position: position,
      name: _locationPickerEmptyToNull(poi?.name) ??
          _locationPickerEmptyToNull(name),
      address: _locationPickerEmptyToNull(poi?.address) ??
          _locationPickerEmptyToNull(reGeocode?.formattedAddress),
      poiId: _locationPickerEmptyToNull(poi?.poiId),
      poi: poi,
      reGeocode: reGeocode,
      source: LocationPickerResultSource.currentLocation,
    );
  }

  /// 转换为路线规划点。
  RoutePoint toRoutePoint() {
    return RoutePoint(
      position: position,
      name: name,
      poiId: poiId,
    );
  }

  /// 转换为导航点。
  NaviPoint toNaviPoint({double? startAngle}) {
    return NaviPoint(
      position: position,
      name: name,
      poiId: poiId,
      startAngle: startAngle,
    );
  }
}

String? _locationPickerEmptyToNull(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}
