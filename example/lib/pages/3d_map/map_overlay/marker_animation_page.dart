import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 点标记动画：调用 [AMapController.animateMarker]（默认 `durationMs` 800，与 Android 基准一致；iOS 呼吸/透明度总时长已对齐）。
class MarkerAnimationPage extends StatefulWidget {
  const MarkerAnimationPage({super.key});

  static const title = 'Marker动画功能';

  @override
  State<MarkerAnimationPage> createState() => _MarkerAnimationPageState();
}

class _MarkerAnimationPageState extends State<MarkerAnimationPage> {
  static const _markerId = 'marker_animation_demo';

  AMapController? _controller;
  bool _markerReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(MarkerAnimationPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
              onMapCreated: (c) async {
                setState(() => _controller = c);
                await c.waitForMapCompleted();
                if (!mounted || _controller != c) return;
                c.addMarker(
                  Marker(
                    id: _markerId,
                    position:
                        Position(latitude: 39.984120, longitude: 116.307484),
                    bitmap: Bitmap(asset: 'assets/map-marker.png'),
                  ),
                );
                if (mounted) setState(() => _markerReady = true);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _markerReady ? '选择一种动画' : '地图加载中…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: !_markerReady
                            ? null
                            : () => _play(MarkerAnimationKind.pulseScale),
                        child: const Text('呼吸'),
                      ),
                      FilledButton(
                        onPressed: !_markerReady
                            ? null
                            : () => _play(MarkerAnimationKind.growOnce),
                        child: const Text('生长'),
                      ),
                      FilledButton(
                        onPressed: !_markerReady
                            ? null
                            : () => _play(MarkerAnimationKind.moveRoundTrip),
                        child: const Text('移动'),
                      ),
                      FilledButton(
                        onPressed: !_markerReady
                            ? null
                            : () => _play(MarkerAnimationKind.rotateOnce),
                        child: const Text('旋转一周'),
                      ),
                      FilledButton(
                        onPressed: !_markerReady
                            ? null
                            : () => _play(MarkerAnimationKind.fadePulse),
                        child: const Text('透明度脉冲'),
                      ),
                      OutlinedButton(
                        onPressed: !_markerReady ? null : _cancel,
                        child: const Text('取消动画'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _play(MarkerAnimationKind kind) async {
    final c = _controller;
    if (c == null || !_markerReady) return;
    try {
      await c.animateMarker(_markerId, kind: kind);
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _cancel() async {
    final c = _controller;
    if (c == null || !_markerReady) return;
    await c.cancelMarkerAnimation(_markerId);
  }
}
