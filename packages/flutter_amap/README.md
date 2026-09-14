# flutter_amap_plus

面向 Android、iOS 的 Flutter 高德地图插件，提供地图、覆盖物、定位、搜索、天气、路线查询与地点选择能力。

从 2.0.0 起，驾车/步行/骑行导航与智能巡航已迁移到独立的 [`flutter_amap_navi`](https://pub.dev/packages/flutter_amap_navi) 包。本包不导出任何导航 API，也不依赖导航包。

## 功能清单

以下清单与仓库根目录 `example/lib/features/map_3d/index.dart` 的菜单保持一致。`✅` 表示示例已经实现，`—` 表示尚未实现。

### 创建地图

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 显示地图 | ✅ | ✅ |
| 地图 ListView | ✅ | ✅ |
| 地图 Recycle | — | — |
| 显示地图（6 种实现地图的方式） | — | — |
| ViewPager TextureMapView | — | — |
| 地图多实例 | ✅ | ✅ |
| 室内地图功能 | — | — |
| AMapOptions 实现地图 | — | — |

### 地图交互

| 功能 | Android | iOS |
| --- | :---: | :---: |
| UI Settings 功能 | ✅ | ✅ |
| 地图 Logo 位置 | ✅ | ✅ |
| Layers 图层功能 | — | — |
| 手势交互 | ✅ | ✅ |
| Events 功能 | ✅ | ✅ |
| 地图 POI 点击功能 | ✅ | ✅ |
| 改变地图中心点 | ✅ | ✅ |
| 地图动画效果 | ✅ | ✅ |
| 自定义缩放 | ✅ | ✅ |
| 地图截屏功能 | ✅ | ✅ |
| 限制缩放级别功能 | ✅ | ✅ |
| 限制显示区域功能 | ✅ | ✅ |

### 地图上绘制

| 功能 | Android | iOS |
| --- | :---: | :---: |
| Markers 功能 | ✅ | ✅ |
| Marker 点击回调 | ✅ | ✅ |
| Marker 动画功能 | ✅ | ✅ |
| InfoWindow 功能 | ✅ | ✅ |
| 自定义 Marker | ✅ | ✅ |
| Location 几种模式 | ✅ | ✅ |
| Location 小蓝点自定义功能 | ✅ | ✅ |
| Location 小蓝点自定义模式 | ✅ | ✅ |
| Polylines 功能 | ✅ | ✅ |
| 绘制多彩线 | ✅ | ✅ |
| Polyline 样式增强 | ✅ | ✅ |
| 绘制大地曲线 | ✅ | ✅ |
| 绘制弧线 | ✅ | ✅ |
| NavigateArrow 功能 | ✅ | ✅ |
| Polygons 功能 | — | — |
| 热力图功能 | — | — |
| GroundOverlay 功能 | — | — |
| OpenGL 接口功能 | — | — |
| 自定义建筑物 | — | — |
| 海量点功能 | — | — |
| 绘制空心多边形功能 | — | — |
| 显示单个省份地图 | — | — |
| 粒子效果 | — | — |
| 粒子效果 + 天气示例 | — | — |
| 蜂窝热力图 | — | — |

### 查询地图数据

| 功能 | Android | iOS |
| --- | :---: | :---: |
| POI 关键字搜索 | ✅ | ✅ |
| POI 周边搜索 | ✅ | ✅ |
| POI ID 搜索功能 | — | — |
| 沿途搜索 | — | — |
| 输入提示 | — | — |
| POI 父子关系 | — | — |
| 天气查询 | ✅ | ✅ |
| 地理编码功能 | ✅ | ✅ |
| 逆地理编码功能 | ✅ | ✅ |
| 行政区划查询 | — | — |
| 行政区划边界查询 | — | — |
| Busline 公交查询 | — | — |
| 公交站点查询 | — | — |
| 云图检索 | — | — |

### 出行路线规划

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 驾车路径规划 | ✅ | ✅ |
| 驾车未来路径规划 | — | — |
| 步行路径规划 | ✅ | ✅ |
| 公交路径规划 | — | — |
| 骑行路径规划 | ✅ | ✅ |
| 货车路径规划 | — | — |
| 距离测量 | ✅ | ✅ |
| Route 路径规划 | — | — |

### 短串分享

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 短串分享 | — | — |

### 离线地图

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 离线地图功能（已过时） | — | — |
| 离线地图功能（组件包含 UI） | — | — |

### 地图计算工具

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 坐标系转换 | ✅ | ✅ |
| 经纬度转屏幕像素 | ✅ | ✅ |
| 两点间距离 | ✅ | ✅ |
| 点是否在多边形内 | ✅ | ✅ |

### 扩展功能

| 功能 | Android | iOS |
| --- | :---: | :---: |
| 轨迹纠偏功能 | — | — |
| 轨迹纠偏功能（便捷版） | — | — |
| 平滑移动 | ✅ | ✅ |

> 个别定位模式、蓝点样式和停止地图动画等能力在两端的原生语义存在差异，示例会按平台采用对应实现或最接近的兼容行为。

## 安装

```yaml
dependencies:
  flutter_amap_plus: ^2.0.6
```

## 初始化

请在展示地图前传入平台 Key，并使用应用实际取得的隐私授权状态：

```dart
import 'package:flutter_amap_plus/flutter_amap_plus.dart';

await AMapWidget.init(
  apiKey: ApiKey(
    iosKey: 'your-ios-key',
    androidKey: 'your-android-key',
  ),
  agreePrivacy: true,
);
```

创建地图：

```dart
AMapWidget(
  mapOptions: AMapMapOptions(
    initCameraPosition: CameraPosition(
      position: Position(latitude: 39.9087, longitude: 116.3975),
      zoom: 15,
    ),
  ),
  onMapCreated: (controller) async {
    await controller.waitForMapCompleted();
  },
)
```

搜索入口为 `AMapSearch`。路线查询仍属于地图搜索能力，继续使用 `PathPlanningStrategy`；它与导航包的 `NaviDrivingStrategy` 是彼此独立的类型。

## 轨迹平滑移动

`AMapController` 可以让 Marker 沿轨迹移动，并支持暂停、继续、停止以及进度监听。总时长必须是不小于 1 秒的整秒时长。

```dart
final progressSubscription =
    controller.onSmoothMoveMarkerProgress.listen((event) {
  debugPrint(
    '${event.value}: ${(event.progress * 100).toStringAsFixed(0)}%, '
    '剩余 ${event.remainingDistance.toStringAsFixed(1)} 米',
  );
});

await controller.startSmoothMoveMarker(
  marker: Marker(id: 'car', position: points.first),
  points: points,
  duration: const Duration(seconds: 30),
);

final status = controller.smoothMoveMarkerStatus('car');

await controller.pauseSmoothMoveMarker('car');
await controller.resumeSmoothMoveMarker('car');
await controller.stopSmoothMoveMarker('car');

await progressSubscription.cancel();
```

`onSmoothMoveMarkerCompleted` 在自然播放到终点时触发。`stopSmoothMoveMarker` 会停止播放并移除移动 Marker，不触发完成事件。

## 平台配置

### Android

- `minSdk` 24，Java/JVM 17。
- 宿主按使用场景声明网络、粗略/精确定位等权限，并在运行时请求定位权限。
- 如宿主依赖 Manifest Key，可在 `<application>` 中声明 `com.amap.api.v2.apikey`；Dart 初始化仍然必须调用。
- 本包固定使用 `com.amap.api:3dmap-location-search:11.2.100_loc11.2.100_sea9.8.1`，只包含 3D 地图、定位和搜索，不引入导航 SDK。

#### Release 混淆配置

高德 11.2.100 定位库会通过 JNI 和反射访问内部类。若宿主 release 构建启用了 R8/ProGuard，而规则没有覆盖新版的 `com.amap.location` 与 `com.amap.api.col` 命名空间，可能出现 debug 正常、release 首次定位或打开地图时直接闪退。典型日志包含 `libapssdk.so`、`JNI DETECTED ERROR IN APPLICATION: java_class == null` 和 `SIGABRT`。

插件源码已通过 `consumer-rules.pro` 自动向宿主传递规则。仍固定使用 `flutter_amap_plus 2.0.5` 或更早版本的应用，还应在 `android/app/proguard-rules.pro` 中确认包含：

```proguard
-keep class com.amap.api.col.** { *; }
-keep class com.amap.location.** { *; }
-dontwarn com.amap.**
-dontwarn com.autonavi.**
-dontwarn net.jafama.**
```

前两条防止 JNI/反射目标被改名或移除；后三条只忽略高德合包中未提供的可选能力告警，避免 R8 因 `GnssSoftLocator`、`FastMath` 等非当前合包必需类终止构建。

修改后必须用 release 包在真机上验证地图显示和定位；仅验证 debug 包不能覆盖这类问题。

### iOS

- 最低 iOS 12.0。
- 使用定位时，在 `Info.plist` 中提供 `NSLocationWhenInUseUsageDescription`；后台定位按业务补充 Always 权限和 Background Modes。
- 地图独立集成时固定使用 `AMap3DMap 11.2.100`、`AMapSearch 9.8.1`、`AMapLocation 2.12.2`，不引入 `AMapNavi`。
- 如果 iOS 宿主同时使用 `flutter_amap_navi`，在 `Podfile` 的 `flutter_ios_podfile_setup` 之前设置 `ENV['FLUTTER_AMAP_USE_NAVI_SDK'] = 'true'`，让地图插件复用 `AMapNavi` 内含的地图能力，避免重复链接 `AMap3DMap`。

可运行的最小工程见 [`example`](example/README.md)。完整地图与导航联合示例位于仓库根目录 `example/`。

## 2.0 迁移

从 1.x 升级时，请同时阅读仓库的 [迁移指南](https://github.com/zhiye1995/flutter_amap/blob/main/docs/migration-2.0.md)。关键变化是移除导航导出、移除 `AMapSdkConfig.preloadNaviIcons`，以及导航包必须单独初始化。

## License

见 [LICENSE](LICENSE)。

### 折线覆盖物

新增样式、逐段纹理/颜色编号、原地更新与迁移规则见 [折线、导航箭头和弧线](doc/polylines.md)。
