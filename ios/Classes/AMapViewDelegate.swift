//
//  AMapViewDelegate.swift
//  amap
//
//  Created by Wenqi Li on 2023/8/22.
//

import Foundation
import Flutter
import UIKit
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

/// MAAnnotation 的 title/subtitle 从 Objective-C 桥接后可能是 `String?` 或 `String??`，
/// 直接 `?? ""` 后仍可能得到 `String?`，对 `isEmpty` 会触发编译错误；用 NSString 统一判断是否有展示文案。
fileprivate func amapAnnotationLineHasText(_ line: Any?) -> Bool {
  let ns = line as? NSString
  return (ns?.length ?? 0) > 0
}

fileprivate func amapOverlayLineWidth(_ width: Double) -> CGFloat {
  return CGFloat(width / Double(UIScreen.main.scale))
}

class AMapViewDelegate: NSObject, MAMapViewDelegate {
  let registrar: FlutterPluginRegistrar
  let mapView: MAMapView
  let controller: AMapController
  private var resetsTrackingAfterFirstLocation = false

  init(_ registrar: FlutterPluginRegistrar, mapView: MAMapView, controller: AMapController) {
    self.registrar = registrar
    self.mapView = mapView
    self.controller = controller
  }

  func applyUserLocationType(_ type: UserLocationType?, animated: Bool) {
    guard let type = type else { return }
    resetsTrackingAfterFirstLocation = type.resetsTrackingAfterFirstLocation
    mapView.setUserTrackingMode(type.userTrackingMode, animated: animated)
  }

  func mapView(_ mapView: MAMapView!, viewFor _annotation: MAAnnotation!) -> MAAnnotationView! {
    if let annotation = _annotation as? Annotation {
      var annotationView: MAAnnotationView
      if let bitmap = annotation.bitmap {
        annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: annotation.id)
        annotationView.image = bitmap.toUIImage(registrar: registrar)
        annotationView.layer.anchorPoint = CGPointMake(0.5, 1)
      } else {
        annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.id)
      }
      annotationView.isDraggable = true
      annotationView.canShowCallout =
        amapAnnotationLineHasText(_annotation.title) || amapAnnotationLineHasText(_annotation.subtitle)
      return annotationView
    }
    return nil
  }

  /// 地图初始化完成（在此之后，可以进行坐标计算）
  func mapInitComplete(_ mapView: MAMapView!) {
    controller.onMapInitComplete()
  }

  /// 地图开始加载
  func mapViewWillStartLoadingMap(_ mapView: MAMapView!) {
    NSLog("mapViewWillStartLoadingMap")
  }

  /// 地图加载成功
  func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
    controller.onMapCompleted()
  }

  /// 地图加载失败
  func mapViewDidFailLoadingMap(_ mapView: MAMapView!, withError error: Error!) {
    NSLog("mapViewDidFailLoadingMap")
  }

  /// 单击地图回调，返回经纬度
  func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
    if let selected = mapView.selectedAnnotations as? [Any] {
      for case let ann as MAAnnotation in selected {
        mapView.deselectAnnotation(ann, animated: true)
      }
    }
    controller.onMapPress(position: coordinate.position)
  }

  /// 长按地图，返回经纬度
  func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
    controller.onMapLongPress(position: coordinate.position)
  }

  /// 地图区域改变过程中会调用此接口 since 4.6.0
  func mapViewRegionChanged(_ mapView: MAMapView!) {
    controller.onCameraChange(camera: mapView.cameraPosition)
  }

  /// 地图区域即将改变时会调用此接口，如实现此接口则不会触发回掉mapView:regionWillChangeAnimated:
  func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool, wasUserAction: Bool) {
    controller.onCameraChangeStart(camera: mapView.cameraPosition)
  }

  /// 地图区域改变完成后会调用此接口，如实现此接口则不会触发回掉mapView:regionDidChangeAnimated:
  func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
    controller.onCameraChangeFinish(camera: mapView.cameraPosition)
  }

  /// 地图将要发生移动时调用此接口
  func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
    controller.onMapMoveStart(position: mapView.position)
  }

  /// 地图移动结束后调用此接口
  func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
    controller.onMapMoveEnd(position: mapView.position)
  }

  /// 地图将要发生缩放时调用此接口
  func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool) {
    controller.onZoomChangeStart(zoom: mapView.zoomLevel)
  }

  /// 地图缩放结束后调用此接口
  func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
    controller.onZoomChangeEnd(zoom: mapView.zoomLevel)
  }

  /// 当touchPOIEnabled == YES时，单击地图使用该回调获取POI信息
  func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
    controller.onPoiClick(poi: (pois.first as! MATouchPoi).poi)
  }

  /// 当mapView新添加annotation views时，调用此接口
  func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
    NSLog("didAddAnnotationViews")
  }

  /// 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调
  func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
    NSLog("didSelect")
  }

  /// 当取消选中一个annotation view时，调用此接口
  func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
    NSLog("didDeselect")
  }

  /// 拖动annotation view时view的状态变化
  func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState oldState: MAAnnotationViewDragState) {
    let id = view.reuseIdentifier!
    let position = view.annotation.coordinate.position
    if(oldState == .none && newState == .starting) {
      controller.onMarkerDragStart(markerId: id, position: position)
    } else if(oldState == .dragging && newState == .dragging) {
      controller.onMarkerDrag(markerId: id, position: position)
    } else if(oldState == .dragging && (newState == .canceling || newState == .ending)) {
      controller.onMarkerDragEnd(markerId: id, position: position)
    }
  }

  /// 标注view被点击时，触发该回调。（since 5.7.0）
  func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
    controller.onMarkerClick(view.annotation.hash)
    let ann = view.annotation!
    if amapAnnotationLineHasText(ann.title) || amapAnnotationLineHasText(ann.subtitle) {
      mapView.selectAnnotation(ann, animated: true)
    }
  }

  /// 标注view的calloutview整体点击时，触发该回调。只有使用默认calloutview时才生效。
  func mapView(_ mapView: MAMapView!, didAnnotationViewCalloutTapped view: MAAnnotationView!) {
    NSLog("didAnnotationViewCalloutTapped")
  }

  /// 标注view的accessory view(必须继承自UIControl)被点击时，触发该回调
  func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    NSLog("calloutAccessoryControlTapped")
  }

  /// 当plist配置NSLocationAlwaysUsageDescription或者NSLocationAlwaysAndWhenInUseUsageDescription，并且[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined，会调用代理的此方法。
  /// 此方法实现调用后台权限API即可（ 该回调必须实现 [locationManager requestAlwaysAuthorization] ）; since 6.8.0
  func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
    locationManager.requestWhenInUseAuthorization()
  }

  /// 位置或者设备方向更新后，会调用此函数
  func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
    controller.onUserLocationChange(location: userLocation.toLocation)
    if updatingLocation && resetsTrackingAfterFirstLocation {
      resetsTrackingAfterFirstLocation = false
      mapView.setUserTrackingMode(.none, animated: false)
    }
  }

  /// 在地图View将要启动定位时，会调用此函数
  func mapViewWillStartLocatingUser(_ mapView: MAMapView!) {
    NSLog("mapViewWillStartLocatingUser")
  }

  /// 在地图View停止定位后，会调用此函数
  func mapViewDidStopLocatingUser(_ mapView: MAMapView!) {
    NSLog("mapViewDidStopLocatingUser")
  }

  /// 定位失败后，会调用此函数
  func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
    NSLog("didFailToLocateUserWithError")
  }

  /// 当userTrackingMode改变时，调用此接口
  func mapView(_ mapView: MAMapView!, didChange mode: MAUserTrackingMode, animated: Bool) {
    NSLog("didChange:MAUserTrackingMode")
  }

  /// 根据 overlay 生成对应的 Renderer
  func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
    if let line = overlay as? MAPolyline, let style = controller.api.navigateArrowStyle(for: line) {
      let renderer = MAPolylineRenderer(polyline: line)
      renderer?.is3DArrowLine = true
      renderer?.strokeColor = style.color
      renderer?.sideColor = style.sideColor
      renderer?.lineWidth = amapOverlayLineWidth(style.width)
      return renderer
    }
    if let line = overlay as? MAPolyline, let style = controller.api.polylineStyle(for: line) {
      let renderer: MAPolylineRenderer? = {
        if let multiLine = line as? MAMultiPolyline, !style.colors.isEmpty {
          let renderer = MAMultiColoredPolylineRenderer(multiPolyline: multiLine)
          renderer?.strokeColors = style.colors
          renderer?.gradient = style.gradient
          return renderer
        }
        return MAPolylineRenderer(polyline: line)
      }()
      renderer?.strokeColor = style.color
      renderer?.lineWidth = amapOverlayLineWidth(style.width)
      return renderer
    }
    if let arc = overlay as? MAArc, let style = controller.api.arcStyle(for: arc) {
      let renderer = MAArcRenderer(arc: arc)
      renderer?.strokeColor = style.color
      renderer?.lineWidth = amapOverlayLineWidth(style.width)
      return renderer
    }
    if let polygon = overlay as? MAPolygon, let style = controller.api.polygonStyle(for: polygon) {
      let renderer = MAPolygonRenderer(polygon: polygon)
      renderer?.strokeColor = style.strokeColor
      renderer?.fillColor = style.fillColor
      renderer?.lineWidth = amapOverlayLineWidth(style.strokeWidth)
      return renderer
    }
    return nil
  }

  /// 当mapView新添加overlay renderers时，调用此接口
  func mapView(_ mapView: MAMapView!, didAddOverlayRenderers overlayRenderers: [Any]!) {
    NSLog("didAddOverlayRenderers")
  }

  /// 地形图加载失败
  func mapView(_ mapView: MAMapView!, didFailLoadTerrainWithError error: Error!) {
    NSLog("didFailLoadTerrainWithError")
  }

  /// 室内地图出现,返回室内地图信息
  func mapView(_ mapView: MAMapView!, didIndoorMapShowed indoorInfo: MAIndoorInfo!) {
    NSLog("didIndoorMapShowed")
  }

  /// 室内地图楼层发生变化,返回变化的楼层
  func mapView(_ mapView: MAMapView!, didIndoorMapFloorIndexChanged indoorInfo: MAIndoorInfo!) {
    NSLog("didIndoorMapFloorIndexChanged")
  }

  /// 室内地图消失后,返回室内地图信息
  func mapView(_ mapView: MAMapView!, didIndoorMapHidden indoorInfo: MAIndoorInfo!) {
    NSLog("didIndoorMapHidden")
  }

  /// 离线地图数据将要被加载, 调用reloadMap会触发该回调，离线数据生效前的回调.
  func offlineDataWillReload(_ mapView: MAMapView!) {
    NSLog("offlineDataWillReload")
  }

  /// 离线地图数据加载完成, 调用reloadMap会触发该回调，离线数据生效后的回调.
  func offlineDataDidReload(_ mapView: MAMapView!) {
    NSLog("offlineDataDidReload")
  }
}
