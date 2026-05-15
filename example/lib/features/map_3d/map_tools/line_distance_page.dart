import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class LineDistancePage extends StatefulWidget {
  const LineDistancePage({super.key});

  static const title = '两点间距离';

  @override
  State<LineDistancePage> createState() => _LineDistancePageState();
}

class _LineDistancePageState extends State<LineDistancePage> {
  static final _center = Position(latitude: 39.908722, longitude: 116.397499);
  static final _defaultStart = Position(
    latitude: 39.908722,
    longitude: 116.397499,
  );
  static final _defaultEnd = Position(
    latitude: 39.914884,
    longitude: 116.403883,
  );

  AMapController? _controller;
  var _points = <Position>[_defaultStart, _defaultEnd];
  double? _distance;
  var _ready = false;
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(LineDistancePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(position: _center, zoom: 15),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              onMapPress: _addPoint,
              onPoiClick: (poi) => _addPoint(poi.position),
            ),
          ),
          SafeArea(top: false, child: _buildPanel()),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      for (var i = 0; i < _points.length; i++)
        Marker(
          id: 'line_distance_marker_$i',
          position: _points[i],
          title: i == 0 ? '起点' : '终点',
          snippet: _formatPosition(_points[i]),
        ),
    };
  }

  Set<Polyline> get _polylines {
    if (_points.length < 2) return const <Polyline>{};
    return <Polyline>{
      Polyline(
        id: 'line_distance_line',
        points: _points,
        color: const Color(0xFF1976D2),
        width: 10,
      ),
    };
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
              _distance == null ? '等待计算' : _formatDistance(_distance!),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(_statusText),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: !_ready || _loading || _points.length < 2
                      ? null
                      : _calculate,
                  icon: const Icon(Icons.straighten),
                  label: const Text('计算距离'),
                ),
                OutlinedButton.icon(
                  onPressed: !_ready ? null : _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重置'),
                ),
                OutlinedButton.icon(
                  onPressed: _points.isEmpty ? null : _clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('清空'),
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
    await controller.waitForMapCompleted();
    if (!mounted || _controller != controller) return;
    setState(() => _ready = true);
    await _calculate();
    if (mounted) context.snackBar('点击地图设置起点和终点，超过两个点会重新开始。');
  }

  Future<void> _addPoint(Position position) async {
    setState(() {
      _points = _points.length >= 2
          ? <Position>[position]
          : [..._points, position];
      _distance = null;
    });
    if (_points.length == 2) {
      await _calculate();
    }
  }

  Future<void> _calculate() async {
    final controller = _controller;
    if (controller == null || _points.length < 2) return;
    setState(() => _loading = true);
    try {
      final distance = await controller.calculateLineDistance(
        _points.first,
        _points.last,
      );
      if (!mounted) return;
      setState(() => _distance = distance);
    } on Object catch (e) {
      LoadingUtil.showError('距离计算失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() {
      _points = <Position>[_defaultStart, _defaultEnd];
      _distance = null;
    });
    await _calculate();
  }

  void _clear() {
    setState(() {
      _points = <Position>[];
      _distance = null;
    });
  }

  String get _statusText {
    if (!_ready) return '地图加载中...';
    if (_points.isEmpty) return '点击地图选择起点。';
    if (_points.length == 1) return '已选择起点：${_formatPosition(_points.first)}';
    return '起点：${_formatPosition(_points.first)}\n'
        '终点：${_formatPosition(_points.last)}';
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(2)} km';
  return '${meters.toStringAsFixed(1)} m';
}

String _formatPosition(Position position) {
  return '${position.latitude.toStringAsFixed(6)}, '
      '${position.longitude.toStringAsFixed(6)}';
}
