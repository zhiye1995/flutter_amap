import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

import 'package:flutter_amap_example/core/utils/utils.dart';

final _mapCenter = Position(latitude: 39.984120, longitude: 116.307484);
final _linePadding = EdgePadding(top: 80, right: 60, bottom: 120, left: 60);

/// Polylines 功能：普通折线的添加、删除、样式更新，以及地图点击追加路径点。
class PolylinesPage extends StatefulWidget {
  const PolylinesPage({super.key});

  static const title = 'Polylines功能';

  @override
  State<PolylinesPage> createState() => _PolylinesPageState();
}

class _PolylinesPageState extends State<PolylinesPage> {
  static const _lineId = 'polyline_basic_demo';

  AMapController? _controller;
  var _ready = false;
  var _visible = true;
  var _wide = false;
  var _red = false;
  var _points = <Position>[
    Position(latitude: 39.984080, longitude: 116.305260),
    Position(latitude: 39.984520, longitude: 116.306240),
    Position(latitude: 39.983830, longitude: 116.307600),
    Position(latitude: 39.984260, longitude: 116.308760),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PolylinesPage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition:
                  CameraPosition(position: _mapCenter, zoom: 16.4),
              onMapCreated: _bootstrap,
              onMapPress: _appendPoint,
              onPoiClick: (poi) => _appendPoint(poi.position),
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _ready ? '点地图追加折线节点，当前 ${_points.length} 个点。' : '地图加载中...',
              children: [
                FilledButton(
                  onPressed: !_ready ? null : _toggleVisible,
                  child: Text(_visible ? '移除折线' : '添加折线'),
                ),
                FilledButton(
                  onPressed: !_ready || !_visible ? null : _toggleWidth,
                  child: Text(_wide ? '细线' : '粗线'),
                ),
                FilledButton(
                  onPressed: !_ready || !_visible ? null : _toggleColor,
                  child: Text(_red ? '蓝色' : '红色'),
                ),
                OutlinedButton(
                  onPressed: !_ready ? null : _reset,
                  child: const Text('重置'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;
    await _draw();
    c.moveCameraToFitPosition(
        _points, _linePadding, const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _ready = true);
      context.snackBar('点击地图空白处或 POI，可把点追加到折线尾部。');
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null || !_visible || _points.length < 2) return;
    await c.addPolyline(
      Polyline(
        id: _lineId,
        points: _points,
        color: _red ? const Color(0xFFE53935) : const Color(0xFF1976D2),
        width: _wide ? 18 : 10,
      ),
    );
  }

  Future<void> _replaceLine() async {
    final c = _controller;
    if (c == null) return;
    await c.removePolyline(_lineId);
    await _draw();
  }

  Future<void> _appendPoint(Position position) async {
    if (!_ready || !_visible) return;
    setState(() => _points = [..._points, position]);
    await _replaceLine();
  }

  Future<void> _toggleVisible() async {
    final c = _controller;
    if (c == null) return;
    setState(() => _visible = !_visible);
    if (_visible) {
      await _draw();
    } else {
      await c.removePolyline(_lineId);
    }
  }

  Future<void> _toggleWidth() async {
    setState(() => _wide = !_wide);
    await _replaceLine();
  }

  Future<void> _toggleColor() async {
    setState(() => _red = !_red);
    await _replaceLine();
  }

  Future<void> _reset() async {
    setState(() {
      _visible = true;
      _wide = false;
      _red = false;
      _points = <Position>[
        Position(latitude: 39.984080, longitude: 116.305260),
        Position(latitude: 39.984520, longitude: 116.306240),
        Position(latitude: 39.983830, longitude: 116.307600),
        Position(latitude: 39.984260, longitude: 116.308760),
      ];
    });
    await _replaceLine();
  }
}

/// 绘制多彩线：同一条折线按线段设置不同颜色，并支持渐变模式。
class MultiColorPolylinePage extends StatefulWidget {
  const MultiColorPolylinePage({super.key});

  static const title = '绘制多彩线';

  @override
  State<MultiColorPolylinePage> createState() => _MultiColorPolylinePageState();
}

class _MultiColorPolylinePageState extends State<MultiColorPolylinePage> {
  static const _lineId = 'polyline_multicolor_demo';

  AMapController? _controller;
  var _ready = false;
  var _gradient = false;

  final _points = <Position>[
    Position(latitude: 39.982870, longitude: 116.304980),
    Position(latitude: 39.984000, longitude: 116.305920),
    Position(latitude: 39.983360, longitude: 116.307160),
    Position(latitude: 39.984620, longitude: 116.308080),
    Position(latitude: 39.983920, longitude: 116.309360),
  ];

  final _colors = const <Color>[
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(MultiColorPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition:
                  CameraPosition(position: _mapCenter, zoom: 16.2),
              onMapCreated: _bootstrap,
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: _gradient ? '渐变多彩线：颜色在线段之间平滑过渡。' : '分段多彩线：每一段使用一个独立颜色。',
              children: [
                for (final color in _colors) _ColorDot(color: color),
                FilledButton(
                  onPressed: !_ready ? null : _toggleGradient,
                  child: Text(_gradient ? '切换为分段' : '切换为渐变'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;
    await _draw();
    c.moveCameraToFitPosition(
        _points, _linePadding, const Duration(milliseconds: 300));
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await c.removePolyline(_lineId);
    await c.addPolyline(
      Polyline(
        id: _lineId,
        points: _points,
        color: _colors.first,
        colors: _colors,
        gradient: _gradient,
        width: 16,
      ),
    );
  }

  Future<void> _toggleGradient() async {
    setState(() => _gradient = !_gradient);
    await _draw();
  }
}

/// 绘制大地曲线：同一组远距离点分别以普通折线和大地曲线展示，便于观察曲率差异。
class GeodesicPolylinePage extends StatefulWidget {
  const GeodesicPolylinePage({super.key});

  static const title = '绘制大地曲线';

  @override
  State<GeodesicPolylinePage> createState() => _GeodesicPolylinePageState();
}

class _GeodesicPolylinePageState extends State<GeodesicPolylinePage> {
  static const _straightId = 'polyline_straight_compare';
  static const _geodesicId = 'polyline_geodesic_demo';

  AMapController? _controller;
  var _ready = false;
  var _showCompare = true;

  final _points = <Position>[
    Position(latitude: 39.904211, longitude: 116.407395), // 北京
    Position(latitude: 31.230416, longitude: 121.473701), // 上海
    Position(latitude: 22.543099, longitude: 114.057868), // 深圳
    Position(latitude: 35.689487, longitude: 139.691711), // 东京
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(GeodesicPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: Position(latitude: 31.8, longitude: 123.0),
                zoom: 4.2,
              ),
              onMapCreated: _bootstrap,
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title: '橙色为大地曲线；蓝色为普通折线对比，远距离航线弯曲更明显。',
              children: [
                const _LegendDot(color: Color(0xFFFF6F00), label: '大地曲线'),
                if (_showCompare)
                  const _LegendDot(color: Color(0xFF1976D2), label: '普通折线'),
                FilledButton(
                  onPressed: !_ready ? null : _toggleCompare,
                  child: Text(_showCompare ? '隐藏普通线' : '显示普通线'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;
    _addCityMarkers(c);
    await _draw();
    c.moveCameraToFitPosition(
        _points, _linePadding, const Duration(milliseconds: 300));
    if (mounted) setState(() => _ready = true);
  }

  void _addCityMarkers(AMapController c) {
    const names = ['北京', '上海', '深圳', '东京'];
    for (var i = 0; i < _points.length; i++) {
      c.addMarker(
        Marker(
          id: 'geodesic_city_$i',
          position: _points[i],
          title: names[i],
          snippet: '大地曲线节点',
        ),
      );
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await c.removePolyline(_straightId);
    await c.removePolyline(_geodesicId);
    if (_showCompare) {
      await c.addPolyline(
        Polyline(
          id: _straightId,
          points: _points,
          color: const Color(0x991976D2),
          width: 8,
        ),
      );
    }
    await c.addPolyline(
      Polyline(
        id: _geodesicId,
        points: _points,
        color: const Color(0xFFFF6F00),
        width: 10,
        geodesic: true,
      ),
    );
  }

  Future<void> _toggleCompare() async {
    setState(() => _showCompare = !_showCompare);
    await _draw();
  }
}

/// 绘制弧线：起点、途经点、终点三点决定圆弧形状。
class ArcPolylinePage extends StatefulWidget {
  const ArcPolylinePage({super.key});

  static const title = '绘制弧线';

  @override
  State<ArcPolylinePage> createState() => _ArcPolylinePageState();
}

class _ArcPolylinePageState extends State<ArcPolylinePage> {
  static const _arcId = 'arc_demo';
  static const _referenceId = 'arc_reference_line';

  AMapController? _controller;
  var _ready = false;
  var _useNorthPassed = true;

  final _start = Position(latitude: 39.982950, longitude: 116.304900);
  final _northPassed = Position(latitude: 39.987050, longitude: 116.307200);
  final _southPassed = Position(latitude: 39.981200, longitude: 116.307200);
  final _end = Position(latitude: 39.983050, longitude: 116.310200);

  Position get _passed => _useNorthPassed ? _northPassed : _southPassed;

  List<Position> get _fitPoints => [_start, _northPassed, _southPassed, _end];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ArcPolylinePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition:
                  CameraPosition(position: _mapCenter, zoom: 15.8),
              onMapCreated: _bootstrap,
            ),
          ),
          SafeArea(
            top: false,
            child: _Panel(
              title:
                  _useNorthPassed ? '当前使用北侧途经点，弧线向上拱起。' : '当前使用南侧途经点，弧线向下拱起。',
              children: [
                const _LegendDot(color: Color(0xFFE53935), label: 'Arc'),
                const _LegendDot(color: Color(0x661976D2), label: '三点参考线'),
                FilledButton(
                  onPressed: !_ready ? null : _togglePassedPoint,
                  child: const Text('切换途经点'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bootstrap(AMapController c) async {
    setState(() => _controller = c);
    await c.waitForMapCompleted();
    if (!mounted || _controller != c) return;
    _addMarkers(c);
    await _draw();
    c.moveCameraToFitPosition(
        _fitPoints, _linePadding, const Duration(milliseconds: 300));
    if (mounted) setState(() => _ready = true);
  }

  void _addMarkers(AMapController c) {
    final markers = <(String, String, Position)>[
      ('arc_start', '起点', _start),
      ('arc_passed_north', '北侧途经点', _northPassed),
      ('arc_passed_south', '南侧途经点', _southPassed),
      ('arc_end', '终点', _end),
    ];
    for (final (id, title, position) in markers) {
      c.addMarker(Marker(id: id, position: position, title: title));
    }
  }

  Future<void> _draw() async {
    final c = _controller;
    if (c == null) return;
    await c.removeArc(_arcId);
    await c.removePolyline(_referenceId);
    await c.addPolyline(
      Polyline(
        id: _referenceId,
        points: [_start, _passed, _end],
        color: const Color(0x661976D2),
        width: 6,
      ),
    );
    await c.addArc(
      Arc(
        id: _arcId,
        start: _start,
        passed: _passed,
        end: _end,
        color: const Color(0xFFE53935),
        width: 12,
      ),
    );
  }

  Future<void> _togglePassedPoint() async {
    setState(() => _useNorthPassed = !_useNorthPassed);
    await _draw();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorDot(color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
