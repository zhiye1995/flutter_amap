import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// Marker 点击回调 — 仅弹出提示，不删除标记（对齐高德 Android 3D Demo 中「点击 Marker 回调」类示例）。
class MarkerClickCallbackPage extends StatefulWidget {
  const MarkerClickCallbackPage({super.key});

  static const title = 'Marker点击回调';

  @override
  State<MarkerClickCallbackPage> createState() =>
      _MarkerClickCallbackPageState();
}

class _MarkerClickCallbackPageState extends State<MarkerClickCallbackPage> {
  /// 预置点 id -> 坐标，供点击回调展示
  static final Map<String, Position> _presetPositions = {
    'demo_1': Position(latitude: 39.984120, longitude: 116.307484),
    'demo_2': Position(latitude: 39.984350, longitude: 116.307200),
    'demo_3': Position(latitude: 39.983900, longitude: 116.307750),
  };

  Future<void> _addPresetMarkers(AMapController c) async {
    await c.waitForMapCompleted();
    if (!mounted) return;
    final bitmap = Bitmap(asset: 'assets/map-marker.png');
    for (final e in _presetPositions.entries) {
      c.addMarker(
        Marker(
          id: e.key,
          position: e.value,
          bitmap: bitmap,
        ),
      );
    }
  }

  void _onMarkerClick(String markerId) {
    final pos = _presetPositions[markerId];
    if (!mounted) return;
    final text = pos != null
        ? 'onMarkerClick: id=$markerId\n${pos.latitude}, ${pos.longitude}'
        : 'onMarkerClick: id=$markerId';
    LoadingUtil.showToast(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MarkerClickCallbackPage.title),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '地图上已有 ${_presetPositions.length} 个固定标记；点击任意标记查看回调信息（不会删除）。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _presetPositions['demo_1']!,
                zoom: 17.2,
              ),
              onMapCreated: _addPresetMarkers,
              onMarkerClick: _onMarkerClick,
            ),
          ),
        ],
      ),
    );
  }
}
