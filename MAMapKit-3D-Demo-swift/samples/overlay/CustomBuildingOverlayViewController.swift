//
//  CustomBuildingOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/22.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class CustomBuildingOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var customBuindingOverlay: MACustomBuildingOverlay!
    var buildingOption: MACustomBuildingOverlayOption!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.isShowsBuildings = false
        mapView.zoomLevel = 16.1
        customBuindingOverlay.defaultOption.visibile = true
        
        customBuindingOverlay.addCustomOption(buildingOption)
        
        mapView.add(customBuindingOverlay)
        mapView.add(customBuindingOverlay, level: MAOverlayLevel.aboveRoads)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.centerCoordinate = CLLocationCoordinate2DMake(39.915449, 116.397142)
        mapView.cameraDegree = 30
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    func initOverlay() {
        customBuindingOverlay = MACustomBuildingOverlay.init()
        
        var coordinate1: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.922665, longitude: 116.391863),
            CLLocationCoordinate2D(latitude: 39.923027, longitude: 116.401669),
            CLLocationCoordinate2D(latitude: 39.913581, longitude: 116.402163),
            CLLocationCoordinate2D(latitude: 39.913186, longitude: 116.392314)]
        
        buildingOption = MACustomBuildingOverlayOption.init(coordinates: &coordinate1[0], count: 4)
        buildingOption.heightScale = 4;
        buildingOption.topColor = UIColor.init(red: 238/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
        buildingOption.sideColor = UIColor.init(red: 239/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1.0)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MACustomBuildingOverlay.self))
        {
            let renderer = MACustomBuildingOverlayRenderer.init(customBuildingOverlay: (overlay as! MACustomBuildingOverlay))
            return renderer;
        }
        return nil;
    }
}
