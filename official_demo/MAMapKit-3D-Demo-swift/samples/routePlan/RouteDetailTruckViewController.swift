//
//  RouteDetailTruckViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/30.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class RouteDetailTruckViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
    let kLocationName: String = "您的位置"
    let kPointGas: String = "加油站"
    let kPointViolation: String = "违章点"
    var isLocated: Bool = false
    var limits:Array<Any> = []
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var totalCourse: NSInteger = 0
    var previousItem: UIBarButtonItem!
    var nextItem: UIBarButtonItem!
    var serviceAnnotations: Array<Any>?
    var violationAnnotations:Array<MAPointAnnotation> = []
    var gasAnnotations:Array<MAAnnotation> = []

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888)
        destinationCoordinate  = CLLocationCoordinate2DMake(40.589872, 117.081956)
        serviceAnnotations = Array.init()
        initMapView()
        initSearch()
        let sws = makeSwitchsPannelView()
        sws.center = CGPoint.init(x: sws.bounds.midX + 10, y: self.view.bounds.height - sws.bounds.midY - 70)
        
        sws.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleRightMargin]
        self.view.addSubview(sws)
        initTrucklimitAreaOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.addOverlays(limits)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow;
        mapView.userLocation.title = kLocationName;
        self.view.addSubview(mapView)
    }
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    func makeSwitchsPannelView() -> UIView {
        let ret = UIView.init()
        ret.backgroundColor = UIColor.white
        let sw1 = UISwitch.init()
        let sw2 = UISwitch.init()
        let sw3 = UISwitch.init()
        let sw4 = UISwitch.init()

        let l1 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: sw1.bounds.height))
        l1.text = "路况:"
        
        let l2 = UILabel.init(frame: CGRect.init(x: 0, y: l1.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l2.text = "违章:"
        
        let l3 = UILabel.init(frame: CGRect.init(x: 0, y: l2.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l3.text = "加气站:"
        
        let l4 = UILabel.init(frame: CGRect.init(x: 0, y: l3.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l4.text = "维修站:"
        
        ret.addSubview(l1)
        ret.addSubview(sw1)
        ret.addSubview(l2)
        ret.addSubview(sw2)
        ret.addSubview(l3)
        ret.addSubview(sw3)
        ret.addSubview(l4)
        ret.addSubview(sw4)
        
        var temp = sw1.frame
        temp.origin.x = l1.frame.maxX + 5
        sw1.frame = temp
        
        temp = sw2.frame
        temp.origin.x = l2.frame.maxX + 5
        temp.origin.y = l2.frame.minY
        sw2.frame = temp
        
        temp = sw3.frame
        temp.origin.x = l3.frame.maxX + 5
        temp.origin.y = l3.frame.minY
        sw3.frame = temp
        
        temp = sw4.frame
        temp.origin.x = l4.frame.maxX + 5
        temp.origin.y = l4.frame.minY
        sw4.frame = temp
        
        sw1.addTarget(self, action: #selector(self.switchTraffic(sender:)), for: UIControlEvents.valueChanged)
        sw2.addTarget(self, action: #selector(self.enableViolation(sender:)), for: UIControlEvents.valueChanged)
        sw3.addTarget(self, action: #selector(self.enableGas(sender:)), for: UIControlEvents.valueChanged)
        sw4.addTarget(self, action: #selector(self.enableService(sender:)), for: UIControlEvents.valueChanged)

        sw1.isOn = mapView.isShowTraffic
        sw2.isOn = true
        sw3.isOn = true
        sw4.isOn = true
        
        ret.bounds = CGRect.init(x: 0, y: 0, width: sw4.frame.maxX, height: l4.frame.maxY)
        
        return ret
    }
    
    @objc func switchTraffic(sender: UISwitch) {
        mapView.isShowTraffic = sender.isOn
    }
    
    @objc func enableViolation(sender: UISwitch) {
        if (sender.isOn) {
            mapView.addAnnotations(violationAnnotations)
        }else{
            mapView.removeAnnotations(violationAnnotations)
        }
    }
    
    @objc func enableGas(sender: UISwitch) {
        if (sender.isOn) {
            mapView.addAnnotations(gasAnnotations)
        }else{
            mapView.removeAnnotations(gasAnnotations)
        }
    }
    
    @objc func enableService(sender: UISwitch) {
        if (sender.isOn) {
            mapView.addAnnotations(serviceAnnotations!)
        }else{
            mapView.removeAnnotations(serviceAnnotations!)
        }
    }
    
    func searchRoutePlanningTruck() {
        let request = AMapTruckRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        search.aMapTruckRouteSearch(request)
    }
    
    func poiPresentAnnomation(pois: Array<AMapPOI>) -> Void {
        if(gasAnnotations.count > 0){
            mapView.removeAnnotations(gasAnnotations)
            gasAnnotations.removeAll()
        }
        for poi: AMapPOI in pois {
            let annotation = MATrackPointAnnotation.init()
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(poi.location!.latitude), CLLocationDegrees(poi.location!.longitude))
            annotation.type = 0
            annotation.title = poi.name
            annotation.subtitle = poi.address
            mapView.addAnnotation(annotation)
            gasAnnotations.append(annotation)
        }
    }
    
    func servicePresentAnnomation(pois: Array<AMapPOI>) -> Void {
        if(serviceAnnotations!.count > 0){
            mapView.removeAnnotations(serviceAnnotations!)
            serviceAnnotations?.removeAll()
        }
        for poi: AMapPOI in pois {
            let annotation = MATrackPointAnnotation.init()
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(poi.location!.latitude), CLLocationDegrees(poi.location!.longitude))
            annotation.type = 1
            annotation.title = poi.name
            annotation.subtitle = poi.address
            mapView.addAnnotation(annotation)
            serviceAnnotations?.append(annotation)
        }
    }
    
    func initTrucklimitAreaOverlay() -> Void {
        let mData: Data? = try! Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Trucklimit", ofType: "txt")!))
        
        if(mData != nil) {
            let jsonObj = try? JSONSerialization.jsonObject(with: mData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
            var arr:Array<Any> = Array.init()
            for dict in jsonObj! {
                let area:String = dict["area"] as! String
                let line:String = dict["line"] as! String
                if (area.count != 0) {
                    let tmp = area.components(separatedBy: ";")
                    if tmp.count > 0{
                        let count = tmp.count
                        let coordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
                        for i in 0..<count {
                            let single = tmp[i]
                            let coord = single.components(separatedBy: ",")
                            if coord.count == 2{
                                let lat = coord.last! as NSString
                                let lon = coord.first! as NSString
                                coordinates[i].latitude = lat.doubleValue
                                coordinates[i].longitude = lon.doubleValue
                            }
                        }
                        let polygon = MAPolygon.init(coordinates: coordinates, count: UInt(count))
                        arr.append(polygon!)
                        coordinates.deallocate()
                    }
                }else if(line.count != 0){
                    let tmp0 = line.components(separatedBy: "|")
                    for res in tmp0{
                        let tmp = res.components(separatedBy: ";")
                        if tmp.count > 0{
                            let count = tmp.count
                            let coordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
                            for i in 0..<count{
                                let single = tmp[i]
                                let coord = single.components(separatedBy: ",")
                                if coord.count == 2{
                                    let lat = coord.last! as NSString
                                    let lon = coord.first! as NSString
                                    coordinates[i].latitude = lat.doubleValue
                                    coordinates[i].longitude = lon.doubleValue
                                }
                            }
                            let polyline = MAPolyline.init(coordinates: coordinates, count: UInt(count))
                            arr.append(polyline!)
                            coordinates.deallocate()
                        }
                    }
                }
            }
            limits = arr
        }
    }
    
    func searchGasPOI() {
        let request = AMapPOIAroundSearchRequest.init()
        request.keywords = "加油站"
        let coor: CLLocationCoordinate2D = mapView.userLocation.coordinate
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coor.latitude), longitude: CGFloat(coor.longitude))
        request.radius = 60*1000;
        request.types = "010100";
        request.offset = 100;
        self.search.aMapPOIAroundSearch(request)
    }
    
    func searchServicePOI() -> Void {
        let request = AMapPOIAroundSearchRequest.init()
        let coor: CLLocationCoordinate2D = mapView.userLocation.coordinate
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coor.latitude), longitude: CGFloat(coor.longitude))
        request.radius = 60*1000;
        request.types = "030000";
        request.offset = 100;
        self.search.aMapPOIAroundSearch(request)
    }
    
    func getViolationPOI() -> Void {
        let file = Bundle.main.path(forResource: "weizhang", ofType: "txt")
        guard let locationString = try? String(contentsOfFile: file!) else {
            return
        }
        let locations = locationString.components(separatedBy: "\n")
        for oneLocation in locations {
            let coordinate = oneLocation.components(separatedBy: ",")
            if coordinate.count == 2{
                let annotation = MATrackPointAnnotation.init()
                annotation.type = 2
                let lat = coordinate.last! as NSString
                let lon = coordinate.first! as NSString
                annotation.coordinate = CLLocationCoordinate2D.init(latitude: lat.doubleValue, longitude: lon.doubleValue)
                annotation.subtitle = kPointViolation
                violationAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(violationAnnotations)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if(overlay.isKind(of: MAPolyline.self)){
            let polylineRenderer = MAPolylineRenderer.init(overlay: overlay)
            polylineRenderer!.strokeColor = UIColor.red
            polylineRenderer!.lineWidth   = 2
            polylineRenderer!.lineDashType = kMALineDashTypeNone
            return polylineRenderer
        }
        if(overlay.isKind(of: MAPolygon.self)){
            let polygonRenderer = MAPolygonRenderer.init(overlay: overlay)
            polygonRenderer!.lineWidth   = 1.0
            polygonRenderer!.strokeColor = UIColor.red.withAlphaComponent(0.3)
            polygonRenderer!.fillColor   = UIColor.red.withAlphaComponent(0.3)
            return polygonRenderer
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MATrackPointAnnotation.self) {
            let kannotation:MATrackPointAnnotation = annotation as! MATrackPointAnnotation
            
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            annotationView!.image = nil
            
            if annotation.title == kLocationName{
                return nil;
            }else if (kannotation.type == 0){
                annotationView!.image = UIImage(named: "gaspoint")
            }else if (kannotation.type == 1){
                annotationView!.image = UIImage(named: "servicepoint")
            }else if (kannotation.type == 2){
                annotationView!.image = UIImage(named: "Violation")
            }
            
            return annotationView!
        }
        
        return nil
    }
    //pragma mark - MAMapViewDelegate
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    //MARK: - AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        
    }
    
    /*poi查询回调函数*/
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if (response.pois.count > 0){
            if (request.types == "010100"){
                poiPresentAnnomation(pois: response.pois)
            }else if (request.types == "030000"){
                servicePresentAnnomation(pois: response.pois)
            }
        }
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !updatingLocation {
            return
        }
        if userLocation.location.horizontalAccuracy < 0 {
            return
        }
        // only the first locate used.
        if !self.isLocated {
            self.isLocated = true
            self.mapView.userTrackingMode = .follow
            self.mapView.centerCoordinate = userLocation.location.coordinate
            searchGasPOI()
            getViolationPOI()
            searchServicePOI()
        }
        
    }
}
