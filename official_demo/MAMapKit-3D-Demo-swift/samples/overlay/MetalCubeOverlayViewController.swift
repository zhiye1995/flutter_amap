//
//  StereoOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class MetalCubeOverlayViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    var cubeOverlay: CubeOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlays()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(cubeOverlay)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        MAMapView.metalEnabled = true;
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func initOverlays() {
        cubeOverlay = CubeOverlay.init(center: CLLocationCoordinate2DMake(39.99325, 116.473209), lengthOfSide: 5000.0)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: CubeOverlay.self))
        {
            let renderer = MetalCubeOverlayRenderer.init(cubeOverlay: overlay as! CubeOverlay!)
            
            return renderer;
        }
        
        return nil;
    }
    
    func mapView(_ mapView: MAMapView!, didAddOverlayRenderers overlayRenderers: [Any]!) {
        let mapStatus:MAMapStatus = mapView.getMapStatus();
        mapStatus.centerCoordinate = self.cubeOverlay.coordinate;
        mapStatus.cameraDegree = 60.0;
        mapStatus.rotationDegree = 135.0;
        mapStatus.zoomLevel = 12;
        
        mapView.setMapStatus(mapStatus, animated:true, duration: 5.0);
    }
}
