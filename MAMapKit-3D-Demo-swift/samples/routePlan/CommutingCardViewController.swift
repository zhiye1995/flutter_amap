//
//  CommutingCardViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/5/8.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
import UIKit
class CommutingCardViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate,CommutSettingViewControllerDelegate {
    let RoutePlanningPaddingEdge: NSInteger = 20
    let RoutePlanningViewControllerStartTitle: String = "起点"
    let RoutePlanningViewControllerDestinationTitle: String = "终点"
    let kLocationName: String = "您的位置"
    let kFirstBusStart: String = "kFirstBusStart"
    let kElseBusStart: String = "kElseBusStart"
    let kSelectPolyLine: String = "选择路线"
    var type:CommutingCardType = CommutingCardType.bus
    var titleLab:UILabel!
    var timeLab:UILabel!
    var startBtn:UIButton!
    var busNams: Array<String> = []
    var busViaStopsAno:Array<MABusStopAnnotation> = []
    var selectPolyLineAno:Array<Any> = []
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var naviRoute: MANaviRoute?
    var route: AMapRoute?
    var driveNaviRoutes: Array<Any>?
    var transit: AMapTransit?
    var bottomView: UIView!
    var seconds: NSInteger = 0
    var optionalPolyLines: Array<CustomMAMultiPolyline>?
    var selectedIndex: NSInteger = 0
    var _starLab:UILabel!
    var _endLab:UILabel!
    var startPOI:String = "国家广告产业园"
    var destinationPOI:String = "奥北家园"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        startCoordinate        = CLLocationCoordinate2DMake(39.903351, 116.473098)
        destinationCoordinate  = CLLocationCoordinate2DMake(40.018217, 116.418767)
        busNams = Array.init()
        busViaStopsAno = Array.init()
        driveNaviRoutes = Array.init()
        selectPolyLineAno = Array.init()
        optionalPolyLines = Array.init()
        initMapView()
        initSearch()
        initControls()
        initStartAndEnd()
        route = AMapRoute.init()
        if (type == CommutingCardType.bus) {
            searchRoutePlanningBus()
        }else if (type == CommutingCardType.drive){
            searchRoutePlanningDrive()
        }
        addDefaultAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        mapView.isShowTraffic = false
        mapView.userLocation.title = kLocationName
        self.view.addSubview(mapView)
    }
    
    func initSearch() {
        search = AMapSearchAPI.init()
        search.delegate = self
    }
    
    func initStartAndEnd() -> Void {
        let base = UIView.init(frame: CGRect.init(x: 75, y: 20, width: self.view.bounds.size.width - 70 - 50, height: 60))
        base.backgroundColor = UIColor.white
        self.view.addSubview(base)
        _starLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 190, height: 30))
        _starLab.text = "起点:"+self.startPOI
        _starLab.textColor = UIColor.black
        _starLab.font = UIFont.systemFont(ofSize: 14)
        base.addSubview(_starLab)
        let startBtn = UIButton.init(frame: CGRect.init(x: _starLab.bounds.origin.x + _starLab.bounds.size.width, y: 0, width: 60, height: 25))
        startBtn.backgroundColor = UIColor.red
        startBtn.setTitle("重选起点", for: UIControlState.normal)
        startBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        startBtn.addTarget(self, action: #selector(self.startBtn(sender:)), for: UIControlEvents.touchUpInside)
        base.addSubview(startBtn)
        
        _endLab = UILabel.init(frame: CGRect.init(x: 0, y: 30, width: 190, height: 30))
        _endLab.text = "终点:"+self.destinationPOI
        _endLab.textColor = UIColor.black
        _endLab.font = UIFont.systemFont(ofSize: 14)
        base.addSubview(_endLab)
        let endBtn = UIButton.init(frame: CGRect.init(x: _endLab.bounds.origin.x + _endLab.bounds.size.width, y: 30, width: 60, height: 25))
        endBtn.backgroundColor = UIColor.red
        endBtn.setTitle("重选终点", for: UIControlState.normal)
        endBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        endBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        endBtn.addTarget(self, action: #selector(self.endBtn(sender:)), for: UIControlEvents.touchUpInside)
        base.addSubview(endBtn)
    }
    
    @objc func startBtn(sender : UIButton) -> Void {
        let startVC = CommutSettingViewController.init()
        startVC.delegate = self
        startVC.type = 0;
        self.navigationController?.pushViewController(startVC, animated: true)
    }
    
    @objc func endBtn(sender : UIButton) -> Void {
        let endVC = CommutSettingViewController.init()
        endVC.delegate = self;
        endVC.type = 1
        self.navigationController?.pushViewController(endVC, animated: true)
    }
    
    func initControls() {
        let btn1 = UIButton.init()
        btn1.backgroundColor = UIColor.red
        btn1.layer.cornerRadius = 5
        btn1.layer.masksToBounds = true
        btn1.frame = CGRect.init(x: 10, y: 20, width: 60, height: 40)
        btn1.setTitle("切为驾车", for: UIControlState.normal)
        btn1.setTitleColor(UIColor.black, for: UIControlState.normal)
        btn1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn1.addTarget(self, action:#selector(self.setting(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(btn1)
    }
    
    
    @objc func setting(sender:UIButton) {
        if(type == CommutingCardType.drive){
            type = CommutingCardType.bus
            sender.setTitle("切为驾车", for: UIControlState.normal)
            searchRoutePlanningBus()
        }else{
            type = CommutingCardType.drive
            sender.setTitle("切为公交", for: UIControlState.normal)
            searchRoutePlanningDrive()
        }
        addDefaultAnnotations()
    }
    
    func addDefaultAnnotations() -> Void {
        let startAnnotation = MAPointAnnotation.init()
        startAnnotation.coordinate = startCoordinate
        startAnnotation.title = RoutePlanningViewControllerStartTitle
        let destinationAnnotation = MAPointAnnotation.init()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = RoutePlanningViewControllerDestinationTitle
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(destinationAnnotation)
    }
    func searchRoutePlanningDrive() -> Void {
        let navi = AMapDrivingCalRouteSearchRequest.init()
        navi.showFieldType = AMapDrivingRouteShowFieldType.init(rawValue: AMapDrivingRouteShowFieldType.cost.rawValue|AMapDrivingRouteShowFieldType.tmcs.rawValue|AMapDrivingRouteShowFieldType.navi.rawValue|AMapDrivingRouteShowFieldType.cities.rawValue|AMapDrivingRouteShowFieldType.polyline.rawValue)!
        navi.strategy = 32
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate!.latitude), longitude: CGFloat(startCoordinate!.longitude))
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate!.latitude), longitude: CGFloat(destinationCoordinate!.longitude))
        search.aMapDrivingV2RouteSearch(navi)
    }
    func searchRoutePlanningBus() -> Void {
        let navi = AMapTransitRouteSearchRequest.init()
        navi.strategy = 32
        navi.showFieldsType = AMapTransitRouteShowFieldsType.all
        navi.city = "beijing"
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate!.latitude), longitude: CGFloat(startCoordinate!.longitude))
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate!.latitude), longitude: CGFloat(destinationCoordinate!.longitude))
        search.aMapTransitRouteSearch(navi)
    }
    
    /* 展示当前路线方案. */
    func presentCurrentCourse() -> Void {
        mapView.removeOverlays(mapView.overlays)
        if type == CommutingCardType.bus {
            naviRoute = MANaviRoute.init(transit: transit, start: AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate!.latitude), longitude: CGFloat(startCoordinate!.longitude)), end: AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate!.latitude), longitude: CGFloat(destinationCoordinate!.longitude)))
            naviRoute?.add(to: mapView)
            
            mapView.setVisibleMapRect(CommonUtility.mapRect(forOverlays: naviRoute?.routePolylines), edgePadding: UIEdgeInsetsMake(CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge)), animated: true)
        }else if(type == CommutingCardType.drive){
            optionalPolyLines?.removeAll()
            driveNaviRoutes?.removeAll()
            let ctype = MANaviAnnotationType.drive
            if(route == nil || route?.paths == nil){
                return
            }
            for path:AMapPath in route?.paths ?? [] {
                let navi = MANaviRoute.init(for: path, withNaviType: ctype, showTraffic: true, start: AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate!.latitude), longitude: CGFloat(startCoordinate!.longitude)), end: AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate!.latitude), longitude: CGFloat(destinationCoordinate!.longitude)))
                if (driveNaviRoutes!.count == selectedIndex) {
                    navi!.selected = true
                }
                for poly:Any in (navi!.routePolylines! as [AnyObject]){
                    if((poly as AnyObject).isKind(of: CustomMAMultiPolyline.self)){
                        optionalPolyLines?.append(poly as! CustomMAMultiPolyline)
                    }
                }
                driveNaviRoutes?.append(navi as? MANaviRoute as Any)
            }
            var selectnavi : MANaviRoute?
            for navi:MANaviRoute in (driveNaviRoutes as! [MANaviRoute]){
                if(navi.selected == false){
                    navi.add(to: mapView)
                }else{
                    selectnavi = navi
                }
            }
            if( selectnavi != nil){
                selectnavi!.add(to: mapView)
            }

            let overlays:Array<MAOverlay> = (self.driveNaviRoutes![selectedIndex] as! MANaviRoute).routePolylines as! Array<MAOverlay>
            
            mapView.setVisibleMapRect(CommonUtility.mapRect(forOverlays: overlays), edgePadding: UIEdgeInsetsMake(CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge), CGFloat(RoutePlanningPaddingEdge)), animated: true)
            fetchSelectPolyLineAno()
        }
    }
    
    func fetchSelectPolyLineAno() -> Void {
        let current = route?.paths[selectedIndex].duration
        mapView.removeAnnotations(selectPolyLineAno)
        selectPolyLineAno.removeAll()
        for i in 0..<(optionalPolyLines!.count){
            if i != selectedIndex{
                let kdurtion = (route?.paths[i].duration)!
                var tip = ""
                if(labs(kdurtion - current!) < 60){
                    tip = "时间相近"
                }else{
                    if(kdurtion > current!){
                        let tim = (kdurtion - current!) / 60
                        tip.append("慢")
                        tip.append(String(tim))
                        tip.append("分钟")
                    }else{
                        let tim = (current! - kdurtion) / 60
                        tip.append("快")
                        tip.append(String(tim))
                        tip.append("分钟")
                    }
                }
                let pp = CommonUtility.fetchPointPolylinePoints((optionalPolyLines as! [MAPolyline]), mapView: mapView, index: i, selected: selectedIndex)
                if(CLLocationCoordinate2DIsValid(pp)){
                    let ano = MAPointAnnotation.init()
                    ano.coordinate = pp
                    ano.title = tip
                    ano.subtitle = kSelectPolyLine
                    selectPolyLineAno.append(ano)
                }
            }
        }
        mapView.addAnnotations(selectPolyLineAno)
    }
    
    func updateBottomViewInfo() -> Void {
        self.view.addSubview(kbottomView())
        updateBottomInfo()
    }
    func kbottomView() -> UIView {
        if(bottomView == nil){
            bottomView = UIView.init(frame: CGRect.init(x: 10, y: self.view.bounds.size.height - 60, width: self.view.bounds.size.width - 20, height: 60))
            bottomView.backgroundColor = UIColor.white
            bottomView.layer.cornerRadius = 5
            bottomView.layer.masksToBounds = true
            titleLab = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: bottomView.bounds.size.width - 20, height: 30))
            titleLab.textColor = UIColor.black
            titleLab.font = UIFont.systemFont(ofSize: 13)
            titleLab.textAlignment = NSTextAlignment.left
            bottomView.addSubview(titleLab)
            startBtn = UIButton.init(frame: CGRect.init(x: bottomView.bounds.size.width - 60, y: 0, width: 50, height: 40))
            startBtn.backgroundColor = UIColor.blue
            startBtn.setTitle("出发", for: UIControlState.normal)
            startBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            bottomView.addSubview(startBtn)
            startBtn.addTarget(self, action: #selector(self.goStart), for: UIControlEvents.touchUpInside)
            
            timeLab = UILabel.init(frame: CGRect.init(x: 20, y: 30, width: bottomView.bounds.size.width - 20, height: 30))
            timeLab.textColor = UIColor.black
            timeLab.font = UIFont.systemFont(ofSize: 13)
            timeLab.textAlignment = NSTextAlignment.left
            bottomView.addSubview(timeLab)
        }
        if(CommutingCardType.drive == type){
            startBtn.isHidden = false
        }else{
            startBtn.isHidden = true
        }
        return bottomView
    }
    
    func updateBottomInfo() -> Void {
        var transline:String = ""
        if(CommutingCardType.drive == type){
            seconds = route?.paths != nil ? (route?.paths[selectedIndex].duration)! : 0
        }
        for i in 0..<busNams.count{
            let nam:String = busNams[i]
            transline.append(nam)
            if(i != busNams.count - 1){
                transline.append("->")
            }
        }
        let nowtim:Int = Int(CommonUtility.getNowTimeTimestamp())
        let forevertime = nowtim + seconds
        let fortime = CommonUtility.getForeverTime(forevertime)
        
        let hour = seconds/3600
        let minite = (seconds - hour * 3600)/60
        titleLab.text = hour > 0 ? "全程"+String(hour)+"小时"+String(minite)+"分钟  " + transline : "全程"+String(minite)+"分钟  " + transline
        
        timeLab.text = "预计" + String(fortime ?? "") + "到达"
    }
    @objc func goStart(){
        let config = AMapNaviConfig.init()
        config.appName = CommonUtility.getApplicationName()
        config.appScheme = CommonUtility.getApplicationScheme()
        config.destination = destinationCoordinate
        config.strategy = AMapDrivingStrategy.fastest
        if AMapURLSearch.openAMapNavigation(config) {
            AMapURLSearch.getLatestAMapApp()
        }
    }
    
    func addBusDepartureStopAnnotation(buslines:Array<AMapBusLine>)  {
        var visStops:Array<AMapBusStop> = []
        for i in 0..<buslines.count{
            let busLine:AMapBusLine = buslines[i] as! AMapBusLine
            let departureStop = busLine.departureStop
            let annotation = MAPointAnnotation.init()
            annotation.coordinate = CLLocationCoordinate2DMake(Double((departureStop?.location.latitude)!), Double((departureStop?.location.longitude)!))
            if(i == 0){
                annotation.title = kFirstBusStart
            }else{
                annotation.title = kElseBusStart
            }
            mapView.addAnnotation(annotation)
            let busAno = MABusStopAnnotation.init()
            busAno.coordinate = CLLocationCoordinate2DMake(Double((departureStop?.location.latitude)!), Double((departureStop?.location.longitude)!))
            if (busLine.name.components(separatedBy: "(").count > 0) {
                let busNam:String = busLine.name.components(separatedBy: "(").first!
                busAno.busName = busNam
            }
            busAno.stopName = (i != 0) ? departureStop!.name : departureStop!.name+"上车";
            mapView.addAnnotation(busAno)
            for st:AMapBusStop in busLine.viaBusStops{
                visStops.append(st)
            }
        }
        for stop:AMapBusStop in visStops {
            let busAno = MABusStopAnnotation.init()
            busAno.coordinate = CLLocationCoordinate2DMake(Double((stop.location.latitude)), Double((stop.location.longitude)))
            busAno.stopName = stop.name
            busViaStopsAno.append(busAno)
        }
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: LineDashPolyline.self))
        {
            let polylineRenderer:MAPolylineRenderer = MAPolylineRenderer.init(overlay: (overlay as! LineDashPolyline).polyline)
            polylineRenderer.lineWidth  = 8
            polylineRenderer.lineDashType = kMALineDashTypeSquare;
            polylineRenderer.strokeColor = UIColor.red
            return polylineRenderer;
        }
        if (overlay.isKind(of: MANaviPolyline.self))
        {
            let naviPolyline:MANaviPolyline = overlay as! MANaviPolyline
            let polylineRenderer:MAPolylineRenderer = MAPolylineRenderer.init(overlay: naviPolyline.polyline)
            polylineRenderer.lineWidth = 10
            
            if (naviPolyline.type == MANaviAnnotationType.walking)
            {
                polylineRenderer.lineDashType = kMALineDashTypeSquare;
                polylineRenderer.strokeColor = naviRoute!.walkingColor;
            }
            else if (naviPolyline.type == MANaviAnnotationType.railway)
            {
                polylineRenderer.strokeColor = naviRoute!.railwayColor;
            }
            else
            {
                polylineRenderer.strokeColor = UIColor.green.withAlphaComponent(0.8)
            }
            return polylineRenderer;
        }
        if (overlay.isKind(of: CustomMAMultiPolyline.self))
        {
            let polylineRenderer:MAMultiTexturePolylineRenderer = MAMultiTexturePolylineRenderer.init(multiPolyline: overlay as! CustomMAMultiPolyline)
            
            if (selectedIndex < optionalPolyLines?.count ?? 0 && (overlay as! CustomMAMultiPolyline) == optionalPolyLines?[selectedIndex] ?? nil) {
                polylineRenderer.lineWidth = 30
                polylineRenderer.strokeTextureImages = (overlay as! CustomMAMultiPolyline).mutablePolylineTexturesSelect as! [UIImage]
            }else{
                polylineRenderer.lineWidth = 30*0.8;
                polylineRenderer.strokeTextureImages = (overlay as! CustomMAMultiPolyline).mutablePolylineTextures as? [UIImage]
            }
            return polylineRenderer;
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isKind(of: MAPointAnnotation.self))
        {
            let routePlanningCellIdentifier:String = "RoutePlanningCellIdentifier"
            
            var poiAnnotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: routePlanningCellIdentifier)
            
            if (poiAnnotationView == nil)
            {
                poiAnnotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: routePlanningCellIdentifier)
            }
            
            poiAnnotationView!.canShowCallout = true;
            poiAnnotationView!.image = nil;
            
            var isExist = false
            if (annotation.isKind(of: MABusStopAnnotation.self)) {
                for but:MABusStopAnnotation in busViaStopsAno{
                    if ((annotation as! MABusStopAnnotation) == but){
                        isExist = true
                    }
                }
                
                if (isExist) {
                    let busPlanningCellIdentifier:String = "busPlanningCellIdentifier"
                    var busAnnotationView: BusStateAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: busPlanningCellIdentifier)) as! BusStateAnnotationView
                    if (busAnnotationView == nil)
                    {
                        busAnnotationView = BusStateAnnotationView.init(annotation: annotation, reuseIdentifier: busPlanningCellIdentifier)
                    }
                    busAnnotationView!.canShowCallout = false
                    busAnnotationView!.image = UIImage.init(named: "circle")
                    busAnnotationView!.stopName = (annotation as! MABusStopAnnotation).stopName
                    busAnnotationView!.busName = ""
                    busAnnotationView!.centerOffset = CGPoint.init(x: 0, y: 0)
                    return busAnnotationView;
                }else{
                    let busPlanningCellIdentifier2: String = "busPlanningCellIdentifier2"
                    var busAnnotationView: BusStateAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: busPlanningCellIdentifier2)) as? BusStateAnnotationView
                    if (busAnnotationView == nil)
                    {
                        busAnnotationView = BusStateAnnotationView.init(annotation: annotation, reuseIdentifier: busPlanningCellIdentifier2)
                    }
                    busAnnotationView!.canShowCallout = false
                    busAnnotationView!.image = nil
                    busAnnotationView!.busName = (annotation as! MABusStopAnnotation).busName
                    busAnnotationView!.stopName = (annotation as! MABusStopAnnotation).stopName
                    busAnnotationView!.centerOffset = CGPoint.init(x: 60, y: -40)
                    return busAnnotationView;
                }
            }
            
            if (annotation.title == kFirstBusStart) {
                poiAnnotationView!.canShowCallout = false
                poiAnnotationView!.image = UIImage.init(named: "busstate")
            }else if (annotation.title==kElseBusStart){
                poiAnnotationView!.canShowCallout = false
                poiAnnotationView!.image = UIImage.init(named: "transforstop")
            }else if (annotation.subtitle == kSelectPolyLine){
                let busPlanningCellIdentifier3: String = "busPlanningCellIdentifier3"
                let busAnnotationView3 = MAPolyLineSelectAnnotationView.init(annotation: annotation, reuseIdentifier: busPlanningCellIdentifier3)
                busAnnotationView3!.canShowCallout = false
                busAnnotationView3!.image = nil
                busAnnotationView3!.tip = (annotation as! MAPointAnnotation).title
                return busAnnotationView3
            }
            
            /* 起点. */
            if (annotation.title == RoutePlanningViewControllerStartTitle)
            {
                poiAnnotationView!.image = UIImage.init(named: "default_common_route_startpoint_normal")
            }
                /* 终点. */
            else if(annotation.title == RoutePlanningViewControllerDestinationTitle)
            {
                poiAnnotationView!.image = UIImage.init(named: "default_common_route_endpoint_normal")
            }
            return poiAnnotationView;
        }
        return nil
    }
    
    //pragma mark - MAMapViewDelegate
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    func mapView(_ mapView: MAMapView!, didChange mode: MAUserTrackingMode, animated: Bool) {
        
    }
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        if (mapView.zoomLevel > 14) {
            mapView.addAnnotations(busViaStopsAno)
        }else{
            mapView.removeAnnotations(busViaStopsAno)
        }
    }
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        if (optionalPolyLines == nil || optionalPolyLines!.count <= 1) {
            return
        }
        var hitIndex = -1
        var i = 0
        for polyline:CustomMAMultiPolyline in optionalPolyLines! {
            let hit:Bool = CommonUtility.polylineHitTest(with: coordinate, mapView: mapView, polylinePoints: polyline.points, pointCount: Int(polyline.pointCount), lineWidth: 25)
            if(hit == true){
                hitIndex = i
                break
            }
            i+=1
        }
        if(hitIndex >= 0 && self.selectedIndex != hitIndex) {
            self.selectedIndex = hitIndex;
            presentCurrentCourse()
            updateBottomInfo()
        }
    }
    
    //MARK: - AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        
    }
    
    /*查询回调函数*/
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        if (response.route == nil)
        {
            return;
        }
        if (type == CommutingCardType.drive && response.route.paths == nil) {
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        addDefaultAnnotations()

        busNams.removeAll()
        route = response.route
        transit = route?.transits?.first ?? nil
        if (response.count > 0)
        {
            presentCurrentCourse()
            if (type == CommutingCardType.bus) {
                var busLines:Array<AMapBusLine> = []
                for seg:AMapSegment in transit!.segments{
                    if (seg.buslines.count > 0) {
                        busLines.append(seg.buslines.first!)
                    }
                    seconds += ((seg.taxi?.duration ?? 0) + (seg.walking?.duration ?? 0) + (seg.buslines.first?.duration ?? 0));
                }
                for busLine: AMapBusLine in busLines{
                    if(busLine.name.components(separatedBy: "(").count > 0){
                        let busNam = busLine.name.components(separatedBy: "(").first
                        busNams.append(busNam!)
                    }
                }
                addBusDepartureStopAnnotation(buslines: busLines)
            }else if (type == CommutingCardType.drive){
                seconds = (route?.paths != nil) ? route!.paths[selectedIndex].duration : 0;
            }
            updateBottomViewInfo()
        }
    }
    
    func updateLocation(_ tip: AMapTip, type ktype: Int) {
        if (ktype == 0) {
            self.startCoordinate        = CLLocationCoordinate2DMake(CLLocationDegrees(tip.location!.latitude), CLLocationDegrees(tip.location!.longitude));
            startPOI = tip.name
            _starLab.text = "起点:"+startPOI
        }else{
            self.destinationCoordinate        = CLLocationCoordinate2DMake(CLLocationDegrees(tip.location!.latitude), CLLocationDegrees(tip.location!.longitude));
            destinationPOI = tip.name
            _endLab.text = "终点:"+self.destinationPOI
        }
        if (type == CommutingCardType.bus) {
            searchRoutePlanningBus()
        }else if (type == CommutingCardType.drive){
            searchRoutePlanningDrive()
        }
        addDefaultAnnotations()
    }
}
