part of '../../../flutter_amap.dart';

/// 拖动地图后，与上次周边搜索中心距离小于该值（米）则不再请求。
const double _kMinNearbySearchMoveMeters = 40;

/// 认为 POI 与地图中心“足够近”、可跳过相机动画的距离（米）。
const double _kSkipMoveCameraMeters = 15;

double _mapPlacePickerDistanceMeters(Position a, Position b) {
  const earthRadiusMeters = 6371000.0;
  final dLat = math.pi / 180 * (b.latitude - a.latitude);
  final dLon = math.pi / 180 * (b.longitude - a.longitude);
  final lat1 = math.pi / 180 * a.latitude;
  final lat2 = math.pi / 180 * b.latitude;
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return 2 * earthRadiusMeters * math.asin(math.min(1.0, math.sqrt(h)));
}

String _mapPlacePickerFormatDistanceLine(PoiItem poi) {
  final d = poi.distance;
  if (d == null || d <= 0) return '';
  if (d < 1000) return '${d}m内';
  return '${(d / 1000).toStringAsFixed(1)}km内';
}

String _mapPlacePickerFormatAddressLine(PoiItem poi) {
  final parts = <String>[];
  if (poi.adName != null && poi.adName!.isNotEmpty) {
    parts.add(poi.adName!);
  }
  if (poi.address != null && poi.address!.isNotEmpty) {
    parts.add(poi.address!);
  }
  return parts.join('');
}

String _mapPlacePickerFormatSubtitle(PoiItem poi) {
  final distanceText = _mapPlacePickerFormatDistanceLine(poi);
  final addressText = _mapPlacePickerFormatAddressLine(poi);
  if (distanceText.isNotEmpty && addressText.isNotEmpty) {
    return '$distanceText | $addressText';
  }
  if (distanceText.isNotEmpty) return distanceText;
  if (addressText.isNotEmpty) return addressText;
  return '';
}

Map<String, HighlightedWord>? _mapPlacePickerKeywordHighlights(
  String keyword,
  TextStyle highlightStyle,
) {
  if (keyword.isEmpty) return null;
  return <String, HighlightedWord>{
    keyword: HighlightedWord(textStyle: highlightStyle),
  };
}
