import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 显示地图页面 — 高度模仿官方 Android Demo UI
class ShowMapPage extends StatefulWidget {
  const ShowMapPage({super.key});

  static const title = '显示地图';

  @override
  State<ShowMapPage> createState() => _ShowMapPageState();
}

class _ShowMapPageState extends State<ShowMapPage> {
  MapType _mapType = MapType.standard;
  bool _customStyleEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ShowMapPage.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 底层地图
          AMapFlutter(
            initCameraPosition: CameraPosition(
              position: Position(latitude: 39.984120, longitude: 116.307484),
              zoom: 17.2,
            ),
            mapType: _mapType,
            mapStyle: _customStyleEnabled ? "amap://styles/darkblue" : "amap://styles/normal",
          ),

          // 左上角叠加面板：个性化地图开头
          Positioned(
            top: 20,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _customStyleEnabled,
                    onChanged: (value) {
                      setState(() {
                        _customStyleEnabled = value ?? false;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text(
                    '',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // 右上角叠加面板：地图类型切换组
          Positioned(
            top: 20,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMapTypeButton('标准地图', MapType.standard),
                const SizedBox(height: 8),
                _buildMapTypeButton('卫星地图', MapType.satellite),
                const SizedBox(height: 8),
                _buildMapTypeButton('夜间模式', MapType.standardNight),
                const SizedBox(height: 8),
                _buildMapTypeButton('导航模式', MapType.navi),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地图类型切换按钮
  Widget _buildMapTypeButton(String title, MapType type) {
    final isSelected = _mapType == type;
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          setState(() {
            _mapType = type;
          });
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
