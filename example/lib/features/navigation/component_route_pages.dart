import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';

import 'navigation.dart';

/// 使用明确的起点和终点打开导航组件的路线规划页。
class StartEndRoutePage extends StatelessWidget {
  const StartEndRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComponentRoutePage(
      title: '起终点算路',
      description: '选择起点和终点后，由导航组件计算驾车路线。',
      useCurrentLocationAsStart: false,
    );
  }
}

/// 不传起点，由导航 SDK 使用当前位置打开路线规划页。
class CurrentLocationRoutePage extends StatelessWidget {
  const CurrentLocationRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComponentRoutePage(
      title: '无起点算路',
      description: '仅选择终点，导航 SDK 将使用设备当前位置作为起点。',
      useCurrentLocationAsStart: true,
    );
  }
}

class WayPointRoutePage extends StatelessWidget {
  const WayPointRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const _ComponentRoutePage(
    title: '途经点算路',
    description: '按途经点的先后顺序规划驾车路线，可添加、修改或移除途经点。',
    useCurrentLocationAsStart: false,
    includeWayPoints: true,
  );
}

class DirectNavigationPage extends StatelessWidget {
  const DirectNavigationPage({super.key});

  @override
  Widget build(BuildContext context) => const _ComponentRoutePage(
    title: '组件直接导航',
    description: '使用起终点和途经点算路后，直接进入驾车导航页面。',
    useCurrentLocationAsStart: false,
    includeWayPoints: true,
    pageType: NaviPageType.navi,
  );
}

class CustomActivityRoutePage extends StatelessWidget {
  const CustomActivityRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const _ComponentRoutePage(
    title: '自定义 Activity 的导航组件',
    description: '在 Android 自定义原生容器中打开路线规划，支持接入宿主生命周期。',
    useCurrentLocationAsStart: false,
    useCustomActivity: true,
  );
}

class _ComponentRoutePage extends StatefulWidget {
  const _ComponentRoutePage({
    required this.title,
    required this.description,
    required this.useCurrentLocationAsStart,
    this.includeWayPoints = false,
    this.pageType = NaviPageType.route,
    this.useCustomActivity = false,
  });

  final String title;
  final String description;
  final bool useCurrentLocationAsStart;
  final bool includeWayPoints;
  final NaviPageType pageType;
  final bool useCustomActivity;

  @override
  State<_ComponentRoutePage> createState() => _ComponentRoutePageState();
}

class _ComponentRoutePageState extends State<_ComponentRoutePage> {
  static final PoiItem _defaultStart = PoiItem(
    poiId: '',
    name: '北京站',
    position: Position(latitude: 39.904556, longitude: 116.427231),
  );
  static final PoiItem _defaultEnd = PoiItem(
    poiId: '',
    name: '故宫博物院',
    position: Position(latitude: 39.917337, longitude: 116.397056),
  );

  // 与官方 IndexActivity 的途经点算路、直接导航示例保持相同顺序。
  late PoiItem _start;
  late PoiItem _end;
  late final List<PoiItem> _wayPoints;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    if (widget.includeWayPoints) {
      _start = PoiItem(
        poiId: '',
        name: '立水桥(北5环)',
        position: Position(latitude: 40.041986, longitude: 116.414496),
      );
      _end = PoiItem(
        poiId: '',
        name: '新三余公园(南5环)',
        position: Position(latitude: 39.773801, longitude: 116.368984),
      );
      _wayPoints = [
        PoiItem(
          poiId: '',
          name: '首开广场',
          position: Position(latitude: 39.993266, longitude: 116.473193),
        ),
        _defaultEnd,
        _defaultStart,
      ];
    } else {
      _start = _defaultStart;
      _end = _defaultEnd;
      _wayPoints = [];
    }
  }

  bool get _isDirect => widget.pageType == NaviPageType.navi;
  bool get _supported =>
      !widget.useCustomActivity ||
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  Future<void> _pickWayPoint([int? index]) async {
    if (index == null && _wayPoints.length >= 3) return;
    final point = await AMapMapPlacePicker.show(
      context,
      config: MapPlacePickerConfig(
        title: index == null ? '添加途经点' : '修改途经点 ${index + 1}',
        hintText: '搜索途经地点',
        initialPosition: index == null
            ? _start.position
            : _wayPoints[index].position,
      ),
    );
    if (!mounted || point == null) return;
    setState(() {
      if (index == null) {
        _wayPoints.add(point);
      } else {
        _wayPoints[index] = point;
      }
    });
  }

  Future<void> _pickPoint({required bool isStart}) async {
    final currentPoint = isStart ? _start : _end;
    final point = await AMapMapPlacePicker.show(
      context,
      config: MapPlacePickerConfig(
        title: isStart ? '选择起点' : '选择终点',
        hintText: isStart ? '搜索起点' : '搜索终点',
        initialPosition: currentPoint.position,
      ),
    );
    if (point == null || !mounted) return;

    setState(() {
      if (isStart) {
        _start = point;
      } else {
        _end = point;
      }
    });
  }

  NaviPoint _toNaviPoint(PoiItem point) {
    return NaviPoint(
      name: point.name,
      poiId: point.poiId.isEmpty ? null : point.poiId,
      position: NaviPosition(
        latitude: point.position.latitude,
        longitude: point.position.longitude,
      ),
    );
  }

  Future<void> _calculateRoute() async {
    if (_isOpening || !_supported) return;
    setState(() => _isOpening = true);

    try {
      await AMapNavi.startNavigation(
        config: NaviConfig(
          naviType: NaviType.driver,
          pageType: widget.pageType,
          start: widget.useCurrentLocationAsStart ? null : _toNaviPoint(_start),
          end: _toNaviPoint(_end),
          wayPoints: _wayPoints.isEmpty
              ? null
              : _wayPoints.map(_toNaviPoint).toList(),
          androidActivityClassName: widget.useCustomActivity
              ? 'com.example.amap_flutter_example.CustomNaviActivity'
              : null,
        ),
      );
    } catch (error) {
      if (mounted) await LoadingUtil.showError('打开导航组件失败：$error');
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.useCurrentLocationAsStart)
                const _CurrentLocationTile()
              else
                _PointTile(
                  label: '起点',
                  point: _start,
                  color: const Color(0xFF20A464),
                  onTap: () => _pickPoint(isStart: true),
                ),
              const SizedBox(height: 12),
              if (widget.includeWayPoints) ...[
                for (var i = 0; i < _wayPoints.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _PointTile(
                          label: '途经点 ${i + 1}',
                          point: _wayPoints[i],
                          color: Colors.orange,
                          onTap: () => _pickWayPoint(i),
                        ),
                      ),
                      IconButton(
                        tooltip: '移除途经点 ${i + 1}',
                        onPressed: () => setState(() => _wayPoints.removeAt(i)),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _wayPoints.length < 3
                      ? () => _pickWayPoint()
                      : null,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text('添加途经点（${_wayPoints.length}/3）'),
                ),
                const SizedBox(height: 12),
              ],
              _PointTile(
                label: '终点',
                point: _end,
                color: const Color(0xFFE94B4B),
                onTap: () => _pickPoint(isStart: false),
              ),
              const SizedBox(height: 24),
              if (!_supported) ...[
                const Text('自定义 Activity 示例仅支持 Android。'),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isOpening || !_supported ? null : _calculateRoute,
                  icon: _isOpening
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.alt_route),
                  label: Text(
                    _isOpening ? '正在打开…' : (_isDirect ? '开始导航' : '开始算路'),
                  ),
                ),
              ),
              if (_isDirect) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NavigationPage(),
                    ),
                  ),
                  child: const Text('导航事件与图标调试'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationTile extends StatelessWidget {
  const _CurrentLocationTile();

  @override
  Widget build(BuildContext context) {
    return const _RoutePointTile(
      color: Color(0xFF20A464),
      label: '起点',
      title: '当前位置',
      subtitle: '由导航 SDK 定位',
      trailing: Icon(Icons.my_location, color: Colors.grey),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({
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
    final address = point.address?.trim();
    final coordinate =
        '${point.position.latitude.toStringAsFixed(6)}, '
        '${point.position.longitude.toStringAsFixed(6)}';
    return _RoutePointTile(
      color: color,
      label: label,
      title: point.name,
      subtitle: address == null || address.isEmpty ? coordinate : address,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _RoutePointTile extends StatelessWidget {
  const _RoutePointTile({
    required this.color,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final Color color;
  final String label;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label · $title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
