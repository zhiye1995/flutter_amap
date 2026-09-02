import 'package:flutter/material.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AMapNavi.init(
    config: NaviSdkConfig(
      apiKey: NaviApiKey(
        iosKey: const String.fromEnvironment('AMAP_IOS_KEY'),
        androidKey: const String.fromEnvironment('AMAP_ANDROID_KEY'),
      ),
      agreePrivacy: true,
    ),
  );
  runApp(const NaviExampleApp());
}

class NaviExampleApp extends StatelessWidget {
  const NaviExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_amap_navi')),
        body: Center(
          child: FilledButton(
            onPressed: () => AMapNavi.startNavigation(
              config: NaviConfig(
                naviType: NaviType.driver,
                start: NaviPoint(
                  name: '起点',
                  position: NaviPosition(
                    latitude: 39.9841,
                    longitude: 116.3075,
                  ),
                ),
                end: NaviPoint(
                  name: '终点',
                  position: NaviPosition(
                    latitude: 39.9087,
                    longitude: 116.3975,
                  ),
                ),
              ),
            ),
            child: const Text('启动导航'),
          ),
        ),
      ),
    );
  }
}
