# 地图与导航联合示例

此示例同时使用 `flutter_amap_plus` 和 `flutter_amap_navi`，演示地图、搜索、地点选择、路线规划和导航能力。

## 在应用中引用

在宿主应用的 `pubspec.yaml` 中加入：

```yaml
dependencies:
  flutter_amap_plus: ^2.0.5
  flutter_amap_navi: ^1.0.2
```

执行 `flutter pub get` 后分别导入：

```dart
import 'package:flutter_amap_plus/flutter_amap_plus.dart';
import 'package:flutter_amap_navi/flutter_amap_navi.dart';
```

两个插件需要分别初始化，并传入相同的平台 Key 和同一份真实隐私授权状态：

```dart
await AMapWidget.init(
  apiKey: ApiKey(iosKey: iosKey, androidKey: androidKey),
  agreePrivacy: agreed,
);

await AMapNavi.init(
  config: NaviSdkConfig(
    apiKey: NaviApiKey(iosKey: iosKey, androidKey: androidKey),
    agreePrivacy: agreed,
  ),
);
```

## Android release 配置

使用 `flutter_amap_plus: ^2.0.5` 与 `flutter_amap_navi: ^1.0.2` 时，请在宿主的 `android/app/proguard-rules.pro` 中确认包含以下规则，避免 debug 正常而 release 在高德定位初始化时闪退：

```proguard
-keep class com.amap.api.col.** { *; }
-keep class com.amap.location.** { *; }
-dontwarn com.amap.**
-dontwarn com.autonavi.**
-dontwarn net.jafama.**
```

插件后续版本会通过 `consumer-rules.pro` 自动传递这些规则；当前版本建议宿主显式配置，并使用 release 包进行真机验证。两条 `-keep` 防止 JNI/反射目标被改名或移除，三条 `-dontwarn` 用于高德合包未提供的可选能力，避免 R8 因缺少 `GnssSoftLocator`、`FastMath` 等类而终止构建。

## 运行示例

在仓库根目录执行：

```shell
flutter pub get
flutter run -d <device-id> --dart-define=AMAP_ANDROID_KEY=<your-key>
```

iOS 使用 `AMAP_IOS_KEY`。iOS 同时引用地图和导航时，还需按两个插件 README 的说明配置 `FLUTTER_AMAP_USE_NAVI_SDK`。
