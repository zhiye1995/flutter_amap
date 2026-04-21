import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import '../../../utils.dart';

/// 地图Poi点击功能页面
class PoiClickPage extends StatefulWidget {
  /// 地图Poi点击功能页面构造函数
  const PoiClickPage({super.key});

  /// 地图Poi点击功能页面标题
  static const title = '底图POI点击';

  @override
  State<PoiClickPage> createState() => _PoiClickPageState();
}

class _PoiClickPageState extends State<PoiClickPage> {
  late AMapController controller;
  Poi? _clickedPoi;
  String? _markerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.snackBar('点击底图上的兴趣点（POI）查看信息');
    });
  }

  void _onPoiClick(Poi poi) {
    setState(() {
      _clickedPoi = poi;
    });

    // 移除之前的标记
    if (_markerId != null) {
      controller.removeMarker(_markerId!);
    }

    // 添加新标记
    final String markerId = 'poi_marker_${DateTime.now().millisecondsSinceEpoch}';
    final marker = Marker(
      id: markerId,
      position: poi.position,
      bitmap: Bitmap(
        asset: "assets/map-marker.png",
      ),
    );
    
    _markerId = markerId;
    controller.addMarker(marker);
    
    // 同时也移动相机到该点
    controller.moveCamera(CameraPosition(position: poi.position, zoom: 18), const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PoiClickPage.title)),
      body: Stack(
        children: [
          AMapWidget(
            initCameraPosition: CameraPosition(
              position: Position(latitude: 39.984120, longitude: 116.307484),
              zoom: 17.2,
            ),
            onMapCreated: (controller) => this.controller = controller,
            onPoiClick: _onPoiClick,
          ),
          if (_clickedPoi != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _clickedPoi!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '经度: ${_clickedPoi!.position.longitude.toStringAsFixed(6)}\n纬度: ${_clickedPoi!.position.latitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
