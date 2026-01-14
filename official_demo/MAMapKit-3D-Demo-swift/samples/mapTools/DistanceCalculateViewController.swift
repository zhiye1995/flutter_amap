//
//  DistanceCalculateViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class DistanceCalculateViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var pin1: MAPointAnnotation!
    var pin2: MAPointAnnotation!
    
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
            
            let p1 = MAMapPointForCoordinate(loc1)
            let p2 = MAMapPointForCoordinate(loc2)
            
            let distance =  MAMetersBetweenMapPoints(p1, p2)
            
            self.view.makeToast(String.init(format: "distance between two pins = %.2f", distance), duration: 1.5)
        }

    }
}

