## 2.0.5

- 折线提交前折叠相邻重复坐标，避免高德轨迹/路线中的零长度段导致地图创建失败。
- 平滑移动示例不再把官方轨迹里的重复点直接传给折线覆盖物。

## 2.0.4

- 因 pub.dev 上 `flutter_amap` 名称已被占用，本版本以 `flutter_amap_plus` 发布。
- 因 2.0.3 已占用，重新发布包含 iOS polyline Swift 编译超时修复的版本。
- 内容覆盖 2.0.3：逐段纹理与折线样式增强、Marker `zIndex`，以及折线绘制校验。

## 2.0.3

- 统一双端逐段纹理编号，新增独立颜色编号、端点/连接/虚线类型及折线点击回调。
- 同 ID 折线和导航箭头支持原地更新，iOS 层级调整不再重建所有折线。
- 绘制前校验几何、样式组合和索引；增加严格地图等待及示例失败重试。
- Marker 新增 `zIndex`，可控制与折线等覆盖物的叠放顺序。
- 修复 iOS 复杂 polyline 表达式导致的 Swift 编译超时。
- 迁移注意：textureIndexes 不再接受 iOS 坐标边界含义；渐变要求每个点一个颜色。详见 [折线文档](doc/polylines.md)。

## 2.0.2

- 补充 2.0.1 版本变更记录并修复发布校验问题。

## 2.0.1

- 修复依赖源配置并完善 2.0 版本后的发布配置。

## 2.0.0

- Move the package into a Dart Pub Workspace.
- Keep map, location, search, weather, route query and place picker APIs.
- Move navigation and cruise APIs into the independent `flutter_amap_navi` package.
- Remove `AMapSdkConfig.preloadNaviIcons`; navigation assets are now owned by the navigation package.
- Use map-only Android and iOS SDK dependencies so map-only apps do not bundle AMap navigation.
- Replace Android's deprecated `SmoothMoveMarker` with `MovingPointOverlay`, add reliable pause/resume cleanup, and expose throttled smooth-move progress events on Android and iOS.

## 1.0.11

- Migrate Android build to Flutter 3.44: AGP 9.0.1, Gradle 9.1.0, Kotlin 2.3.20.
- Convert plugin `android/` Gradle scripts from Groovy to Kotlin DSL (`.kts`).
- Raise Android `minSdk` from 21 to 24; require Java/JVM 17.
- Align example app with Flutter 3.44 built-in Kotlin transition flags (`android.builtInKotlin=false`, `android.newDsl=false`).

## 0.7.0

Migrate deprecated "onBackground" to "onSurface".

Move conversion from "LatLng" to "Position" to shared utils.

## 0.6.1

Update annotation view in iOS to fix an issue where tapping on the left side of the custom icon did not trigger the "didAnnotationViewTapped" method.

## 0.6.0

Remove ```geolocator``` dependency and upgrade dependencies.

Add ```/android/app/.cxx``` directory in ```.gitignore``` file.

Upgrade ```Gradle``` and ```Android Gradle Plugin``` versions.

Update ```compileSdk``` version in Android.

Stop exporting ```latlong2``` dependency.

Upgrade to use Dart3.3 new feature as using extension type to do js interop.

Add JS function name in JS annotation and remove unnecessary JS annotation.

## 0.5.3

Use "setVisibleMapRect" to move camera in iOS, as edge padding can be set.

## 0.5.2

Separate ```MessageCodec``` as a standalone file.

Remove ```updateMarker``` api.

Add functionality of showing custom marker icon.

Add ```size``` property in ```Bitmap``` and add ```bitmap``` property in ```Marker```.

Add marker icon as asset and customize marker icon of map in example app.

Scale marker icon size on iOS platform.

## 0.5.1

Add "minZoomLevel" and "maxZoomLevel" property of "AMapFlutter".

## 0.5.0

Add "initFitPositions" in "AMapFlutter".

Add "fitPositions" field in "MapInitConfig".

Use "_AMapApiCodec" as "creationParamsCodec" when creating "AndroidView" and "UiKitView".

When map initializing completed, move camera to fit positions in Android and iOS.

Recover "Position" custom type.

Add "EdgePadding" utility and expose utilities.

Remove the deprecated option 'android.enableR8'.

Upgrade android gradle plugin and compileSdk.

## 0.4.1

Include "latlong2" dependency in "amap_flutter" dependency.

## 0.4.0

Use "geolocator" dependency instead of self defined "Position".

Upgrade Android gradle configuration and iOS configuration.

## 0.3.2

Make ```position``` of ```CameraPosition``` as un-nullable.

## 0.3.1

Update README.md.

## 0.3.0

## 0.2.2

Change return type of "init" method of "AMapFlutter" to "Future".

## 0.2.1

Change ```MapView``` to ```TextureMapView```.

## 0.2.0

Use "LatLng" from "latlong2" dependency in public apis.

## 0.1.0

Change the direction of map control offset to center on iOS.

Extract checking platform as a common utility.

Upgrade dependencies, and update environment restriction.

Update example app.

Clean up code.

## 0.0.2

Add GitHub Actions configuration to automatically publish to pub.dev from Github.

Lint code and reformat code.

## 0.0.1

Initial release.
