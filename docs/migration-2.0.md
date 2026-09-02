# flutter_amap 1.x → 2.0 迁移指南

2.0 将地图与导航拆成两个独立插件。地图相关 API 继续从 `flutter_amap` 导出；导航、巡航和导航事件从 `flutter_amap_navi` 导出。

## 1. 更新依赖

只使用地图：

```yaml
dependencies:
  flutter_amap: ^2.0.0
```

同时使用地图和导航：

```yaml
dependencies:
  flutter_amap: ^2.0.0
  flutter_amap_navi: ^1.0.0
```

## 2. 更新 import

```dart
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
```

`AMapNavi`、全部 `Navi*`/`Cruise*` 类型和导航事件只由第二个入口导出。

## 3. 分别初始化

旧版只初始化地图 SDK。新版在隐私授权后分别初始化，Key 和授权状态必须一致：

```dart
await AMapWidget.init(
  apiKey: ApiKey(iosKey: iosKey, androidKey: androidKey),
  agreePrivacy: agreed,
);

await AMapNavi.init(
  config: NaviSdkConfig(
    apiKey: NaviApiKey(iosKey: iosKey, androidKey: androidKey),
    agreePrivacy: agreed,
    preloadNaviIcons: true,
  ),
);
```

`AMapSdkConfig.preloadNaviIcons` 已删除，改由 `NaviSdkConfig.preloadNaviIcons` 控制。导航启动不再自动同意隐私协议；漏掉 `AMapNavi.init` 会收到明确的 `StateError`。

## 4. 替换导航专用类型

| 1.x 导航上下文 | 2.0 导航包 |
| --- | --- |
| `Position` | `NaviPosition` |
| `PathPlanningStrategy` | `NaviDrivingStrategy` |
| `ApiKey` / `AMapSdkConfig` | `NaviApiKey` / `NaviSdkConfig` |

联合应用需要在自己的边界显式转换，两个插件之间不会建立依赖：

```dart
NaviPosition toNaviPosition(Position value) => NaviPosition(
  latitude: value.latitude,
  longitude: value.longitude,
);

NaviDrivingStrategy toNaviStrategy(PathPlanningStrategy value) =>
    NaviDrivingStrategy.fromId(value.id);
```

## 5. 资源与平台配置

- 导航图标已迁入 `flutter_amap_navi`，内部路径为 `packages/flutter_amap_navi/assets/navigation/...`，应用无需复制。
- 天气图标继续由 `flutter_amap` 提供。
- Android 导航 Activity、主题和混淆规则由导航插件负责；宿主仍需声明并运行时申请实际使用的定位权限。
- iOS 宿主仍需在 `Info.plist` 中声明定位用途，后台导航按业务启用 Location Background Mode。
