import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 距离测量：点击地图添加测量点，使用 Marker 和 Polyline 展示累计距离。
class DistanceMeasurePage extends StatefulWidget {
  const DistanceMeasurePage({super.key});

  static const title = '距离测量';

  @override
  State<DistanceMeasurePage> createState() => _DistanceMeasurePageState();
}

class _DistanceMeasurePageState extends State<DistanceMeasurePage> {
  static final _mapCenter = Position(
    latitude: 39.908722,
    longitude: 116.397499,
  );
  static final _fitPadding = EdgePadding(
    top: 90,
    right: 56,
    bottom: 230,
    left: 56,
  );
  static const _lineId = 'distance_measure_line';

  AMapController? _controller;
  var _points = <Position>[];
  var _segmentLabelIcons = <String, _SegmentLabelIcon>{};
  var _labelGeneration = 0;
  var _ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(DistanceMeasurePage.title)),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _mapCenter,
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              onMapPress: _addPoint,
              onPoiClick: (poi) => _addPoint(poi.position),
            ),
          ),
          SafeArea(top: false, child: _buildPanel(context)),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      for (var index = 0; index < _points.length; index++)
        Marker(
          id: 'distance_measure_marker_$index',
          position: _points[index],
          title: _markerTitle(index),
          snippet: _markerSnippet(index),
        ),
      for (var index = 1; index < _points.length; index++)
        if (_segmentLabelIcons[_segmentLabelId(index)] case final icon?)
          Marker(
            id: _segmentLabelId(index),
            position: _midpoint(_points[index - 1], _points[index]),
            bitmap: Bitmap(
              bytes: icon.bytes,
              size: Size(width: icon.width, height: icon.height),
            ),
          ),
    };
  }

  Set<Polyline> get _polylines {
    if (_points.length < 2) return const <Polyline>{};
    return <Polyline>{
      Polyline(
        id: _lineId,
        points: _points,
        color: const Color(0xFF1976D2),
        width: 10,
      ),
    };
  }

  Widget _buildPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDistance(_totalDistance),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(_statusText, style: theme.textTheme.bodyMedium),
            if (_points.length >= 2) ...[
              const SizedBox(height: 8),
              Text(
                '最后一段：${_formatDistance(_lastSegmentDistance)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _ready && _points.length > 1 ? _fitPoints : null,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('适配视野'),
                ),
                OutlinedButton.icon(
                  onPressed: _points.isEmpty ? null : _undoPoint,
                  icon: const Icon(Icons.undo),
                  label: const Text('撤销'),
                ),
                OutlinedButton.icon(
                  onPressed: _points.isEmpty ? null : _clearPoints,
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
    context.snackBar('点击地图空白处或 POI 添加测量点。');
  }

  void _addPoint(Position position) {
    setState(() => _points = [..._points, position]);
    _refreshSegmentLabels();
  }

  void _undoPoint() {
    if (_points.isEmpty) return;
    setState(() => _points = _points.take(_points.length - 1).toList());
    _refreshSegmentLabels();
  }

  void _clearPoints() {
    if (_points.isEmpty) return;
    setState(() {
      _points = <Position>[];
      _segmentLabelIcons = <String, _SegmentLabelIcon>{};
    });
    _labelGeneration++;
  }

  void _fitPoints() {
    if (_points.length < 2) return;
    _controller?.moveCameraToFitPosition(
      _points,
      _fitPadding,
      const Duration(milliseconds: 300),
    );
  }

  String get _statusText {
    if (!_ready) return '地图加载中...';
    if (_points.isEmpty) return '点击地图添加起点。';
    if (_points.length == 1) return '已添加起点，请继续点击地图添加终点。';
    return '已添加 ${_points.length} 个测量点，可继续追加或撤销。';
  }

  double get _totalDistance {
    var total = 0.0;
    for (var index = 1; index < _points.length; index++) {
      total += _distanceBetween(_points[index - 1], _points[index]);
    }
    return total;
  }

  double get _lastSegmentDistance {
    if (_points.length < 2) return 0;
    return _distanceBetween(_points[_points.length - 2], _points.last);
  }

  String _markerTitle(int index) {
    if (index == 0) return '起点';
    if (index == _points.length - 1) return '终点';
    return '途经点 $index';
  }

  String _markerSnippet(int index) {
    final position = _points[index];
    final coordinate =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    if (index == 0) return coordinate;

    final segment = _distanceBetween(_points[index - 1], position);
    var total = 0.0;
    for (var i = 1; i <= index; i++) {
      total += _distanceBetween(_points[i - 1], _points[i]);
    }
    return '分段 ${_formatDistance(segment)}，累计 ${_formatDistance(total)}\n$coordinate';
  }

  Future<void> _refreshSegmentLabels() async {
    final generation = ++_labelGeneration;
    final points = List<Position>.of(_points);
    final icons = <String, _SegmentLabelIcon>{};

    for (var index = 1; index < points.length; index++) {
      final text = _formatDistance(
        _distanceBetween(points[index - 1], points[index]),
      );
      final icon = await _buildSegmentLabelIcon(text);
      if (icon != null) {
        icons[_segmentLabelId(index)] = icon;
      }
    }

    if (!mounted || generation != _labelGeneration) return;
    setState(() => _segmentLabelIcons = icons);
  }

  Future<_SegmentLabelIcon?> _buildSegmentLabelIcon(String text) async {
    const pixelRatio = 2.0;
    const horizontalPadding = 10.0;
    const verticalPadding = 5.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    final rect = Rect.fromLTWH(0, 0, width, height);
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF1976D2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    textPainter.paint(canvas, const Offset(horizontalPadding, verticalPadding));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * pixelRatio).ceil(),
      (height * pixelRatio).ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) return null;
    return _SegmentLabelIcon(bytes: bytes, width: width, height: height);
  }

  double _distanceBetween(Position start, Position end) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _radians(end.latitude - start.latitude);
    final dLon = _radians(end.longitude - start.longitude);
    final lat1 = _radians(start.latitude);
    final lat2 = _radians(end.latitude);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * earthRadiusMeters * math.asin(math.min(1.0, math.sqrt(h)));
  }

  double _radians(double degrees) => degrees * math.pi / 180.0;

  Position _midpoint(Position start, Position end) {
    return Position(
      latitude: (start.latitude + end.latitude) / 2,
      longitude: (start.longitude + end.longitude) / 2,
    );
  }

  String _segmentLabelId(int index) => 'distance_measure_segment_label_$index';

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(2)}公里';
    return '${meters.toStringAsFixed(0)}米';
  }
}

class _SegmentLabelIcon {
  const _SegmentLabelIcon({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final double width;
  final double height;
}
