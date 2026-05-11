import 'dart:io';

enum PlatformEnum {
  android,
  ios,
  unknown,
}

class PlatformUtil {
  const PlatformUtil._();

  static PlatformEnum get platform {
    if (Platform.isAndroid) {
      return PlatformEnum.android;
    } else if (Platform.isIOS) {
      return PlatformEnum.ios;
    } else {
      return PlatformEnum.unknown;
    }
  }

  static final bool isAndroid = Platform.isAndroid;
  static final bool isIOS = Platform.isIOS;
}
