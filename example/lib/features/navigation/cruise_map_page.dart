import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 智能巡航示例：地图展示自车位置，右上角开启/关闭巡航（依赖插件 [AMapNavi.startCruiseMode]）。
///
/// 巡航需联网，效果宜在真实驾车环境验证；与正式导航互斥。
class CruiseMapPage extends StatefulWidget {
  const CruiseMapPage({super.key});

  @override
  State<CruiseMapPage> createState() => _CruiseMapPageState();
}

typedef _CruiseStatsSnapshot = ({int? distanceMeters, int? timeSeconds});

class _CruiseLogEntry {
  const _CruiseLogEntry({
    required this.summary,
    required this.detail,
  });

  final String summary;
  final String detail;
}

class _CruiseMapPageState extends State<CruiseMapPage> {
  static const int _maxLogLines = 5000;

  AMapController? _controller;
  Location? _lastLocation;

  /// 巡航统计：仅驱动统计条局部重绘，不打日志。
  final ValueNotifier<_CruiseStatsSnapshot> _cruiseStats =
      ValueNotifier<_CruiseStatsSnapshot>(
    (distanceMeters: null, timeSeconds: null),
  );

  final List<_CruiseLogEntry> _cruiseLogLines = [];

  StreamSubscription<CruiseTrafficFacilitiesEvent>? _subFacilities;
  StreamSubscription<CruiseStatisticsEvent>? _subStatistics;
  StreamSubscription<CruiseCongestionEvent>? _subCongestion;
  StreamSubscription<NaviTextEvent>? _subNaviText;

  @override
  void initState() {
    super.initState();
    _subFacilities = AMapNavi.onCruiseTrafficFacilities.listen(
      (CruiseTrafficFacilitiesEvent e) {
        _appendCruiseLog(
          '巡航道路设施 / 电子眼等信息: ${e.facilities.length} 条 ${_summarizeFacilities(e.facilities)}',
          detail: _stringify(_facilitiesToDetail(e.facilities)),
        );
      },
    );
    _subStatistics = AMapNavi.onCruiseStatistics.listen(
      (CruiseStatisticsEvent e) {
        final CruiseStatisticsInfo s = e.statistics;
        if (!mounted) return;
        _cruiseStats.value = (
          distanceMeters: s.cumulativeDistanceMeters,
          timeSeconds: s.cumulativeTimeSeconds,
        );
      },
    );
    _subCongestion = AMapNavi.onCruiseCongestion.listen(
      (CruiseCongestionEvent e) {
        _appendCruiseLog(
          '巡航拥堵信息（主要为 Android）: ${_summarizeCongestion(e.congestion)}',
          detail: _stringify(_congestionToDetail(e.congestion)),
        );
      },
    );
    _subNaviText = AMapNavi.onNaviText.listen(
      (NaviTextEvent e) => _appendCruiseLog(
        'naviText: ${e.text}',
        detail: _stringify(<String, Object?>{'text': e.text}),
      ),
    );
  }

  void _appendCruiseLog(String message, {String? detail}) {
    final DateTime n = DateTime.now();
    final String ts =
        '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
    final String line = '[$ts] $message';
    debugPrint('[CruiseMapPage] $line');
    if (!mounted) return;
    setState(() {
      _cruiseLogLines.insert(
        0,
        _CruiseLogEntry(summary: line, detail: detail ?? line),
      );
      while (_cruiseLogLines.length > _maxLogLines) {
        _cruiseLogLines.removeLast();
      }
    });
  }

  String _formatCruiseDurationSeconds(int? seconds) {
    if (seconds == null) return '—';
    final Duration d = Duration(seconds: seconds);
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h时${m.toString().padLeft(2, '0')}分${s.toString().padLeft(2, '0')}秒';
    }
    if (m > 0) return '$m分${s.toString().padLeft(2, '0')}秒';
    return '$s秒';
  }

  String _summarizeFacilities(List<CruiseTrafficFacilityItem> items) {
    if (items.isEmpty) return '';
    final StringBuffer b = StringBuffer();
    final int n = items.length > 3 ? 3 : items.length;
    for (int i = 0; i < n; i++) {
      final CruiseTrafficFacilityItem f = items[i];
      b.write(
        '[${f.source.name} type=${f.type} dist=${f.remainDistanceMeters} '
        'limit=${_formatSpeedLimit(f.speedLimitKmh)}] ',
      );
    }
    if (items.length > 3) b.write('…');
    return b.toString().trimRight();
  }

  List<Map<String, Object?>> _facilitiesToDetail(
    List<CruiseTrafficFacilityItem> items,
  ) {
    return items
        .map(
          (f) => <String, Object?>{
            'source': f.source.name,
            'type': f.type,
            'latitude': f.latitude,
            'longitude': f.longitude,
            'remainDistanceMeters': f.remainDistanceMeters,
            'speedLimitKmh': f.speedLimitKmh,
            'raw': f.raw,
          },
        )
        .toList();
  }

  String _summarizeCongestion(CruiseCongestionInfo info) {
    final String name =
        info.roadName?.isNotEmpty == true ? info.roadName! : '未知道路';
    final String length =
        info.lengthMeters == null ? '—' : '${info.lengthMeters}m';
    final String time = info.estimatedTimeSeconds == null
        ? '—'
        : _formatCruiseDurationSeconds(info.estimatedTimeSeconds);
    return 'road=$name length=$length status=${info.status ?? '—'} '
        'time=$time links=${info.links.length} raw=${info.raw}';
  }

  Map<String, Object?> _congestionToDetail(CruiseCongestionInfo info) {
    return <String, Object?>{
      'roadName': info.roadName,
      'lengthMeters': info.lengthMeters,
      'status': info.status,
      'estimatedTimeSeconds': info.estimatedTimeSeconds,
      'links': info.links
          .map(
            (link) => <String, Object?>{
              'status': link.status,
              'coords': link.coords
                  .map(
                    (p) => <String, double>{
                      'latitude': p.latitude,
                      'longitude': p.longitude,
                    },
                  )
                  .toList(),
              'raw': link.raw,
            },
          )
          .toList(),
      'raw': info.raw,
    };
  }

  String _stringify(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> _showCruiseLogDetail(_CruiseLogEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('巡航回调原数据'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                entry.detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.25,
                    ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String _formatSpeedLimit(int? kmh) {
    if (kmh == null || kmh <= 0) return '—';
    return '$kmh';
  }

  void _clearCruiseLog() {
    if (_cruiseLogLines.isEmpty) return;
    setState(_cruiseLogLines.clear);
  }

  String _formatFileTimestamp(DateTime n) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_'
        '${two(n.hour)}${two(n.minute)}${two(n.second)}';
  }

  String _buildExportText() {
    final DateTime now = DateTime.now();
    final StringBuffer buffer = StringBuffer()
      ..writeln('AMap 智能巡航日志')
      ..writeln('导出时间: $now')
      ..writeln('日志条数: ${_cruiseLogLines.length}')
      ..writeln('============================================================');
    for (final entry in _cruiseLogLines.reversed) {
      buffer
        ..writeln()
        ..writeln(entry.summary)
        ..writeln('--- detail ---')
        ..writeln(entry.detail);
    }
    return buffer.toString();
  }

  Future<void> _shareCruiseLogs() async {
    if (_cruiseLogLines.isEmpty) {
      LoadingUtil.showToast('暂无可导出的巡航日志');
      return;
    }
    try {
      final Directory dir = await getTemporaryDirectory();
      final String fileName =
          'amap_cruise_log_${_formatFileTimestamp(DateTime.now())}.txt';
      final File file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(_buildExportText(), encoding: utf8);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/plain', name: fileName)],
          subject: 'AMap 智能巡航日志',
          text: 'AMap 智能巡航日志，共 ${_cruiseLogLines.length} 条。',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('导出失败：$e');
    }
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
    _cruiseStats.dispose();
    _controller?.destroy();
    super.dispose();
  }

  Future<void> _startCruise() async {
    try {
      await AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both);
      _appendCruiseLog('已调用 startCruiseMode(mode=CruiseBroadcastMode.both)');
      if (!mounted) return;
      LoadingUtil.showSuccess('已开启智能巡航（需联网）');
    } on StateError catch (e) {
      if (!mounted) return;
      LoadingUtil.showToast('$e');
    } catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('开启失败：$e');
    }
  }

  Future<void> _stopCruise() async {
    try {
      await AMapNavi.stopCruiseMode();
      _appendCruiseLog('已调用 stopCruiseMode()');
      if (!mounted) return;
      _cruiseStats.value = (distanceMeters: null, timeSeconds: null);
      LoadingUtil.showSuccess('已关闭智能巡航');
    } catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('关闭失败：$e');
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_controller == null) return;
    try {
      final Location loc = _lastLocation ??
          await _controller!.waitForUserLocation(
            timeout: const Duration(seconds: 10),
          );
      await _controller!.moveCamera(
        CameraPosition(position: loc.position, zoom: 16),
      );
    } catch (e) {
      if (!mounted) return;
      LoadingUtil.showError('定位失败：$e');
    }
  }

  void _showCruiseHelp() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('智能巡航说明'),
          content: const Text(
            '地图展示定位；巡航播报与设施数据由高德导航 SDK 通过事件下发（需在户外驾车场景验证）。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(BuildContext context) {
    return Stack(
      children: [
        AMapWidget(
          initCameraPosition: CameraPosition(zoom: 16),
          showUserLocation: true,
          geolocationControlEnabled: true,
          userLocationStyle: UserLocationStyle(
            userLocationType: Platform.isAndroid
                ? UserLocationType.locationTypeLocationRotate
                : UserLocationType.locationTypeMapRotate,
          ),
          onUserLocationChange: (location) => _lastLocation = location,
          onMapCreated: (c) => setState(() => _controller = c),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Material(
            elevation: 2,
            shape: const CircleBorder(),
            color: Theme.of(context).colorScheme.surface,
            child: IconButton(
              tooltip: '移动到当前位置',
              visualDensity: VisualDensity.compact,
              onPressed: _controller == null ? null : _moveToCurrentLocation,
              icon: const Icon(Icons.my_location),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsRow(context),
                  const Divider(height: 10),
                  _buildLogHeader(context),
                  const SizedBox(height: 4),
                  SizedBox(height: 150, child: _buildLogList(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return ValueListenableBuilder<_CruiseStatsSnapshot>(
      valueListenable: _cruiseStats,
      builder: (context, stats, _) {
        final textStyle = Theme.of(context).textTheme.bodySmall;
        return Row(
          children: [
            Expanded(
              child: Text(
                '距离：${stats.distanceMeters ?? '—'} m',
                style: textStyle,
              ),
            ),
            Expanded(
              child: Text(
                '时间：${_formatCruiseDurationSeconds(stats.timeSeconds)}',
                style: textStyle,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          '巡航回调',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        IconButton(
          tooltip: '分享日志',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          onPressed: _cruiseLogLines.isEmpty ? null : _shareCruiseLogs,
          icon: const Icon(Icons.ios_share, size: 20),
        ),
        IconButton(
          tooltip: '说明',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          onPressed: _showCruiseHelp,
          icon: const Icon(Icons.help_outline, size: 20),
        ),
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const ui.Size(42, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: _cruiseLogLines.isEmpty ? null : _clearCruiseLog,
          child: const Text('清空'),
        ),
      ],
    );
  }

  Widget _buildLogList(BuildContext context) {
    if (_cruiseLogLines.isEmpty) {
      return Center(
        child: Text(
          '开启巡航后显示设施 / 拥堵 / 播报文案，点击日志可看原数据。',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(right: 6, bottom: 4),
        itemCount: _cruiseLogLines.length,
        itemBuilder: (context, index) {
          final _CruiseLogEntry entry = _cruiseLogLines[index];
          return InkWell(
            onTap: () => _showCruiseLogDetail(entry),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                entry.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.2,
                    ),
              ),
            ),
          );
        },
      ),
    );
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
      body: Column(
        children: [
          Expanded(child: _buildMap(context)),
          _buildBottomPanel(context),
        ],
      ),
    );
  }
}
