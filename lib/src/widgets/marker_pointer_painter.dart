import 'dart:ui' as ui show Size;
import 'package:flutter/cupertino.dart';

/// 标记点下方小尖角绘制器
class MarkerPointerPainter extends CustomPainter {
  MarkerPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
