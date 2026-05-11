import 'package:flutter/material.dart';

import 'loading_util.dart';

/// BuildContext 的扩展工具。
extension ContextExt on BuildContext {
  /// 显示 alert dialog。
  Future<void> alert(String title) async {
    return showDialog(
      context: this,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: Navigator.of(this).pop,
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示轻提示。
  Future<void> snackBar(String message) {
    return LoadingUtil.showToast(message);
  }
}
