import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 地图截屏 — 行为对齐高德 Android / iOS Demo「地图截图」：截取当前可视地图区域并预览。
class MapScreenshotPage extends StatefulWidget {
  const MapScreenshotPage({super.key});

  static const title = '地图截屏功能';

  @override
  State<MapScreenshotPage> createState() => _MapScreenshotPageState();
}

class _MapScreenshotPageState extends State<MapScreenshotPage> {
  AMapController? _controller;
  var _busy = false;

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await c.takeMapSnapshot();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('地图截图'),
            content: SingleChildScrollView(
              child: Image.memory(bytes),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('截屏失败: ${e.message ?? e.code}');
    } catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('截屏失败: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapScreenshotPage.title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _busy ? null : _capture,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('截屏'),
          ),
        ],
      ),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position: Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        onMapCreated: (c) => _controller = c,
      ),
    );
  }
}
