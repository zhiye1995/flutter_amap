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
      bitmap: result[2] != null ? Bitmap.decode(result[2]! as List<Object?>) : null,
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

