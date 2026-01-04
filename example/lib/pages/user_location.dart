import 'package:flutter_amap/amap_flutter.dart';
import 'package:flutter/material.dart';

/// 地图定位页面
class UserLocationPage extends StatefulWidget {
  /// 地图定位页面构造函数
  const UserLocationPage({super.key});

  /// 地图定位页面标题
  static const title = '地图定位';

  @override
  State<UserLocationPage> createState() => _UserLocationPageState();
}

class _UserLocationPageState extends State<UserLocationPage> {
  AMapController? controller;
  Location? _lastLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UserLocationPage.title),
        actions: [
          TextButton(
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
                          heading: location.heading,
                          zoom: 13,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "定位获取失败：$e\n"
                            "请确认已授予定位权限，并等待 onUserLocationChange 回调触发后再点击。",
                          ),
                        ),
                      );
                    }
                  },
            child: const Text("当前位置"),
          ),
        ],
      ),
      body: AMapFlutter(
        showUserLocation: true,
        onUserLocationChange: (location) {
          _lastLocation = location;
          debugPrint(
            '${location.position.latitude}, ${location.position.longitude}',
          );
        },
        onMapCreated: (controller) async {
          setState(() {
            this.controller = controller;
          });
        },
      ),
    );
  }
}
