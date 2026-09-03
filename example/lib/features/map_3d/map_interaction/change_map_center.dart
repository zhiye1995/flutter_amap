import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 改变地图中心点 — 行为对齐高德 Android_3D_Demo `CameraActivity` 中
/// 预设视点（中关村 / 陆家嘴）、动画开关与方恒参考点 Marker。
/// 像素级 scrollBy、停止动画等见「地图动画效果」页。
class ChangeMapCenterPage extends StatefulWidget {
  const ChangeMapCenterPage({super.key});

  static const title = '改变地图中心点';

  @override
  State<ChangeMapCenterPage> createState() => _ChangeMapCenterPageState();
}

class _ChangeMapCenterPageState extends State<ChangeMapCenterPage> {
  /// 与官方 Demo `Constants.FANGHENG` 一致
  static final _fangheng = Position(latitude: 39.989614, longitude: 116.481763);

  /// `Constants.ZHONGGUANCUN`，CameraPosition(zoom=18, tilt=0, bearing=30)
  static final _zhongguancun = CameraPosition(
    position: Position(latitude: 39.983456, longitude: 116.315495),
    zoom: 18,
    heading: 30,
    skew: 0,
  );

  /// `Constants.SHANGHAI`（陆家嘴示例），CameraPosition(zoom=18, tilt=30, bearing=0)
  static final _lujiazui = CameraPosition(
    position: Position(latitude: 31.238068, longitude: 121.501654),
    zoom: 18,
    heading: 0,
    skew: 30,
  );

  static const _fanghengMarkerId = 'demo_fangheng';

  late AMapController _controller;
  var _animated = false;
  var _fanghengMarkerAdded = false;

  Future<void> _goZhongguancun() async {
    final duration = _animated ? const Duration(milliseconds: 1000) : null;
    await _controller.moveCamera(_zhongguancun, duration);
  }

  Future<void> _goLujiazui() async {
    final duration = _animated ? const Duration(milliseconds: 1000) : null;
    await _controller.moveCamera(_lujiazui, duration);
    if (!mounted || duration == null) {
      return;
    }
    // LoadingUtil.showSuccess('Animation to 陆家嘴 complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ChangeMapCenterPage.title),
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
            top: 20,
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ElevatedButton(
                    onPressed: _goZhongguancun,
                    child: const Text('去中关村'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ElevatedButton(
                    onPressed: _goLujiazui,
                    child: const Text('去陆家嘴'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              '说明：像素平移与「停止动画」见「地图动画效果」示例页。',
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
