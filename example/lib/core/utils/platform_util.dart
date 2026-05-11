import 'dart:io';

import 'package:flutter/foundation.dart';

enum PlatformEnum {
  android,
  ios,
  web,
  unknown,
}

class PlatformUtil {
  const PlatformUtil._();

  static PlatformEnum get platform {
    if (kIsWeb) {
      return PlatformEnum.web;
    } else if (Platform.isAndroid) {
      return PlatformEnum.android;
    } else if (Platform.isIOS) {
      return PlatformEnum.ios;
    } else {
      return PlatformEnum.unknown;
    }
  }

  static const bool isWeb = kIsWeb;
  static final bool isAndroid = !kIsWeb && Platform.isAndroid;
  static final bool isIOS = !kIsWeb && Platform.isIOS;
}
