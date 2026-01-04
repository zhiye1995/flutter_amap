import 'package:flutter_amap/amap_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/add_remove_marker.dart';
import 'pages/map_controls.dart';
import 'pages/map_controls_position.dart';
import 'pages/map_events.dart';
import 'pages/map_features.dart';
import 'pages/map_layers.dart';
import 'pages/map_restriction.dart';
import 'pages/map_setting.dart';
import 'pages/map_styles.dart';
import 'pages/map_types.dart';
import 'pages/map_view.dart';
import 'pages/navigation.dart';
import 'pages/user_location.dart';

void main() {
  runApp(const App());
}

/// 主程序
class App extends StatefulWidget {
  /// 主程序构造函数
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AMapFlutter.init(
      apiKey: ApiKey(
        iosKey: "14cf569c80ddc89d84513331ed8c5164",
        androidKey: "fddb0c469571c9686915aade4e2a7a18",
        webKey: "fc9908dc4103f3d8274070bb34ab37af",
      ),
      agreePrivacy: true,
    );
    if (!kIsWeb) {
      await requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.status;
    // 已授权，直接返回
    if (status.isGranted) return;
    // 如果已经是永久拒绝状态，不要自动跳转设置页面
    // 避免每次启动都打开设置页面，应该让用户主动触发
    if (status.isPermanentlyDenied) return;
    // 首次请求权限
    await Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(),
          disabledColor: Colors.grey,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(),
          disabledColor: Colors.grey[400],
        ),
        home: FutureBuilder<void>(
          future: _bootstrapFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text("Init failed: ${snapshot.error}"),
                ),
              );
            }
            return Scaffold(
              body: ListView(children: [
                Item(
                  MapSettingPage.title,
                  (_) => const MapSettingPage(),
                ),
                if (kIsWeb)
                  Item(
                    MapStylesPage.title,
                    (_) => const MapStylesPage(),
                  )
                else
                  Item(
                    MapTypesPage.title,
                    (_) => const MapTypesPage(),
                  ),
                if (kIsWeb)
                  Item(
                    MapFeaturesPage.title,
                    (_) => const MapFeaturesPage(),
                  ),
                Item(
                  MapControlsPage.title,
                  (_) => const MapControlsPage(),
                ),
                Item(
                  MapControlsPositionPage.title,
                  (_) => const MapControlsPositionPage(),
                ),
                Item(
                  MapLayersPage.title,
                  (_) => const MapLayersPage(),
                ),
                Item(
                  MapViewPage.title,
                  (_) => const MapViewPage(),
                ),
                Item(
                  MapRestrictionPage.title,
                  (_) => const MapRestrictionPage(),
                ),
                Item(
                  MapEventsPage.title,
                  (_) => const MapEventsPage(),
                ),
                Item(
                  AddRemoveMarkerPage.title,
                  (_) => const AddRemoveMarkerPage(),
                ),
                Item(
                  UserLocationPage.title,
                  (_) => const UserLocationPage(),
                ),
                if (!kIsWeb)
                  Item(
                    NavigationPage.title,
                    (_) => const NavigationPage(),
                  ),
              ]),
            );
          },
        ),
      ),
    );
  }
}

/// 示例项目
class Item extends StatelessWidget {
  /// 示例标题
  final String title;

  /// 示例创建器
  final Widget Function(BuildContext) builder;

  /// 示例项目构造函数
  const Item(this.title, this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: builder)),
    );
  }
}
