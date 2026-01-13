import 'package:flutter/cupertino.dart';
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
import 'pages/place_picker.dart';
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
        // androidKey: "25304ab4b426667f31055e3e5e4808a8", // home
        androidKey: "fddb0c469571c9686915aade4e2a7a18", // company
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
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
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
        children: const [
          _CategorySection(
            title: '地图',
            icon: Icons.map,
            children: [
              _SubCategorySection(
                title: '创建地图',
                children: [
                  _FeatureItem(
                    title: '显示地图',
                    isCompleted: true,
                    page: MapSettingPage(),
                  ),
                  _FeatureItem(
                    title: '显示定位蓝点',
                    isCompleted: true,
                    page: UserLocationPage(),
                  ),
                  _FeatureItem(
                    title: '显示室内地图',
                    isCompleted: true,
                    page: MapLayersPage(),
                  ),
                  _FeatureItem(
                    title: '切换地图图层',
                    isCompleted: true,
                    page: MapTypesPage(),
                  ),
                  _FeatureItem(
                    title: '使用离线地图',
                    isCompleted: true,
                    page: MapSettingPage(),
                  ),
                  _FeatureItem(
                    title: '显示英文地图',
                    isCompleted: true,
                    page: MapSettingPage(),
                  ),
                  _FeatureItem(
                    title: '自定义地图',
                    isCompleted: true,
                    page: MapStylesPage(),
                    webOnly: true,
                  ),
                  _FeatureItem(
                    title: '地图显示要素',
                    isCompleted: true,
                    page: MapFeaturesPage(),
                    webOnly: true,
                  ),
                  _FeatureItem(
                    title: '地图限制区域',
                    isCompleted: true,
                    page: MapRestrictionPage(),
                  ),
                ],
              ),
              _SubCategorySection(
                title: '与地图交互',
                children: [
                  _FeatureItem(
                    title: '控件交互',
                    isCompleted: true,
                    page: MapControlsPage(),
                  ),
                  _FeatureItem(
                    title: '控件位置调整',
                    isCompleted: true,
                    page: MapControlsPositionPage(),
                  ),
                  _FeatureItem(
                    title: '手势交互',
                    isCompleted: true,
                    page: MapSettingPage(),
                  ),
                  _FeatureItem(
                    title: '调用方法交互',
                    isCompleted: true,
                    page: MapViewPage(),
                  ),
                  _FeatureItem(
                    title: '地图截屏功能',
                    isCompleted: true,
                    page: MapEventsPage(),
                  ),
                ],
              ),
              _SubCategorySection(
                title: '在地图上绘制',
                children: [
                  _FeatureItem(
                    title: '绘制点标记',
                    isCompleted: true,
                    page: AddRemoveMarkerPage(),
                  ),
                  _FeatureItem(
                    title: '绘制折线',
                    isCompleted: true,
                    page: MapEventsPage(),
                  ),
                  _FeatureItem(
                    title: '绘制面',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '轨迹纠偏',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '点平滑移动',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '绘制海量点图层',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '地图计算工具',
                children: [
                  _FeatureItem(
                    title: '坐标转换',
                    isCompleted: true,
                    page: MapViewPage(),
                  ),
                  _FeatureItem(
                    title: '距离/面积计算',
                    isCompleted: true,
                    page: MapViewPage(),
                  ),
                  _FeatureItem(
                    title: '距离测量',
                    isCompleted: true,
                    page: MapViewPage(),
                  ),
                ],
              ),
            ],
          ),
          _CategorySection(
            title: '搜索',
            icon: Icons.search,
            children: [
              _SubCategorySection(
                title: '获取地图数据',
                children: [
                  _FeatureItem(
                    title: '获取POI数据',
                    isCompleted: true,
                    page: PlacePickerPage(),
                    mobileOnly: true,
                  ),
                  _FeatureItem(
                    title: '获取地址描述数据',
                    isCompleted: true,
                    page: PlacePickerPage(),
                    mobileOnly: true,
                  ),
                  _FeatureItem(
                    title: '获取行政区划数据',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '获取公交数据',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '获取天气数据',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '获取业务数据（云图功能）',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '获取交通态势信息',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '出行线路规划',
                children: [
                  _FeatureItem(
                    title: '驾车出行路线规划',
                    isCompleted: true,
                    page: NavigationPage(),
                    mobileOnly: true,
                  ),
                  _FeatureItem(
                    title: '步行出行路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '公交出行路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '骑行出行路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '货车出行路线规划',
                    isCompleted: false,
                  ),
                ],
              ),
            ],
          ),
          _CategorySection(
            title: '导航',
            icon: Icons.navigation,
            children: [
              _SubCategorySection(
                title: '导航组件',
                children: [
                  _FeatureItem(
                    title: '使用导航组件',
                    isCompleted: true,
                    page: NavigationPage(),
                    mobileOnly: true,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '出行路线规划',
                children: [
                  _FeatureItem(
                    title: '驾车路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '货车路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '步行路线规划',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '骑行路线规划',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '在地图上导航',
                children: [
                  _FeatureItem(
                    title: '实时导航',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '模拟导航',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '智能巡航',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '传入外部GPS数据',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '导航UI定制化',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: 'HUD导航模式',
                children: [
                  _FeatureItem(
                    title: 'HUD导航',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '获取导航数据',
                children: [
                  _FeatureItem(
                    title: '导航数据',
                    isCompleted: false,
                  ),
                ],
              ),
              _SubCategorySection(
                title: '语音播报',
                children: [
                  _FeatureItem(
                    title: '语音合成',
                    isCompleted: false,
                  ),
                ],
              ),
            ],
          ),
          _CategorySection(
            title: '定位',
            icon: Icons.my_location,
            children: [
              _SubCategorySection(
                title: '获取位置',
                children: [
                  _FeatureItem(
                    title: '获取定位数据',
                    isCompleted: true,
                    page: UserLocationPage(),
                  ),
                ],
              ),
              _SubCategorySection(
                title: '辅助功能',
                children: [
                  _FeatureItem(
                    title: '地理围栏',
                    isCompleted: false,
                  ),
                  _FeatureItem(
                    title: '坐标转换与位置判断',
                    isCompleted: false,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 一级分类区块
class _CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      initiallyExpanded: true,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: children,
    );
  }
}

/// 二级分类区块
class _SubCategorySection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SubCategorySection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.only(left: 24),
      children: children,
    );
  }
}

/// 功能项
class _FeatureItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final Widget? page;
  final bool webOnly;
  final bool mobileOnly;

  const _FeatureItem({
    required this.title,
    required this.isCompleted,
    this.page,
    this.webOnly = false,
    this.mobileOnly = false,
  });

  bool get _isAvailable {
    if (!isCompleted) return false;
    if (webOnly && !kIsWeb) return false;
    if (mobileOnly && kIsWeb) return false;
    return page != null;
  }

  String get _platformHint {
    if (webOnly) return ' (仅Web)';
    if (mobileOnly) return ' (仅移动端)';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? Colors.green : colorScheme.outline,
        size: 20,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _isAvailable
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          if (_platformHint.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _platformHint.trim(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
      trailing: _isAvailable
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.3),
              size: 20,
            )
          : isCompleted
              ? null
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '开发中',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
      onTap: () {
        if (_isAvailable && page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page!),
          );
        } else if (!isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「$title」功能正在开发中，敬请期待！'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (webOnly && !kIsWeb) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「$title」功能仅在 Web 端可用'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (mobileOnly && kIsWeb) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「$title」功能仅在移动端可用'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}
