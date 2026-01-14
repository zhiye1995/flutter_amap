//
//  CustomAnnotationViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by 翁乐 on 10/10/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

import UIKit

class CustomAnnotationViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(returnAction))
        
        mapView = MAMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        
        navigationItem.rightBarButtonItem = rightItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addAnnotationWithCooordinate(coordinate: mapView.centerCoordinate)
    }
    
    @objc func returnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func addAction() {
        let randomCoordinate = mapView.convert(randomPoint(), toCoordinateFrom: view)
        
        addAnnotationWithCooordinate(coordinate: randomCoordinate)
    }
    
    func randomPoint() -> CGPoint {
        return CGPoint(x: CGFloat(arc4random() % UInt32(view.bounds.width)), y: CGFloat(arc4random() % UInt32(view.bounds.height)))
    }
    
    func offsetToContainRect(innerRect: CGRect, outerRect: CGRect) -> CGSize {
        let nudgeRight: CGFloat = CGFloat.maximum(0, outerRect.minX - innerRect.minX)
        let nudgeLeft: CGFloat = CGFloat.minimum(0, outerRect.maxX - innerRect.maxX)
        let nudgeTop: CGFloat = CGFloat.maximum(0, outerRect.minY - innerRect.minY)
        let nudgeBottom: CGFloat = CGFloat.minimum(0, outerRect.maxY - innerRect.maxY)
        
        return CGSize.init(width: nudgeLeft == 0 ? 0 : nudgeRight , height: nudgeTop == 0 ? 0: nudgeBottom)
    }
    
    func addAnnotationWithCooordinate(coordinate: CLLocationCoordinate2D) {
        let annotation: MAPointAnnotation? = MAPointAnnotation()
        annotation?.coordinate = coordinate
        annotation?.title = "AutoNavi"
        annotation?.subtitle = "CustomAnnotationView"
        
        mapView.addAnnotation(annotation!)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let customReuseIndetifier: String = "customReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customReuseIndetifier) as? CustomAnnotationView
            
            if annotationView == nil {
                annotationView = CustomAnnotationView.init(annotation: annotation, reuseIdentifier: customReuseIndetifier)
                
                annotationView?.canShowCallout = false
                annotationView?.isDraggable = true
                annotationView?.calloutOffset = CGPoint.init(x: 0, y: -5)
            }
            
            annotationView?.portrait = UIImage.init(named: "hema")
            annotationView?.name = "河马"
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view is CustomAnnotationView {
            let cusView = view as! CustomAnnotationView
            var frame: CGRect = cusView.convert(cusView.calloutView.frame, to: mapView)
            
            frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsets.init(top: kCalloutViewMargin, left: kCalloutViewMargin, bottom: kCalloutViewMargin, right: kCalloutViewMargin))
            
            if !mapView.frame.contains(frame) {
                let offset: CGSize = offsetToContainRect(innerRect: frame, outerRect: mapView.frame)
                var theCenter: CGPoint = mapView.center
                theCenter = CGPoint.init(x: theCenter.x - offset.width, y: theCenter.y - offset.height)
                
                let coordinate: CLLocationCoordinate2D = mapView.convert(theCenter, toCoordinateFrom: mapView)
                
                mapView.setCenter(coordinate, animated: true)
            }
        }
    }
}
