import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

/// 智能巡航示例：地图展示自车位置，右上角开启/关闭巡航（依赖插件 [AMapNavi.startCruiseMode]）。
///
/// 巡航需联网，效果宜在真实驾车环境验证；与正式导航互斥。
class CruiseMapPage extends StatefulWidget {
  const CruiseMapPage({super.key});

  @override
  State<CruiseMapPage> createState() => _CruiseMapPageState();
}

class _CruiseMapPageState extends State<CruiseMapPage> {
  static const int _maxLogLines = 200;

  AMapController? _controller;
  Location? _lastLocation;

  final List<String> _cruiseLogLines = [];

  StreamSubscription<CruiseTrafficFacilitiesEvent>? _subFacilities;
  StreamSubscription<CruiseStatisticsEvent>? _subStatistics;
  StreamSubscription<CruiseCongestionEvent>? _subCongestion;
  StreamSubscription<NaviTextEvent>? _subNaviText;

  @override
  void initState() {
    super.initState();
    _subFacilities = AMapNavi.onCruiseTrafficFacilities.listen(
      (CruiseTrafficFacilitiesEvent e) => _appendCruiseLog(
        'cruiseTrafficFacilities: ${e.facilities.length} 条 ${_summarizeFacilities(e.facilities)}',
      ),
    );
    _subStatistics = AMapNavi.onCruiseStatistics.listen(
      (CruiseStatisticsEvent e) {
        final CruiseStatisticsInfo s = e.statistics;
        _appendCruiseLog(
          'cruiseStatistics: 累计距离=${s.cumulativeDistanceMeters ?? '-'} m, '
          '累计时间=${s.cumulativeTimeSeconds ?? '-'} s, extra=${s.extra}',
        );
      },
    );
    _subCongestion = AMapNavi.onCruiseCongestion.listen(
      (CruiseCongestionEvent e) => _appendCruiseLog(
        'cruiseCongestion: raw=${e.congestion.raw}',
      ),
    );
    _subNaviText = AMapNavi.onNaviText.listen(
      (NaviTextEvent e) => _appendCruiseLog('naviText: ${e.text}'),
    );
  }

  void _appendCruiseLog(String message) {
    final DateTime n = DateTime.now();
    final String ts =
        '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
    final String line = '[$ts] $message';
    debugPrint('[CruiseMapPage] $line');
    if (!mounted) return;
    setState(() {
      _cruiseLogLines.insert(0, line);
      while (_cruiseLogLines.length > _maxLogLines) {
        _cruiseLogLines.removeLast();
      }
    });
  }

  String _summarizeFacilities(List<CruiseTrafficFacilityItem> items) {
    if (items.isEmpty) return '';
    final StringBuffer b = StringBuffer();
    final int n = items.length > 3 ? 3 : items.length;
    for (int i = 0; i < n; i++) {
      final CruiseTrafficFacilityItem f = items[i];
      b.write(
        '[${f.source.name} type=${f.type} dist=${f.remainDistanceMeters} '
        'limit=${f.speedLimitKmh}] ',
      );
    }
    if (items.length > 3) b.write('…');
    return b.toString().trimRight();
  }

  void _clearCruiseLog() {
    if (_cruiseLogLines.isEmpty) return;
    setState(_cruiseLogLines.clear);
  }

  @override
  void dispose() {
    _subFacilities?.cancel();
    _subStatistics?.cancel();
    _subCongestion?.cancel();
    _subNaviText?.cancel();
    if (AMapNavi.isCruising) {
      unawaited(AMapNavi.stopCruiseMode());
    }
    _controller?.destroy();
    super.dispose();
  }

  Future<void> _startCruise() async {
    try {
      await AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both);
      _appendCruiseLog('已调用 startCruiseMode(mode=CruiseBroadcastMode.both)');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已开启智能巡航（需联网）'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('开启失败：$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _stopCruise() async {
    try {
      await AMapNavi.stopCruiseMode();
      _appendCruiseLog('已调用 stopCruiseMode()');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已关闭智能巡航'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('关闭失败：$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能巡航'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: AMapNavi.isCruisingListenable,
            builder: (context, cruising, _) {
              if (!cruising) {
                return TextButton(
                  onPressed: _startCruise,
                  child: const Text('开启巡航'),
                );
              }
              return TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: _stopCruise,
                child: const Text('关闭巡航'),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AMapWidget(
            initCameraPosition: CameraPosition(zoom: 16),
            showUserLocation: true,
            geolocationControlEnabled: true,
            userLocationStyle: UserLocationStyle(
              userLocationType: Platform.isAndroid ? UserLocationType.locationTypeMapRotate : UserLocationType.locationTypeMapRotate,
            ),
            onUserLocationChange: (location) {
              _lastLocation = location;
            },
            onMapCreated: (c) => setState(() => _controller = c),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface.withValues(
                            alpha: 0.94,
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              10,
                              6,
                              4,
                              0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '巡航回调',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed:
                                      _cruiseLogLines.isEmpty ? null : _clearCruiseLog,
                                  child: const Text('清空'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: _cruiseLogLines.isEmpty
                                ? Center(
                                    child: Text(
                                      '开启巡航后，设施 / 统计 / 拥堵 / 播报文案\n'
                                      '将通过插件事件在此显示（驾车场景更易触发）。',
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )
                                : Scrollbar(
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        8,
                                      ),
                                      itemCount: _cruiseLogLines.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: SelectableText(
                                            _cruiseLogLines[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontFamily: 'monospace',
                                                  height: 1.25,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface.withValues(
                            alpha: 0.92,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '地图展示定位；巡航播报与设施数据由高德导航 SDK 通过事件下发（需在户外驾车场景验证）。',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              tooltip: '移动到当前位置',
                              onPressed: _controller == null
                                  ? null
                                  : () async {
                                      try {
                                        final Location loc =
                                            _lastLocation ??
                                                await _controller!
                                                    .waitForUserLocation(
                                                  timeout: const Duration(
                                                    seconds: 10,
                                                  ),
                                                );
                                        await _controller!.moveCamera(
                                          CameraPosition(
                                            position: loc.position,
                                            zoom: 16,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('定位失败：$e'),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.my_location),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
