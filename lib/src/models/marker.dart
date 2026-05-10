part of '../../../flutter_amap.dart';

// ==================== 标记点和POI相关类型 ====================

/// 点标记动画类型（Android 使用高德 [Marker.setAnimation]；iOS 对 [MAAnnotationView] 做 UIView 动画，语义对齐）。
enum MarkerAnimationKind {
  /// 缩放脉冲（偏官方 Demo「呼吸」：1↔略放大 + REVERSE）。
  pulseScale,

  /// 绕锚点旋转一周
  rotateOnce,

  /// 透明度起伏
  fadePulse,

  /// 生长：一次性从 0 缩放到正常尺寸（对齐官方常用 `ScaleAnimation(0,1,0,1)`）。
  growOnce,

  /// 移动：沿经纬度短距离移动再复原（Android [TranslateAnimation]；iOS 对 annotation `coordinate` 插值）。
  moveRoundTrip,
}

/// 图片信息
class Bitmap {
  Bitmap({
    this.asset,
    this.bytes,
    this.size,
  });

  /// 图片资源路径
  String? asset;

  /// 图片数据
  Uint8List? bytes;

  /// 图片尺寸
  Size? size;

  Object encode() {
    return <Object?>[
      asset,
      bytes,
      size,
    ];
  }

  static Bitmap decode(List<Object?> result) {
    return Bitmap(
      asset: result[0] as String?,
      bytes: result[1] as Uint8List?,
      size: result[2] as Size?,
    );
  }

  Bitmap copyWith({
    String? asset,
    Uint8List? bytes,
    Size? size,
  }) {
    return Bitmap(
      asset: asset ?? this.asset,
      bytes: bytes ?? this.bytes,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Bitmap &&
        asset == other.asset &&
        listEquals(bytes, other.bytes) &&
        size == other.size;
  }

  @override
  int get hashCode => Object.hash(
        asset,
        bytes == null ? null : Object.hashAll(bytes!),
        size,
      );
}

/// 标记点配置属性
class Marker {
  Marker({
    required this.id,
    required this.position,
    this.bitmap,
    this.title,
    this.snippet,
  });

  /// 标记点ID
  String id;

  /// 标记点的位置
  Position position;

  /// 标记点自定义图标信息
  Bitmap? bitmap;

  /// InfoWindow 标题（Android [MarkerOptions.title]；iOS callout `title`）
  String? title;

  /// InfoWindow 副标题（Android [MarkerOptions.snippet]；iOS callout `subtitle`）
  String? snippet;

  Object encode() {
    return <Object?>[
      id,
      position.encode(),
      bitmap?.encode(),
      title,
      snippet,
    ];
  }

  static Marker decode(List<Object?> result) {
    return Marker(
      id: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
      bitmap:
          result[2] != null ? Bitmap.decode(result[2]! as List<Object?>) : null,
      title: result.length > 3 ? result[3] as String? : null,
      snippet: result.length > 4 ? result[4] as String? : null,
    );
  }

  Marker copyWith({
    String? id,
    Position? position,
    Bitmap? bitmap,
    String? title,
    String? snippet,
  }) {
    return Marker(
      id: id ?? this.id,
      position: position ?? this.position,
      bitmap: bitmap ?? this.bitmap,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Marker &&
        id == other.id &&
        position == other.position &&
        bitmap == other.bitmap &&
        title == other.title &&
        snippet == other.snippet;
  }

  @override
  int get hashCode => Object.hash(id, position, bitmap, title, snippet);
}

/// 折线覆盖物配置。
class Polyline {
  Polyline({
    required this.id,
    required this.points,
    this.color = const Color(0xCC00BFFF),
    this.width = 10,
    this.visible = true,
  });

  /// 折线ID
  String id;

  /// 折线坐标点
  List<Position> points;

  /// 折线颜色
  Color color;

  /// 折线宽度
  double width;

  /// 是否可见
  bool visible;

  Object encode() {
    return <Object?>[
      id,
      points.map((position) => position.encode()).toList(),
      color.toARGB32(),
      width,
      visible,
    ];
  }

  static Polyline decode(List<Object?> result) {
    return Polyline(
      id: result[0]! as String,
      points: (result[1]! as List<Object?>)
          .map((position) => Position.decode(position! as List<Object?>))
          .toList(),
      color: Color(result[2]! as int),
      width: result[3]! as double,
      visible: result[4]! as bool,
    );
  }

  Polyline copyWith({
    String? id,
    List<Position>? points,
    Color? color,
    double? width,
    bool? visible,
  }) {
    return Polyline(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Polyline &&
        id == other.id &&
        listEquals(points, other.points) &&
        color == other.color &&
        width == other.width &&
        visible == other.visible;
  }

  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(points),
        color,
        width,
        visible,
      );
}

/// 多边形覆盖物配置。
class Polygon {
  Polygon({
    required this.id,
    required this.points,
    this.strokeWidth = 10,
    this.strokeColor = const Color(0xCC00BFFF),
    this.fillColor = const Color(0xC487CEFA),
    this.visible = true,
  });

  /// 多边形ID
  String id;

  /// 多边形坐标点
  List<Position> points;

  /// 边框宽度
  double strokeWidth;

  /// 边框颜色
  Color strokeColor;

  /// 填充颜色
  Color fillColor;

  /// 是否可见
  bool visible;

  Object encode() {
    return <Object?>[
      id,
      points.map((position) => position.encode()).toList(),
      strokeWidth,
      strokeColor.toARGB32(),
      fillColor.toARGB32(),
      visible,
    ];
  }

  static Polygon decode(List<Object?> result) {
    return Polygon(
      id: result[0]! as String,
      points: (result[1]! as List<Object?>)
          .map((position) => Position.decode(position! as List<Object?>))
          .toList(),
      strokeWidth: result[2]! as double,
      strokeColor: Color(result[3]! as int),
      fillColor: Color(result[4]! as int),
      visible: result[5]! as bool,
    );
  }

  Polygon copyWith({
    String? id,
    List<Position>? points,
    double? strokeWidth,
    Color? strokeColor,
    Color? fillColor,
    bool? visible,
  }) {
    return Polygon(
      id: id ?? this.id,
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor ?? this.fillColor,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Polygon &&
        id == other.id &&
        listEquals(points, other.points) &&
        strokeWidth == other.strokeWidth &&
        strokeColor == other.strokeColor &&
        fillColor == other.fillColor &&
        visible == other.visible;
  }

  @override
  int get hashCode => Object.hash(
        id,
        Object.hashAll(points),
        strokeWidth,
        strokeColor,
        fillColor,
        visible,
      );
}

/// 地图兴趣点
class Poi {
  Poi({
    required this.name,
    required this.position,
  });

  /// 兴趣点的名称
  String name;

  /// 兴趣点的位置
  Position position;

  Object encode() {
    return <Object?>[
      name,
      position.encode(),
    ];
  }

  static Poi decode(List<Object?> result) {
    return Poi(
      name: result[0]! as String,
      position: Position.decode(result[1]! as List<Object?>),
    );
  }

  Poi copyWith({
    String? name,
    Position? position,
  }) {
    return Poi(
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }
}
