//
//  LockedAnnotationViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by shaobin on 16/9/28.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class LockedAnnotationViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    var annotations: Array<MAPointAnnotation>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addAnnotations(annotations)
//        mapView.showAnnotations(annotations, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        mapView.selectAnnotation(annotations.first!, animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "固定", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.lockAction))
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
    
    func initAnnotations() {
        annotations = Array()
        
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.992520, longitude: 116.336170),
            CLLocationCoordinate2D(latitude: 39.978234, longitude: 116.352343)]
        
        for (idx, coor) in coordinates.enumerated() {
            let anno = MAPointAnnotation()
            anno.coordinate = coor
            anno.title = String(idx)
            
            if(idx == 0) {
                anno.isLockedToScreen = true
                anno.lockedScreenPoint = CGPoint.init(x: 160, y: 160)
            }
            
            annotations.append(anno)
        }
        
    }
    
    //MARK: - MAMapViewDelegate
    
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
            
            let idx = annotations.index(of: annotation as! MAPointAnnotation)
            annotationView!.pinColor = MAPinAnnotationColor(rawValue: idx! % 3)!
            
            return annotationView!
        }
        
        return nil
    }

    //MARK: - event handling
    @objc func lockAction() {
        self.annotations.first?.isLockedToScreen = true
        self.annotations.first?.lockedScreenPoint = self.mapView.center
    }

}
