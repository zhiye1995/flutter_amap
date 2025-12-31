import Flutter
// `MAMapKit` 通常来自 `AMap3DMap`。
// 但在一些集成方式下（例如仅引入 `AMapNavi`），`MAMapKit` 这个 Swift module 可能不存在，
// 地图相关类型会通过 `AMapNaviKit` 暴露出来；因此这里做条件导入以兼容两种情况。
#if canImport(MAMapKit)
import MAMapKit
#elseif canImport(AMapNaviKit)
import AMapNaviKit
#else
#error("Neither MAMapKit nor AMapNaviKit is available. Please add AMapNavi (recommended) or AMap3DMap to your Pod dependencies.")
#endif

class AMapFlutter: NSObject, FlutterPlatformView {
  private let mapView: MAMapView
  private let mapViewDelegate: AMapViewDelegate

  init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar, args: [String: Any?]?) {
    var mapInitConfig: MapInitConfig?
    if(args != nil) {
      if let options = args!["options"] as? [Any?] {
        mapInitConfig = MapInitConfig.fromList(options)
      }
    }
    mapView = MAMapView(frame: frame)
    let api = _AMapApi(registrar: registrar, mapView: mapView, mapInitConfig: mapInitConfig)
    let controller = AMapController(viewId: viewId, registrar: registrar, api: api)
    mapViewDelegate = AMapViewDelegate(registrar, mapView: mapView, controller: controller)
    super.init()
    mapView.delegate = mapViewDelegate
    mapView.showsUserLocation = false
  }

  func view() -> UIView {
    mapView
  }
}
