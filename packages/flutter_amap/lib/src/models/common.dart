part of '../../../flutter_amap.dart';

// ==================== 通用类型 ====================

/// 高德地图api key
class ApiKey {
  ApiKey({
    required this.iosKey,
    required this.androidKey,
  });

  /// iOS平台的key
  final String iosKey;

  /// Android平台的key
  final String androidKey;

  Object encode() {
    return <Object?>[
      iosKey,
      androidKey,
    ];
  }

  static ApiKey decode(List<Object?> result) {
    return ApiKey(
      iosKey: result[0] as String,
      androidKey: result[1] as String,
    );
  }

  ApiKey copyWith({
    String? iosKey,
    String? androidKey,
  }) {
    return ApiKey(
      iosKey: iosKey ?? this.iosKey,
      androidKey: androidKey ?? this.androidKey,
    );
  }
}
