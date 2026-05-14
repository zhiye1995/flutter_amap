import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

class RoutePlanPage extends StatefulWidget {
  const RoutePlanPage({super.key, required this.type});

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
  static final _defaultStart = Position(
    latitude: 29.468220,
    longitude: 106.648317,
  );
  static final _defaultEnd = Position(
    latitude: 29.437143,
    longitude: 106.486523,
  );
  static final _padding = EdgePadding(
    top: 170,
    right: 52,
    bottom: 230,
    left: 52,
  );
  static const _routeLinePrefix = 'route_path_';
  static const _brandBlue = Color(0xFF3478F6);
  static const _selectedRouteColor = Color(0xFF00B86B);
  static const _alternativeRouteColors = <Color>[
    Color(0x9990A4B8),
    Color(0x998196A8),
    Color(0x99E8590C),
    Color(0x992E7D32),
    Color(0x997B1FA2),
  ];

  final _startLatController = TextEditingController(text: '39.908722');
  final _startLngController = TextEditingController(text: '116.397499');
  final _endLatController = TextEditingController(text: '39.989872');
  final _endLngController = TextEditingController(text: '116.481956');
  final _wayPointsController = TextEditingController();
  final _avoidRoadController = TextEditingController();

  AMapController? _controller;
  Location? _lastLocation;
  LocationPickerResult? _startLocation;
  LocationPickerResult? _endLocation;
  RoutePlanResult? _result;
  final _routePolylineIds = <String>{};
  var _driveStrategy = PathPlanningStrategy.drivingMultipleRoutesDefault;
  var _selectedPathIndex = 0;
  var _loading = false;
  var _extensions = RoutePlanExtensions.all;
  String? _errorMessage;

  @override
  void dispose() {
    _startLatController.dispose();
    _startLngController.dispose();
    _endLatController.dispose();
    _endLngController.dispose();
    _wayPointsController.dispose();
    _avoidRoadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildRouteHeader(context),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AMapWidget(
                    initCameraPosition: CameraPosition(
                      position: _defaultStart,
                      zoom: 11,
                    ),
                    showUserLocation: true,
                    markers: _markers,
                    onMapPress: _selectNearestRoute,
                    onUserLocationChange: (location) {
                      _lastLocation = location;
                    },
                    onMapCreated: (controller) {
                      _controller = controller;
                      final result = _result;
                      if (result != null) {
                        _drawRoute(result, fitSelected: false);
                      }
                    },
                  ),
                ),
                Positioned(
                  left: 6,
                  bottom: 25,
                  child: _buildMapShortcutButtons(),
                ),
              ],
            ),
          ),
          SizedBox(height: 180, child: _buildBottomPanel()),
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

  bool get _isDrive => widget.type == RoutePlanType.drive;

  Widget _buildRouteHeader(BuildContext context) {
    return Material(
      color: _brandBlue,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Align(
                  alignment: .topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildRouteInputLine(
                        prefix: '从',
                        title: _startTitle,
                        position: _startPosition,
                        onTap: () => _pickPosition(isStart: true),
                      ),
                      const SizedBox(height: 10),
                      _buildRouteInputLine(
                        prefix: '到',
                        title: _endTitle,
                        position: _endPosition,
                        onTap: () => _pickPosition(isStart: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: _swapStartEnd,
                      tooltip: '交换起终点',
                      icon: const Icon(Icons.swap_vert, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _loading ? null : _searchRoute,
                      tooltip: '查询路线',
                      icon: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInputLine({
    required String prefix,
    required String title,
    required Position position,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              prefix,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapShortcutButtons() {
    return Column(
      children: [
        _buildMapButton(Icons.refresh, _searchRoute),
        const SizedBox(height: 12),
        _buildMapButton(Icons.tune, _showRouteOptions),
        const SizedBox(height: 12),
        _buildMapButton(Icons.my_location, _moveToCurrentLocation),
      ],
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return Transform.scale(
      scale: 0.82,
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: IconButton(
          onPressed: _loading ? null : onPressed,
          icon: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final result = _result;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                _buildErrorBanner(),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: result == null || result.paths.isEmpty
                    ? _buildPlanningPanel()
                    : _buildRouteResultPanel(result),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanningPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton.icon(
                onPressed: _loading ? null : _searchRoute,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.alt_route, size: 18),
                label: Text(
                  _loading ? '查询中...' : '查询路线',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrivingExtraOptions() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('更多驾车参数'),
      children: [
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
            hintText: '仅支持一条',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDrivingStrategyDropdown() {
    return DropdownButtonFormField<PathPlanningStrategy>(
      initialValue: _driveStrategy,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: '驾车策略',
        helperText:
            '${_driveStrategy.multipleRoute ? '多路线策略' : '单路线策略'}：${_driveStrategy.description}',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final strategy in PathPlanningStrategy.values)
          DropdownMenuItem<PathPlanningStrategy>(
            value: strategy,
            child: Text(
              '${strategy.displayName} · ${strategy.multipleRoute ? '多路线' : '单路线'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: _loading
          ? null
          : (value) {
              if (value == null) return;
              setState(() => _driveStrategy = value);
            },
    );
  }

  Widget _buildRouteResultPanel(RoutePlanResult result) {
    final paths = result.paths;
    final selectedIndex = _selectedIndexFor(paths.length);
    final selectedPath = paths[selectedIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _buildRoutePlanCard(
                paths[index],
                index,
                index == selectedIndex,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _routeSummary(selectedPath),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const ui.Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(fontSize: 13),
              ),
              onPressed: selectedPath.steps.isEmpty
                  ? null
                  : () => _showRouteStepDetails(selectedPath),
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text(
                '详情',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 118,
              height: 38,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _openNativeNavi,
                child: const Text('打开路线规划'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoutePlanCard(RoutePath path, int index, bool selected) {
    final color = selected ? _brandBlue : const Color(0xFFE8E8E8);
    final foreground = selected ? Colors.white : Colors.black87;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _selectRoute(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 118,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? _brandBlue : const Color(0xFFDADDE2),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              color: color,
              alignment: Alignment.center,
              child: Text(
                _pathTitle(path, index),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(path.duration),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? _brandBlue : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDistance(path.distance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? _brandBlue : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(RouteStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            child: _buildRouteStepIcon(step),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction ?? step.road ?? '-',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${step.action ?? step.assistantAction ?? '-'} · '
                  '${_formatDistance(step.distance)} · '
                  '${_formatDuration(step.duration)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRouteStepDetails(RoutePath path) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D3D8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '路段详情（${path.steps.length}）',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: '关闭',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: path.steps.length,
                    itemBuilder: (context, index) {
                      return _buildStepItem(path.steps[index]);
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _errorMessage!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }

  Future<void> _searchRoute() async {
    final origin =
        _startLocation?.toRoutePoint() ??
        RoutePoint(position: _startPosition, name: '起点');
    final destination =
        _endLocation?.toRoutePoint() ??
        RoutePoint(position: _endPosition, name: '终点');
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
            strategy: _driveStrategy,
            wayPoints: _parseWayPoints(),
            avoidRoad: _emptyToNull(_avoidRoadController.text),
            extensions: _extensions,
          ),
        ),
        RoutePlanType.walk => await AMapSearch.searchWalkRoute(
          WalkRouteQuery(
            origin: origin,
            destination: destination,
            extensions: _extensions,
          ),
        ),
        RoutePlanType.ride => await AMapSearch.searchRideRoute(
          RideRouteQuery(
            origin: origin,
            destination: destination,
            extensions: _extensions,
          ),
        ),
      };
      if (!mounted) return;
      setState(() {
        _result = result;
        _selectedPathIndex = 0;
      });
      await _drawRoute(result, fitSelected: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('路线规划失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _drawRoute(
    RoutePlanResult result, {
    bool fitSelected = true,
  }) async {
    final controller = _controller;
    if (controller == null) return;
    await _clearRouteOverlays(controller);
    final allPoints = <Position>[];
    final selectedIndex = _selectedIndexFor(result.paths.length);
    final drawOrder = <int>[
      for (var index = 0; index < result.paths.length; index++)
        if (index != selectedIndex) index,
      if (result.paths.isNotEmpty) selectedIndex,
    ];
    for (final pathIndex in drawOrder) {
      final path = result.paths[pathIndex];
      final points = _pathPoints(path);
      if (points.length < 2) continue;
      allPoints.addAll(points);
      final lineId = '$_routeLinePrefix$pathIndex';
      _routePolylineIds.add(lineId);
      final selected = pathIndex == selectedIndex;
      await controller.addPolyline(
        Polyline(
          id: lineId,
          points: points,
          width: selected ? 14 : 8,
          color: _routeColor(pathIndex, selected: selected),
        ),
      );
    }
    if (allPoints.length < 2) return;
    final selectedPoints = _pathPoints(result.paths[selectedIndex]);
    controller.moveCameraToFitPosition(
      fitSelected && selectedPoints.length >= 2 ? selectedPoints : allPoints,
      _padding,
      const Duration(milliseconds: 300),
    );
  }

  Future<void> _clearRouteOverlays(AMapController controller) async {
    for (final id in _routePolylineIds.toList()) {
      await controller.removePolyline(id);
    }
    _routePolylineIds.clear();
  }

  List<Position> _pathPoints(RoutePath path) {
    if (path.polyline.length >= 2) return path.polyline;
    return path.steps.expand((step) => step.polyline).toList();
  }

  Future<void> _selectRoute(int index) async {
    final result = _result;
    if (result == null || index < 0 || index >= result.paths.length) return;
    if (index != _selectedPathIndex) {
      setState(() => _selectedPathIndex = index);
    }
    await _drawRoute(result);
  }

  Future<void> _selectNearestRoute(Position tapPosition) async {
    final result = _result;
    if (result == null || result.paths.length < 2) return;
    var nearestIndex = -1;
    var nearestDistance = double.infinity;
    for (var index = 0; index < result.paths.length; index++) {
      final points = _pathPoints(result.paths[index]);
      if (points.length < 2) continue;
      final distance = _distanceToPolylineMeters(tapPosition, points);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = index;
      }
    }
    if (nearestIndex < 0) return;
    final scale = await _controller?.getScalePerPixel();
    final toleranceMeters = math.max(30.0, (scale ?? 8.0) * 26.0);
    if (nearestDistance <= toleranceMeters) {
      await _selectRoute(nearestIndex);
    }
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
        start:
            _startLocation?.toNaviPoint() ??
            NaviPoint(position: _startPosition, name: '起点'),
        end:
            _endLocation?.toNaviPoint() ??
            NaviPoint(position: _endPosition, name: '终点'),
        drivingStrategy: _driveStrategy,
        startNaviDirectly: false,
      ),
    );
  }

  Future<void> _showRouteOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isDrive ? '路线参数' : '扩展信息',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isDrive) ...[
                    _buildDrivingStrategyDropdown(),
                    const SizedBox(height: 12),
                    _buildDrivingExtraOptions(),
                  ],
                  const SizedBox(height: 12),
                  FilterChip(
                    label: const Text('返回扩展信息'),
                    selected: _extensions == RoutePlanExtensions.all,
                    onSelected: (value) {
                      setState(() {
                        _extensions = value
                            ? RoutePlanExtensions.all
                            : RoutePlanExtensions.base;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _searchRoute();
                    },
                    child: const Text('按当前参数重算'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPosition({required bool isStart}) async {
    final result = await AMapLocationPicker.show(
      context,
      config: LocationPickerConfig(
        title: isStart ? '选择起点' : '选择终点',
        hintText: isStart ? '搜索起点' : '搜索终点',
        initialKeyword: isStart ? _startSearchKeyword : _endSearchKeyword,
        location: isStart ? _startPosition : _endPosition,
        includeCurrentLocation: isStart,
        currentLocationText: '我的位置',
      ),
    );
    if (result == null || !mounted) return;

    await _applyPickedPosition(isStart: isStart, result: result);
  }

  Future<void> _applyPickedPosition({
    required bool isStart,
    required LocationPickerResult result,
  }) async {
    setState(() {
      _setPositionText(isStart: isStart, position: result.position);
      if (isStart) {
        _startLocation = result;
      } else {
        _endLocation = result;
      }
      _result = null;
      _selectedPathIndex = 0;
      _errorMessage = null;
    });

    final controller = _controller;
    if (controller == null) return;
    await _clearRouteOverlays(controller);
    await controller.moveCamera(
      CameraPosition(position: result.position, zoom: 14),
      const Duration(milliseconds: 300),
    );
  }

  Future<void> _swapStartEnd() async {
    setState(() {
      final lat = _startLatController.text;
      final lng = _startLngController.text;
      _startLatController.text = _endLatController.text;
      _startLngController.text = _endLngController.text;
      _endLatController.text = lat;
      _endLngController.text = lng;
      final location = _startLocation;
      _startLocation = _endLocation;
      _endLocation = location;
      _result = null;
      _selectedPathIndex = 0;
      _errorMessage = null;
    });
    final controller = _controller;
    if (controller != null) await _clearRouteOverlays(controller);
  }

  Future<void> _moveToCurrentLocation() async {
    final controller = _controller;
    if (controller == null) return;

    try {
      final location = await controller.getUserLocation();
      _lastLocation = location;
      if (!mounted) return;

      setState(() {
        _setPositionText(isStart: true, position: location.position);
        _startLocation = LocationPickerResult.fromCurrentLocation(
          position: location.position,
          name: '我的位置',
        );
        _result = null;
        _selectedPathIndex = 0;
        _errorMessage = null;
      });
      await _clearRouteOverlays(controller);
      await controller.moveCamera(
        CameraPosition(position: location.position, zoom: 16),
        const Duration(milliseconds: 300),
      );
    } catch (e) {
      if (!mounted) return;
      final cachedLocation = _lastLocation;
      if (cachedLocation != null) {
        await controller.moveCamera(
          CameraPosition(position: cachedLocation.position, zoom: 16),
          const Duration(milliseconds: 300),
        );
        return;
      }
      setState(() => _errorMessage = e.toString());
      LoadingUtil.showError('定位获取失败: $e');
    }
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
          return RoutePoint(
            position: Position(latitude: lat, longitude: lng),
          );
        })
        .whereType<RoutePoint>()
        .toList();
  }

  void _setPositionText({required bool isStart, required Position position}) {
    final latController = isStart ? _startLatController : _endLatController;
    final lngController = isStart ? _startLngController : _endLngController;
    latController.text = _formatCoordinate(position.latitude);
    lngController.text = _formatCoordinate(position.longitude);
  }

  String get _startTitle => _startLocation?.name ?? '我的位置';

  String get _endTitle => _endLocation?.name ?? '目的地';

  String? get _startSearchKeyword {
    final name = _startLocation?.name;
    return name == '我的位置' ? null : name;
  }

  String? get _endSearchKeyword => _endLocation?.name;

  Position get _startPosition {
    return Position(
      latitude:
          double.tryParse(_startLatController.text.trim()) ??
          _defaultStart.latitude,
      longitude:
          double.tryParse(_startLngController.text.trim()) ??
          _defaultStart.longitude,
    );
  }

  Position get _endPosition {
    return Position(
      latitude:
          double.tryParse(_endLatController.text.trim()) ??
          _defaultEnd.latitude,
      longitude:
          double.tryParse(_endLngController.text.trim()) ??
          _defaultEnd.longitude,
    );
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _formatCoordinate(double value) {
    return value.toStringAsFixed(6);
  }

  int _selectedIndexFor(int length) {
    if (length <= 0) return 0;
    return _selectedPathIndex.clamp(0, length - 1).toInt();
  }

  Color _routeColor(int index, {required bool selected}) {
    if (selected) return _selectedRouteColor;
    return _alternativeRouteColors[index % _alternativeRouteColors.length];
  }

  String _pathTitle(RoutePath path, int index) {
    final strategy = path.strategy?.trim();
    if (strategy != null && strategy.isNotEmpty) {
      if (strategy.length <= 6) return strategy;
      if (strategy.contains('时间')) return '时间短';
      if (strategy.contains('距离')) return '距离短';
      if (strategy.contains('拥堵')) return '躲避拥堵';
      if (strategy.contains('收费')) return '少收费';
      if (strategy.contains('高速')) return '高速优先';
      return strategy;
    }
    if (index == 0 && _isDrive) return _driveStrategy.label;
    return index == 0 ? '推荐' : '方案 ${index + 1}';
  }

  String _routeSummary(RoutePath path) {
    final lights = path.totalTrafficLights;
    if (lights != null && lights > 0) return '红绿灯$lights个';
    final strategy = path.strategy?.trim();
    if (strategy != null && strategy.isNotEmpty) return strategy;
    return '${_formatDistance(path.distance)} · ${_formatDuration(path.duration)}';
  }

  Widget _buildRouteStepIcon(RouteStep step) {
    final iconName = _routeStepIconAssetName(step);
    return Image.asset(
      'assets/navigation/$iconName.png',
      package: 'flutter_amap',
      width: 18,
      height: 18,
      color: Colors.black,
      errorBuilder: (_, __, ___) => const SizedBox(width: 18, height: 18),
    );
  }

  String _routeStepIconAssetName(RouteStep step) {
    final actionName = step.action?.trim().isNotEmpty == true
        ? step.action!.trim()
        : step.assistantAction?.trim();

    if (actionName == null || actionName.isEmpty) return '9';
    if (actionName == '左转') return '2';
    if (actionName == '右转') return '3';
    if (actionName == '向左前方行驶') return '4';
    if (actionName == '向右前方行驶') return '5';
    if (actionName == '向左后方行驶') return '6';
    if (actionName == '向右后方行驶') return '7';
    if (actionName == '左转调头') return '8';
    if (actionName == '直行') return '9';
    if (actionName == '到达途经点') return '10';
    if (actionName == '进入环岛') return '11';
    if (actionName == '驶出环岛') return '12';
    if (actionName == '到达服务区') return '13';
    if (actionName == '到达收费站') return '14';
    if (actionName == '到达目的地') return '15';
    if (actionName == '到达隧道') return '16';
    if (actionName == '靠左') return '65';
    if (actionName == '靠右') return '66';
    return '9';
  }

  double _distanceToPolylineMeters(Position point, List<Position> polyline) {
    var minDistance = double.infinity;
    for (var index = 0; index < polyline.length - 1; index++) {
      final distance = _distanceToSegmentMeters(
        point,
        polyline[index],
        polyline[index + 1],
      );
      if (distance < minDistance) minDistance = distance;
    }
    return minDistance;
  }

  double _distanceToSegmentMeters(
    Position point,
    Position start,
    Position end,
  ) {
    const earthRadiusMeters = 6371000.0;
    final baseLat = _radians(point.latitude);

    double x(Position p) {
      return _radians(p.longitude - point.longitude) *
          math.cos(baseLat) *
          earthRadiusMeters;
    }

    double y(Position p) {
      return _radians(p.latitude - point.latitude) * earthRadiusMeters;
    }

    final startX = x(start);
    final startY = y(start);
    final endX = x(end);
    final endY = y(end);
    final dx = endX - startX;
    final dy = endY - startY;
    final len2 = dx * dx + dy * dy;
    if (len2 == 0) return math.sqrt(startX * startX + startY * startY);
    final t = (-(startX * dx + startY * dy) / len2).clamp(0.0, 1.0).toDouble();
    final nearestX = startX + t * dx;
    final nearestY = startY + t * dy;
    return math.sqrt(nearestX * nearestX + nearestY * nearestY);
  }

  double _radians(double degrees) => degrees * math.pi / 180.0;

  String _formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)}公里';
    return '${meters.toStringAsFixed(0)}米';
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '-';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes分钟';
    return '${minutes ~/ 60}小时${minutes % 60}分钟';
  }
}
