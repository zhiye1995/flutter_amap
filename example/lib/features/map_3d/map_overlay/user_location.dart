import 'package:flutter/foundation.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_example/core/utils/utils.dart';

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
    final isAndroidHost = defaultTargetPlatform == TargetPlatform.android;
    final isIosHost = defaultTargetPlatform == TargetPlatform.iOS;
    final platformHint = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => '当前设备：iOS。请在下方「iOS」一行选择；「Android」行仅作对照，不可点选。',
      TargetPlatform.android =>
        '当前设备：Android。请在下方「Android」一行选择；「iOS」行仅展示可映射子集，不可点选。',
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
                    if (isAndroidHost)
                      _buildModeStrip(
                        context,
                        title: 'Android（高德 MyLocationStyle）',
                        types: UserLocationType.values
                            .where((t) => t.hasAndroidMyLocationStyleMapping)
                            .toList(),
                        interactive: isAndroidHost,
                      ),
                    const SizedBox(height: 12),
                    if (isIosHost)
                      _buildModeStrip(
                        context,
                        title: 'iOS（MAUserTrackingMode 可映射）',
                        types: UserLocationType.values
                            .where((t) => t.hasIosNativeTrackingMapping)
                            .toList(),
                        interactive: isIosHost,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_modeTitle(t)),
                      tooltip: t.platformAvailabilityLabel,
                      selected: _mode == t,
                      onSelected: interactive
                          ? (selected) {
                              if (!selected) return;
                              setState(() => _mode = t);
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
}
