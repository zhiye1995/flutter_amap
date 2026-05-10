本项目由 [amap_flutter](https://pub.dev/packages/amap_flutter) 原作者改编而来。

https://lbs.amap.com/api/android-navi-sdk/download

Android导航SDK 

# Flutter 高德地图插件功能清单

功能完成度以 `example/lib/pages/3d_map` 示例（含同目录下独立页面源码）为准。

## 地图
### 创建地图
- [x] 显示地图
- [x] 显示定位蓝点
- [ ] 显示室内地图
- [ ] 切换地图图层
- [x] 使用离线地图
- [ ] 显示英文地图
- [x] 自定义地图
- [x] 地图显示要素（Web）

### 与地图交互
- [x] 控件交互
- [x] 控件位置调整
- [x] 手势交互
- [x] 调用方法交互
- [x] 地图截屏功能
- [x] 地图限制区域

### 在地图上绘制
- [x] 绘制点标记
- [x] 绘制折线
- [x] 绘制面
- [ ] 轨迹纠偏
- [ ] 点平滑移动
- [ ] 绘制海量点图层

### 地图计算工具
- [ ] 坐标转换
- [ ] 距离/面积计算
- [ ] 距离测量

## 搜索
### 获取地图数据
- [x] 获取POI数据
- [x] 获取地址描述数据
- [ ] 获取行政区划数据
- [ ] 获取公交数据
- [x] 获取天气数据
- [ ] 获取业务数据（云图功能）
- [ ] 获取交通态势信息

### 出行线路规划
- [x] 驾车出行路线规划
- [ ] 步行出行路线规划
- [ ] 公交出行路线规划
- [ ] 骑行出行路线规划
- [ ] 货车出行路线规划

## 导航
### 导航组件
- [x] 使用导航组件

### 出行路线规划
- [x] 驾车路线规划
- [ ] 货车路线规划
- [ ] 步行路线规划
- [ ] 骑行路线规划

### 在地图上导航
- [ ] 实时导航
- [ ] 模拟导航
- [ ] 智能巡航
- [ ] 传入外部GPS数据
- [ ] 导航UI定制化

### HUD导航模式
- [ ] HUD导航

### 获取导航数据
- [ ] 导航数据

### 语音播报
- [ ] 语音合成

## 定位
### 获取位置
- [x] 获取定位数据

### 辅助功能
- [ ] 地理围栏
- [ ] 坐标转换与位置判断

## AMapWidget API 分层

`AMapWidget` 仍兼容旧的平铺参数，同时推荐新代码使用分组 options，减少跨端参数混在同一个构造函数里的误用。

- 核心地图配置：`AMapMapOptions`，包含地图类型、初始视野、缩放范围、图层、离线自定义样式。
- 手势配置：`AMapGestureOptions`，包含拖拽、缩放、俯仰、旋转以及 Web 鼠标/触摸缩放开关。
- 控件配置：`AMapUiOptions`，包含指南针、比例尺、缩放控件、Logo 和控件位置。
- 定位配置：`AMapLocationOptions`，包含定位蓝点、定位按钮和定位样式。
- Web 专属配置：`AMapWebOptions`，包含 `mapStyle`、`mapFeatures`、`viewMode`、`terrain` 等 Web SDK 参数。
- SDK 初始化配置：`AMapSdkConfig`，用于集中传入 `ApiKey`、隐私同意状态和导航图标预加载开关。

## 平台能力矩阵

| 能力 | Android | iOS | Web | 说明 |
| --- | --- | --- | --- | --- |
| 创建地图、多地图实例 | 支持 | 支持 | 入口保留 | Web 入口依赖 `src/web/amap_flutter_web_plugin.dart` 的实际实现 |
| 相机移动、限制区域 | 支持 | 支持 | 入口保留 | `moveCamera` 默认等待地图加载完成 |
| Marker 声明式集合 | 支持 | 支持 | 入口保留 | `markers` 按 `id` 做增删/替换 |
| Polyline/Polygon 声明式集合 | 支持 | 支持 | 入口保留 | `polylines`、`polygons` 按 `id` 做增删/替换 |
| 定位蓝点 | 支持 | 支持 | 不支持 | 需业务侧先申请运行时定位权限 |
| 自定义离线样式 | 支持 | 支持 | 忽略 | 启用时会切回标准底图 |
| Web 地图样式/要素/鹰眼/图层 | 忽略 | 忽略 | 设计支持 | 推荐放入 `AMapWebOptions` |
| 导航、搜索、天气 | 支持 | 部分支持 | 不支持 | 以 example 与原生 SDK 能力为准 |

## 回归检查清单

- 双地图和 ListView 地图页面：确认创建、销毁、滚动回收后无残留事件回调。
- 相机操作页面：确认地图加载完成前后调用 `moveCamera` 都能生效。
- Marker 页面：确认声明式 `markers` 与 Controller `addMarker/removeMarker` 不互相破坏。
- Polyline/Polygon 页面：确认 Android/iOS 能正确绘制、更新和移除覆盖物。
- 定位页面：确认 `showUserLocation`、`userLocationStyle`、`onUserLocationChange` 仍正常。
- 自定义样式页面：确认启用/关闭样式后底图类型和缩放范围正常。
