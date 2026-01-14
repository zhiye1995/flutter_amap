part of '../../../flutter_amap.dart';

// ==================== 基础几何类型 ====================

/// 位置
class Position {
  Position({
    required double latitude,
    required double longitude,
  })  : latitude = latitude < -90.0 ? -90.0 : (latitude > 90.0 ? 90.0 : latitude),
        longitude =
        longitude >= -180 && longitude < 180 ? longitude : (longitude + 180.0) % 360.0 - 180.0;

  /// 位置的纬度
  double latitude;

  /// 位置的经度
  double longitude;

  Object encode() {
    return <Object?>[
      latitude,
      longitude,
    ];
  }

  static Position decode(List<Object?> result) {
    assert(result.length == 2);
    return Position(
      latitude: result[0]! as double,
      longitude: result[1]! as double,
    );
  }

  Position copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// 地图区域
class Region {
  Region({
    required this.north,
    required this.east,
    required this.south,
    required this.west,
  });

  /// 最北的纬度
  double north;

  /// 最东的经度
  double east;

  /// 最南的纬度
  double south;

  /// 最西的经度
  double west;

  Object encode() {
    return <Object?>[
      north,
      east,
      south,
      west,
    ];
  }

  static Region decode(List<Object?> result) {
    return Region(
      north: result[0]! as double,
      east: result[1]! as double,
      south: result[2]! as double,
      west: result[3]! as double,
    );
  }

  Region copyWith({
    double? north,
    double? east,
    double? south,
    double? west,
  }) {
    return Region(
      north: north ?? this.north,
      east: east ?? this.east,
      south: south ?? this.south,
      west: west ?? this.west,
    );
  }
}

/// 对象的像素尺寸
class Size {
  Size({
    required this.width,
    required this.height,
  });

  double width;
  double height;

  Object encode() {
    return <Object?>[
      width,
      height,
    ];
  }

  static Size decode(List<Object?> result) {
    return Size(
      width: result[0]! as double,
      height: result[1]! as double,
    );
  }

  Size copyWith({
    double? width,
    double? height,
  }) {
    return Size(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// 点标记图标锚点
class Anchor {
  Anchor({
    required this.x,
    required this.y,
  });

  /// 点标记图标锚点的X坐标
  double x;

  /// 点标记图标锚点的Y坐标
  double y;

  Object encode() {
    return <Object?>[
      x,
      y,
    ];
  }

  static Anchor decode(List<Object?> result) {
    return Anchor(
      x: result[0]! as double,
      y: result[1]! as double,
    );
  }

  Anchor copyWith({
    double? x,
    double? y,
  }) {
    return Anchor(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

