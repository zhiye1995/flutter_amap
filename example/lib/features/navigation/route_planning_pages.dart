import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';

enum _RoutePlanKind { drive, walk, ride, truck }

/// 驾车、步行、骑行和货车的普通导航算路示例。
class NaviRoutePlanPage extends StatefulWidget {
  const NaviRoutePlanPage.drive({super.key}) : _kind = _RoutePlanKind.drive;
  const NaviRoutePlanPage.walk({super.key}) : _kind = _RoutePlanKind.walk;
  const NaviRoutePlanPage.ride({super.key}) : _kind = _RoutePlanKind.ride;
  const NaviRoutePlanPage.truck({super.key}) : _kind = _RoutePlanKind.truck;

  final _RoutePlanKind _kind;

  String get title => switch (_kind) {
    _RoutePlanKind.drive => '驾车路径规划',
    _RoutePlanKind.walk => '步行路径规划',
    _RoutePlanKind.ride => '骑行路径规划',
    _RoutePlanKind.truck => '货车导航路径规划',
  };

  @override
  State<NaviRoutePlanPage> createState() => _NaviRoutePlanPageState();
}

class _NaviRoutePlanPageState extends State<NaviRoutePlanPage> {
  PoiItem _start = _RouteDefaults.start;
  PoiItem _end = _RouteDefaults.end;
  bool _opening = false;

  final _plateController = TextEditingController(text: '京A12345');
  final _heightController = TextEditingController(text: '3.2');
  final _widthController = TextEditingController(text: '2.5');
  final _lengthController = TextEditingController(text: '8.0');
  final _weightController = TextEditingController(text: '12.0');
  final _loadController = TextEditingController(text: '8.0');
  final _axisController = TextEditingController(text: '2');

  bool get _isTruck => widget._kind == _RoutePlanKind.truck;

  @override
  void dispose() {
    _plateController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _loadController.dispose();
    _axisController.dispose();
    super.dispose();
  }

  Future<void> _pickPoint(bool isStart) async {
    final current = isStart ? _start : _end;
    final point = await AMapMapPlacePicker.show(
      context,
      config: MapPlacePickerConfig(
        title: isStart ? '选择起点' : '选择终点',
        hintText: isStart ? '搜索起点' : '搜索终点',
        initialPosition: current.position,
      ),
    );
    if (!mounted || point == null) return;
    setState(() => isStart ? _start = point : _end = point);
  }

  Future<void> _calculate() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await AMapNavi.startNavigation(
        config: NaviConfig(
          naviType: switch (widget._kind) {
            _RoutePlanKind.walk => NaviType.walk,
            _RoutePlanKind.ride => NaviType.ride,
            _ => NaviType.driver,
          },
          pageType: NaviPageType.route,
          start: _RouteDefaults.toNaviPoint(_start),
          end: _RouteDefaults.toNaviPoint(_end),
          multipleRoute: !_isTruck,
          vehicleInfo: _isTruck
              ? NaviVehicleInfo(
                  vehicleId: _plateController.text.trim(),
                  type: 1,
                  size: 2,
                  height: double.tryParse(_heightController.text),
                  width: double.tryParse(_widthController.text),
                  length: double.tryParse(_lengthController.text),
                  weight: double.tryParse(_weightController.text),
                  load: double.tryParse(_loadController.text),
                  axisNums: int.tryParse(_axisController.text),
                  vehicleLoadSwitch: true,
                  isRestriction: true,
                )
              : null,
        ),
      );
    } catch (error) {
      if (mounted) await LoadingUtil.showError('路径规划失败：$error');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PointCard(
            label: '起点',
            point: _start,
            color: const Color(0xFF20A464),
            onTap: () => _pickPoint(true),
          ),
          const SizedBox(height: 12),
          _PointCard(
            label: '终点',
            point: _end,
            color: const Color(0xFFE94B4B),
            onTap: () => _pickPoint(false),
          ),
          if (_isTruck) ...[
            const SizedBox(height: 16),
            Text('货车参数', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '车辆尺寸、总重和核定载重会传给导航 SDK，用于限高、限重和货车限行算路。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _TruckField(label: '车牌号', controller: _plateController),
            Row(
              children: [
                Expanded(
                  child: _TruckField(
                    label: '车高（米）',
                    controller: _heightController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TruckField(
                    label: '车宽（米）',
                    controller: _widthController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _TruckField(
                    label: '车长（米）',
                    controller: _lengthController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TruckField(label: '轴数', controller: _axisController),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _TruckField(
                    label: '总重（吨）',
                    controller: _weightController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TruckField(
                    label: '核定载重（吨）',
                    controller: _loadController,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _opening ? null : _calculate,
              icon: _opening
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.alt_route),
              label: Text(_opening ? '正在打开…' : '打开路线规划页'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 不改变当前导航路线的独立驾车算路示例。
class IndependentRoutePlanPage extends StatefulWidget {
  const IndependentRoutePlanPage({super.key});

  @override
  State<IndependentRoutePlanPage> createState() =>
      _IndependentRoutePlanPageState();
}

class _IndependentRoutePlanPageState extends State<IndependentRoutePlanPage> {
  PoiItem _start = _RouteDefaults.start;
  PoiItem _end = _RouteDefaults.end;
  AMapController? _mapController;
  NaviIndependentRouteResult? _result;
  bool _loading = false;

  Set<Marker> get _markers => {
    Marker(id: 'independent_start', position: _start.position, title: '起点'),
    Marker(id: 'independent_end', position: _end.position, title: '终点'),
  };

  Future<void> _pickPoint(bool isStart) async {
    final current = isStart ? _start : _end;
    final point = await AMapMapPlacePicker.show(
      context,
      config: MapPlacePickerConfig(
        title: isStart ? '选择起点' : '选择终点',
        hintText: isStart ? '搜索起点' : '搜索终点',
        initialPosition: current.position,
      ),
    );
    if (!mounted || point == null) return;
    setState(() => isStart ? _start = point : _end = point);
  }

  Future<void> _calculate() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final value = await AMapNavi.calculateIndependentRoute(
        request: NaviIndependentRouteRequest(
          start: _RouteDefaults.toNaviPoint(_start),
          end: _RouteDefaults.toNaviPoint(_end),
        ),
      );
      if (!mounted) return;
      setState(() => _result = value);
      await _drawRoutes(value);
    } catch (error) {
      if (mounted) await LoadingUtil.showError('独立路径规划失败：$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _drawRoutes(NaviIndependentRouteResult result) async {
    final controller = _mapController;
    if (controller == null) return;
    for (var i = 0; i < 3; i++) {
      await controller.removePolyline('independent_route_$i');
    }
    const colors = [Color(0xFF1976D2), Color(0xFF7E57C2), Color(0xFF26A69A)];
    for (var i = result.paths.length - 1; i >= 0; i--) {
      final coordinates = result.paths[i].coordinates
          .map(
            (point) =>
                Position(latitude: point.latitude, longitude: point.longitude),
          )
          .toList();
      if (coordinates.length < 2) continue;
      await controller.addPolyline(
        Polyline(
          id: 'independent_route_$i',
          points: coordinates,
          width: i == result.mainPathIndex ? 12 : 8,
          color: colors[i % colors.length],
        ),
      );
    }
    final mainCoordinates =
        result.mainPath?.coordinates
            .map(
              (point) => Position(
                latitude: point.latitude,
                longitude: point.longitude,
              ),
            )
            .toList() ??
        const <Position>[];
    if (mainCoordinates.length >= 2) {
      controller.moveCameraToFitPosition(
        mainCoordinates,
        EdgePadding(top: 50, right: 40, bottom: 60, left: 40),
        const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('独立路径规划'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: AMapWidget(
              initCameraPosition: CameraPosition(
                position: _start.position,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('独立算路结果只用于预览，不会覆盖正在使用的导航路线。'),
                const SizedBox(height: 12),
                _PointCard(
                  label: '起点',
                  point: _start,
                  color: const Color(0xFF20A464),
                  onTap: () => _pickPoint(true),
                ),
                const SizedBox(height: 8),
                _PointCard(
                  label: '终点',
                  point: _end,
                  color: const Color(0xFFE94B4B),
                  onTap: () => _pickPoint(false),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : _calculate,
                  icon: _loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.route),
                  label: Text(_loading ? '算路中…' : '计算独立路线'),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 12),
                  for (var i = 0; i < _result!.paths.length; i++)
                    _RouteResultCard(
                      index: i,
                      path: _result!.paths[i],
                      isMain: i == _result!.mainPathIndex,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteResultCard extends StatelessWidget {
  const _RouteResultCard({
    required this.index,
    required this.path,
    required this.isMain,
  });

  final int index;
  final NaviIndependentRoutePath path;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final kilometers = (path.distanceMeters / 1000).toStringAsFixed(1);
    final minutes = (path.durationSeconds / 60).round();
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text('路线 ${index + 1}${isMain ? ' · 主路线' : ''}'),
        subtitle: Text(
          '$kilometers km · $minutes 分钟 · 收费 ${path.tollCost ?? 0} 元\n'
          '红绿灯 ${path.trafficLightCount ?? 0} 个 · ${path.coordinates.length} 个形状点',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _TruckField extends StatelessWidget {
  const _TruckField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: label == '车牌号'
            ? TextInputType.text
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.label,
    required this.point,
    required this.color,
    required this.onTap,
  });

  final String label;
  final PoiItem point;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.location_on, color: color),
        title: Text(
          '$label · ${point.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          point.address?.isNotEmpty == true
              ? point.address!
              : '${point.position.latitude.toStringAsFixed(6)}, ${point.position.longitude.toStringAsFixed(6)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

abstract final class _RouteDefaults {
  static final start = PoiItem(
    poiId: '',
    name: '北京站',
    position: Position(latitude: 39.904556, longitude: 116.427231),
  );
  static final end = PoiItem(
    poiId: '',
    name: '颐和园',
    position: Position(latitude: 39.999676, longitude: 116.275453),
  );

  static NaviPoint toNaviPoint(PoiItem point) => NaviPoint(
    name: point.name,
    poiId: point.poiId.isEmpty ? null : point.poiId,
    position: NaviPosition(
      latitude: point.position.latitude,
      longitude: point.position.longitude,
    ),
  );
}
