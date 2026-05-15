import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class PolygonContainsPage extends StatefulWidget {
  const PolygonContainsPage({super.key});

  static const title = '点是否在多边形内';

  @override
  State<PolygonContainsPage> createState() => _PolygonContainsPageState();
}

class _PolygonContainsPageState extends State<PolygonContainsPage> {
  static final _center = Position(latitude: 39.908722, longitude: 116.397499);

  final _polygon = <Position>[
    Position(latitude: 39.914760, longitude: 116.391210),
    Position(latitude: 39.915420, longitude: 116.404480),
    Position(latitude: 39.906100, longitude: 116.405380),
    Position(latitude: 39.904880, longitude: 116.394260),
  ];

  AMapController? _controller;
  Position? _testPoint;
  bool? _contains;
  var _ready = false;
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PolygonContainsPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(position: _center, zoom: 15),
              markers: _markers,
              polygons: _polygons,
              onMapCreated: _onMapCreated,
              onMapPress: _checkPoint,
              onPoiClick: (poi) => _checkPoint(poi.position),
            ),
          ),
          SafeArea(top: false, child: _buildPanel()),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      for (var i = 0; i < _polygon.length; i++)
        Marker(
          id: 'polygon_vertex_$i',
          position: _polygon[i],
          title: '顶点 ${i + 1}',
        ),
      if (_testPoint != null)
        Marker(
          id: 'polygon_test_point',
          position: _testPoint!,
          title: _contains == true ? '在多边形内' : '不在多边形内',
          snippet: _formatPosition(_testPoint!),
        ),
    };
  }

  Set<Polygon> get _polygons {
    return <Polygon>{
      Polygon(
        id: 'polygon_contains_area',
        points: _polygon,
        strokeWidth: 8,
        strokeColor: const Color(0xFF1976D2),
        fillColor: const Color(0x331976D2),
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
              _resultTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _contains == false
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
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
                  onPressed: !_ready || _loading
                      ? null
                      : () => _checkPoint(_center),
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('检测中心点'),
                ),
                OutlinedButton.icon(
                  onPressed: _testPoint == null ? null : _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('清除点'),
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
    controller.moveCameraToFitPosition(
      _polygon,
      EdgePadding(top: 80, right: 56, bottom: 220, left: 56),
      const Duration(milliseconds: 300),
    );
    if (mounted) context.snackBar('点击地图检测该点是否在蓝色多边形内。');
  }

  Future<void> _checkPoint(Position point) async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _loading = true);
    try {
      final contains = await controller.containsCoordinate(point, _polygon);
      if (!mounted) return;
      setState(() {
        _testPoint = point;
        _contains = contains;
      });
    } on Object catch (e) {
      LoadingUtil.showError('多边形判断失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clear() {
    setState(() {
      _testPoint = null;
      _contains = null;
    });
  }

  String get _resultTitle {
    if (!_ready) return '地图加载中';
    if (_contains == null) return '等待检测';
    return _contains! ? '在多边形内' : '不在多边形内';
  }

  String get _statusText {
    if (_testPoint == null) return '点击地图任意位置，调用插件判断点与多边形关系。';
    return '检测点：${_formatPosition(_testPoint!)}';
  }
}

String _formatPosition(Position position) {
  return '${position.latitude.toStringAsFixed(6)}, '
      '${position.longitude.toStringAsFixed(6)}';
}
