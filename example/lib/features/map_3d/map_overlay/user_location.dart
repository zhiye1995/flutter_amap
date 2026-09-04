import 'package:flutter/foundation.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

/// 演示 [UserLocationStyle.userLocationType] 的平台模式及语义差异。
///
/// Android 完整映射高德 `MyLocationStyle` 的八种模式；iOS 仅提供
/// `none`、`follow`、`followWithHeading` 三种原生追踪能力。
class UserLocationPage extends StatefulWidget {
  const UserLocationPage({super.key});

  static const title = 'Location几种模式';

  @override
  State<UserLocationPage> createState() => _UserLocationPageState();
}

class _UserLocationPageState extends State<UserLocationPage> {
  AMapController? controller;
  Location? _lastLocation;
  static UserLocationType? _lastSelectedMode;
  UserLocationType _mode = _restoreMode();

  @override
  void dispose() {
    controller?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAndroidHost = defaultTargetPlatform == TargetPlatform.android;
    final isIosHost = defaultTargetPlatform == TargetPlatform.iOS;
    final platformHint = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => '当前设备：iOS。只有 iOS 行可操作；Android 行用于语义对照。',
      TargetPlatform.android => '当前设备：Android。只有 Android 行可操作；iOS 行用于语义对照。',
      _ => '当前设备：${defaultTargetPlatform.name}。两行均为对照，不可点选。',
    };

    return Scaffold(
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
                          final Location location =
                              _lastLocation ??
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
                          LoadingUtil.showError(
                            '定位获取失败：$e\n'
                            '请确认已授予定位权限，并等待 onUserLocationChange 后再试。',
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
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      platformHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    _buildModeStrip(
                      context,
                      title: 'Android（高德 MyLocationStyle）',
                      types: UserLocationType.values
                          .where((t) => t.hasAndroidMyLocationStyleMapping)
                          .toList(),
                      interactive: isAndroidHost,
                      androidSemantics: true,
                    ),
                    const SizedBox(height: 12),
                    _buildModeStrip(
                      context,
                      title: 'iOS（MAUserTrackingMode）',
                      types: UserLocationType.values
                          .where((t) => t.hasIosNativeTrackingMapping)
                          .toList(),
                      interactive: isIosHost,
                      androidSemantics: false,
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

  Widget _buildModeStrip(
    BuildContext context, {
    required String title,
    required List<UserLocationType> types,
    required bool interactive,
    required bool androidSemantics,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_modeTitle(t, android: androidSemantics)),
                      tooltip: _modeDescription(t, android: androidSemantics),
                      selected: interactive && _mode == t,
                      onSelected: interactive
                          ? (selected) {
                              if (!selected) return;
                              setState(() {
                                _mode = t;
                                _lastSelectedMode = t;
                              });
                            }
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static UserLocationType _restoreMode() {
    final last = _lastSelectedMode;
    if (last != null && _isSelectableOnHost(last)) {
      return last;
    }
    return UserLocationType.locationTypeFollow;
  }

  static bool _isSelectableOnHost(UserLocationType type) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => type.hasAndroidMyLocationStyleMapping,
      TargetPlatform.iOS => type.hasIosNativeTrackingMapping,
      _ => false,
    };
  }

  static String _modeTitle(UserLocationType t, {required bool android}) {
    if (!android) {
      return switch (t) {
        UserLocationType.locationTypeShow => '持续显示',
        UserLocationType.locationTypeLocate => '首次居中',
        UserLocationType.locationTypeFollow => '连续居中',
        UserLocationType.locationTypeMapRotate => '方向跟随',
        _ => '不支持',
      };
    }
    return switch (t) {
      UserLocationType.locationTypeShow => '单次不居中',
      UserLocationType.locationTypeLocate => '单次居中',
      UserLocationType.locationTypeFollow => '连续居中',
      UserLocationType.locationTypeMapRotate => '地图随向',
      UserLocationType.locationTypeLocationRotate => '蓝点随向',
      UserLocationType.locationTypeLocationRotateNoCenter => '蓝点随向·不居中',
      UserLocationType.locationTypeFollowNoCenter => '连续·不居中',
      UserLocationType.locationTypeMapRotateNoCenter => '地图随向·不居中',
    };
  }

  static String _modeDescription(UserLocationType t, {required bool android}) {
    if (!android) {
      return switch (t) {
        UserLocationType.locationTypeShow => '持续更新蓝点，相机不跟随（none）',
        UserLocationType.locationTypeLocate => '首次位置更新时居中，随后取消相机跟随；定位仍继续',
        UserLocationType.locationTypeFollow => '持续更新蓝点并保持居中（follow）',
        UserLocationType.locationTypeMapRotate =>
          '持续居中，地图按设备方向旋转（followWithHeading）',
        _ => 'iOS 没有等价的原生追踪模式',
      };
    }
    switch (t) {
      case UserLocationType.locationTypeShow:
        return '获取一次位置，不移动地图中心，成功后停止定位';
      case UserLocationType.locationTypeLocate:
        return '获取一次位置并移动到地图中心，成功后停止定位';
      case UserLocationType.locationTypeFollow:
        return '持续更新蓝点并保持居中，默认每秒定位一次';
      case UserLocationType.locationTypeMapRotate:
        return '持续居中，地图按设备方向旋转';
      case UserLocationType.locationTypeLocationRotate:
        return '持续居中，蓝点按设备方向旋转';
      case UserLocationType.locationTypeLocationRotateNoCenter:
        return '蓝点按设备方向旋转，不移动地图中心';
      case UserLocationType.locationTypeFollowNoCenter:
        return '持续更新蓝点，不移动地图中心';
      case UserLocationType.locationTypeMapRotateNoCenter:
        return '地图按设备方向旋转，不移动地图中心';
    }
  }
}
