import 'package:flutter/foundation.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 地图事件回调页面（UI 与行为对齐官方 Android Demo `EventsActivity`：
/// 地图 + 三块文案：单击/长按、相机变化、触摸屏幕坐标）
class MapEventsPage extends StatefulWidget {
  /// 地图事件回调页面构造函数
  const MapEventsPage({super.key});

  /// 地图事件回调页面标题
  static const title = '地图事件回调';

  @override
  State<MapEventsPage> createState() => _MapEventsPageState();
}

class _MapEventsPageState extends State<MapEventsPage> {
  /// 与官方 Demo `tap_text` 对应
  String _tapText = '';

  /// 与官方 Demo `camera_text` 对应
  String _cameraText = '';

  /// 与官方 Demo `touch_text` 对应（屏幕坐标，相对地图区域）
  String _touchText = '';

  void _logDebug(String tag, Object? detail) {
    if (kDebugMode) {
      debugPrint('$tag: $detail');
    }
  }

  String _formatCameraPosition(CameraPosition c) {
    final p = c.position;
    final target = p != null ? 'LatLng(${p.latitude}, ${p.longitude})' : 'null';
    return 'CameraPosition(bearing: ${c.heading}, target: $target, tilt: ${c.skew}, zoom: ${c.zoom})';
  }

  void _onPointerEvent(PointerEvent event, String phase) {
    final p = event.localPosition;
    setState(() {
      _touchText =
          '触摸事件：屏幕位置 ${p.dx.toStringAsFixed(1)} ${p.dy.toStringAsFixed(1)} ($phase)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(MapEventsPage.title)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (e) => _onPointerEvent(e, 'down'),
                    onPointerMove: (e) => _onPointerEvent(e, 'move'),
                    onPointerUp: (e) => _onPointerEvent(e, 'up'),
                    child: AMapWidget(
                      initCameraPosition: CameraPosition(
                        position: Position(
                            latitude: 39.984120, longitude: 116.307484),
                        zoom: 17.2,
                      ),
                      onMapInitComplete: () {
                        _logDebug('onMapInitComplete', '');
                      },
                      onMapCompleted: () {
                        _logDebug('onMapCompleted', '');
                      },
                      onMapPress: (position) {
                        setState(() {
                          _tapText =
                              'tapped, point=${position.latitude}, ${position.longitude}';
                        });
                        _logDebug('onMapPress', position.encode());
                      },
                      onMapDoublePress: (position) {
                        _logDebug('onMapDoublePress', position.encode());
                      },
                      onMapRightPress: (position) {
                        _logDebug('onMapRightPress', position.encode());
                      },
                      onMapLongPress: (position) {
                        setState(() {
                          _tapText =
                              'long pressed, point=${position.latitude}, ${position.longitude}';
                        });
                        _logDebug('onMapLongPress', position.encode());
                      },
                      onCameraChange: (cameraPosition) {
                        setState(() {
                          _cameraText =
                              'onCameraChange:${_formatCameraPosition(cameraPosition)}';
                        });
                        _logDebug('onCameraChange', cameraPosition.encode());
                      },
                      onCameraChangeStart: (cameraPosition) {
                        _logDebug(
                            'onCameraChangeStart', cameraPosition.encode());
                      },
                      onCameraChangeFinish: (cameraPosition) {
                        setState(() {
                          _cameraText =
                              'onCameraChangeFinish:${_formatCameraPosition(cameraPosition)}';
                        });
                        _logDebug(
                            'onCameraChangeFinish', cameraPosition.encode());
                        // 官方 Android Demo 在 onCameraChangeFinish 末尾用投影可视区域判断
                        // Constants.SHANGHAI(31.238068, 121.501654) 是否在当前视野内并 Toast。
                        // 本插件未暴露 getVisibleRegion 等价能力，故不实现该 Toast。
                      },
                      onMapMoveStart: (position) {
                        _logDebug('onMapMoveStart', position.encode());
                      },
                      onMapMove: (position) {
                        _logDebug('onMapMove', position.encode());
                      },
                      onMapMoveEnd: (position) {
                        _logDebug('onMapMoveEnd', position.encode());
                      },
                      onMapResized: (size) {
                        _logDebug('onMapResized', size.encode());
                      },
                      onZoomChange: (zoom) {
                        _logDebug('onZoomChange', zoom);
                      },
                      onZoomChangeStart: (zoom) {
                        _logDebug('onZoomChangeStart', zoom);
                      },
                      onZoomChangeEnd: (zoom) {
                        _logDebug('onZoomChangeEnd', zoom);
                      },
                      onRotateChange: (rotate) {
                        _logDebug('onRotateChange', rotate);
                      },
                      onRotateChangeStart: (rotate) {
                        _logDebug('onRotateChangeStart', rotate);
                      },
                      onRotateChangeEnd: (rotate) {
                        _logDebug('onRotateChangeEnd', rotate);
                      },
                      onMouseMove: (position) {
                        _logDebug('onMouseMove', position.encode());
                      },
                      onMouseWheel: (zoom) {
                        _logDebug('onMouseWheel', zoom);
                      },
                      onMouseOver: (position) {
                        _logDebug('onMouseOver', position.encode());
                      },
                      onMouseOut: (position) {
                        _logDebug('onMouseOut', position.encode());
                      },
                      onMouseUp: (position) {
                        _logDebug('onMouseUp', position.encode());
                      },
                      onMouseDown: (position) {
                        _logDebug('onMouseDown', position.encode());
                      },
                      onDragStart: (position) {
                        _logDebug('onDragStart', position.encode());
                      },
                      onDragging: (position) {
                        _logDebug('onDragging', position.encode());
                      },
                      onDragEnd: (position) {
                        _logDebug('onDragEnd', position.encode());
                      },
                      onTouchStart: (position) {
                        _logDebug('onTouchStart', position.encode());
                      },
                      onTouching: (position) {
                        _logDebug('onTouching', position.encode());
                      },
                      onTouchEnd: (position) {
                        _logDebug('onTouchEnd', position.encode());
                      },
                      onPoiClick: (poi) {
                        _logDebug('onPoiClick', poi.encode());
                      },
                      onMarkerClick: (markerId) {
                        _logDebug('onMarkerClick', markerId);
                      },
                      onMarkerDragStart: (markerId, position) {
                        _logDebug('onMarkerDragStart',
                            '$markerId, ${position.encode()}');
                      },
                      onMarkerDrag: (markerId, position) {
                        _logDebug(
                            'onMarkerDrag', '$markerId, ${position.encode()}');
                      },
                      onMarkerDragEnd: (markerId, position) {
                        _logDebug('onMarkerDragEnd',
                            '$markerId, ${position.encode()}');
                      },
                      onUserLocationChange: (location) {
                        _logDebug('onUserLocationChange', location.encode());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          _EventInfoPanel(
            tapText: _tapText,
            cameraText: _cameraText,
            touchText: _touchText,
          ),
        ],
      ),
    );
  }
}

/// 底部信息区，对应官方布局中 `tap_text` / `camera_text` / `touch_text`。
class _EventInfoPanel extends StatelessWidget {
  const _EventInfoPanel({
    required this.tapText,
    required this.cameraText,
    required this.touchText,
  });

  final String tapText;
  final String cameraText;
  final String touchText;

  static const _mono = TextStyle(
    fontSize: 11,
    height: 1.25,
    fontFamily: 'monospace',
  );

  static const _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      elevation: 4,
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('单击 / 长按', style: _labelStyle),
              const SizedBox(height: 2),
              Text(
                tapText.isEmpty ? '（等待地图点击或长按）' : tapText,
                style: _mono,
              ),
              const SizedBox(height: 10),
              const Text('相机', style: _labelStyle),
              const SizedBox(height: 2),
              Text(
                cameraText.isEmpty ? '（拖动或缩放地图以触发）' : cameraText,
                style: _mono,
              ),
              const SizedBox(height: 10),
              const Text('触摸', style: _labelStyle),
              const SizedBox(height: 2),
              Text(
                touchText.isEmpty
                    ? '（在地图区域滑动；部分平台地图为 PlatformView 时可能无回调）'
                    : touchText,
                style: _mono,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
