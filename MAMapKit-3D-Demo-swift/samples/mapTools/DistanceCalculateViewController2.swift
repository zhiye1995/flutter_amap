//
//  DistanceCalculateViewController2.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class DistanceCalculateViewController2: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var pin: MAPointAnnotation!
    var lineCoords:[CLLocationCoordinate2D] = []
    var line:MAPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initMapView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initAnnotations()
        initLine()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    func initAnnotations() {
        pin = MAPointAnnotation.init()
        pin.coordinate = CLLocationCoordinate2DMake(39.992520, 116.336170)
        pin.title = "拖动我哦"
        
        mapView.addAnnotations([pin])
        mapView.selectAnnotation(pin, animated: true)
    }
    
    func initLine() {
        lineCoords = [CLLocationCoordinate2DMake(39.925539, 116.0),
                      CLLocationCoordinate2DMake(39.925539, 116.5)]
        
        line = MAPolyline.init(coordinates: &lineCoords, count: UInt(lineCoords.count))
        mapView.add(line)
    }
    
    //MARK: - mapview delegate
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView)
            
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
            let loc = self.pin.coordinate
            let p = MAMapPointForCoordinate(loc)
            let lineBegin = MAMapPointForCoordinate(lineCoords[0])
            let lineEnd = MAMapPointForCoordinate(lineCoords[1])
            
            let distance =  CommonUtility.distance(to: p, fromLineSegmentBetween: lineBegin, and: lineEnd)
            self.view.makeToast(String.init(format: "distance = %.2f", distance), duration: 1.5)
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAPolyline.self))
        {
            let renderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline)
            renderer?.strokeColor = UIColor.blue
            renderer?.lineWidth = 2.0
            renderer?.lineDashType = kMALineDashTypeNone
            
            return renderer;
        }
        
        return nil;
    }
}
