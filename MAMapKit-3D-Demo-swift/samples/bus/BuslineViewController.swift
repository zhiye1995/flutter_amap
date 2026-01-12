//
//  BuslineViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class BuslineViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initSearch()
        initSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func initSearchBar() {
        searchBar = UISearchBar()
        searchBar.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        searchBar.delegate = self
        searchBar.placeholder = "请输入北京公交线路名称"
        searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar
    }
    
    
    //MARK: - Action
    
    func searchBusline(withKeyword keyword: String?) {
        
        if keyword == nil || keyword! == "" {
            return
        }
        
        let request = AMapBusLineNameSearchRequest()
        request.keywords = keyword
        request.city = "北京"
        request.requireExtension = true
        search.aMapBusLineNameSearch(request)
    }
    
    //MARK:- UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBusline(withKeyword: searchBar.text)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        print("name: \(String(describing: view.annotation.title))")
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.isDraggable = false
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            
            return annotationView!
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.cyan
            
            return renderer
        }
        
        return nil
    }
    
    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onBusLineSearchDone(_ request: AMapBusLineBaseSearchRequest!, response: AMapBusLineSearchResponse!) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if response.count == 0 {
            return
        }
        
        if let busline = response.buslines.first {
            
            // polyline
            let polyline: MAPolyline = CommonUtility.polyline(for: busline)
            mapView.add(polyline)
            
            // stops
            var annos = Array<MAPointAnnotation>()
            
            for aStop in busline.busStops {
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(aStop.location.latitude), longitude: CLLocationDegrees(aStop.location.longitude))
                let anno = MAPointAnnotation()
                anno.coordinate = coordinate
                anno.title = aStop.name
                annos.append(anno)
            }
            
            mapView.addAnnotations(annos)
            mapView.showAnnotations(annos, animated: false)
            mapView.selectAnnotation(annos.first!, animated: true)
        }
    }
}
