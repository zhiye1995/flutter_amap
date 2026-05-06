# 高德智能巡航：Context7 检索说明与最小接入示例

本文说明使用 **Context7**（`resolve-library-id` / `query-docs`）检索「高德智能巡航」时的结论与局限，并给出 Android / iOS **最小接入骨架**（语义对齐官方巡航指南）。能力对照、回调详情与双端差异请以仓库内 [巡航模式_Android与iOS对照说明.md](./巡航模式_Android与iOS对照说明.md) 及当前 SDK 参考手册为准。

---

## 1. Context7 检索说明

### 1.1 使用的工具与查询意图

| 项目 | 说明 |
|------|------|
| 工具 | `resolve-library-id`（按名称解析 Library ID）、`query-docs`（按 libraryId + 自然语言查询文档片段） |
| 典型 Library ID | `/websites/lbs_amap_api`、`/websites/lbs_amap_document`、`/amap-demo/amap-sdk-skills` 等（检索词含「高德开放平台」「AMap」） |
| `researchMode` | `query-docs` 的深度检索需 Context7 API Key；未配置密钥时**无法使用**，本文不依赖该模式 |

### 1.2 检索结论（重要）

- 在当前 Context7 索引中，针对上述库的查询返回内容多为：**LBS 产品线概览**、**Web 服务 HTTP API**、或 **`amap-sdk-skills` 中与「LLM Agent / 自然语言导航」相关的示例**。
- **未检索到**与官方「智能巡航 / 无算路巡航」直接对应的可运行片段，例如：`startAimlessMode`、`AimlessModeListener`、`AMapNaviDetectedMode` 等类的**完整、可拷贝的官方示例代码**。

### 1.3 请勿混淆的概念

| 概念 | 说明 |
|------|------|
| **智能巡航（本页主题）** | 导航 SDK 提供的无起终点、不算路的驾车巡航模式，见下文官方「智能巡航」开发指南。 |
| **LLM Agent SDK（Context7 易误命中）** | `amap-sdk-skills` 等索引中的自然语言查询、Agent 回调等，**不是**智能巡航 API，勿混用。 |

后续若在 Context7 中能稳定命中巡航专用片段，可在本节追加：**检索日期**、**Library ID**、**query 关键词** 便于维护。

---

## 2. 官方文档与仓库内对照文档

- Android：[智能巡航（Android 导航 SDK）](https://developer.amap.com/api/android-navi-sdk/guide/navigation-map/cruise-navi)
- iOS：[智能巡航（iOS 导航 SDK）](https://developer.amap.com/api/ios-navi-sdk/guide/navigation-map/cruise-navi)

**类名、枚举、属性**以你工程集成的**导航 SDK 版本**及对应 **参考手册 / 头文件**为准。

更完整的双端 API 对照、回调表、与正式导航的切换顺序，见：[巡航模式_Android与iOS对照说明.md](./巡航模式_Android与iOS对照说明.md)。

---

## 3. 最小接入示例（代码骨架）

以下仅为**文档级骨架**：包名、初始化顺序、权限与隐私合规需按官方最新文档补齐；模式取值与对照表一致。

### 3.1 Android（Kotlin）

语义：`AimlessModeListener` 注册 → `startAimlessMode(mode)` / `stopAimlessMode()`；与正式导航互斥时需先 `stopNavi` 再开巡航（详见对照文档）。

```kotlin
// 说明：import 与类型名以当前 Android 导航 SDK 为准。

// val aMapNavi: AMapNavi = ... // 已初始化的导航实例

val aimlessListener = object : AimlessModeListener {
    override fun onUpdateTrafficFacility(infos: Array<out AMapNaviTrafficFacilityInfo>?) {
        // 道路设施更新
    }

    override fun onUpdateAimlessModeElecCameraInfo(cameraInfo: Array<out AMapNaviTrafficFacilityInfo>?) {
        // 电子眼更新
    }

    override fun updateAimlessModeStatistics(stat: AimLessModeStat?) {
        // 巡航统计
    }

    override fun updateAimlessModeCongestionInfo(info: AimLessModeCongestionInfo?) {
        // 巡航拥堵（Android 巡航页提供的回调）
    }
}

// aMapNavi.addAimlessModeListener(aimlessListener)

// 模式：1 仅电子眼；2 仅特殊路段；3 电子眼 + 特殊路段（与官方巡航指南一致）
// aMapNavi.startAimlessMode(3)

// 关闭巡航
// aMapNavi.stopAimlessMode()
```

若监听器接口方法签名随 SDK 变更，以实现类所需 override 为准。

### 3.2 iOS（Objective-C 骨架）

语义：`AMapNaviDriveManager` 单例设置 `delegate`，通过 `detectedMode` 开启/关闭巡航枚举；关闭时常用 `AMapNaviDetectedModeNone`。

```objc
// #import 以当前 iOS 导航 SDK 为准。

// self 实现 AMapNaviDriveManagerDelegate

// [AMapNaviDriveManager sharedInstance].delegate = self;

// 开启（示例：电子眼 + 特殊道路，枚举名以 SDK 为准）
// [AMapNaviDriveManager sharedInstance].detectedMode = AMapNaviDetectedModeCameraAndSpecialRoad;

// 关闭巡航后再开正式导航
// [AMapNaviDriveManager sharedInstance].detectedMode = AMapNaviDetectedModeNone;

#pragma mark - AMapNaviDriveManagerDelegate（摘录）

// - (void)driveManager:(AMapNaviDriveManager *)driveManager updateCruiseInfo:(AMapNaviCruiseInfo *)cruiseInfo { }

// - (void)driveManager:(AMapNaviDriveManager *)driveManager updateTrafficFacilities:(NSArray<AMapNaviTrafficFacilityInfo *> *)facilities { }
```

### 3.3 iOS（Swift 骨架）

```swift
// AMapNaviDriveManager.shared().delegate = self

// AMapNaviDriveManager.shared().detectedMode = .cameraAndSpecialRoad // 枚举以 SDK 为准

// AMapNaviDriveManager.shared().detectedMode = .none

// func driveManager(_ driveManager: AMapNaviDriveManager, updateCruiseInfo cruiseInfo: AMapNaviCruiseInfo?) { }
// func driveManager(_ driveManager: AMapNaviDriveManager, updateTrafficFacilities facilities: [AMapNaviTrafficFacilityInfo]?) { }
```

后台持续定位、`allowsBackgroundLocationUpdates` 等见官方巡航页与 [iOS background modes.md](./iOS%20background%20modes.md)（若适用）。

---

## 4. 与本仓库 `flutter_amap` 插件的关系

本仓库**已实现**智能巡航在原生与 Dart 之间的事件通道（与 [巡航模式_Android与iOS对照说明.md §7](./巡航模式_Android与iOS对照说明.md#7-与本仓库-amap_flutter-插件的关系) 中早期「未注册 `AimlessModeListener`、未转发巡航」的表述相比，**请以当前代码为准**）。

| 层级 | 说明与路径 |
|------|------------|
| Dart | `AMapNavi.startCruiseMode` / `stopCruiseMode`；事件流 `onCruiseTrafficFacilities`、`onCruiseStatistics`、`onCruiseCongestion`（见 [lib/src/amap_navi.dart](../lib/src/amap_navi.dart)） |
| Android | `AMapNaviApi` 中 `startCruiseMode` / `stopCruiseMode`，注册 [AimlessModeListenerImpl.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AimlessModeListenerImpl.kt) 并写入与导航共用的 EventChannel（[AMapNaviApi.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AMapNaviApi.kt)） |
| iOS | [AMapNaviApi.swift](../ios/Classes/AMapNaviApi.swift) 设置 `detectedMode`；巡航统计与设施回调在 [AMapNaviDelegate.swift](../ios/Classes/AMapNaviDelegate.swift) |

**说明：** [AMapNaviListenerImpl.kt](../android/src/main/kotlin/com/morbit/amap_flutter/AMapNaviListenerImpl.kt) 实现的 `AMapNaviListener` 上，部分与巡航同名的已弃用方法可能仍为空实现；**巡航业务数据以 `AimlessModeListener` 实现类与上述 EventChannel 为准**，勿仅依赖 `AMapNaviListener` 中弃用回调。

第三节「最小骨架」仍适用于**脱离本插件、自行集成导航 SDK** 的场景；使用本插件时请优先调用 Dart API 与事件流。

---

## 5. 维护说明

- 升级 **Android / iOS 导航 SDK** 后，请重新核对 [官方智能巡航页面](https://developer.amap.com/api/android-navi-sdk/guide/navigation-map/cruise-navi) 与 [iOS 对应页](https://developer.amap.com/api/ios-navi-sdk/guide/navigation-map/cruise-navi)，并同步更新 [巡航模式_Android与iOS对照说明.md](./巡航模式_Android与iOS对照说明.md)。
- Context7 索引更新后，可在 **§1** 补充实际命中的 Library ID 与检索用语，便于团队复现。
