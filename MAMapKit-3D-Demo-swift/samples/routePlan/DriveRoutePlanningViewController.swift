//
//  DriveRoutePlanningViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class DriveRoutePlanningViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var naviRoute: MANaviRoute?
    var route: AMapRoute?
    var currentSearchType: AMapRoutePlanningType = AMapRoutePlanningType.drive
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888)
        destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956)
        
        initMapView()
        initSearch()
        addDefaultAnnotations()
        
        initToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.makeToast("请点击底部tab选择出行方式", duration: 3, position: CSToastPositionCenter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    func initToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let segmentControl = UISegmentedControl(items: ["驾 车", "步 行", "公 交", "跨 城", "骑 行", "货车"])
        segmentControl.addTarget(self, action:#selector(self.searchTypeAction(sender:)), for: UIControlEvents.valueChanged)
        let segmentItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems = [flexibleItem, segmentItem, flexibleItem]
        
    }

    func addDefaultAnnotations() {

        let anno = MAPointAnnotation()
        anno.coordinate = startCoordinate
        anno.title = "起点"
        
        mapView.addAnnotation(anno)
        
        let annod = MAPointAnnotation()
        annod.coordinate = destinationCoordinate
        annod.title = "终点"
        
        mapView.addAnnotation(annod)
    }
    
    //MARK: - Action
    
    @objc func searchTypeAction(sender: UISegmentedControl) {
        currentSearchType = AMapRoutePlanningType(rawValue: sender.selectedSegmentIndex)!
        
        startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888)
        destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956)
        
        switch currentSearchType {
        case .drive:
            searchRoutePlanningDrive()
            break
        case .walk:
            searchRoutePlanningWalk()
            break
        case .bus:
            searchRoutePlanningBus()
            break
        case .busCrossCity:
            
            startCoordinate        = CLLocationCoordinate2DMake(40.818311, 111.670801)
            destinationCoordinate  = CLLocationCoordinate2DMake(44.433942, 125.184449)
            
            searchRoutePlanningBusCrossCity()
            break
        case .riding:
            searchRoutePlanningRiding()
            break
        case .truck:
            searchRoutePlanningTruck()
            break;
        }
    }
    
    func searchRoutePlanningDrive() {
        let request = AMapDrivingCalRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        request.showFieldType = AMapDrivingRouteShowFieldType.init(rawValue: AMapDrivingRouteShowFieldType.cost.rawValue|AMapDrivingRouteShowFieldType.tmcs.rawValue|AMapDrivingRouteShowFieldType.navi.rawValue|AMapDrivingRouteShowFieldType.cities.rawValue|AMapDrivingRouteShowFieldType.polyline.rawValue)!
        
        search.aMapDrivingV2RouteSearch(request)
    }
    
    func searchRoutePlanningWalk() {
        let request = AMapWalkingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        request.showFieldsType = .all
        search.aMapWalkingRouteSearch(request)
    }
    
    func searchRoutePlanningBus() {
        let request = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        request.showFieldsType = .all
        request.city = "010"
        request.destinationCity = "010"
        search.aMapTransitRouteSearch(request)
    }
    
    func searchRoutePlanningBusCrossCity() {
        let request = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        request.showFieldsType = .all
        request.city = "0471"
        request.destinationCity = "0431"
        search.aMapTransitRouteSearch(request)
    }
    
    func searchRoutePlanningRiding() {
        let request = AMapRidingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        request.showFieldsType = .all
        search.aMapRidingRouteSearch(request)
    }
    func searchRoutePlanningTruck() {
        let request = AMapTruckRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        search.aMapTruckRouteSearch(request)
    }
    
    /* 展示当前路线方案. */
    func presentCurrentCourse() {
        
        let start = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        let end = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        if currentSearchType == .bus || currentSearchType == .busCrossCity {
            naviRoute = MANaviRoute(for: route?.transits.first, start: start, end: end)
        } else {
            let type = MANaviAnnotationType(rawValue: currentSearchType.rawValue)
            
            naviRoute = MANaviRoute(for: route?.paths.first, withNaviType: type!, showTraffic: true, start: start, end: end)
        }
        
        naviRoute?.add(to: mapView)
        
        mapView.showOverlays((naviRoute?.routePolylines)!, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.red
            renderer.lineDashType = kMALineDashTypeSquare
            
            return renderer
        }
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            
            if naviPolyline.type == MANaviAnnotationType.walking {
                renderer.strokeColor = naviRoute?.walkingColor
            }
            else if naviPolyline.type == MANaviAnnotationType.railway {
                renderer.strokeColor = naviRoute?.railwayColor;
            }
            else {
                renderer.strokeColor = naviRoute?.routeColor;
            }
 
            return renderer
        }
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline!)
            renderer.lineWidth = 8.0
            renderer.strokeColors = naviRoute?.multiPolylineColors
            
            return renderer
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {

        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            annotationView!.image = nil
            
            if annotation.isKind(of: MANaviAnnotation.self) {
                let naviAnno = annotation as! MANaviAnnotation
                
                switch naviAnno.type {
                case MANaviAnnotationType.railway:
                    annotationView!.image = UIImage(named: "railway_station")
                    break
                case MANaviAnnotationType.drive:
                    annotationView!.image = UIImage(named: "car")
                    break
                case MANaviAnnotationType.riding:
                    annotationView!.image = UIImage(named: "ride")
                    break
                case MANaviAnnotationType.walking:
                    annotationView!.image = UIImage(named: "man")
                    break
                case MANaviAnnotationType.bus:
                    annotationView!.image = UIImage(named: "bus")
                    break
                case .truck:
                    annotationView!.image = UIImage(named: "truck")
                    break
                case .futureDrive:
                    annotationView!.image = UIImage(named: "car")
                    break
                }
            }
            else {
                if annotation.title == "起点" {
                    annotationView!.image = UIImage(named: "startPoint")
                }
                else if annotation.title == "终点" {
                    annotationView!.image = UIImage(named: "endPoint")
                }
            }
            return annotationView!
        }
        
        return nil
    }
    
    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        addDefaultAnnotations()
        
        self.route = nil
        if response.count > 0 {
            
            self.route = response.route
            presentCurrentCourse()
        }
    }
}
