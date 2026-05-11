# Flutter 高德地图插件

本项目由 [amap_flutter](https://pub.dev/packages/amap_flutter) 原作者改编而来，目标是在 Flutter 中统一接入高德地图、搜索、定位、路线规划与导航能力，支持 Android、iOS 。

Android 导航 SDK 下载地址：https://lbs.amap.com/api/android-navi-sdk/download

## 当前状态

功能完成度以 `example/lib/features` 示例为准：

- `example/lib/features/map_3d`：地图创建、交互、覆盖物、定位、天气、路线规划等示例。
- `example/lib/features/navigation`：导航组件、地点选择、智能巡航、导航事件和图标收集示例。
- `example/lib/core/utils`：示例 App 通用工具，包含平台判断、Context 扩展和基于 `flutter_easyloading` 的轻提示封装。

## 快速开始

### 初始化 SDK

在 App 启动时先初始化高德 Key 与隐私协议状态：

```dart
await AMapWidget.init(
  apiKey: ApiKey(
    iosKey: '你的 iOS Key',
    androidKey: '你的 Android Key',
  ),
  agreePrivacy: true,
);
```

Android 导航、路线规划等原生页面还建议在宿主 `AndroidManifest.xml` 的 `<application>` 内配置高德 Key：

```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="你的 Android Key" />
```

### 创建地图

```dart
AMapWidget(
  mapOptions: AMapMapOptions(
    initCameraPosition: CameraPosition(
      position: Position(latitude: 39.984120, longitude: 116.307484),
      zoom: 16,
    ),
    showTraffic: true,
  ),
  gestureOptions: const AMapGestureOptions(
    dragEnable: true,
    zoomEnable: true,
  ),
  uiOptions: const AMapUiOptions(
    compassControlEnabled: true,
    scaleControlEnabled: true,
  ),
  onMapCreated: (controller) async {
    await controller.waitForMapCompleted();
  },
)
```

`AMapWidget` 仍兼容旧的平铺参数；新代码推荐优先使用分组 options，避免 Android、iOS 参数混在同一层。

## AMapWidget API 分层

- 核心地图配置：`AMapMapOptions`，包含地图类型、初始视野、缩放范围、交通图层、室内图、卫星图、路网图、自定义离线样式等。
- 手势配置：`AMapGestureOptions`，包含拖拽、缩放、俯仰、旋转。
- 控件配置：`AMapUiOptions`，包含指南针、比例尺、缩放控件、Logo 和控件位置。
- 定位配置：`AMapLocationOptions`，包含定位蓝点、定位按钮和定位样式。
- SDK 初始化配置：`AMapSdkConfig`，用于集中传入 `ApiKey`、隐私同意状态和导航图标预加载开关。

## 功能清单

### 地图

- [x] 显示地图、多地图实例、ListView 中复用地图
- [x] 初始相机、视野移动、区域适配、缩放控制
- [x] 地图加载完成等待：`waitForMapCompleted`
- [x] 地图限制区域：`setRestrictRegion` / `removeRestrictRegion`
- [x] 地图截屏：`takeMapSnapshot`
- [x] 比例尺获取：`getScalePerPixel`
- [x] 停止相机动画：`stopCameraAnimation`
- [x] 自定义离线样式

### 地图交互事件

- [x] 点击、长按
- [x] 相机变化、移动开始/移动中/移动结束
- [x] 缩放、旋转事件
- [x] POI 点击事件
- [x] Marker 点击与拖拽事件
- [x] 用户定位变化事件

### 覆盖物

- [x] Marker 声明式集合：`markers`
- [x] Controller 增删 Marker：`addMarker` / `removeMarker`
- [x] 自定义 Marker 图标：asset、bytes、size、CustomPainter 栅格化
- [x] Marker 点击回调
- [x] Marker 动画：呼吸、旋转、透明度、生长、往返移动
- [x] Marker 动画取消：`cancelMarkerAnimation`
- [x] InfoWindow / callout：`showInfoWindow` / `hideInfoWindow`
- [x] Polyline 声明式集合与 Controller 增删
- [x] 多彩线、渐变线、大地曲线
- [x] Arc 弧线
- [x] Polygon 多边形
- [ ] 轨迹纠偏
- [ ] 点平滑移动
- [ ] 海量点图层

### 定位

- [x] 显示定位蓝点
- [x] 获取当前定位：`getUserLocation`
- [x] 等待首次定位：`waitForUserLocation`
- [x] 定位模式切换：跟随、旋转、定位一次等
- [x] 自定义定位样式：图标、精度圈颜色、锚点、定位频次、iOS 蓝点表现
- [ ] 地理围栏

### 搜索与地点选择

- [x] 输入提示：`AMapSearch.requestInputTips`
- [x] 周边 POI 搜索：`AMapSearch.searchPOIAround`
- [x] 地图地点选择器：`AMapMapPlacePicker`
- [x] 底部弹窗地点选择器：`AMapPlacePicker`
- [x] 实时天气查询：`searchWeatherLive`
- [x] 天气预报查询：`searchWeatherForecast`
- [x] 基于当前位置查询天气
- [ ] 行政区划查询
- [ ] 公交数据查询
- [ ] 云图业务数据
- [ ] 交通态势查询

### 导航

- [x] 导航组件启动：`AMapNavi.startNavigation`
- [x] 路线规划页与直接导航页：`NaviPageType.route` / `NaviPageType.navi`
- [x] 驾车、步行、骑行导航类型枚举：`NaviType`
- [x] 起点、终点、途经点配置：`NaviPoint`
- [x] 车牌号、摩托车排量等导航配置：`NaviConfig`
- [x] 导航状态监听：`isNavigatingListenable`
- [x] 停止导航：`stopNavigation`
- [x] 智能巡航：`startCruiseMode` / `stopCruiseMode`
- [x] 巡航状态监听：`isCruisingListenable`
- [x] 导航事件流：初始化、路线计算、偏航、拥堵重算、到达目的地、退出导航等
- [x] 导航引导信息：剩余距离、剩余时间、下一路名、转向图标等
- [x] 导航图标资源预加载与原生图标缓存
- [x] 巡航道路设施、巡航统计、巡航拥堵信息事件
- [ ] HUD 导航
- [ ] 完全自定义导航 UI 示例
- [ ] 外部 GPS 数据导航

## 示例工程

示例工程入口：`example/lib/main.dart`。

目录结构：

```text
example/lib
├── core
│   └── utils
│       ├── context_ext.dart
│       ├── loading_util.dart
│       ├── platform_util.dart
│       └── utils.dart
├── features
│   ├── map_3d
│   │   ├── create_map
│   │   ├── map_interaction
│   │   ├── map_overlay
│   │   ├── map_query
│   │   └── route_planning
│   └── navigation
└── main.dart
```

示例 App 使用 `flutter_easyloading` 统一替代页面中的 `ScaffoldMessenger` 轻提示：

```dart
CupertinoApp(
  builder: LoadingUtil.init(),
  home: const FeatureListPage(),
)
```

## 平台能力矩阵

| 能力 | Android | iOS | 说明 |
| --- | --- | --- | --- |
| 创建地图、多地图实例 | 支持 | 支持 |  |
| 相机移动、缩放、限制区域 | 支持 | 支持 | `moveCamera` 默认等待地图加载完成 |
| 地图交互事件 | 支持 | 支持 |  |
| Marker 声明式集合 | 支持 | 支持 | `markers` 按 `id` 做增删/替换 |
| Marker 动画 | 支持 | 支持 | Android 使用原生 Marker 动画，iOS 使用 UIView 动画 |
| InfoWindow / callout | 支持 | 支持 | 依赖 Marker 的 `title` / `snippet` |
| Polyline/Arc/Polygon | 支持 | 支持 | `polylines`、`arcs`、`polygons` 按 `id` 做增删/替换 |
| 定位蓝点 | 支持 | 支持 | 需业务侧先申请运行时定位权限 |
| 自定义离线样式 | 支持 | 支持 | 启用时会切回标准底图 |
| 搜索、POI、天气 | 支持 | 支持 | 以 example 与原生 SDK 能力为准 |
| 导航组件 | 支持 | 支持 |  |
| 智能巡航 | 支持 | 支持 | 与正式导航互斥，需联网和真实驾车场景验证 |

## 回归检查清单

- 双地图和 ListView 地图页面：确认创建、销毁、滚动回收后无残留事件回调。
- 相机操作页面：确认地图加载完成前后调用 `moveCamera` 都能生效。
- Marker 页面：确认声明式 `markers` 与 Controller `addMarker/removeMarker` 不互相破坏。
- Marker 动画页面：确认播放、取消和 UnsupportedError 提示正常。
- InfoWindow 页面：确认 `title` / `snippet`、显示和隐藏逻辑正常。
- Polyline/Arc/Polygon 页面：确认 Android/iOS 能正确绘制、更新和移除覆盖物。
- 定位页面：确认 `showUserLocation`、`userLocationStyle`、`onUserLocationChange`、`waitForUserLocation` 仍正常。
- 自定义样式页面：确认启用/关闭样式后底图类型和缩放范围正常。
- 搜索与地点选择页面：确认输入提示、周边搜索、地点选择器和天气查询正常。
- 导航页面：确认启动/停止导航、事件订阅、转向图标、智能巡航互斥逻辑正常。
