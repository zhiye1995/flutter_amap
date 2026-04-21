import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 限制缩放级别 — 对齐高德 Android 3D Demo：运行时设置最小/最大缩放级别；关闭时恢复为 SDK 常用全量范围 3–20。
class MapZoomRestrictionPage extends StatefulWidget {
  const MapZoomRestrictionPage({super.key});

  static const title = '限制缩放级别功能';

  /// 与常见官方示例一致：限制在 15–18 级之间缩放。
  static const double restrictedMinZoom = 15;
  static const double restrictedMaxZoom = 18;

  static const double sdkMinZoom = 3;
  static const double sdkMaxZoom = 20;

  @override
  State<MapZoomRestrictionPage> createState() => _MapZoomRestrictionPageState();
}

class _MapZoomRestrictionPageState extends State<MapZoomRestrictionPage> {
  var _limitZoom = false;

  @override
  Widget build(BuildContext context) {
    final minZ =
        _limitZoom ? MapZoomRestrictionPage.restrictedMinZoom : MapZoomRestrictionPage.sdkMinZoom;
    final maxZ =
        _limitZoom ? MapZoomRestrictionPage.restrictedMaxZoom : MapZoomRestrictionPage.sdkMaxZoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(MapZoomRestrictionPage.title),
        centerTitle: true,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('限制缩放'),
              Switch(
                value: _limitZoom,
                onChanged: (v) => setState(() => _limitZoom = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              _limitZoom
                  ? '当前缩放被限制在 ${MapZoomRestrictionPage.restrictedMinZoom}–${MapZoomRestrictionPage.restrictedMaxZoom} 级，请双指缩放体验。'
                  : '已恢复为 ${MapZoomRestrictionPage.sdkMinZoom}–${MapZoomRestrictionPage.sdkMaxZoom} 级全范围。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: AMapWidget(
              minZoom: minZ,
              maxZoom: maxZ,
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
