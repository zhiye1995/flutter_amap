//
//  ReGeocodeViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class ReGeocodeViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initSearch()
        initToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let label = UILabel()
        label.text = "长按添加标注进行逆地理查询"
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20)
        label.sizeToFit()
        
        let item = UIBarButtonItem(customView: label)
        self.toolbarItems = [flexibleItem, item, flexibleItem]
    }
    
    //MARK: - Action
    
    func searchRegeocode(withCoordinate coordinate: CLLocationCoordinate2D) {
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        request.requireExtension = true
        
        search.aMapReGoecodeSearch(request)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        print("address: \(String(describing: view.annotation.title))")
    }
    
    func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
        searchRegeocode(withCoordinate: coordinate)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = false
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            
            return annotationView!
        }
        
        return nil
    }

    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
     
        if response.regeocode == nil {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(request.location.latitude), longitude: CLLocationDegrees(request.location.longitude))
        let anno = MAPointAnnotation()
        anno.coordinate = coordinate
        anno.title = response.regeocode.formattedAddress
        
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: false)
    }
}
