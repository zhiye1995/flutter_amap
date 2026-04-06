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

class _AMapApi: NSObject {
  let registrar: FlutterPluginRegistrar
  let mapView: MAMapView
  let mapInitConfig: MapInitConfig?
  var markers = [String: Annotation]()
  var markerIds = [Int: String]()

  init(registrar: FlutterPluginRegistrar, mapView: MAMapView, mapInitConfig: MapInitConfig?) {
    self.registrar = registrar
    self.mapView = mapView
    self.mapInitConfig = mapInitConfig
  }

  func initMap() {
    if let config = mapInitConfig {
      if let type = config.mapType {
        mapView.mapType = type.mapType
      }
      if let cameraPosition = config.cameraPosition {
        if let position = cameraPosition.position {
          mapView.centerCoordinate = position.coordinate
        }
        if let heading = cameraPosition.heading {
          mapView.rotationDegree = heading
        }
        if let skew = cameraPosition.skew {
          mapView.cameraDegree = skew
        }
        if let zoom = cameraPosition.zoom {
          mapView.zoomLevel = zoom
        }
      }
      if let fitPositions = config.fitPositions {
        var north: Double?
        var east: Double?
        var south: Double?
        var west: Double?

        for position in fitPositions {
          if(north == nil || north! < position.latitude) {
            north = position.latitude
          }
          if(east == nil || east! < position.longitude) {
            east = position.longitude
          }
          if(south == nil || south! > position.latitude) {
            south = position.latitude
          }
          if(west == nil || west! > position.longitude) {
            west = position.longitude
          }
        }

        if(north != nil && east != nil && south != nil && west != nil) {
          mapView.setRegion(MACoordinateRegion.init(north!, east!, south!, west!), animated: false)
        }
      }
      if let minZoom = config.minZoom {
        mapView.minZoomLevel = minZoom
      }
      if let maxZoom = config.maxZoom {
        mapView.maxZoomLevel = maxZoom
      }
      if let dragEnable = config.dragEnable {
        mapView.isScrollEnabled = dragEnable
      }
      if let zoomEnable = config.zoomEnable {
        mapView.isZoomEnabled = zoomEnable
      }
      if let tiltEnable = config.tiltEnable {
        mapView.isRotateCameraEnabled = tiltEnable
      }
      if let rotateEnable = config.rotateEnable {
        mapView.isRotateEnabled = rotateEnable
      }
      if let compassControlEnabled = config.compassControlEnabled {
        mapView.showsCompass = compassControlEnabled
      }
      if let scaleControlEnabled = config.scaleControlEnabled {
        mapView.showsScale = scaleControlEnabled
      }
      if let custom = config.customStyleOptions {
        applyCustomStyle(custom)
      }
    }
  }

  private func applyCustomStyle(_ options: CustomStyleOptions) {
    // 离线自定义样式仅作用在标准底图上；若仍为卫星/导航等类型，样式不会正确叠加
    if options.enabled {
      mapView.mapType = MAMapType.standard
    }
    mapView.customMapStyleEnabled = options.enabled
    if options.enabled {
      let styleOption = MAMapCustomStyleOptions()
      styleOption.styleData = options.styleData
      styleOption.styleExtraData = options.styleExtraData
      mapView.setCustomMapStyleOptions(styleOption)
    }
  }

  func updateMapConfig(config: MapUpdateConfig) {
    if let type = config.mapType {
      mapView.mapType = type.mapType
    }
    if let enabled = config.dragEnable {
      mapView.isScrollEnabled = enabled
    }
    if let enabled = config.zoomEnable {
      mapView.isZoomEnabled = enabled
    }
    if let enabled = config.tiltEnable {
      mapView.isRotateCameraEnabled = enabled
    }
    if let enabled = config.rotateEnable {
      mapView.isRotateEnabled = enabled
    }
    if let enabled = config.compassControlEnabled {
      mapView.showsCompass = enabled
    }
    if let enabled = config.scaleControlEnabled {
      mapView.showsScale = enabled
    }
    if let logoPosition = config.logoPosition {
      mapView.logoCenter = logoPosition.controlCenter(size: mapView.logoSize, bounds: mapView.bounds)
    }
    if let compassControlPosition = config.compassControlPosition {
      mapView.compassOrigin = compassControlPosition.controlOrigin(size: mapView.compassSize, bounds: mapView.bounds)
    }
    if let scaleControlPosition = config.scaleControlPosition {
      mapView.scaleOrigin = scaleControlPosition.controlOrigin(size: mapView.scaleSize, bounds: mapView.bounds)
    }
    if let showTraffic = config.showTraffic {
      mapView.isShowTraffic = showTraffic
    }
    if let showBuildings = config.showBuildings {
      mapView.isShowsBuildings = showBuildings
    }
    if let showIndoorMap = config.showIndoorMap {
      mapView.isShowsIndoorMap = showIndoorMap
    }
    if let userLocationConfig = config.userLocationConfig {
      if let showLocation = userLocationConfig.showUserLocation {
        mapView.showsUserLocation = showLocation
      }
      if let userLocationStyle = userLocationConfig.userLocationStyle {
        if let userTrackingMode = userLocationStyle.userLocationType?.userTrackingMode {
          mapView.setUserTrackingMode(userTrackingMode, animated: false)
        }
        mapView.update(userLocationStyle.toUserLocationRepresentation(registrar: registrar))
      }
    }
    if let custom = config.customStyleOptions {
      applyCustomStyle(custom)
    }
  }

  func moveCamera(position: CameraPosition, duration: Int64) {
    let status = MAMapStatus()
    if let it = position.position?.coordinate { status.centerCoordinate = it }
    if let it = position.zoom { status.zoomLevel = it }
    if let it = position.skew { status.cameraDegree = it }
    if let it = position.heading { status.rotationDegree = it }
    mapView.setMapStatus(status, animated: duration > 0)
  }

  func moveCameraToRegion(region: Region, duration: Int64) {
    mapView.setRegion(region.region, animated: duration > 0)
  }

  func moveCameraToRegionWithPosition(positions: [Position?], padding: EdgePadding, duration: Int64) {
    var north: Double?
    var east: Double?
    var south: Double?
    var west: Double?

    for position in positions.filter({ position in position != nil }) {
      if(north == nil || north! < position!.latitude) {
        north = position!.latitude
      }
      if(east == nil || east! < position!.longitude) {
        east = position!.longitude
      }
      if(south == nil || south! > position!.latitude) {
        south = position!.latitude
      }
      if(west == nil || west! > position!.longitude) {
        west = position!.longitude
      }
    }

    if(north != nil && east != nil && south != nil && west != nil) {
      let origin = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: north!, longitude: west!))
      let destination = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: south!, longitude: east!))
      let size = MAMapSize(width: destination.x - origin.x, height: destination.y - origin.y)
      let mapRect = MAMapRect.init(origin: origin, size: size)
      let edgePadding = UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
      mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: false)
    }
  }

  func setRestrictRegion(region: Region) {
    mapView.limitRegion = region.region
  }

  func removeRestrictRegion() {
    mapView.limitRegion = MACoordinateRegion.init()
  }

  func addMarker(marker: Marker) {
    let annotation = marker.annotation
    markers[marker.id] = annotation
    markerIds[annotation.hash] = marker.id
    mapView.addAnnotation(annotation)
  }

  func removeMarker(id: String) {
    if let annotation = markers[id] {
      mapView.removeAnnotation(annotation)
      markers.removeValue(forKey: id)
      markerIds.removeValue(forKey: annotation.hash)
    }
  }

  func getMarkerIdByAnnotation(_ annotation: Int) -> String? {
    return markerIds[annotation]
  }

  func getUserLocation() -> Location? {
    return mapView.userLocation?.toLocation
  }

  func getScalePerPixel() -> Double {
    return mapView.metersPerPointForCurrentZoom
  }

  func start() { }

  func pause() { }

  func resume() { }

  func destroy() { }
}
