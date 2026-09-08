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
