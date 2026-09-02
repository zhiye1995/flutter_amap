part of '../../../flutter_amap_navi.dart';

/// 导航插件专用坐标，避免导航包依赖地图包。
class NaviPosition {
  NaviPosition({required double latitude, required double longitude})
    : latitude = latitude.clamp(-90.0, 90.0),
      longitude = longitude >= -180 && longitude < 180
          ? longitude
          : (longitude + 180.0) % 360.0 - 180.0;

  double latitude;
  double longitude;

  Object encode() => <Object?>[latitude, longitude];

  static NaviPosition decode(List<Object?> result) {
    assert(result.length == 2);
    return NaviPosition(
      latitude: result[0]! as double,
      longitude: result[1]! as double,
    );
  }

  NaviPosition copyWith({double? latitude, double? longitude}) {
    return NaviPosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaviPosition &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// 导航 SDK 的 Android/iOS Key。
class NaviApiKey {
  const NaviApiKey({required this.iosKey, required this.androidKey});

  final String iosKey;
  final String androidKey;
}

/// 导航 SDK 初始化配置。
class NaviSdkConfig {
  const NaviSdkConfig({
    required this.apiKey,
    this.agreePrivacy = true,
    this.preloadNaviIcons = true,
  });

  final NaviApiKey apiKey;
  final bool agreePrivacy;
  final bool preloadNaviIcons;
}

/// 高德导航 SDK 驾车策略，对应原生 0-20 策略 ID。
enum NaviDrivingStrategy {
  drivingDefault(0),
  drivingSaveMoney(1),
  drivingShortestDistance(2),
  drivingNoExpressWays(3),
  drivingAvoidCongestion(4),
  drivingMultiplePrioritySpeedCostDistance(5),
  drivingSingleRouteAvoidHighspeed(6),
  drivingSingleRouteAvoidHighspeedCost(7),
  drivingSingleRouteAvoidCongestionCost(8),
  drivingSingleRouteAvoidHighspeedCostCongestion(9),
  drivingMultipleRoutesDefault(10),
  drivingMultipleShortestTimeDistance(11),
  drivingMultipleRoutesAvoidCongestion(12),
  drivingMultipleRoutesAvoidHighspeed(13),
  drivingMultipleRoutesAvoidCost(14),
  drivingMultipleRoutesAvoidHighspeedCongestion(15),
  drivingMultipleRoutesAvoidHighspeedCost(16),
  drivingMultipleRoutesAvoidCostCongestion(17),
  drivingMultipleRoutesAvoidHighspeedCostCongestion(18),
  drivingMultipleRoutesPriorityHighspeed(19),
  drivingMultipleRoutesPriorityHighspeedAvoidCongestion(20);

  const NaviDrivingStrategy(this.id);

  final int id;

  static NaviDrivingStrategy fromId(int? id) {
    return values.firstWhere(
      (strategy) => strategy.id == id,
      orElse: () => drivingMultipleRoutesDefault,
    );
  }
}
