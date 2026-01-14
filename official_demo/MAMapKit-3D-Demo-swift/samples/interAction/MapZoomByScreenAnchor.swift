//
//  MapZoomByScreenAnchor.swift
//  MAMapKit_3D_Demo
//
//  Created by 翁乐 on 19/10/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

import UIKit

class MapZoomByScreenAnchor: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let annotationView: MAPinAnnotationView = MAPinAnnotationView()
        annotationView.center = .init(x: 0.2 * mapView.bounds.size.width, y: 0.3 * mapView.bounds.size.height)
        annotationView.pinColor = .purple
        
        view.addSubview(annotationView)
        
        let mapStatus: MAMapStatus = mapView.getMapStatus()
        mapStatus.screenAnchor = .init(x: 0.2, y: 0.3)
        mapView.setMapStatus(mapStatus, animated: false)
        
        
    }
}
