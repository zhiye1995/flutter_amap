part of '../../../flutter_amap.dart';

// ==================== UI控件相关类型 ====================

/// UI控件位置锚点
enum UIControlAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// UI控件位置偏移
class UIControlOffset {
  UIControlOffset({
    required this.x,
    required this.y,
  });

  /// X轴方向的位置偏移
  double x;

  /// Y轴方向的位置偏移
  double y;

  Object encode() {
    return <Object?>[
      x,
      y,
    ];
  }

  static UIControlOffset decode(List<Object?> result) {
    return UIControlOffset(
      x: result[0]! as double,
      y: result[1]! as double,
    );
  }

  UIControlOffset copyWith({
    double? x,
    double? y,
  }) {
    return UIControlOffset(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// UI控件位置
class UIControlPosition {
  UIControlPosition({
    required this.anchor,
    required this.offset,
  });

  /// UI控件位置锚点
  UIControlAnchor anchor;

  /// UI控件位置偏移
  UIControlOffset offset;

  Object encode() {
    return <Object?>[
      anchor.index,
      offset.encode(),
    ];
  }

  static UIControlPosition decode(List<Object?> result) {
    return UIControlPosition(
      anchor: result[0] as UIControlAnchor,
      offset: UIControlOffset.decode(result[1]! as List<Object?>),
    );
  }

  UIControlPosition copyWith({
    UIControlAnchor? anchor,
    UIControlOffset? offset,
  }) {
    return UIControlPosition(
      anchor: anchor ?? this.anchor,
      offset: offset ?? this.offset,
    );
  }
}

