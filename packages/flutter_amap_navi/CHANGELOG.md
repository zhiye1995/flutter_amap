## 1.0.0

- Initial independent AMap navigation plugin release.
- Support drive, walk and ride navigation, route pages, cruise mode and navigation event streams.
- Add explicit `AMapNavi.init` configuration and initialization guards.
- Add independent `NaviPosition`, `NaviDrivingStrategy`, `NaviApiKey` and `NaviSdkConfig` types.
- Reuse the navigation aggregate SDK when Android or iOS apps also include `flutter_amap`, avoiding duplicate map SDK implementations.
