//
//  CloudLocalSearchViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CloudLocalSearchViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initSearch()
        
        searchCloudPOI()
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
    
    //MARK: - Action
    
    func searchCloudPOI() {
        
        let request = AMapCloudPOILocalSearchRequest()
        request.tableID = TableID
        request.offset = 50
        
        request.city = "北京"
        request.keywords = ""
        
//        request.filter = ["_name:龙潭"]
        
        search.aMapCloudPOILocalSearch(request)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        print("name: \(String(describing: view.annotation.title))")
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView)
            
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
    
    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onCloudSearchDone(_ request: AMapCloudSearchBaseRequest!, response: AMapCloudPOISearchResponse!) {
        mapView.removeAnnotations(mapView.annotations)
        
        if response.count == 0 {
            return
        }
        
        var annos = Array<MAPointAnnotation>()
        
        for aPOI in response.pois {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(aPOI.location.latitude), longitude: CLLocationDegrees(aPOI.location.longitude))
            let anno = MAPointAnnotation()
            anno.coordinate = coordinate
            anno.title = aPOI.name
            anno.subtitle = aPOI.address
            annos.append(anno)
        }
        
        mapView.addAnnotations(annos)
        mapView.showAnnotations(annos, animated: false)
        mapView.selectAnnotation(annos.first!, animated: true)
    }
}
