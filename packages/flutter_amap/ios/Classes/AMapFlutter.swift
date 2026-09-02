import Flutter
// 地图独立集成使用 MAMapKit；地图与导航联合集成时复用 AMapNaviKit 内含的地图能力。
#if canImport(MAMapKit)
import MAMapKit
#elseif canImport(AMapNaviKit)
import AMapNaviKit
#else
#error("Neither MAMapKit nor AMapNaviKit is available. Check flutter_amap's iOS SDK configuration.")
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
    let delegate = AMapViewDelegate(registrar, mapView: mapView, controller: controller)
    mapViewDelegate = delegate
    api.mapViewDelegate = delegate
    super.init()
    mapView.delegate = mapViewDelegate
    mapView.showsUserLocation = false
  }

  func view() -> UIView {
    mapView
  }
}
