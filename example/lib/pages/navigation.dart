import 'dart:async';
import 'dart:typed_data';

import 'package:amap_flutter/amap_flutter.dart';
import 'package:flutter/material.dart';

/// 导航示例页面
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  static const title = '导航示例';

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  NaviType _naviType = NaviType.driver;
  NaviPageType _pageType = NaviPageType.route;

  // 目的地坐标（示例：重庆茶园） 106.489462,29.437589
  final TextEditingController _latController =
      TextEditingController(text: '29.437589');
  final TextEditingController _lngController =
      TextEditingController(text: '106.489462');
  final TextEditingController _nameController =
      TextEditingController(text: '春晖十里');
  final TextEditingController _carNumberController = TextEditingController();

  // 导航状态
  NaviInfo? _lastNaviInfo;
  NaviLocation? _lastNaviLocation;
  final List<String> _eventLogs = [];

  // 事件订阅
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupNaviListeners();
  }

  void _setupNaviListeners() {
    // 导航信息更新
    _subscriptions.add(
      AMapNavi.onNaviInfoUpdate.listen((event) {
        setState(() {
          _lastNaviInfo = event.naviInfo;
        });
        final info = event.naviInfo;
        _addLog('========================================= \n'
            '📍 导航信息更新:\n'
            '  当前道路: ${info.currentRoadName ?? "未知"}\n'
            '  下一路段: ${info.nextRoadName}\n'
            '  转向类型: ${_getIconTypeName(info.iconType)}\n'
            '  当前路段剩余: ${_formatDistance(info.curStepRetainDistance)} / ${_formatTime(info.curStepRetainTime ?? 0)}\n'
            '  全程剩余: ${_formatDistance(info.pathRetainDistance)} / ${_formatTime(info.pathRetainTime)}\n'
            '  红绿灯: ${info.routeRemainLightCount ?? 0}个\n'
            '  进度: Step=${info.curStep ?? 0}, Link=${info.curLink ?? 0}, Point=${info.curPoint ?? 0}\n'
            '==========================================');
      }),
    );

    // 导航定位变化
    _subscriptions.add(
      AMapNavi.onNaviLocationChange.listen((event) {
        setState(() {
          _lastNaviLocation = event.location;
        });
        // _addLog('定位更新: '
        //     '坐标(${event.location.position.latitude.toStringAsFixed(6)}, '
        //     '${event.location.position.longitude.toStringAsFixed(6)}), '
        //     '速度: ${_formatSpeed(event.location.speed)}');
      }),
    );

    // 导航初始化成功
    _subscriptions.add(
      AMapNavi.onNaviInitSuccess.listen((_) {
        _addLog('✓ 导航初始化成功');
      }),
    );

    // 导航初始化失败
    _subscriptions.add(
      AMapNavi.onNaviInitFailure.listen((event) {
        _addLog('✗ 导航初始化失败: ${event.message}');
      }),
    );

    // 导航开始
    _subscriptions.add(
      AMapNavi.onNaviStart.listen((event) {
        _addLog('▶ 导航开始, 类型: ${event.type}');
      }),
    );

    // 路线计算成功
    _subscriptions.add(
      AMapNavi.onNaviRouteCalculateSuccess.listen((event) {
        _addLog('✓ 路线计算成功, 路线ID: ${event.routeIds}');
      }),
    );

    // 路线计算失败
    _subscriptions.add(
      AMapNavi.onNaviRouteCalculateFailure.listen((event) {
        _addLog('✗ 路线计算失败, 错误码: ${event.errorCode}');
      }),
    );

    // 语音播报
    _subscriptions.add(
      AMapNavi.onNaviText.listen((event) {
        _addLog('🔊 语音: ${event.text}');
      }),
    );

    // 到达目的地
    _subscriptions.add(
      AMapNavi.onNaviArriveDestination.listen((_) {
        _addLog('🏁 到达目的地');
      }),
    );

    // 到达途经点
    _subscriptions.add(
      AMapNavi.onNaviArrivedWayPoint.listen((event) {
        _addLog('📍 到达途经点 ${event.wayPointIndex}');
      }),
    );

    // 偏航重算
    _subscriptions.add(
      AMapNavi.onNaviReCalculateRouteForYaw.listen((_) {
        _addLog('↩ 偏航，正在重新计算路线...');
      }),
    );

    // 拥堵重算
    _subscriptions.add(
      AMapNavi.onNaviReCalculateRouteForTrafficJam.listen((_) {
        _addLog('🚗 拥堵，正在重新计算路线...');
      }),
    );

    // GPS信号弱
    _subscriptions.add(
      AMapNavi.onNaviGpsSignal.listen((event) {
        if (event.isWeak) {
          _addLog('⚠ GPS信号弱');
        }
      }),
    );

    // 退出导航
    _subscriptions.add(
      AMapNavi.onNaviExit.listen((event) {
        _addLog('■ 退出导航页面, 退出码: ${event.exitCode}');
        setState(() {
          _lastNaviInfo = null;
          _lastNaviLocation = null;
        });
      }),
    );
  }

  void _addLog(String log) {
    setState(() {
      _eventLogs.insert(
          0, '[${DateTime.now().toString().substring(11, 19)}] $log');
      if (_eventLogs.length > 50) {
        _eventLogs.removeLast();
      }
      debugPrint(log);
    });
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds秒';
    if (seconds < 3600) return '${seconds ~/ 60}分钟';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '$hours小时$mins分钟';
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters米';
    return '${(meters / 1000).toStringAsFixed(1)}公里';
  }

  String _formatSpeed(double? kmh) {
    if (kmh == null) return '未知';
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  /// 获取转向图标类型名称
  String _getIconTypeName(int iconType) {
    const iconTypeNames = {
      0: '未知',
      1: '直行',
      2: '左转',
      3: '右转',
      4: '左前方',
      5: '右前方',
      6: '左后方',
      7: '右后方',
      8: '左转掉头',
      9: '右转掉头',
      10: '靠左',
      11: '靠右',
      12: '到达途经点',
      13: '到达服务区',
      14: '进入环岛',
      15: '驶出环岛',
      16: '到达目的地',
      17: '进入隧道',
      18: '进入高速',
      19: '驶入服务区',
      20: '驶入收费站',
      21: '驶入检查站',
      22: '进入主路',
      23: '进入辅路',
      24: '左转45度',
      25: '右转45度',
    };
    return iconTypeNames[iconType] ?? '类型$iconType';
  }

  String _formatMs(int? ms) {
    if (ms == null) return '未知';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      String two(int v) => v.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
          '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    } catch (_) {
      return ms.toString();
    }
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value'),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNaviInfoCard(NaviInfo info) {
    final Uint8List? iconPngBytes = info.iconPng;
    final bool hasPngIcon = iconPngBytes != null && iconPngBytes.isNotEmpty;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    '当前导航信息',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (hasPngIcon)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      iconPngBytes,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('无图标'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            _sectionTitle('道路 / 转向'),
            _kv('当前道路', info.currentRoadName ?? ''),
            _kv('下一路段', info.nextRoadName),
            _kv('转向图标类型(iconType)', '${info.iconType}'),

            _sectionTitle('剩余距离 / 时间'),
            _kv('当前路段剩余距离', _formatDistance(info.curStepRetainDistance)),
            _kv(
              '当前路段剩余时间',
              info.curStepRetainTime == null
                  ? '未知'
                  : _formatTime(info.curStepRetainTime!),
            ),
            _kv('全程剩余距离', _formatDistance(info.pathRetainDistance)),
            _kv('预计时间', _formatTime(info.pathRetainTime)),

            _sectionTitle('基础 / 进度'),
            _kv('路线ID(pathId)', info.pathId?.toString() ?? '未知'),
            _kv('导航类型(naviType)', info.naviType?.toString() ?? '未知'),
            _kv('Step/Link/Point', '${info.curStep}/${info.curLink}/${info.curPoint}'),

            _sectionTitle('红绿灯 / 速度'),
            _kv('剩余红绿灯(routeRemainLightCount)', info.routeRemainLightCount?.toString() ?? '未知'),
            _kv('当前速度(currentSpeed)', info.currentSpeed?.toString() ?? '未知'),

            _sectionTitle('图标数据(调试)'),
            _kv('hasIcon', (info.hasIcon ?? false).toString()),
            _kv('iconPng', hasPngIcon ? '有(可渲染)' : '无'),

            _sectionTitle('出口方向信息'),
            if (info.exitDirectionInfo == null)
              _kv('exitDirectionInfo', '无')
            else ...[
              _kv('text', info.exitDirectionInfo!.text ?? ''),
              _kv('exitName', info.exitDirectionInfo!.exitName ?? ''),
              _kv('directionType', info.exitDirectionInfo!.directionType?.toString() ?? ''),
              _kv('distance', info.exitDirectionInfo!.distance?.toString() ?? ''),
            ],

            _sectionTitle('不可避让信息'),
            if (info.notAvoidInfo == null)
              _kv('notAvoidInfo', '无')
            else ...[
              _kv('type', info.notAvoidInfo!.type?.toString() ?? ''),
              _kv('title', info.notAvoidInfo!.title ?? ''),
              _kv('content', info.notAvoidInfo!.content ?? ''),
              _kv('roadName', info.notAvoidInfo!.roadName ?? ''),
              _kv('distance', info.notAvoidInfo!.distance?.toString() ?? ''),
              _kv('time', info.notAvoidInfo!.time?.toString() ?? ''),
              _kv(
                'coord',
                info.notAvoidInfo!.coord == null
                    ? ''
                    : '${info.notAvoidInfo!.coord!.latitude},${info.notAvoidInfo!.coord!.longitude}',
              ),
            ],

            _sectionTitle('途经点信息(toViaInfos)'),
            if (info.toViaInfos == null || info.toViaInfos!.isEmpty)
              _kv('toViaInfos', '无')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final v in info.toViaInfos!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'viaIndex=${v.viaIndex ?? ''}, name=${v.name ?? ''}, '
                        'distance=${v.distance ?? ''}, time=${v.time ?? ''}, '
                        'coord=${v.coord == null ? '' : '${v.coord!.latitude},${v.coord!.longitude}'}',
                      ),
                    ),
                ],
              ),

            _sectionTitle('raw(调试)'),
            SelectableText(info.raw ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildNaviLocationCard(NaviLocation loc) {
    final lat = loc.position.latitude;
    final lng = loc.position.longitude;
    final hasCoord = !(lat == 0.0 && lng == 0.0);

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '当前定位信息',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    hasCoord ? '已定位' : '坐标未知',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _sectionTitle('坐标'),
            _kv('经纬度', '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'),
            _kv('时间', _formatMs(loc.time)),

            _sectionTitle('航向 / 速度 / 精度'),
            _kv('航向(bearing)', loc.bearing?.toStringAsFixed(1) ?? '未知'),
            _kv('道路方向(roadBearing)', loc.roadBearing?.toStringAsFixed(1) ?? '未知'),
            _kv('速度', _formatSpeed(loc.speed)),
            _kv('精度(accuracy)', loc.accuracy == null ? '未知' : '${loc.accuracy!.toStringAsFixed(1)} m'),
            _kv('海拔(altitude)', loc.altitude == null ? '未知' : '${loc.altitude!.toStringAsFixed(1)} m'),

            _sectionTitle('导航进度索引'),
            _kv('Step/Link/Point', '${loc.curStepIndex ?? ''}/${loc.curLinkIndex ?? ''}/${loc.curPointIndex ?? ''}'),

            _sectionTitle('类型 / 匹配'),
            _kv('matchStatus', loc.matchStatus?.toString() ?? '未知'),
            _kv('locationDataType', loc.locationDataType?.toString() ?? '未知'),
            _kv('locationType', loc.locationType?.toString() ?? '未知'),

            if ((loc.raw ?? '').isNotEmpty) ...[
              _sectionTitle('raw(调试)'),
              SelectableText(loc.raw ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startNavigation() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    // 路径规划模式下，目的地可以为空（用户在导航页面选择目的地）
    // 直接导航模式下，目的地必须填写
    if (_pageType == NaviPageType.navi && (lat == null || lng == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('直接导航模式下，请输入有效的目的地坐标')),
      );
      return;
    }

    _addLog('正在启动导航...');

    try {
      // 构建目的地点（如果有坐标）
      NaviPoint? endPoint;
      if (lat != null && lng != null) {
        endPoint = NaviPoint(
          position: Position(latitude: lat, longitude: lng),
          name: _nameController.text.isNotEmpty ? _nameController.text : null,
        );
      }

      await AMapNavi.startNavigation(
        config: NaviConfig(
          naviType: _naviType,
          pageType: _pageType,
          carNumber: _carNumberController.text.isNotEmpty
              ? _carNumberController.text
              : null,
          end: endPoint,
        ),
      );
    } catch (e) {
      _addLog('✗ 启动导航失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动导航失败: $e')),
        );
      }
    }
  }

  Future<void> _stopNavigation() async {
    try {
      await AMapNavi.stopNavigation();
      _addLog('■ 导航已停止');
      setState(() {
        _lastNaviInfo = null;
        _lastNaviLocation = null;
      });
    } catch (e) {
      _addLog('✗ 停止导航失败: $e');
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    _carNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(NavigationPage.title),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: AMapNavi.isNavigatingListenable,
            builder: (context, isNavigating, _) {
              if (!isNavigating) return const SizedBox.shrink();
              return TextButton(
                onPressed: _stopNavigation,
                child: const Text('停止导航'),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 导航类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('导航类型',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<NaviType>(
                      segments: const [
                        ButtonSegment(
                            value: NaviType.driver, label: Text('驾车')),
                        ButtonSegment(value: NaviType.walk, label: Text('步行')),
                        ButtonSegment(value: NaviType.ride, label: Text('骑行')),
                      ],
                      selected: {_naviType},
                      onSelectionChanged: (values) {
                        setState(() {
                          _naviType = values.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 页面类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('页面类型',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<NaviPageType>(
                      segments: const [
                        ButtonSegment(
                            value: NaviPageType.route, label: Text('路线规划')),
                        ButtonSegment(
                            value: NaviPageType.navi, label: Text('直接导航')),
                      ],
                      selected: {_pageType},
                      onSelectionChanged: (values) {
                        setState(() {
                          _pageType = values.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 目的地设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('目的地',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              labelText: '纬度',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _lngController,
                            decoration: const InputDecoration(
                              labelText: '经度',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '地点名称（可选）',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _carNumberController,
                      decoration: const InputDecoration(
                        labelText: '车牌号（可选，用于限行规避）',
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: '例如：京A12345',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 启动导航按钮
            ValueListenableBuilder<bool>(
              valueListenable: AMapNavi.isNavigatingListenable,
              builder: (context, isNavigating, _) {
                return FilledButton.icon(
                  onPressed: _startNavigation,
                  icon: const Icon(Icons.navigation),
                  label: Text(isNavigating ? '继续导航' : '启动导航'),
                );
              },
            ),

            const SizedBox(height: 16),

            // 导航信息显示
            if (_lastNaviInfo != null)
              _buildNaviInfoCard(_lastNaviInfo!),

            const SizedBox(height: 12),

            // 导航定位信息显示
            if (_lastNaviLocation != null)
              _buildNaviLocationCard(_lastNaviLocation!),

            const SizedBox(height: 16),

            // 事件日志
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('事件日志',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _eventLogs.clear();
                            });
                          },
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _eventLogs.isEmpty
                          ? const Center(child: Text('暂无事件'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _eventLogs.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  _eventLogs[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                );
                              },
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
}
