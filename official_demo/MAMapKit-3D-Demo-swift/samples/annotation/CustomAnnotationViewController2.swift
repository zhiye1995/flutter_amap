//
//  CustomAnnotationViewController2.swift
//  MAMapKit_3D_Demo
//
//  Created by 翁乐 on 10/10/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

import UIKit

class CustomAnnotationViewController2: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: self, action: #selector(returnAction))
        
        mapView = MAMapView.init(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addAnnotationWithCooordinate(coordinate: mapView.centerCoordinate)
    }
    
    @objc func returnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func addAnnotationWithCooordinate(coordinate: CLLocationCoordinate2D) {
        let annotation: MAPointAnnotation? = MAPointAnnotation()
        annotation?.coordinate = coordinate
        annotation?.title = "AutoNavi"
        annotation?.subtitle = "CustomAnnotationView2"
        
        mapView.addAnnotation(annotation!)
    }
    
    func offsetToContainRect(innerRect: CGRect, outerRect: CGRect) -> CGSize {
        let nudgeRight: CGFloat = CGFloat.maximum(0, outerRect.minX - innerRect.minX)
        let nudgeLeft: CGFloat = CGFloat.minimum(0, outerRect.maxX - innerRect.maxX)
        let nudgeTop: CGFloat = CGFloat.maximum(0, outerRect.minY - innerRect.minY)
        let nudgeBottom: CGFloat = CGFloat.minimum(0, outerRect.maxY - innerRect.maxY)
        
        return CGSize.init(width: nudgeLeft == 0 ? 0 : nudgeRight , height: nudgeTop == 0 ? 0: nudgeBottom)
    }
    
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let customReuseIndetifier: String = "customReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customReuseIndetifier) as? CustomAnnotationView2
            
            if annotationView == nil {
                annotationView = CustomAnnotationView2.init(annotation: annotation, reuseIdentifier: customReuseIndetifier)
                
                annotationView?.canShowCallout = false
                annotationView?.isDraggable = true
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        
    }
}
