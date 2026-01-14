//
//  MapBoundaryViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by shaobin on 16/9/28.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class MapBoundaryViewController: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView!
    var overlays: Array<MAOverlay>!
    var limitRegion: MACoordinateRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        self.limitRegion = MACoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: 40, longitude: 116), span: MACoordinateSpan.init(latitudeDelta: 2, longitudeDelta: 2))
        
        initMapView()
        initBorderLine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //注意，不要在viewWillAppear里设置
        self.mapView.limitRegion = self.limitRegion
        
        mapView.addOverlays(overlays)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        let frame = self.view.bounds
        
        mapView = MAMapView(frame: frame)
        mapView.delegate = self
        mapView.isRotateEnabled = false
        self.view.addSubview(mapView)
    }
    
    func initBorderLine() {
        overlays = Array()
        
        // polyline
        var lineCoordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: self.limitRegion.center.latitude + self.limitRegion.span.latitudeDelta/2, longitude: self.limitRegion.center.longitude - self.limitRegion.span.longitudeDelta/2),
            
            CLLocationCoordinate2D(latitude: self.limitRegion.center.latitude + self.limitRegion.span.latitudeDelta/2, longitude: self.limitRegion.center.longitude + self.limitRegion.span.longitudeDelta/2),
            
            CLLocationCoordinate2D(latitude: self.limitRegion.center.latitude - self.limitRegion.span.latitudeDelta/2, longitude: limitRegion.center.longitude + self.limitRegion.span.longitudeDelta/2),
            
            CLLocationCoordinate2D(latitude: self.limitRegion.center.latitude - self.limitRegion.span.latitudeDelta/2, longitude: self.limitRegion.center.longitude - self.limitRegion.span.longitudeDelta/2),
            
            CLLocationCoordinate2D(latitude: self.limitRegion.center.latitude + self.limitRegion.span.latitudeDelta/2, longitude: self.limitRegion.center.longitude - self.limitRegion.span.longitudeDelta/2)]
        
        let polyline: MAPolyline = MAPolyline(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
        overlays.append(polyline)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor.red
            
            return renderer
        }
        
        return nil
    }

}
