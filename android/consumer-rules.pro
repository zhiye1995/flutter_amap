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

## 导航
-keep class com.amap.api.navi.** { *; }

## 导航语音相关（不同版本 Navi SDK 可能引入的包名不同；这里做并集以保证兼容）
-keep class com.alibaba.idst.nui.** { *; }     # Navi V8.1.0+ 常见
-keep class com.alibaba.idst.nls.** { *; }     # Navi V7.3.0 以前常见
-keep class com.alibaba.mit.alitts.** { *; }   # Navi V7.3.0+ 常见
-keep class com.nlspeech.nlscodec.** { *; }    # Navi V7.3.0 以前常见

## 部分版本 SDK 可能引用 Google 包（按官方建议保留）
-keep class com.google.** { *; }


