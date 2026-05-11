import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

/// 地图初始化设置页面（地图全屏 + Stack 浮层；右上角 UI 与 [ShowMapPage] 地图类型按钮组一致）
class MapSettingPage extends StatefulWidget {
  /// 地图初始化设置页面构造函数
  const MapSettingPage({super.key});

  /// 地图初始化设置页面标题
  static const title = '地图初始化设置';

  @override
  State<MapSettingPage> createState() => _MapSettingPageState();
}

class _MapSettingPageState extends State<MapSettingPage> {
  bool dragEnable = true;
  bool zoomEnable = true;
  bool tiltEnable = true;
  bool rotateEnable = true;
  bool showIndoorMap = false;

  /// 与 [ShowMapPage] 中 `_buildMapTypeButton` 视觉一致：开启为蓝底，关闭为白底
  Widget _buildSettingButton(
      String title, bool enabled, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Checkbox(value: enabled, onChanged: (value) => onPressed()),
            Text(title),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapSettingPage.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 39.984120, longitude: 116.307484),
                zoom: 17.2,
              ),
              dragEnable: dragEnable,
              zoomEnable: zoomEnable,
              tiltEnable: tiltEnable,
              rotateEnable: rotateEnable,
              showIndoorMap: showIndoorMap,
            ),
          ),
          // 右上角叠加面板：与 show_map 地图类型切换组相同结构（Positioned + Column.end + 竖排按钮）
          Positioned(
            top: 20,
            right: 12,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSettingButton(
                  '允许拖拽',
                  dragEnable,
                  () => setState(() => dragEnable = !dragEnable),
                ),
                const SizedBox(height: 8),
                _buildSettingButton(
                  '允许缩放',
                  zoomEnable,
                  () => setState(() => zoomEnable = !zoomEnable),
                ),
                const SizedBox(height: 8),
                _buildSettingButton(
                  '允许倾斜',
                  tiltEnable,
                  () => setState(() => tiltEnable = !tiltEnable),
                ),
                const SizedBox(height: 8),
                _buildSettingButton(
                  '允许旋转',
                  rotateEnable,
                  () => setState(() => rotateEnable = !rotateEnable),
                ),
                const SizedBox(height: 8),
                _buildSettingButton(
                  '室内地图',
                  showIndoorMap,
                  () => setState(() => showIndoorMap = !showIndoorMap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
