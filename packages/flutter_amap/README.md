# flutter_amap

面向 Android、iOS 的 Flutter 高德地图插件，提供地图、覆盖物、定位、搜索、天气、路线查询与地点选择能力。

从 2.0.0 起，驾车/步行/骑行导航与智能巡航已迁移到独立的 [`flutter_amap_navi`](https://pub.dev/packages/flutter_amap_navi) 包。本包不导出任何导航 API，也不依赖导航包。

## 安装

```yaml
dependencies:
  flutter_amap: ^2.0.0
```

## 初始化

请在展示地图前传入平台 Key，并使用应用实际取得的隐私授权状态：

```dart
import 'package:flutter_amap/flutter_amap.dart';

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
