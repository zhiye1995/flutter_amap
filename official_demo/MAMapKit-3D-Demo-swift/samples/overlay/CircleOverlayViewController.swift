//
//  CircleOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/22.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class CircleOverlayViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var overlays: Array<MAOverlay>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlays()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addOverlays(overlays)
        mapView.showOverlays(overlays, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
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
    
    func initOverlays() {
        overlays = Array()
        
        // circle
        let circle: MACircle = MACircle(center: CLLocationCoordinate2D(latitude: 39.996441, longitude: 116.411146), radius: 10000)
        circle.hollowShapes = [MACircle(center: CLLocationCoordinate2D(latitude: 39.996441, longitude: 116.411146), radius: 5000)]
        overlays.append(circle)
        
        // polygon
        var polygonCoordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.781892, longitude: 116.283413),
            CLLocationCoordinate2D(latitude: 39.787600, longitude: 116.391842),
            CLLocationCoordinate2D(latitude: 39.733187, longitude: 116.417932),
            CLLocationCoordinate2D(latitude: 39.704653, longitude: 116.338255)]
        
        let polygon: MAPolygon = MAPolygon(coordinates: &polygonCoordinates, count: UInt(polygonCoordinates.count))
        overlays.append(polygon)
        
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MACircle.self) {
            let renderer: MACircleRenderer = MACircleRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.blue
            renderer.fillColor = UIColor.red.withAlphaComponent(0.4)
            
            return renderer
        }
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.cyan
            
            return renderer
        }
        if overlay.isKind(of: MAPolygon.self) {
            let renderer: MAPolygonRenderer = MAPolygonRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.green
            renderer.fillColor = UIColor.yellow.withAlphaComponent(0.4)
            
            return renderer
        }
        
        return nil
    }
}
