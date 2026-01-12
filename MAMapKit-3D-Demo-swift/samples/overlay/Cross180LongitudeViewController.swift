//
//  Cross180LongitudeViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/22.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class Cross180LongitudeViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var polyline: MAMultiPolyline!
    var _180LonPolyline: MAPolyline!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        initMapView()
        
        var pCoords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 40.079666, longitude: 116.602058),
            CLLocationCoordinate2D(latitude: 37.969392, longitude: -122.51812 + 360),
            CLLocationCoordinate2D(latitude: 31.36216, longitude: 121.499214)]
        
        polyline = MAMultiPolyline.init(coordinates: &pCoords, count: 3)
        polyline.drawStyleIndexes = [0,1,2]
        mapView.add(polyline)
        
        var pCoords2: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 90, longitude: 180),
            CLLocationCoordinate2D(latitude: -90, longitude: 180)]
        _180LonPolyline = MAPolyline.init(coordinates: &pCoords2, count: 2)
        mapView.add(_180LonPolyline)
        mapView.showOverlays([polyline], animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isEqual(polyline))
        {
            let polylineRenderer = MAMultiColoredPolylineRenderer.init(overlay: overlay)
            polylineRenderer?.lineWidth = 5
            polylineRenderer?.strokeColors = [UIColor.blue,UIColor.red,UIColor.yellow]
            polylineRenderer!.isGradient = true
            return polylineRenderer;
        }else if(overlay.isEqual(_180LonPolyline)) {
            let render = MAPolylineRenderer.init(overlay: overlay)
            render?.lineWidth = 1
            render?.strokeColor = UIColor.black
            render?.lineDashType = kMALineDashTypeSquare
            return render
        }
        return nil;
    }
}

