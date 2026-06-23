# 官方 Android 3D 地图示例（可选对照）

本目录用于放置**高德开放平台**提供的 Android 地图 SDK 示例工程，便于与插件内 `animateMarker` 等行为做像素级对照。

## 如何获取 Demo

1. 打开 [高德开放平台 · Android 地图 SDK](https://lbs.amap.com/api/android-sdk/summary)，在「示例代码」或相关下载区获取官方示例压缩包（名称常含 `AMap_Android_API_3DMap_Demo` 等）。
2. 将解压后的工程**整个目录**拷贝到本仓库 `official_example/` 下（例如 `official_example/AMap_Android_API_3DMap_Demo/`）。
3. 在 Android Studio 中单独打开该 Demo 工程对照 `Marker` 与 `com.amap.api.maps.model.animation` 包下的用法。

## 与「生长」动画对应的典型代码（官方仓库摘要）

高德示例中「生长」效果常用 **`ScaleAnimation(0, 1, 0, 1)`** 配合 `setDuration` / `marker.setAnimation` / `marker.startAnimation()`，与插件中 `MarkerAnimationKind.growOnce` 的 Android 实现一致思路。参考社区示例说明：[amap-demo/android-marker-grow](https://github.com/amap-demo/android-marker-grow)。

## 「移动」动画说明

高德 3D SDK 的 **`TranslateAnimation(LatLng target)`** 表示沿经纬度移动到目标点（参见官方包 `com.amap.api.maps.model.animation.TranslateAnimation`）。插件中 `MarkerAnimationKind.moveRoundTrip` 在 Android 侧为「当前位置 → 附近经纬度 → 再移回」的两段 `TranslateAnimation`，便于在地图上观察「移动」效果且不改变 Flutter 侧已缓存的 `Marker` 数据模型（动画结束后原生会将点位设回起点）。
