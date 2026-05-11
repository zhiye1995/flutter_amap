import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// InfoWindow / callout：通过 [Marker.title]、[Marker.snippet] 与 [AMapController.showInfoWindow] / [hideInfoWindow] 演示。
class InfoWindowPage extends StatefulWidget {
  const InfoWindowPage({super.key});

  static const title = 'InfoWindow功能';

  @override
  State<InfoWindowPage> createState() => _InfoWindowPageState();
}

class _InfoWindowPageState extends State<InfoWindowPage> {
  static const _markerA = 'info_window_marker_a';
  static const _markerB = 'info_window_marker_b';

  AMapController? _controller;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(InfoWindowPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 16.8,
              ),
              onMapCreated: (c) async {
                setState(() => _controller = c);
                await c.waitForMapCompleted();
                if (!mounted || _controller != c) return;
                final icon = Bitmap(asset: 'assets/map-marker.png');
                c.addMarker(
                  Marker(
                    id: _markerA,
                    position:
                        Position(latitude: 39.984120, longitude: 116.307484),
                    bitmap: icon,
                    title: '信息窗标题 A',
                    snippet: '副标题：点击地图空白处可关闭（原生）。',
                  ),
                );
                c.addMarker(
                  Marker(
                    id: _markerB,
                    position:
                        Position(latitude: 39.98350, longitude: 116.30820),
                    bitmap: icon,
                    title: '标记 B',
                    snippet: '仅作第二个示例点。',
                  ),
                );
                if (mounted) setState(() => _ready = true);
              },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _ready ? '点标记或下方按钮显示信息窗。' : '地图加载中…',
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
                        onPressed: !_ready
                            ? null
                            : () => _call((c) => c.showInfoWindow(_markerA)),
                        child: const Text('显示 A 信息窗'),
                      ),
                      FilledButton(
                        onPressed: !_ready
                            ? null
                            : () => _call((c) => c.showInfoWindow(_markerB)),
                        child: const Text('显示 B 信息窗'),
                      ),
                      OutlinedButton(
                        onPressed: !_ready
                            ? null
                            : () => _call((c) => c.hideInfoWindow()),
                        child: const Text('隐藏信息窗'),
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

  Future<void> _call(Future<void> Function(AMapController c) fn) async {
    final c = _controller;
    if (c == null || !_ready) return;
    try {
      await fn(c);
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      LoadingUtil.showToast('$e');
    }
  }
}
