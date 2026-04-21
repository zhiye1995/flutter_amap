import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 限制地图显示区域 — 对应高德 Android `AMap.setMapStatusLimits` / 本插件 [AMapController.setRestrictRegion]。
class MapRestrictionPage extends StatefulWidget {
  const MapRestrictionPage({super.key});

  static const title = '限制显示区域功能';

  @override
  State<MapRestrictionPage> createState() => _MapRestrictionPageState();
}

class _MapRestrictionPageState extends State<MapRestrictionPage> {
  final Region restrictedRegion = Region(
    north: 39.98437,
    east: 116.31863,
    south: 39.97837,
    west: 116.31363,
  );

  AMapController? _controller;
  var restricted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapRestrictionPage.title),
        centerTitle: true,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('限制区域'),
              Switch(
                value: restricted,
                onChanged: (value) {
                  final c = _controller;
                  if (c == null) return;
                  setState(() {
                    restricted = value;
                    if (value) {
                      c.setRestrictRegion(restrictedRegion);
                    } else {
                      c.removeRestrictRegion();
                    }
                  });
                },
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
              restricted
                  ? '地图中心与视野被限制在预设矩形内，不可拖出该区域。'
                  : '未限制：可自由拖动地图。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
              onMapCreated: (c) => setState(() => _controller = c),
            ),
          ),
        ],
      ),
    );
  }
}
