import 'dart:ui' as ui;

import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 对齐高德 Android 3D Demo「自定义 Marker / 更换图标」：多条 [Marker] 使用不同 [Bitmap]（asset、[Size]、文件 bytes、以及 [CustomPainter] 栅格化后的 bytes）。可将 Demo `res/drawable*` 中位图复制为 `assets/custom_marker_*.png` 替换本页资源。
class CustomMarkerPage extends StatefulWidget {
  const CustomMarkerPage({super.key});

  static const title = '自定义Marker';

  @override
  State<CustomMarkerPage> createState() => _CustomMarkerPageState();
}

class _CustomMarkerPageState extends State<CustomMarkerPage> {
  static const _assetA = 'custom_marker_asset_a';
  static const _assetB = 'custom_marker_asset_b';
  static const _sized = 'custom_marker_sized';
  static const _fromBytes = 'custom_marker_from_bytes';
  static const _painterCar = 'custom_marker_painter_car';
  static const _painterMoto = 'custom_marker_painter_moto';

  AMapController? _controller;
  var _ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CustomMarkerPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 16.8,
              ),
              onMapCreated: (c) => _bootstrap(c),
              onMarkerClick: (id) {
                if (!mounted) return;
                LoadingUtil.showToast('onMarkerClick: $id');
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                _ready
                    ? '红/绿：asset；蓝：Size；bytes：PNG；汽车/摩托：[CustomPainter] 转 PNG。'
                    : '地图加载中…',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;

    c.addMarker(
      Marker(
        id: _assetA,
        position: Position(latitude: 39.98435, longitude: 116.30720),
        bitmap: Bitmap(asset: 'assets/custom_marker_a.png'),
      ),
    );
    c.addMarker(
      Marker(
        id: _assetB,
        position: Position(latitude: 39.98385, longitude: 116.30775),
        bitmap: Bitmap(asset: 'assets/custom_marker_b.png'),
      ),
    );
    c.addMarker(
      Marker(
        id: _sized,
        position: Position(latitude: 39.98400, longitude: 116.30805),
        bitmap: Bitmap(
          asset: 'assets/custom_marker_c.png',
          size: Size(width: 32, height: 32),
        ),
      ),
    );

    final data = await rootBundle.load('assets/custom_marker_a.png');
    final pngBytes = data.buffer.asUint8List();
    c.addMarker(
      Marker(
        id: _fromBytes,
        position: Position(latitude: 39.98355, longitude: 116.30735),
        bitmap: Bitmap(bytes: pngBytes, size: Size(width: 40, height: 40)),
      ),
    );

    final carPng = await _customPainterToPng(
      const _CarMarkerPainter(),
      ui.Size(56, 56),
    );
    if (carPng != null) {
      c.addMarker(
        Marker(
          id: _painterCar,
          position: Position(latitude: 39.98455, longitude: 116.30790),
          bitmap: Bitmap(bytes: carPng, size: Size(width: 48, height: 48)),
        ),
      );
    }

    final motoPng = await _customPainterToPng(
      const _MotoMarkerPainter(),
      ui.Size(56, 56),
    );
    if (motoPng != null) {
      c.addMarker(
        Marker(
          id: _painterMoto,
          position: Position(latitude: 39.98340, longitude: 116.30815),
          bitmap: Bitmap(bytes: motoPng, size: Size(width: 48, height: 48)),
        ),
      );
    }

    if (mounted) setState(() => _ready = true);
  }
}

/// 将 [CustomPainter] 绘制结果编码为 PNG，供 [Bitmap.bytes] 作为 Marker 图标（插件侧无 View 转 Bitmap API）。
Future<Uint8List?> _customPainterToPng(
  CustomPainter painter,
  ui.Size layoutSize,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, layoutSize);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    layoutSize.width.ceil(),
    layoutSize.height.ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  return byteData?.buffer.asUint8List();
}

/// 俯视角简化小汽车（车身 + 窗 + 双轮）。
class _CarMarkerPainter extends CustomPainter {
  const _CarMarkerPainter();

  @override
  void paint(Canvas canvas, ui.Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.84, h * 0.48),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF1565C0));
    final cabin = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.34, w * 0.64, h * 0.22),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(cabin, Paint()..color = const Color(0xFFBBDEFB));
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(body, stroke);
    final wheelR = w * 0.09;
    final wheel = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(Offset(w * 0.26, h * 0.76), wheelR, wheel);
    canvas.drawCircle(Offset(w * 0.74, h * 0.76), wheelR, wheel);
    final hub = Paint()..color = const Color(0xFF90A4AE);
    canvas.drawCircle(Offset(w * 0.26, h * 0.76), wheelR * 0.45, hub);
    canvas.drawCircle(Offset(w * 0.74, h * 0.76), wheelR * 0.45, hub);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 侧视简化摩托车（双轮 + 车架 + 车把）。
class _MotoMarkerPainter extends CustomPainter {
  const _MotoMarkerPainter();

  @override
  void paint(Canvas canvas, ui.Size size) {
    final w = size.width;
    final h = size.height;
    final frame = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final rWheel = w * 0.11;
    final rear = Offset(w * 0.22, h * 0.68);
    final front = Offset(w * 0.78, h * 0.68);
    canvas.drawCircle(rear, rWheel, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(front, rWheel, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(
        rear, rWheel * 0.45, Paint()..color = const Color(0xFFB0BEC5));
    canvas.drawCircle(
        front, rWheel * 0.45, Paint()..color = const Color(0xFFB0BEC5));

    final path = Path()
      ..moveTo(rear.dx + rWheel * 0.35, rear.dy - rWheel * 0.2)
      ..quadraticBezierTo(w * 0.42, h * 0.32, w * 0.52, h * 0.38)
      ..lineTo(w * 0.72, h * 0.36)
      ..lineTo(w * 0.82, h * 0.30);
    canvas.drawPath(path, frame);

    final seat = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.36, w * 0.22, h * 0.10),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(seat, Paint()..color = const Color(0xFF8D1A1A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
