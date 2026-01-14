part of '../../../flutter_amap.dart';

// ==================== 通用类型 ====================

/// 高德地图api key
class ApiKey {
  ApiKey({
    required this.iosKey,
    required this.androidKey,
    required this.webKey,
  });

  /// iOS平台的key
  final String iosKey;

  /// Android平台的key
  final String androidKey;

  /// Web平台的key
  final String webKey;

  Object encode() {
    return <Object?>[
      iosKey,
      androidKey,
      webKey,
    ];
  }

  static ApiKey decode(List<Object?> result) {
    return ApiKey(
      iosKey: result[0] as String,
      androidKey: result[1] as String,
      webKey: result[2] as String,
    );
  }

  ApiKey copyWith({
    String? iosKey,
    String? androidKey,
    String? webKey,
  }) {
    return ApiKey(
      iosKey: iosKey ?? this.iosKey,
      androidKey: androidKey ?? this.androidKey,
      webKey: webKey ?? this.webKey,
    );
  }
}

