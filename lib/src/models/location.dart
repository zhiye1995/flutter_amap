part of '../../../flutter_amap.dart';

// ==================== 用户定位相关类型 ====================

/// 用户定位类型
enum UserLocationType {
  ///只定位一次（Android Only）
  locationTypeShow,

  ///定位一次，且将视角移动到地图中心点
  locationTypeLocate,

  ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
  locationTypeFollow,

  ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
  locationTypeMapRotate,

  ///连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）默认执行此种模式（Android Only）
  locationTypeLocationRotate,

  ///连续定位、蓝点不会移动到地图中心点，定位点依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  locationTypeLocationRotateNoCenter,

  ///连续定位、蓝点不会移动到地图中心点，并且蓝点会跟随设备移动（Android Only）
  locationTypeFollowNoCenter,

  ///连续定位、蓝点不会移动到地图中心点，地图依照设备方向旋转，并且蓝点会跟随设备移动（Android Only）
  locationTypeMapRotateNoCenter,
}

/// 定位点
class Location {
  Location({
    required this.position,
    this.heading,
    this.accuracy,
  });

  /// 定位点的位置
  Position position;

  /// 定位点的方向
  double? heading;

  /// 定位点的精确度
  double? accuracy;

  Object encode() {
    return <Object?>[
      position.encode(),
      heading,
      accuracy,
    ];
  }

  static Location decode(List<Object?> result) {
    return Location(
      position: Position.decode(result[0]! as List<Object?>),
      heading: result[1] as double?,
      accuracy: result[2] as double?,
    );
  }

  Location copyWith({
    Position? position,
    double? heading,
    double? accuracy,
  }) {
    return Location(
      position: position ?? this.position,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

/// 用户定位配置
class UserLocationConfig {
  UserLocationConfig({
    this.userLocationButton,
    this.showUserLocation,
    this.userLocationStyle,
  });

  final bool? userLocationButton;
  final bool? showUserLocation;
  final UserLocationStyle? userLocationStyle;

  Object encode() {
    return <Object?>[
      userLocationButton,
      showUserLocation,
      userLocationStyle?.encode(),
    ];
  }

  static UserLocationConfig decode(List<Object?> result) {
    return UserLocationConfig(
      userLocationButton: result[0] as bool?,
      showUserLocation: result[1] as bool?,
      userLocationStyle: result[2] != null
          ? UserLocationStyle.decode(result[2]! as List<Object?>)
          : null,
    );
  }

  UserLocationConfig copyWith({
    bool? userLocationButton,
    bool? showUserLocation,
    UserLocationStyle? userLocationStyle,
  }) {
    return UserLocationConfig(
      userLocationButton: userLocationButton ?? this.userLocationButton,
      showUserLocation: showUserLocation ?? this.showUserLocation,
      userLocationStyle: userLocationStyle ?? this.userLocationStyle,
    );
  }
}

/// 用户定位样式
class UserLocationStyle {
  UserLocationStyle({
    this.userLocationType,
    this.fillColor,
    this.strokeColor,
    this.lineWidth,
    this.image,
  });

  /// 用户定位类型
  final UserLocationType? userLocationType;

  /// 精度圈的填充颜色
  final Color? fillColor;

  /// 精度圈的边线颜色
  final Color? strokeColor;

  /// 精度圈的边线宽度
  final double? lineWidth;

  /// 定位图标以替代蓝色原点
  final Bitmap? image;

  Object encode() {
    return <Object?>[
      userLocationType?.index,
      fillColor?.value,
      strokeColor?.value,
      lineWidth,
      image?.encode(),
    ];
  }

  static UserLocationStyle decode(List<Object?> result) {
    return UserLocationStyle(
      userLocationType: result[0] as UserLocationType?,
      fillColor: result[1] != null ? Color(result[1] as int) : null,
      strokeColor: result[2] != null ? Color(result[2] as int) : null,
      lineWidth: result[3] as double?,
      image:
          result[4] != null ? Bitmap.decode(result[4]! as List<Object?>) : null,
    );
  }

  UserLocationStyle copyWith({
    UserLocationType? userLocationType,
    Color? fillColor,
    Color? strokeColor,
    double? lineWidth,
    Bitmap? image,
  }) {
    return UserLocationStyle(
      userLocationType: userLocationType ?? this.userLocationType,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      lineWidth: lineWidth ?? this.lineWidth,
      image: image ?? this.image,
    );
  }
}

/// 与高德 Android [MyLocationStyle]、插件 iOS `UserLocationType.userTrackingMode` 映射对照，便于 UI 区分双端差异。
extension UserLocationTypePlatform on UserLocationType {
  /// Android 插件是否映射到 [MyLocationStyle]（当前枚举值均在高德 Android SDK 中有对应常量）。
  bool get hasAndroidMyLocationStyleMapping {
    return switch (this) {
      UserLocationType.locationTypeShow ||
      UserLocationType.locationTypeLocate ||
      UserLocationType.locationTypeFollow ||
      UserLocationType.locationTypeMapRotate ||
      UserLocationType.locationTypeLocationRotate ||
      UserLocationType.locationTypeLocationRotateNoCenter ||
      UserLocationType.locationTypeFollowNoCenter ||
      UserLocationType.locationTypeMapRotateNoCenter =>
        true,
    };
  }

  /// iOS 是否有较接近的 `MAUserTrackingMode` 原生语义（`false` 时原生层会回退到可表达的最近模式）。
  bool get hasIosNativeTrackingMapping {
    return switch (this) {
      UserLocationType.locationTypeShow ||
      UserLocationType.locationTypeLocate ||
      UserLocationType.locationTypeFollow ||
      UserLocationType.locationTypeMapRotate =>
        true,
      _ => false,
    };
  }

  /// 枚举注释中标注为（Android Only）或与 Android 默认语义强绑定、不以 iOS 为主展示的类型。
  bool get isAndroidDocumentationOnly {
    return switch (this) {
      UserLocationType.locationTypeShow ||
      UserLocationType.locationTypeLocationRotate ||
      UserLocationType.locationTypeLocationRotateNoCenter ||
      UserLocationType.locationTypeFollowNoCenter ||
      UserLocationType.locationTypeMapRotateNoCenter =>
        true,
      _ => false,
    };
  }

  /// 一行中文说明，用于示例页 Chip 副标题或 Tooltip。
  String get platformAvailabilityLabel {
    if (hasIosNativeTrackingMapping) {
      if (isAndroidDocumentationOnly) {
        return 'Android：文档标注 Only；iOS：有基础映射（如仅显/追踪）';
      }
      return 'Android / iOS：双端可用';
    }
    return 'Android：完整；iOS：回退到最接近的 MAUserTrackingMode（不完全等价）';
  }
}
