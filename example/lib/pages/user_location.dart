import 'package:flutter_amap/amap_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:coordtransform/coordtransform.dart';

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

  /// 用于 FutureBuilder 的初始位置 Future
  late Future<Position> _initialPositionFuture;

  @override
  void initState() {
    super.initState();
    _initialPositionFuture = _getCurrentPosition();
  }

  /// 获取当前位置（WGS84 -> GCJ02 转换）
  Future<Position> _getCurrentPosition() async {
    // 检查定位服务是否开启
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('定位服务未开启');
    }

    // 检查定位权限
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw Exception('定位权限被拒绝');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('定位权限被永久拒绝，请在设置中开启');
    }

    // 获取当前位置（WGS84 坐标系）
    final geo.Position geoPosition = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
      ),
    );

    // WGS84 -> GCJ02（高德坐标系）转换
    // geolocator 返回的是 WGS84（GPS 标准坐标）
    // 高德地图使用 GCJ02（火星坐标系）
    final CoordResult gcj02 = CoordTransform.transformWGS84toGCJ02(
      geoPosition.longitude,
      geoPosition.latitude,
    );

    debugPrint(
      '坐标转换: WGS84(${geoPosition.latitude}, ${geoPosition.longitude}) '
      '-> GCJ02(${gcj02.lat}, ${gcj02.lon})',
    );

    return Position(
      latitude: gcj02.lat,
      longitude: gcj02.lon,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller?.destroy();
  }

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
                          zoom: 16,
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
      body: FutureBuilder<Position>(
        future: _initialPositionFuture,
        builder: (context, snapshot) {
          // 加载中状态
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在获取位置信息...'),
                ],
              ),
            );
          }

          // 错误状态
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('获取位置失败: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialPositionFuture = _getCurrentPosition();
                      });
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // 成功获取位置，显示地图
          final Position initialPosition = snapshot.data!;

          return AMapFlutter(
            // 使用 geolocator 获取的位置初始化相机位置
            initCameraPosition: CameraPosition(
              position: initialPosition,
              zoom: 16,
            ),
            showUserLocation: true,
            // 连续定位，蓝点跟随设备移动，但不自动移动地图中心
            userLocationStyle: UserLocationStyle(
              //   ///定位一次，且将视角移动到地图中心点
              //   locationTypeLocate,
              //
              //   ///连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
              //   locationTypeFollow,
              //
              //   ///连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
              //   locationTypeMapRotate,
              userLocationType: UserLocationType.locationTypeLocate,
            ),
            onUserLocationChange: (location) {
              _lastLocation = location;
              debugPrint(
                'onUserLocationChange::::${location.position.latitude}, ${location.position.longitude}',
              );
            },
            onMapCreated: (controller) async {
              setState(() {
                this.controller = controller;
              });
            },
          );
        },
      ),
    );
  }
}
