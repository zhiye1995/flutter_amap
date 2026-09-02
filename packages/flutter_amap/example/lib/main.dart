import 'package:flutter/material.dart';
import 'package:flutter_amap/flutter_amap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AMapWidget.init(
    apiKey: ApiKey(
      iosKey: const String.fromEnvironment('AMAP_IOS_KEY'),
      androidKey: const String.fromEnvironment('AMAP_ANDROID_KEY'),
    ),
    agreePrivacy: true,
  );
  runApp(const MapExampleApp());
}

class MapExampleApp extends StatelessWidget {
  const MapExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_amap')),
        body: AMapWidget(
          mapOptions: AMapMapOptions(
            initCameraPosition: CameraPosition(
              position: Position(latitude: 39.9087, longitude: 116.3975),
              zoom: 15,
            ),
          ),
        ),
      ),
    );
  }
}
