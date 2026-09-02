import 'dart:async';

import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:crypto/crypto.dart';

/// 收集的图标信息
class CollectedIcon {
  final int iconType;
  final Uint8List bytes;
  final String md5Hash;

  CollectedIcon({
    required this.iconType,
    required this.bytes,
    required this.md5Hash,
  });
}

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
  final TextEditingController _latController = TextEditingController(
    text: '29.437589',
  );
  final TextEditingController _lngController = TextEditingController(
    text: '106.489462',
  );
  final TextEditingController _nameController = TextEditingController(
    text: '春晖十里',
  );
  final TextEditingController _carNumberController = TextEditingController();

  // 导航状态
  NaviInfo? _lastNaviInfo;
  NaviLocation? _lastNaviLocation;
  bool _isStartingNavigation = false;
  final List<String> _eventLogs = [];

  // 收集的转向图标：md5Hash -> CollectedIcon（使用 MD5 去重，同一 iconType 可能有多种图标）
  final Map<String, CollectedIcon> _collectedIcons = {};

  // 所有出现过的 iconType（包括没有图标的）
  final Set<int> _allIconTypes = {};

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
        final info = event.naviInfo;

        // 收集所有出现过的 iconType（包括没有图标的）
        if (info.iconType > 0) {
          final isNewType = !_allIconTypes.contains(info.iconType);
          if (isNewType) {
            _allIconTypes.add(info.iconType);
            _addLog(
              '📌 发现新 iconType: ${info.iconType} (${_getIconTypeName(info.iconType)}), '
              '已发现 ${_allIconTypes.length} 种类型',
            );
          }
        }

        // 收集图标：仅当图标来自原生端且 iconType > 0 时，计算 MD5 后收集
        // 静态资源图标不需要收集
        if (info.iconType > 0 && info.icon != null && info.isIconFromNative) {
          final iconBytes = info.icon!;
          // 计算图标内容的 MD5
          final iconMd5 = md5.convert(iconBytes).toString();
          final isNew = !_collectedIcons.containsKey(iconMd5);

          if (isNew) {
            _collectedIcons[iconMd5] = CollectedIcon(
              iconType: info.iconType,
              bytes: iconBytes,
              md5Hash: iconMd5,
            );

            // 统计该 iconType 已有几种变体
            final sameTypeCount = _collectedIcons.values
                .where((icon) => icon.iconType == info.iconType)
                .length;

            _addLog(
              '🎨 收集到新图标: iconType=${info.iconType} (${_getIconTypeName(info.iconType)}), '
              '该类型第 $sameTypeCount 种变体, MD5=${iconMd5.substring(0, 8)}..., '
              '总计 ${_collectedIcons.length} 个图标',
            );
          }
        }

        setState(() {
          _lastNaviInfo = info;
        });
        _addLog(
          '========================================= \n'
          '📍 导航信息更新:\n'
          '  当前道路: ${info.currentRoadName ?? "未知"}\n'
          '  下一路段: ${info.nextRoadName}\n'
          '  转向类型: ${info.iconType}--${_getIconTypeName(info.iconType)}\n'
          '  当前路段剩余: ${_formatDistance(info.curStepRetainDistance)} / ${_formatTime(info.curStepRetainTime ?? 0)}\n'
          '  全程剩余: ${_formatDistance(info.pathRetainDistance)} / ${_formatTime(info.pathRetainTime)}\n'
          '  红绿灯: ${info.routeRemainLightCount ?? 0}个\n'
          '  进度: Step=${info.curStep ?? 0}, Link=${info.curLink ?? 0}, Point=${info.curPoint ?? 0}\n'
          '==========================================',
        );
      }),
    );

    // 导航定位变化
    _subscriptions.add(
      AMapNavi.onNaviLocationChange.listen((event) {
        // setState(() {
        //   _lastNaviLocation = event.location;
        // });
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
        0,
        '[${DateTime.now().toString().substring(11, 19)}] $log',
      );
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
  /// 基于 AMapNaviIconType 枚举定义
  String _getIconTypeName(int iconType) {
    const iconTypeNames = {
      0: '无定义',
      1: '车图标',
      2: '左转',
      3: '右转',
      4: '左前方',
      5: '右前方',
      6: '左后方',
      7: '右后方',
      8: '左转掉头',
      9: '直行',
      10: '到达途经点',
      11: '进入环岛',
      12: '驶出环岛',
      13: '到达服务区',
      14: '到达收费站',
      15: '到达目的地',
      16: '进入隧道',
      17: '进入环岛(左行)',
      18: '驶出环岛(左行)',
      19: '右转掉头',
      20: '顺行',
      21: '环岛左转',
      22: '环岛右转',
      23: '环岛直行',
      24: '环岛掉头',
      25: '环岛左转(左行)',
      26: '环岛右转(左行)',
      27: '环岛直行(左行)',
      28: '环岛掉头(左行)',
      29: '人行横道',
      30: '过街天桥',
      31: '地下通道',
      32: '通过广场',
      33: '通过公园',
      34: '通过扶梯',
      35: '通过直梯',
      36: '通过索道',
      37: '空中通道',
      38: '穿越通道',
      39: '行人道路',
      40: '游船路线',
      41: '观光车路线',
      42: '通过滑道',
      43: '通过阶梯',
      44: '通过斜坡',
      45: '通过桥',
      46: '通过渡轮',
      47: '通过地铁',
      48: '进入建筑物',
      49: '离开建筑物',
      50: '电梯换层',
      51: '楼梯换层',
      52: '扶梯换层',
      53: '红绿灯路口',
      54: '普通路口',
      65: '靠左',
      66: '靠右',
    };
    return iconTypeNames[iconType] ?? '类型$iconType';
  }

  /// 保存所有收集到的图标到相册
  Future<void> _saveIconsToGallery() async {
    if (_collectedIcons.isEmpty) {
      LoadingUtil.showToast('暂无收集到的图标');
      return;
    }

    _addLog('开始保存图标到相册...');

    int successCount = 0;
    int failCount = 0;

    for (final entry in _collectedIcons.entries) {
      final md5Hash = entry.key;
      final icon = entry.value;
      final iconName = _getIconTypeName(icon.iconType);
      // 文件名包含 iconType、名称和 MD5 前8位，确保唯一性
      final fileName =
          'navi_icon_${icon.iconType}_${iconName}_${md5Hash.substring(0, 8)}.png';

      try {
        final result = await SaverGallery.saveImage(
          icon.bytes,
          quality: 100,
          fileName: fileName,
          skipIfExists: false,
        );

        if (result.isSuccess) {
          successCount++;
          _addLog('✓ 图标已保存: $fileName');
        } else {
          failCount++;
          _addLog('✗ 图标保存失败: $fileName, error=${result.errorMessage}');
        }
      } catch (e) {
        failCount++;
        _addLog('✗ 图标保存异常: $fileName, error=$e');
      }
    }

    if (mounted) {
      LoadingUtil.showSuccess('保存完成: 成功 $successCount 个, 失败 $failCount 个');
    }
  }

  /// 清空收集的图标和 iconType
  void _clearCollectedIcons() {
    setState(() {
      _collectedIcons.clear();
      _allIconTypes.clear();
    });
    _addLog('🗑 已清空收集的图标和 iconType');
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
    final Uint8List? icon = info.icon;
    final bool hasIcon = icon != null;

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
                if (hasIcon)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(icon, width: 64, height: 64),
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
            _kv(
              '转向图标类型(iconType)',
              '${info.iconType}--${_getIconTypeName(info.iconType)}',
            ),
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
            _kv(
              'Step/Link/Point',
              '${info.curStep}/${info.curLink}/${info.curPoint}',
            ),
            _sectionTitle('红绿灯 / 速度'),
            _kv(
              '剩余红绿灯(routeRemainLightCount)',
              info.routeRemainLightCount?.toString() ?? '未知',
            ),
            _kv('当前速度(currentSpeed)', info.currentSpeed?.toString() ?? '未知'),
            _sectionTitle('图标数据(调试)'),
            _kv('icon', hasIcon ? '有(可渲染)' : '无'),
            _sectionTitle('出口方向信息'),
            if (info.exitDirectionInfo == null)
              _kv('exitDirectionInfo', '无')
            else ...[
              _kv('text', info.exitDirectionInfo!.text ?? ''),
              _kv('exitName', info.exitDirectionInfo!.exitName ?? ''),
              _kv(
                'directionType',
                info.exitDirectionInfo!.directionType?.toString() ?? '',
              ),
              _kv(
                'distance',
                info.exitDirectionInfo!.distance?.toString() ?? '',
              ),
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

  /// 复制文本到剪贴板
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    LoadingUtil.showToast('已复制: $text');
  }

  /// 构建已收集图标展示卡片
  Widget _buildCollectedIconsCard() {
    // 按 iconType 分组统计图标数量
    final typeIconCount = <int, int>{};
    for (final icon in _collectedIcons.values) {
      typeIconCount[icon.iconType] = (typeIconCount[icon.iconType] ?? 0) + 1;
    }

    // 有图标的 iconType
    final typesWithIcon = typeIconCount.keys.toSet();
    // 没有图标的 iconType
    final typesWithoutIcon = _allIconTypes.difference(typesWithIcon).toList()
      ..sort();

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Expanded(
                  child: Text(
                    '已收集: ${_collectedIcons.length} 个图标, ${_allIconTypes.length} 种 iconType',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: (_collectedIcons.isEmpty && _allIconTypes.isEmpty)
                      ? null
                      : _clearCollectedIcons,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('清空'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _collectedIcons.isEmpty
                      ? null
                      : _saveIconsToGallery,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('保存'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 提示文字
            if (_allIconTypes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('导航过程中会自动收集转向图标和 iconType'),
                ),
              )
            else ...[
              // 有图标的部分
              if (_collectedIcons.isNotEmpty) ...[
                Text(
                  '有图标 (${typesWithIcon.length} 种类型, ${_collectedIcons.length} 个图标):',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _collectedIcons.entries.map((entry) {
                    final icon = entry.value;
                    final sameTypeCount = typeIconCount[icon.iconType] ?? 1;
                    final copyText =
                        '${icon.iconType}: ${_getIconTypeName(icon.iconType)} (MD5: ${icon.md5Hash})';

                    return GestureDetector(
                      onTap: () => _copyToClipboard(copyText),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.memory(
                              icon.bytes,
                              width: 48,
                              height: 48,
                              gaplessPlayback: true,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${icon.iconType}${sameTypeCount > 1 ? " ($sameTypeCount)" : ""}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          SizedBox(
                            width: 56,
                            child: Text(
                              _getIconTypeName(icon.iconType),
                              style: const TextStyle(fontSize: 9),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 没有图标的部分
              if (typesWithoutIcon.isNotEmpty) ...[
                Text(
                  '无图标 (${typesWithoutIcon.length} 种类型，点击复制):',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: typesWithoutIcon.map((iconType) {
                    final copyText = '$iconType: ${_getIconTypeName(iconType)}';

                    return GestureDetector(
                      onTap: () => _copyToClipboard(copyText),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$iconType: ${_getIconTypeName(iconType)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            _kv(
              '道路方向(roadBearing)',
              loc.roadBearing?.toStringAsFixed(1) ?? '未知',
            ),
            _kv('速度', _formatSpeed(loc.speed)),
            _kv(
              '精度(accuracy)',
              loc.accuracy == null
                  ? '未知'
                  : '${loc.accuracy!.toStringAsFixed(1)} m',
            ),
            _kv(
              '海拔(altitude)',
              loc.altitude == null
                  ? '未知'
                  : '${loc.altitude!.toStringAsFixed(1)} m',
            ),
            _sectionTitle('导航进度索引'),
            _kv(
              'Step/Link/Point',
              '${loc.curStepIndex ?? ''}/${loc.curLinkIndex ?? ''}/${loc.curPointIndex ?? ''}',
            ),
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
    if (_isStartingNavigation) return;

    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    // 路径规划模式下，目的地可以为空（用户在导航页面选择目的地）
    // 直接导航模式下，目的地必须填写
    if (_pageType == NaviPageType.navi && (lat == null || lng == null)) {
      LoadingUtil.showToast('直接导航模式下，请输入有效的目的地坐标');
      return;
    }

    setState(() {
      _isStartingNavigation = true;
    });
    _addLog('正在启动导航...');

    try {
      // 构建目的地点（如果有坐标）
      NaviPoint? endPoint;
      if (lat != null && lng != null) {
        endPoint = NaviPoint(
          position: NaviPosition(latitude: lat, longitude: lng),
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
        LoadingUtil.showError('启动导航失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartingNavigation = false;
        });
      } else {
        _isStartingNavigation = false;
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
                    const Text(
                      '导航类型',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<NaviType>(
                      segments: const [
                        ButtonSegment(
                          value: NaviType.driver,
                          label: Text('驾车'),
                        ),
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
                    const Text(
                      '页面类型',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<NaviPageType>(
                      segments: const [
                        ButtonSegment(
                          value: NaviPageType.route,
                          label: Text('路线规划'),
                        ),
                        ButtonSegment(
                          value: NaviPageType.navi,
                          label: Text('直接导航'),
                        ),
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
                    const Text(
                      '目的地',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                              decimal: true,
                            ),
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
                              decimal: true,
                            ),
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
                  onPressed: _isStartingNavigation ? null : _startNavigation,
                  icon: const Icon(Icons.navigation),
                  label: Text(
                    _isStartingNavigation
                        ? '启动中...'
                        : isNavigating
                        ? '继续导航'
                        : '启动导航',
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 导航信息显示
            if (_lastNaviInfo != null) _buildNaviInfoCard(_lastNaviInfo!),

            const SizedBox(height: 12),

            // 已收集的图标展示
            _buildCollectedIconsCard(),

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
                        const Text(
                          '事件日志',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
