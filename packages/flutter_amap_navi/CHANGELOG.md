## 1.0.4

- 修复 Android 转向类型切换后首次收到旧图片，导致同一类型图标长期不更新的问题；按类型和 PNG 内容去重。
- 修复 iOS 同类型图标更新后不再下发的问题，移除异步轮询等待并保护图标缓存的并发访问。

## 1.0.3

- Android 步行、骑行导航改用对应的专用算路引擎和导航视图。
- 修复 Android Release 混淆后高德定位库通过 JNI/反射访问内部类时可能发生的闪退。
- 补充与联合示例一致的分类功能清单，明确 Android、iOS 的实现状态和待开发能力。

## 1.0.2

- 补充 1.0.1 版本变更记录并修复发布校验问题。

## 1.0.1

- 修复 iOS 独立算路编译与 SDK 版本查询。
- 完善 Android 自定义导航容器和导航 SDK 集成配置。

## 1.0.0

- Initial independent AMap navigation plugin release.
- Support drive, walk and ride navigation, route pages, cruise mode and navigation event streams.
- Add explicit `AMapNavi.init` configuration and initialization guards.
- Add independent `NaviPosition`, `NaviDrivingStrategy`, `NaviApiKey` and `NaviSdkConfig` types.
- Reuse the navigation aggregate SDK when Android or iOS apps also include `flutter_amap`, avoiding duplicate map SDK implementations.
