import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class RoutePlanPage extends StatefulWidget {
  const RoutePlanPage({
    super.key,
    required this.type,
  });

  const RoutePlanPage.drive({super.key}) : type = RoutePlanType.drive;
  const RoutePlanPage.walk({super.key}) : type = RoutePlanType.walk;
  const RoutePlanPage.ride({super.key}) : type = RoutePlanType.ride;

  final RoutePlanType type;

  String get title {
    switch (type) {
      case RoutePlanType.drive:
        return '驾车路径规划';
      case RoutePlanType.walk:
        return '步行路径规划';
      case RoutePlanType.ride:
        return '骑行路径规划';
    }
  }

  @override
  State<RoutePlanPage> createState() => _RoutePlanPageState();
}

class _RoutePlanPageState extends State<RoutePlanPage> {
  static final _defaultStart =
      Position(latitude: 39.908722, longitude: 116.397499);
  static final _defaultEnd =
      Position(latitude: 39.989872, longitude: 116.481956);
  static final _padding = EdgePadding(top: 60, right: 60, bottom: 80, left: 60);

  final _startLatController = TextEditingController(text: '39.908722');
  final _startLngController = TextEditingController(text: '116.397499');
  final _endLatController = TextEditingController(text: '39.989872');
  final _endLngController = TextEditingController(text: '116.481956');
  final _strategyController = TextEditingController(text: '10');
  final _wayPointsController = TextEditingController();
  final _avoidRoadController = TextEditingController();

  AMapController? _controller;
  RoutePlanResult? _result;
  var _loading = false;
  var _extensions = RoutePlanExtensions.all;
  String? _errorMessage;

  @override
  void dispose() {
    _startLatController.dispose();
    _startLngController.dispose();
    _endLatController.dispose();
    _endLngController.dispose();
    _strategyController.dispose();
    _wayPointsController.dispose();
    _avoidRoadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _defaultStart,
                zoom: 11,
              ),
              markers: _markers,
              onMapCreated: (controller) => _controller = controller,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildQueryCard(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _buildErrorCard(),
                ],
                const SizedBox(height: 8),
                if (_result != null) _buildResultCard(_result!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> get _markers {
    return <Marker>{
      Marker(id: 'route_start', position: _startPosition, title: '起点'),
      Marker(id: 'route_end', position: _endPosition, title: '终点'),
    };
  }

  Widget _buildQueryCard() {
    final isDrive = widget.type == RoutePlanType.drive;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('路线参数', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _buildPositionRow('起点', _startLatController, _startLngController),
            const SizedBox(height: 10),
            _buildPositionRow('终点', _endLatController, _endLngController),
            const SizedBox(height: 10),
            TextField(
              controller: _strategyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isDrive ? '驾车策略 0-20' : '模式/策略',
                hintText: isDrive ? '10：高德默认多策略' : '0：默认',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            if (isDrive) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _wayPointsController,
                decoration: const InputDecoration(
                  labelText: '途经点（可选）',
                  hintText: 'lat,lng;lat,lng，地图 SDK 驾车最多 6 个',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _avoidRoadController,
                decoration: const InputDecoration(
                  labelText: '避让道路（可选）',
                  hintText: '仅支持一条；与避让区域同时存在时避让道路优先',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
            const SizedBox(height: 8),
            FilterChip(
              label: const Text('返回扩展信息'),
              selected: _extensions == RoutePlanExtensions.all,
              onSelected: (value) => setState(() {
                _extensions =
                    value ? RoutePlanExtensions.all : RoutePlanExtensions.base;
              }),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading ? null : _searchRoute,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.alt_route),
              label: Text(_loading ? '查询中...' : '查询并绘制路线'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openNativeNavi,
              icon: const Icon(Icons.navigation),
              label: const Text('打开原生路线规划页'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionRow(
    String label,
    TextEditingController latController,
    TextEditingController lngController,
  ) {
    return Row(
      children: [
        SizedBox(width: 42, child: Text(label)),
        Expanded(
          child: TextField(
            controller: latController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '纬度',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: lngController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '经度',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          _errorMessage!,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildResultCard(RoutePlanResult result) {
    final paths = result.paths;
    if (paths.isEmpty) {
      return const Card(child: ListTile(title: Text('未返回路线方案')));
    }
    final first = paths.first;
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('路线方案 ${paths.length} 条'),
            subtitle: Text(
              '首条：${_formatDistance(first.distance)} / '
              '${_formatDuration(first.duration)}\n'
              '策略：${first.strategy ?? '-'} '
              '红绿灯：${first.totalTrafficLights ?? 0}',
            ),
            isThreeLine: true,
          ),
          ExpansionTile(
            title: Text('路段明细（${first.steps.length}）'),
            children: [
              for (final step in first.steps.take(12))
                ListTile(
                  dense: true,
                  title: Text(step.instruction ?? step.road ?? '-'),
                  subtitle: Text(
                    '${_formatDistance(step.distance)} '
                    '${_formatDuration(step.duration)}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _searchRoute() async {
    final origin = RoutePoint(position: _startPosition, name: '起点');
    final destination = RoutePoint(position: _endPosition, name: '终点');
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = switch (widget.type) {
        RoutePlanType.drive => await AMapSearch.searchDriveRoute(
            DriveRouteQuery(
              origin: origin,
              destination: destination,
              strategy: int.tryParse(_strategyController.text.trim()) ?? 10,
              wayPoints: _parseWayPoints(),
              avoidRoad: _emptyToNull(_avoidRoadController.text),
              extensions: _extensions,
            ),
          ),
        RoutePlanType.walk => await AMapSearch.searchWalkRoute(
            WalkRouteQuery(
              origin: origin,
              destination: destination,
              mode: int.tryParse(_strategyController.text.trim()) ?? 0,
              extensions: _extensions,
            ),
          ),
        RoutePlanType.ride => await AMapSearch.searchRideRoute(
            RideRouteQuery(
              origin: origin,
              destination: destination,
              mode: int.tryParse(_strategyController.text.trim()) ?? 0,
              extensions: _extensions,
            ),
          ),
      };
      if (!mounted) return;
      setState(() => _result = result);
      await _drawRoute(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('路线规划失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _drawRoute(RoutePlanResult result) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.removePolyline('route_path');
    final points = result.paths.firstOrNull?.polyline ?? const <Position>[];
    if (points.length < 2) return;
    await controller.addPolyline(
      Polyline(
        id: 'route_path',
        points: points,
        width: 12,
        color: const Color(0xFF1976D2),
      ),
    );
    controller.moveCameraToFitPosition(
      points,
      _padding,
      const Duration(milliseconds: 300),
    );
  }

  Future<void> _openNativeNavi() {
    return AMapNavi.startNavigation(
      config: NaviConfig(
        naviType: switch (widget.type) {
          RoutePlanType.drive => NaviType.driver,
          RoutePlanType.walk => NaviType.walk,
          RoutePlanType.ride => NaviType.ride,
        },
        pageType: NaviPageType.route,
        start: NaviPoint(position: _startPosition, name: '起点'),
        end: NaviPoint(position: _endPosition, name: '终点'),
        drivingStrategy: int.tryParse(_strategyController.text.trim()) ?? 10,
        travelStrategy: int.tryParse(_strategyController.text.trim()),
      ),
    );
  }

  List<RoutePoint> _parseWayPoints() {
    final text = _wayPointsController.text.trim();
    if (text.isEmpty) return const <RoutePoint>[];
    return text
        .split(';')
        .map((part) {
          final pair = part.split(',');
          if (pair.length != 2) return null;
          final lat = double.tryParse(pair[0].trim());
          final lng = double.tryParse(pair[1].trim());
          if (lat == null || lng == null) return null;
          return RoutePoint(position: Position(latitude: lat, longitude: lng));
        })
        .whereType<RoutePoint>()
        .toList();
  }

  Position get _startPosition {
    return Position(
      latitude: double.tryParse(_startLatController.text.trim()) ??
          _defaultStart.latitude,
      longitude: double.tryParse(_startLngController.text.trim()) ??
          _defaultStart.longitude,
    );
  }

  Position get _endPosition {
    return Position(
      latitude: double.tryParse(_endLatController.text.trim()) ??
          _defaultEnd.latitude,
      longitude: double.tryParse(_endLngController.text.trim()) ??
          _defaultEnd.longitude,
    );
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '-';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes 分钟';
    return '${minutes ~/ 60}小时${minutes % 60}分钟';
  }
}
