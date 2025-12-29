import 'dart:async';

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

  // 目的地坐标（示例：重庆茶园）
  final TextEditingController _latController =
      TextEditingController(text: '29.497403');
  final TextEditingController _lngController =
      TextEditingController(text: '106.651138');
  final TextEditingController _nameController =
      TextEditingController(text: '重庆茶园');
  final TextEditingController _carNumberController = TextEditingController();

  // 导航状态
  bool _isNavigating = false;
  NaviInfo? _lastNaviInfo;
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
        _addLog('导航信息: 剩余${event.naviInfo.pathRetainDistance}米, '
            '预计${_formatTime(event.naviInfo.pathRetainTime)}, '
            '下一路段: ${event.naviInfo.nextRoadName}');
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
        setState(() {
          _isNavigating = true;
        });
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
        setState(() {
          _isNavigating = false;
        });
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
          _isNavigating = false;
          _lastNaviInfo = null;
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
          if (_isNavigating)
            TextButton(
              onPressed: _stopNavigation,
              child: const Text('停止导航'),
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
            FilledButton.icon(
              onPressed: _startNavigation,
              icon: const Icon(Icons.navigation),
              label: const Text('启动导航'),
            ),

            const SizedBox(height: 16),

            // 导航信息显示
            if (_lastNaviInfo != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('当前导航信息',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('下一路段: ${_lastNaviInfo!.nextRoadName}'),
                      Text(
                          '当前路段剩余: ${_formatDistance(_lastNaviInfo!.curStepRetainDistance)}'),
                      Text(
                          '全程剩余: ${_formatDistance(_lastNaviInfo!.pathRetainDistance)}'),
                      Text(
                          '预计时间: ${_formatTime(_lastNaviInfo!.pathRetainTime)}'),
                    ],
                  ),
                ),
              ),

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
