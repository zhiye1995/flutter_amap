import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 地图控件加载页面
class MapControlsPage extends StatefulWidget {
  /// 地图控件加载页面构造函数
  const MapControlsPage({super.key});

  /// 地图控件加载页面标题
  static const title = '地图控件加载';

  @override
  State<MapControlsPage> createState() => _MapControlsPageState();
}

class _MapControlsPageState extends State<MapControlsPage> {
  static const compass = '指南针';
  static const scale = '比例尺';
  static const zoom = '缩放';
  static const geolocation = '定位按钮';

  static const androidSupport = [compass, scale, zoom, geolocation];
  static const iOSSupport = [compass, scale];

  AMapController? _controller;

  final _state = {
    compass: true,
    scale: true,
    zoom: true,
    geolocation: true,
  };

  List<Widget> get items {
    Iterable<String> keys = switch (PlatformUtil.platform) {
      PlatformEnum.android => androidSupport,
      PlatformEnum.ios => iOSSupport,
      PlatformEnum.unknown => [],
    };
    return keys
        .map(
          (item) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(item),
              ),
              Switch(
                value: _state[item]!,
                onChanged: (value) => setState(() => _state[item] = value),
              ),
            ],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapControlsPage.title),
        actions: [
          TextButton(
            onPressed: _controller == null
                ? null
                : () async {
                    final scalePerPixel = await _controller!.getScalePerPixel();
                    if (!context.mounted) return;
                    LoadingUtil.showToast('每像素代表 $scalePerPixel 米');
                  },
            child: const Text('获取比例尺'),
          ),
        ],
      ),
      body: AMapWidget(
        initCameraPosition: CameraPosition(
          position: Position(latitude: 39.984120, longitude: 116.307484),
          zoom: 17.2,
        ),
        compassControlEnabled: _state[compass]!,
        scaleControlEnabled: _state[scale]!,
        zoomControlEnabled: _state[zoom]!,
        geolocationControlEnabled: _state[geolocation]!,
        onMapCreated: (controller) {
          setState(() {
            _controller = controller;
          });
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }
}
