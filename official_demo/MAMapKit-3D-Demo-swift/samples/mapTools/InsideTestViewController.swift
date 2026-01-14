//
//  InsideTestViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class InsideTestViewController: UIViewController , MAMapViewDelegate {
    
    var mapView: MAMapView!
    var pin: MAPointAnnotation!
    var polygon:MAPolygon!
    
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
        initPolygon()
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
    
    func initPolygon() {
        var coords = [CLLocationCoordinate2DMake(39.881892, 116.293413),
                      CLLocationCoordinate2DMake(39.887600, 116.391842),
                      CLLocationCoordinate2DMake(39.833187, 116.417932),
                      CLLocationCoordinate2DMake(39.804653, 116.338255)]
        
        polygon = MAPolygon.init(coordinates: &coords, count: UInt(coords.count))
        mapView.add(polygon)
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
            let loc = self.pin.coordinate
            let p = MAMapPointForCoordinate(loc)
            
            if(MAPolygonContainsPoint(p, self.polygon.points, 4)) {
                self.view.makeToast("inside", duration: 1.5)
            } else {
                self.view.makeToast("not inside", duration:1.5);
            }
        }
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAPolygon.self))
        {
            let renderer = MAPolygonRenderer.init(polygon: overlay as! MAPolygon!)
            renderer?.strokeColor = UIColor.blue
            renderer?.fillColor = UIColor.red
            renderer?.lineWidth = 2.0
            renderer?.lineDashType = kMALineDashTypeNone
            
            return renderer;
        }
        
        return nil;
    }
}

