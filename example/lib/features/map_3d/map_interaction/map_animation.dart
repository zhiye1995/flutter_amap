import 'dart:math' as math;

import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'package:flutter/material.dart';

/// 地图动画效果 — 对齐高德 Android_3D_Demo `CameraActivity`：
/// 动画开关、停止动画、按像素平移（由 [getScalePerPixel] 换算经纬度）、缩放一级；
/// 另附「去陆家嘴」长距离动画与完成提示。Web 端无比例尺像素接口，平移按钮不可用。
class MapAnimationPage extends StatefulWidget {
  const MapAnimationPage({super.key});

  static const title = '地图动画效果';

  @override
  State<MapAnimationPage> createState() => _MapAnimationPageState();
}

class _MapAnimationPageState extends State<MapAnimationPage> {
  /// 与官方 Demo `Constants.FANGHENG` 一致
  static final _fangheng = Position(latitude: 39.989614, longitude: 116.481763);

  /// `CameraActivity` 陆家嘴示例：`Constants.SHANGHAI`，zoom=18，tilt=30，bearing=0
  static final _lujiazui = CameraPosition(
    position: Position(latitude: 31.238068, longitude: 121.501654),
    zoom: 18,
    heading: 0,
    skew: 30,
  );

  static const _scrollPx = 100.0;
  static const _fanghengMarkerId = 'demo_fangheng_animation';

  late AMapController _controller;
  var _animated = false;
  var _fanghengMarkerAdded = false;

  Duration? get _duration =>
      _animated ? const Duration(milliseconds: 1000) : null;

  Future<void> _stopAnimation() async {
    await _controller.stopCameraAnimation();
    if (!mounted) {
      return;
    }
    context.snackBar('已请求停止相机动画（Android 生效；iOS SDK 无对等 API）');
  }

  /// 按高德 `CameraUpdateFactory.scrollBy(dx, dy)` 的像素语义，用比例尺换算中心点偏移。
  Future<void> _scrollBy(double dx, double dy) async {
    if (PlatformUtil.isWeb) {
      context.snackBar('Web 端未实现 getScalePerPixel，无法模拟像素平移');
      return;
    }
    await _controller.waitForMapCompleted();
    final scale = await _controller.getScalePerPixel();
    final cam = _controller.currentCamera;
    final pos = cam?.position;
    if (cam == null || pos == null || scale <= 0) {
      return;
    }
    final latRad = pos.latitude * math.pi / 180;
    const metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * math.cos(latRad);
    final dLng = -(dx * scale) / metersPerDegLng;
    final dLat = (dy * scale) / metersPerDegLat;
    await _controller.moveCamera(
      CameraPosition(
        position: Position(
          latitude: pos.latitude + dLat,
          longitude: pos.longitude + dLng,
        ),
        zoom: cam.zoom,
        heading: cam.heading,
        skew: cam.skew,
      ),
      _duration,
      false,
    );
  }

  Future<void> _goLujiazui() async {
    final duration = _duration;
    await _controller.moveCamera(_lujiazui, duration);
    if (!mounted || duration == null) {
      return;
    }
    LoadingUtil.showSuccess('Animation to 陆家嘴 complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapAnimationPage.title),
        centerTitle: true,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('动画'),
              Switch(
                value: _animated,
                onChanged: (v) => setState(() => _animated = v),
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
                position: _fangheng,
                zoom: 17.5,
              ),
              onMapCreated: (c) => _controller = c,
              onMapCompleted: () {
                if (_fanghengMarkerAdded) {
                  return;
                }
                _fanghengMarkerAdded = true;
                _controller.addMarker(
                  Marker(
                    id: _fanghengMarkerId,
                    position: _fangheng,
                    bitmap: Bitmap(asset: 'assets/map-marker.png'),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _stopAnimation,
                          child: const Text('停止动画'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _goLujiazui,
                          child: const Text('去陆家嘴'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _scrollBy(-_scrollPx, 0),
                        child: const Text('左移'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _scrollBy(_scrollPx, 0),
                        child: const Text('右移'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _scrollBy(0, -_scrollPx),
                        child: const Text('上移'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _scrollBy(0, _scrollPx),
                        child: const Text('下移'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _controller.zoomIn(duration: _duration),
                        child: const Text('放大'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _controller.zoomOut(duration: _duration),
                        child: const Text('缩小'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Text(
              PlatformUtil.isWeb
                  ? 'Web：平移依赖 getScalePerPixel，请使用 Android/iOS 体验完整示例。'
                  : '平移：按官方 scrollBy(±100px) 换算；停止动画在 Android 上对应 AMap.stopAnimation。',
              style: TextStyle(
                fontSize: 11,
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
