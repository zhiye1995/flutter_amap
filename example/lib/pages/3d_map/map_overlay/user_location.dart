import 'package:flutter/foundation.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';

/// 演示 [UserLocationStyle.userLocationType] 多种模式；双端差异见 [UserLocationTypePlatform]（`lib/src/models/location.dart`）。
class UserLocationPage extends StatefulWidget {
  const UserLocationPage({super.key});

  static const title = 'Location几种模式';

  @override
  State<UserLocationPage> createState() => _UserLocationPageState();
}

class _UserLocationPageState extends State<UserLocationPage> {
  AMapController? controller;
  Location? _lastLocation;
  UserLocationType _mode = UserLocationType.locationTypeFollow;

  @override
  void dispose() {
    controller?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformHint = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => '当前设备：iOS。Chip 第二行「iOS」列为插件映射结果。',
      TargetPlatform.android => '当前设备：Android。以下为高德 MyLocationStyle 全量类型。',
      _ => '当前设备：${defaultTargetPlatform.name}。',
    };

    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(UserLocationPage.title),
          actions: [
            Builder(
              builder: (context) {
                return TextButton(
                  onPressed: controller == null
                      ? null
                      : () async {
                          try {
                            final Location location = _lastLocation ??
                                await controller!.waitForUserLocation(
                                  timeout: const Duration(seconds: 10),
                                );
                            controller!.moveCamera(
                              CameraPosition(
                                position: location.position,
                                zoom: 16,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '定位获取失败：$e\n'
                                  '请确认已授予定位权限，并等待 onUserLocationChange 后再试。',
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('当前位置'),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: AMapWidget(
                initCameraPosition: CameraPosition(zoom: 16),
                showUserLocation: true,
                geolocationControlEnabled: true,
                userLocationStyle: UserLocationStyle(userLocationType: _mode),
                onUserLocationChange: (location) {
                  _lastLocation = location;
                  debugPrint(
                    '${location.position.latitude}, ${location.position.longitude}',
                  );
                },
                onMapCreated: (c) {
                  setState(() => controller = c);
                },
              ),
            ),
            Material(
              elevation: 8,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        platformHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '点选切换模式；第二行：Android / iOS 能力摘要（与枚举扩展一致）。',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: UserLocationType.values
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    selected: _mode == t,
                                    onSelected: (selected) {
                                      if (!selected) return;
                                      setState(() => _mode = t);
                                    },
                                    tooltip: t.platformAvailabilityLabel,
                                    label: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 132,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _modeTitle(t),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Android：${_androidLine(t)}\n'
                                            'iOS：${_iosLine(t)}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _modeTitle(UserLocationType t) {
    switch (t) {
      case UserLocationType.locationTypeShow:
        return '仅显示';
      case UserLocationType.locationTypeLocate:
        return '定位一次';
      case UserLocationType.locationTypeFollow:
        return '连续跟随';
      case UserLocationType.locationTypeMapRotate:
        return '地图转向';
      case UserLocationType.locationTypeLocationRotate:
        return '点随向转';
      case UserLocationType.locationTypeLocationRotateNoCenter:
        return '点转不居中';
      case UserLocationType.locationTypeFollowNoCenter:
        return '跟随不居中';
      case UserLocationType.locationTypeMapRotateNoCenter:
        return '图转不居中';
    }
  }

  static String _androidLine(UserLocationType t) {
    return t.isAndroidDocumentationOnly ? '文档含 Only' : '全量支持';
  }

  static String _iosLine(UserLocationType t) {
    if (t.hasIosNativeTrackingMapping) {
      return t.isAndroidDocumentationOnly ? '有映射·近似' : '有追踪映射';
    }
    return '不切换追踪';
  }
}
