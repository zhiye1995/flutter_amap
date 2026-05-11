# 智能巡航模式：Android 与 iOS 对照说明

本文基于高德开放平台 **Android 导航 SDK** 与 **iOS 导航 SDK** 官方文档中的「智能巡航」章节整理，说明巡航能力、双端 API 与回调差异，便于跨端设计与 Flutter 原生扩展时对齐语义。

- Android 文档：[智能巡航（Android 导航 SDK）](https://developer.amap.com/api/android-navi-sdk/guide/navigation-map/cruise-navi)
- iOS 文档：[智能巡航（iOS 导航 SDK）](https://developer.amap.com/api/ios-navi-sdk/guide/navigation-map/cruise-navi)

---

## 1. 概述：什么是智能巡航

智能巡航是一种**无起终点、不进行路线规划（不算路）**的驾车引导模式。车辆在行驶过程中仍可收到**语音播报**以及**拥堵、道路设施、电子眼**等相关交通信息（具体播报范围取决于你开启的模式）。

**官方文档中的共性约束：**

| 约束项 | 说明 |
|--------|------|
| 联网 | 巡航功能需要联网使用。 |
| 体验场景 | 巡航效果更适合在**实际驾车**过程中体验。 |
| 与导航互斥 | **巡航模式与正式导航模式不能同时使用**。切换时需按文档顺序先停一种再开另一种（见下文「开启与关闭」表）。 |
## 1.1 巡航模式能拿到的参数信息

| 功能（同语义合并；括号内为巡航回调） | 安卓 | iOS |
|----------------------------------------|------|-----|
| 设施类型 | √ | √ |
| 经纬坐标 | √ | √ |
| 距设施剩余距离（米） | √ | √ |
| 限速（km/h） | √ | √ |
| **上述四个参数示例：**前放500米，测速摄像头，限速80km/h<br />**解释：**前放500米（距离），测速摄像头（设施类型），限速80km/h, |  |  |
| **巡航统计** | | |
| 连续行驶/轨迹累积距离（米） | √ | √ |
| 连续运行/启用时间（秒） | √ | √ |
| **巡航拥堵** | | |
| 拥堵路段 link 数组 | √ | |
| 单段 link 形状点集 | √ | |
| 单段 link 拥堵状态 | √ | |
| 拥堵区域道路名称 | √ | |
| 拥堵区域路径长度（米） | √ | |
| 拥堵区域整体拥堵状态 | √ | |
| 预计通过拥堵区域时间（秒） | √ | |


---

## 2. 开启与关闭方式对照

| 项目 | Android | iOS |
|------|---------|-----|
| 核心类型 | `AMapNavi` | `AMapNaviDriveManager`（单例） |
| 监听注册 | `AMapNavi.addAimlessModeListener(AimlessModeListener)` | 实现 `AMapNaviDriveManagerDelegate`，并 `setDelegate:` / `delegate =` |
| 开启巡航 | `startAimlessMode(int aimlessMode)` | `setDetectedMode:` 或 `detectedMode =` 设为非 `None` 的枚举值 |
| 关闭巡航 | `stopAimlessMode()` | `detectedMode` / `setDetectedMode:` 设为 `AMapNaviDetectedModeNone`（文档示例） |
| 模式含义（对应关系） | `1`：只播报电子眼；`2`：只播报特殊路段；`3`：电子眼 + 特殊路段 | `AMapNaviDetectedModeCamera`：电子眼；`AMapNaviDetectedModeSpecialRoad`：特殊道路设施；`AMapNaviDetectedModeCameraAndSpecialRoad`：两者 |
| 从导航切到巡航 | 先 `AMapNavi.stopNavi`，再 `startAimlessMode(...)` | 先 `AMapNaviDriveManager.stopNavi`，再设置 `detectedMode` |
| 从巡航切到导航 | 先 `stopAimlessMode()`，再开启导航 | 先将 `detectedMode` 设为 `AMapNaviDetectedModeNone`，再开启导航 |
| iOS 额外建议 | — | 文档示例中会配置 `allowsBackgroundLocationUpdates`、`pausesLocationUpdatesAutomatically` 等，以满足后台持续定位相关需求（仍需结合 App 能力与系统权限）。 |

---

## 3. 回调与数据：能力总览

| 能力维度 | Android（官方巡航页） | iOS（官方巡航页） | 是否可对齐 |
|----------|------------------------|-------------------|------------|
| 道路设施 / 电子眼类信息 | `AimlessModeListener`：`onUpdateTrafficFacility`、`onUpdateAimlessModeElecCameraInfo`（参数均为 `AMapNaviTrafficFacilityInfo[]`） | `driveManager:updateTrafficFacilities:`（`NSArray<AMapNaviTrafficFacilityInfo *>`） | **语义可对齐**：均为设施/电子眼类数据；**形态不同**：Android 拆两个回调，iOS 一个回调聚合 |
| 巡航统计 | `updateAimlessModeStatistics(AimLessModeStat)` | `driveManager:updateCruiseInfo:`（`AMapNaviCruiseInfo`） | **语义部分对齐**：均为巡航过程统计；**类型与字段**需分别查双端参考手册 |
| 拥堵信息 | `updateAimlessModeCongestionInfo(AimLessModeCongestionInfo)` | 当前「智能巡航」指南页**未**列出对等回调 | **官方巡航页不对等**：若 iOS 需要同类能力，需在 **iOS 导航 SDK 全量 Delegate / 参考手册** 中另行确认 |
| 自车位置用于地图 | 文档建议：`MapView` + `Marker`，结合 `onLocationChange` 更新 | 文档建议：`MAMapView` + `Annotation`，结合 `updateNaviLocation` 更新 | **思路一致**，组件名与 API 不同 |

---

## 4. Android：巡航回调与参数（`AimlessModeListener`）

以下方法名与参数类型以 Android 官方「智能巡航」开发指南为准。

| 回调方法 | 参数类型 | 文档/语义要点 |
|----------|----------|----------------|
| `onUpdateTrafficFacility` | `AMapNaviTrafficFacilityInfo[] infos` | 巡航**道路设施**信息更新。 |
| `onUpdateAimlessModeElecCameraInfo` | `AMapNaviTrafficFacilityInfo[] cameraInfo` | 巡航**电子眼**信息更新。 |
| `updateAimlessModeStatistics` | `AimLessModeStat aimLessModeStat` | 巡航**统计**信息更新。 |
| `updateAimlessModeCongestionInfo` | `AimLessModeCongestionInfo aimLessModeCongestionInfo` | 巡航**拥堵**信息更新。 |

**关于 `AMapNaviTrafficFacilityInfo`：** 官方指南说明可通过该类型获取**道路交通设施**相关信息（例如类型、距设施的剩余距离等）。**具体属性名、枚举取值以 Android 导航 SDK 参考手册中该类定义为准。**

**关于 `AimLessModeStat` / `AimLessModeCongestionInfo`：** 指南未在正文逐字段展开，**字段列表以 Android 导航 SDK 参考手册为准。**

---

## 5. iOS：巡航回调与参数（`AMapNaviDriveManagerDelegate`）

以下以 iOS 官方「智能巡航」开发指南列出的步骤为准。

| 回调方法 | 参数类型 | 文档/语义要点 |
|----------|----------|----------------|
| `driveManager:updateCruiseInfo:` | `AMapNaviCruiseInfo *`（Swift 中可为 optional） | 位置变化时触发；文档说明包含**连续行驶距离**、**连续启用时间**等巡航统计。 |
| `driveManager:updateTrafficFacilities:` | `NSArray<AMapNaviTrafficFacilityInfo *> *` | 巡航中出现电子眼或特殊道路设施时触发；通过 `AMapNaviTrafficFacilityInfo` 获取设施信息。 |

**关于 `AMapNaviTrafficFacilityInfo` / `AMapNaviCruiseInfo`：** **具体属性以 iOS 导航 SDK 参考手册为准。**

---

## 6. 「共同」与「差异」汇总表

| 类别 | 内容 |
|------|------|
| **共同** | 均为无路线「巡航」形态；需联网；适合实车；与正式导航互斥；均提供设施/电子眼类数据与巡航统计类数据的表达（Android 多回调拆分，iOS 统计与设施分两个 delegate 方法）。 |
| **差异 1：API 形态** | Android 使用 `startAimlessMode(int)` + `stopAimlessMode()`；iOS 使用 `detectedMode` / `setDetectedMode:` 枚举开关。 |
| **差异 2：设施与电子眼** | Android 在 `AimlessModeListener` 中拆成 `onUpdateTrafficFacility` 与 `onUpdateAimlessModeElecCameraInfo`；iOS 在 `updateTrafficFacilities` 中统一回调。 |
| **差异 3：拥堵** | Android 巡航页明确提供 `updateAimlessModeCongestionInfo`；iOS 该篇巡航指南**未**给出与之一一对应的回调名，不能假定存在同名或同结构 API。 |
| **差异 4：统计类型** | Android 为 `AimLessModeStat`；iOS 为 `AMapNaviCruiseInfo`；**类名与字段不一定一一对应**，跨端展示需各自解析。 |
| **差异 5：地图联动** | Android：`MapView`、`Marker`、`onLocationChange`；iOS：`MAMapView`、`Annotation`、`updateNaviLocation`。 |

---

## 7. 与本仓库 `amap_flutter` 插件的关系

当前仓库已封装智能巡航能力：

- Dart：通过 [AMapNavi.startCruiseMode](../lib/src/amap_navi.dart) / `stopCruiseMode` 启停，并通过 `onCruiseTrafficFacility`、`onCruiseElecCameraInfo`、`onCruiseStatistics`、`onCruiseCongestion` 订阅巡航事件。
- Android：通过 [AMapNaviApi.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AMapNaviApi.kt) 注册 [AimlessModeListenerImpl.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AimlessModeListenerImpl.kt)，调用 `startAimlessMode` / `stopAimlessMode`，并转发设施、电子眼、统计和拥堵事件。
- iOS：通过 [AMapNaviApi.swift](../ios/Classes/AMapNaviApi.swift) 设置 `AMapNaviDriveManager.detectedMode`，并在 [AMapNaviDelegate.swift](../ios/Classes/AMapNaviDelegate.swift) 转发巡航统计和设施事件。

注意：[AMapNaviListenerImpl.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AMapNaviListenerImpl.kt) 中同名巡航方法属于 `AMapNaviListener` 的已弃用回调，仍为空处理；巡航业务数据以独立的 `AimlessModeListenerImpl` 为准。iOS 官方智能巡航页未给出与 Android `updateAimlessModeCongestionInfo` 对等的拥堵回调，因此 `onCruiseCongestion` 主要为 Android 事件。

---

## 8. 参考链接

- https://developer.amap.com/api/android-navi-sdk/guide/navigation-map/cruise-navi  
- https://developer.amap.com/api/ios-navi-sdk/guide/navigation-map/cruise-navi  

双端类成员、枚举完整定义请以各自 **导航 SDK 参考手册** 与当前集成版本的头文件 / 反编译文档为准。
