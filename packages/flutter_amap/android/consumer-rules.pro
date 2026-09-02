# amap_flutter - AMap (高德) SDK 混淆规则（ProGuard / R8）
#
# 说明：
# - 本文件会通过 Android library 的 consumerProguardFiles 自动传递给集成方 App。
# - 如果你的 App 开启了 minifyEnabled（R8 混淆/压缩），这些规则可避免高德 SDK 反射/资源加载相关的运行时崩溃。
# - 若仍出现 warning，可在 App 的 proguard-rules.pro 中按需补充 `-dontwarn 包名.**`
#

## 3D 地图（V5.0.0 之后通用）
-keep class com.amap.api.maps.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.amap.api.trace.** { *; }

## 2D 地图（如你显式集成了 2D 组件）
-keep class com.amap.api.maps2d.** { *; }
-keep class com.amap.api.mapcore2d.** { *; }

## 定位
-keep class com.amap.api.location.** { *; }
-keep class com.amap.api.fence.** { *; }
-keep class com.autonavi.aps.amapapi.model.** { *; }

## 搜索
-keep class com.amap.api.services.** { *; }

## 部分版本 SDK 可能引用 Google 包（按官方建议保留）
-keep class com.google.** { *; }


