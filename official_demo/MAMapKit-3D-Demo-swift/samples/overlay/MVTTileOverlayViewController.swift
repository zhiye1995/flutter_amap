//
//  MVTTileOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by linshiqing on 2022/4/14.
//  Copyright © 2022 Autonavi. All rights reserved.
//

import UIKit

class MVTTileOverlayViewController: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView?
    var mvtTileOverlay: MAMVTTileOverlay?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MAMapView(frame: view.bounds)
        mapView?.delegate = self
        mapView?.zoomLevel = 5
        mapView?.centerCoordinate = CLLocationCoordinate2DMake(34, 112)
        if let mapView = mapView {
            view.addSubview(mapView)
        }

        let options = MAMVTTileOverlayOptions()
        options.url = "https://restapi.amap.com/rest/lbs/geohub/tiles/mvt"
        options.key = "abe84c0790794c6b77f7c9ca0bc9cf22"
        options.id = "25626c40-897c-11ec-bc53-bddc46ede1ee"
        mvtTileOverlay = MAMVTTileOverlay(option: options)
        mapView?.add(mvtTileOverlay!)
    }

    // MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAMVTTileOverlay.self) {
            let renderer = MAMVTTileOverlayRenderer(tileOverlay: overlay as? MAMVTTileOverlay)
            return renderer
        }

        return nil
    }
}
