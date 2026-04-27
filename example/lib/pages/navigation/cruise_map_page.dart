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
  AMapController? _controller;
  Location? _lastLocation;

  @override
  void dispose() {
    if (AMapNavi.isCruising) {
      unawaited(AMapNavi.stopCruiseMode());
    }
    _controller?.destroy();
    super.dispose();
  }

  Future<void> _startCruise() async {
    try {
      await AMapNavi.startCruiseMode(mode: CruiseBroadcastMode.both);
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
              userLocationType: Platform.isAndroid ? UserLocationType.locationTypeLocationRotate : UserLocationType.locationTypeMapRotate,
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
                child: Material(
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
                                    final Location loc = _lastLocation ??
                                        await _controller!.waitForUserLocation(
                                          timeout:
                                              const Duration(seconds: 10),
                                        );
                                    await _controller!.moveCamera(
                                      CameraPosition(
                                        position: loc.position,
                                        zoom: 16,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('定位失败：$e'),
                                        behavior: SnackBarBehavior.floating,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
