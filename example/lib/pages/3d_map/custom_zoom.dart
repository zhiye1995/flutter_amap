import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 自定义缩放 — 与高德 Android 3D Demo「自定义缩放」一致的核心行为：
/// 关闭 SDK 内置缩放控件（[AMapWidget.zoomControlEnabled] = false），
/// 使用界面上的自定义按钮调用相机缩放（[AMapController.zoomIn] / [zoomOut]）。
class CustomZoomPage extends StatefulWidget {
  const CustomZoomPage({super.key});

  static const title = '自定义缩放';

  @override
  State<CustomZoomPage> createState() => _CustomZoomPageState();
}

class _CustomZoomPageState extends State<CustomZoomPage> {
  AMapController? _controller;
  var _animated = false;
  var _zoomLabel = '—';

  Duration? get _animDuration =>
      _animated ? const Duration(milliseconds: 300) : null;

  Future<void> _zoomIn() async {
    final c = _controller;
    if (c == null) return;
    await c.zoomIn(duration: _animDuration);
  }

  Future<void> _zoomOut() async {
    final c = _controller;
    if (c == null) return;
    await c.zoomOut(duration: _animDuration);
  }

  void _updateZoomLabel(CameraPosition? pos) {
    final z = pos?.zoom;
    final next = z == null ? '—' : z.toStringAsFixed(1);
    if (next == _zoomLabel) return;
    setState(() => _zoomLabel = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomZoomPage.title),
        centerTitle: true,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('动画'),
              Switch(
                value: _animated,
                onChanged: (value) => setState(() => _animated = value),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position:
                    Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
              zoomControlEnabled: false,
              onMapCreated: (c) => setState(() => _controller = c),
              onCameraChange: _updateZoomLabel,
              onCameraChangeFinish: _updateZoomLabel,
            ),
          ),
          Positioned(
            right: 12,
            top: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '放大',
                    onPressed: _controller == null ? null : _zoomIn,
                    icon: const Icon(Icons.add),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _zoomLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '缩小',
                    onPressed: _controller == null ? null : _zoomOut,
                    icon: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              '说明：已关闭 SDK 缩放控件，使用右侧自定义 +/- 缩放；'
              '焦点缩放（zoomBy 指定屏幕点）需原生接口支持，当前插件以视野中心为基准。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
