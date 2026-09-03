import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 平滑移动：Android 对齐官方 `SmoothMoveMarker`，iOS 使用原生计时插值对齐总时长。
class SmoothMovePage extends StatefulWidget {
  const SmoothMovePage({super.key});

  static const title = '平滑移动';

  @override
  State<SmoothMovePage> createState() => _SmoothMovePageState();
}

class _SmoothMovePageState extends State<SmoothMovePage> {
  static const _markerId = 'smooth_move_marker';
  static const _lineId = 'smooth_move_line';
  static const _duration = Duration(seconds: 8);

  static final List<Position> _points = <Position>[
    Position(latitude: 39.997761, longitude: 116.478935),
    Position(latitude: 39.997825, longitude: 116.478939),
    Position(latitude: 39.998549, longitude: 116.478912),
    Position(latitude: 39.998549, longitude: 116.478912),
    Position(latitude: 39.998555, longitude: 116.478998),
    Position(latitude: 39.998555, longitude: 116.478998),
    Position(latitude: 39.99856, longitude: 116.479282),
    Position(latitude: 39.998528, longitude: 116.479658),
    Position(latitude: 39.998453, longitude: 116.480151),
    Position(latitude: 39.998302, longitude: 116.480784),
    Position(latitude: 39.998302, longitude: 116.480784),
    Position(latitude: 39.998184, longitude: 116.481149),
    Position(latitude: 39.997997, longitude: 116.481573),
    Position(latitude: 39.997846, longitude: 116.481863),
    Position(latitude: 39.997718, longitude: 116.482072),
    Position(latitude: 39.997718, longitude: 116.482362),
    Position(latitude: 39.998935, longitude: 116.483633),
    Position(latitude: 39.998968, longitude: 116.48367),
    Position(latitude: 39.999861, longitude: 116.484648),
  ];

  AMapController? _controller;
  var _ready = false;
  var _moving = false;
  var _paused = false;
  var _showStaticMarker = true;

  StreamSubscription<SmoothMoveMarkerCompleteEvent>? _smoothMoveCompletedSub;
  StreamSubscription<SmoothMoveMarkerProgressEvent>? _smoothMoveProgressSub;
  double _progress = 0;
  double _remainingDistance = 0;

  @override
  void dispose() {
    _smoothMoveCompletedSub?.cancel();
    _smoothMoveProgressSub?.cancel();
    _controller?.stopSmoothMoveMarker(_markerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SmoothMovePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _points.first,
                zoom: 17,
              ),
              polylines: <Polyline>{
                Polyline(
                  id: _lineId,
                  points: _points,
                  color: const Color(0xFF3F8CFF),
                  width: 10,
                ),
              },
              markers: _markers,
              onMapCreated: _onMapCreated,
            ),
          ),
          SafeArea(top: false, child: _buildPanel()),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    if (!_showStaticMarker) return const <Marker>{};
    return <Marker>{_buildCarMarker(_points.first)};
  }

  Widget _buildPanel() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _ready ? '参考高德 JS API 轨迹回放示例，使用 car.png 沿蓝色轨迹移动。' : '地图加载中...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_moving) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 4),
              Text(
                '进度 ${(_progress * 100).toStringAsFixed(0)}% · '
                '剩余 ${_remainingDistance.toStringAsFixed(0)} 米',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: !_ready || _moving ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始移动'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !_ready || !_moving || _paused ? null : _pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !_ready || !_moving || !_paused ? null : _resume,
                    icon: const Icon(Icons.play_circle),
                    label: const Text('继续'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !_ready || !_moving ? null : _stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapCreated(AMapController controller) async {
    _controller = controller;
    await _smoothMoveCompletedSub?.cancel();
    _smoothMoveCompletedSub = controller.onSmoothMoveMarkerCompleted.listen((
      event,
    ) {
      if (event.value == _markerId) _onMoveCompleted();
    });
    await _smoothMoveProgressSub?.cancel();
    _smoothMoveProgressSub = controller.onSmoothMoveMarkerProgress.listen((
      event,
    ) {
      if (!mounted || event.value != _markerId) return;
      setState(() {
        _progress = event.progress;
        _remainingDistance = event.remainingDistance;
      });
    });
    await controller.waitForMapCompleted();
    if (!mounted || _controller != controller) return;
    controller.moveCameraToFitPosition(
      _points,
      EdgePadding(left: 160, top: 80, right: 160, bottom: 80),
      const Duration(milliseconds: 300),
    );
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _start() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      _showStaticMarker = false;
      _progress = 0;
      _remainingDistance = 0;
    });
    await controller.startSmoothMoveMarker(
      marker: _buildCarMarker(_points.first),
      points: _points,
      duration: _duration,
    );
    if (!mounted) return;
    setState(() {
      _moving = true;
      _paused = false;
    });
    // context.snackBar('已开始平滑移动');
  }

  Future<void> _pause() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.pauseSmoothMoveMarker(_markerId);
    if (!mounted) return;

    setState(() => _paused = true);
    // context.snackBar('已暂停平滑移动');
  }

  Future<void> _resume() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.resumeSmoothMoveMarker(_markerId);
    if (!mounted) return;

    setState(() => _paused = false);
    // context.snackBar('已继续平滑移动');
  }

  Future<void> _stop() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.stopSmoothMoveMarker(_markerId);
    if (!mounted) return;

    setState(() {
      _moving = false;
      _paused = false;
      _showStaticMarker = true;
      _progress = 0;
      _remainingDistance = 0;
    });
    // context.snackBar('已停止平滑移动');
  }

  void _onMoveCompleted() {
    if (!_moving) return;
    if (mounted) {
      setState(() {
        _moving = false;
        _paused = false;
        _showStaticMarker = false;
        _progress = 1;
        _remainingDistance = 0;
      });
    }
  }

  Marker _buildCarMarker(Position position) {
    const scale = 1.7;
    return Marker(
      id: _markerId,
      position: position,
      bitmap: Bitmap(
        asset: 'assets/car.png',
        size: Size(width: 26 * scale, height: 52 * scale),
      ),
      anchor: Anchor(x: 0.5, y: 0.5),
      title: '平滑移动',
      snippet: '参考 Marker.moveAlong 轨迹回放',
    );
  }
}
