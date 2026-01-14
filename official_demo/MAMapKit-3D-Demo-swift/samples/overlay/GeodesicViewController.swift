//
//  GeodesicViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class GeodesicViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var line: MAGeodesicPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(line)
        mapView.setVisibleMapRect(line.boundingMapRect, animated: false)
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
        var coords:[CLLocationCoordinate2D] = [CLLocationCoordinate2DMake(39.905151, 116.401726),
                                               CLLocationCoordinate2DMake(38.905151, 70.401726)];
        line = MAGeodesicPolyline.init(coordinates: &coords, count: UInt(coords.count))
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAGeodesicPolyline.self))
        {
            let renderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            renderer?.lineWidth = 6.0
            renderer?.strokeColor = UIColor.blue
            
            return renderer;
        }
        
        return nil;
    }
}

