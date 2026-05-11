import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// 示例 App 统一的轻提示工具。
class LoadingUtil {
  const LoadingUtil._();

  static TransitionBuilder init() {
    return EasyLoading.init();
  }

  static Future<void> showToast(String message) {
    return EasyLoading.showToast(message);
  }

  static Future<void> showSuccess(String message) {
    return EasyLoading.showSuccess(message);
  }

  static Future<void> showError(String message) {
    return EasyLoading.showError(message);
  }

  static Future<void> dismiss() {
    return EasyLoading.dismiss();
  }
}
