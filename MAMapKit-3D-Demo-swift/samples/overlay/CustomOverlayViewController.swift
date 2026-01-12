//
//  CustomOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CustomOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var face: FaceOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(face)
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
    
    func initOverlay() {
        face = FaceOverlay.face(withLeftEyeCoordinate: CLLocationCoordinate2DMake(39.933349, 116.315633), leftEyeRadius: 5000, rightEyeCoordinate: CLLocationCoordinate2DMake(39.948691, 116.492479), rightEyeRadius: 5000) as! FaceOverlay!
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: FaceOverlay.self))
        {
            let renderer = FaceOverlayRenderer.init(faceOverlay: overlay as! FaceOverlay!)
            
            renderer?.lineWidth = 6.0
            renderer?.fillColor = UIColor.red.withAlphaComponent(0.4)
            renderer?.strokeColor = UIColor.blue
            renderer?.lineDashType = kMALineDashTypeSquare
            
            return renderer;
        }
        
        return nil;
    }
}

