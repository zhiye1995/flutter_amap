# flutter_amap_navi

面向 Android、iOS 的 Flutter 高德导航插件，支持驾车、步行、骑行导航，路线规划页面、智能巡航与导航事件流。

本包可独立使用，不依赖 `flutter_amap`。如果应用同时需要地图，请分别初始化两个插件，并向两边传入相同的平台 Key 与隐私授权状态。

## 安装

```yaml
dependencies:
  flutter_amap_navi: ^1.0.0
```

## 初始化与启动导航

```dart
import 'package:flutter_amap_navi/flutter_amap_navi.dart';

await AMapNavi.init(
  config: const NaviSdkConfig(
    apiKey: NaviApiKey(
      iosKey: 'your-ios-key',
      androidKey: 'your-android-key',
    ),
    agreePrivacy: true,
    preloadNaviIcons: true,
  ),
);

await AMapNavi.startNavigation(
  config: NaviConfig(
    naviType: NaviType.driver,
    start: NaviPoint(
      name: '起点',
      position: NaviPosition(latitude: 39.9841, longitude: 116.3075),
    ),
    end: NaviPoint(
      name: '终点',
      position: NaviPosition(latitude: 39.9087, longitude: 116.3975),
    ),
    drivingStrategy: NaviDrivingStrategy.drivingMultipleRoutesDefault,
  ),
);
```

`AMapNavi.init` 可重复调用，后一次配置会重新应用。未初始化就启动导航或巡航会抛出 `StateError`；插件不会替应用静默同意隐私协议。

## 与地图包联合使用

两个包刻意不共享 Dart 模型。请在应用边界显式转换：

```dart
NaviPosition toNaviPosition(Position value) => NaviPosition(
  latitude: value.latitude,
  longitude: value.longitude,
);

final naviStrategy = NaviDrivingStrategy.fromId(mapStrategy.id);
```

## 平台配置

### Android

- `minSdk` 24，Java/JVM 17。
- 宿主按业务声明网络、粗略/精确定位、前后台定位和 `WAKE_LOCK` 权限，并在运行时请求定位权限。
- 插件 Manifest 自动合并 `AMapFlutterRouteActivity` 及导航主题。
- 本包固定使用 `com.amap.api:navi-3dmap-location-search:11.2.100_3dmap11.2.100_loc11.2.100_sea9.8.1`。
- 与 `flutter_amap` 联合使用时，插件会自动用该导航合包替换纯地图合包，防止重复类。

### iOS

- 最低 iOS 12.0。
- 在 `Info.plist` 中声明定位用途；巡航或导航需要后台定位时，再启用 Location Background Mode 并提供 Always 权限说明。
- Pod 固定使用 `AMapNavi 11.2.100`。
- 与 `flutter_amap` 联合使用时，在宿主 `Podfile` 的 `flutter_ios_podfile_setup` 之前设置 `ENV['FLUTTER_AMAP_USE_NAVI_SDK'] = 'true'`，避免同时引入 `AMap3DMap`。

可运行的最小工程见 [`example`](example/README.md)。从原单包 API 迁移请阅读 [2.0 迁移指南](https://github.com/zhiye1995/flutter_amap/blob/main/docs/migration-2.0.md)。

## License

见 [LICENSE](LICENSE)。
