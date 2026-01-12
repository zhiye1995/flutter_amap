//
//  DistanceSearchViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by hanxiaoming on 2018/3/19.
//  Copyright © 2018年 Autonavi. All rights reserved.
//

import UIKit

class DistanceSearchViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var pin1: MAPointAnnotation!
    var pin2: MAPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initMapView()
        initSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initAnnotations()
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    func initAnnotations() {
        pin1 = MAPointAnnotation.init()
        pin2 = MAPointAnnotation.init()
        
        pin1.coordinate = CLLocationCoordinate2DMake(39.992520, 116.336170)
        pin2.coordinate = CLLocationCoordinate2DMake(39.892520, 116.436170)
        pin2.title = "拖动我哦"
        
        mapView.addAnnotations([pin1, pin2])
        mapView.selectAnnotation(pin2, animated: true)
    }
    
    //MARK: - mapview delegate
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = true
            annotationView!.pinColor = MAPinAnnotationColor.red
            
            return annotationView!
        }
        
        return nil
    }
    
    func mapView(_ mapView:MAMapView, annotationView:MAAnnotationView, didChange newState:MAAnnotationViewDragState, fromOldState:MAAnnotationViewDragState) {
        if(newState == MAAnnotationViewDragState.ending) {
            let loc1 = self.pin1.coordinate
            let loc2 = self.pin2.coordinate
            
            searchDistance(from: loc1, to: loc2)
        }
        
    }
    
    //MARK: AMapSearch
    
    func searchDistance(from starCoordinate: CLLocationCoordinate2D, to endCoordinate:CLLocationCoordinate2D) {
        
        let request = AMapDistanceSearchRequest()
        request.origins = [AMapGeoPoint.location(withLatitude: CGFloat(starCoordinate.latitude), longitude: CGFloat(starCoordinate.longitude))]
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(endCoordinate.latitude), longitude: CGFloat(endCoordinate.longitude))
        search .aMapDistanceSearch(request)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onDistanceSearchDone(_ request: AMapDistanceSearchRequest!, response: AMapDistanceSearchResponse!) {
        
        if response.results.first != nil {
            let result = response.results.first!
            if (result.info != nil) {
                self.view.makeToast(String.init(format: "distance search failed :%@", result.info), duration: 1.0)
            }
            else {
                self.view.makeToast(String.init(format: "driving distance :%ld m, duration :%ld s", result.distance, result.duration), duration: 1.0)
            }
        }
    }

}
