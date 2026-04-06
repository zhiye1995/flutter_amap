import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

/// 地图多实例页面 — 模仿官方 Android Demo UI
class TwoMapPage extends StatefulWidget {
  const TwoMapPage({super.key});

  static const title = '地图多实例';

  @override
  State<TwoMapPage> createState() => _TwoMapPageState();
}

class _TwoMapPageState extends State<TwoMapPage> {
  // 定义两张地图通用的初始化位置
  final CameraPosition _initPosition = CameraPosition(
    position: Position(latitude: 39.984120, longitude: 116.307484),
    zoom: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TwoMapPage.title),
        centerTitle: true,
      ),
      // 类似 Android 中垂直布局配合 layout_weight="1"
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: _initPosition,
              showIndoorMap: true,
              compassControlEnabled: true,
              scaleControlEnabled: true,
              geolocationControlEnabled: true,
              showUserLocation: true,
            ),
          ),
          const Divider(height: 2, thickness: 2, color: Colors.blueAccent),
          Expanded(
            child: AMapWidget(
              initCameraPosition: _initPosition,
              showIndoorMap: true,
              compassControlEnabled: true,
              scaleControlEnabled: true,
              geolocationControlEnabled: true,
              showUserLocation: true,
            ),
          ),
        ],
      ),
    );
  }
}
