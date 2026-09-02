import 'package:flutter/cupertino.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
import 'package:flutter/material.dart';
import 'core/utils/utils.dart';
import 'features/map_3d/index.dart';
import 'features/navigation/index.dart';

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
    await AMapWidget.init(
      apiKey: ApiKey(
        iosKey: "14cf569c80ddc89d84513331ed8c5164",
        androidKey: "fddb0c469571c9686915aade4e2a7a18", // home
        // androidKey: "fddb0c469571c9686915aade4e2a7a18", // company
      ),
      agreePrivacy: true,
    );
    await AMapNavi.init(
      config: NaviSdkConfig(
        apiKey: NaviApiKey(
          iosKey: "14cf569c80ddc89d84513331ed8c5164",
          androidKey: "fddb0c469571c9686915aade4e2a7a18",
        ),
        agreePrivacy: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        builder: LoadingUtil.init(),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
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
            return const FeatureListPage();
          },
        ),
      ),
    );
  }
}

/// 功能列表页面
class FeatureListPage extends StatelessWidget {
  const FeatureListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高德地图 Flutter 插件'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryCard(
            title: '3D地图目录',
            subtitle: '包含地图显示、图层、覆盖物、定位等功能',
            icon: Icons.map,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const Map3dIndexPage()),
            ),
          ),
          const SizedBox(height: 16),
          _CategoryCard(
            title: '导航目录',
            subtitle: '包含路线规划、导航组件、HUD模式等功能',
            icon: Icons.navigation,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const NavigationIndexPage()),
            ),
          ),
        ],
      ),
    );
  }
}

/// 大类卡片
class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
