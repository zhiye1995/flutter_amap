//
//  GroundOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 17/2/14.
//  Copyright © 2017年 Autonavi. All rights reserved.
//

import UIKit

class GroundOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var groundOverlay: MAGroundOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(groundOverlay)
        mapView.setVisibleMapRect(groundOverlay.boundingMapRect, animated: false)
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
        let coordBounds = MACoordinateBounds.init(northEast: CLLocationCoordinate2DMake(39.939577, 116.388331), southWest: CLLocationCoordinate2DMake(39.935029, 116.384377));
        groundOverlay = MAGroundOverlay.init(bounds: coordBounds, icon: UIImage.init(named: "GWF"))
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAGroundOverlay.self))
        {
            let renderer = MAGroundOverlayRenderer.init(groundOverlay: overlay as! MAGroundOverlay)
            return renderer;
        }
        
        return nil;
    }
}

