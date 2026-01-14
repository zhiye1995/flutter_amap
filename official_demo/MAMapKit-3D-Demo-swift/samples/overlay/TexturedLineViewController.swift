//
//  TexturedLineViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

enum OverlayType:Int {
    case OverlayTypeCommonPolyline=0, OverlayTypeTexturePolyline=1, OverlayTypeArrowPolyline=2, OverlayTypeMultiTexPolyline=3
}

class TexturedLineViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    var overlaysAboveLabels: Array<MAOverlay>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlays()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addOverlays(overlaysAboveLabels)
        mapView.showOverlays(overlaysAboveLabels, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
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
        overlaysAboveLabels = Array()
        
        /* Polyline. */
        var lineCoordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.832136, longitude: 116.34095),
            CLLocationCoordinate2D(latitude: 39.832136, longitude: 116.42095),
            CLLocationCoordinate2D(latitude: 39.902136, longitude: 116.42095),
            CLLocationCoordinate2D(latitude: 39.902136, longitude: 116.44095),
            CLLocationCoordinate2D(latitude: 39.932136, longitude: 116.44095)]
        
        let polyline: MAPolyline = MAPolyline(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
        overlaysAboveLabels.insert(polyline, at:OverlayType.OverlayTypeCommonPolyline.rawValue)
        
        /* Textured Polyline. */
        var texPolylineCoords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.932136, longitude: 116.44095),
            CLLocationCoordinate2D(latitude: 39.932136, longitude: 116.50095),
            CLLocationCoordinate2D(latitude: 39.952136, longitude: 116.50095)]
        
        let texPolyline: MAPolyline = MAPolyline(coordinates: &texPolylineCoords, count: UInt(texPolylineCoords.count))
        overlaysAboveLabels.insert(texPolyline, at: OverlayType.OverlayTypeTexturePolyline.rawValue)
        
        /* Arrow Polyline. */
        var arrowPolylineCoords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.793765, longitude: 116.294653),
            CLLocationCoordinate2D(latitude: 39.831741, longitude: 116.294653),
            CLLocationCoordinate2D(latitude: 39.832136, longitude: 116.34095)]
        
        let arrowPolyline: MAPolyline = MAPolyline(coordinates: &arrowPolylineCoords, count: UInt(arrowPolylineCoords.count))
        overlaysAboveLabels.insert(arrowPolyline, at: OverlayType.OverlayTypeArrowPolyline.rawValue)
        
        /* Multi-Texture Polyline. */
        var mulTexPolylineCoords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.852136, longitude: 116.30095),
            CLLocationCoordinate2D(latitude: 39.852136, longitude: 116.40095),
            CLLocationCoordinate2D(latitude: 39.932136, longitude: 116.40095),
            CLLocationCoordinate2D(latitude: 39.932136, longitude: 116.40095),
            CLLocationCoordinate2D(latitude: 39.982136, longitude: 116.48095)]
        
        let multiTexturePolyline: MAMultiPolyline = MAMultiPolyline.init(coordinates: &mulTexPolylineCoords, count: UInt(mulTexPolylineCoords.count), drawStyleIndexes: [1,2,4])
        overlaysAboveLabels.insert(multiTexturePolyline, at:OverlayType.OverlayTypeMultiTexPolyline.rawValue)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        let index = overlaysAboveLabels.index(where: {$0 === overlay})
        
        if overlay.isKind(of: MAMultiPolyline.self) {
            if (index == OverlayType.OverlayTypeMultiTexPolyline.rawValue )
            {
                let polylineRenderer:MAMultiTexturePolylineRenderer = MAMultiTexturePolylineRenderer.init(multiPolyline: overlay as! MAMultiPolyline!)
                polylineRenderer.lineWidth    = 18.0;
                
                let bad = UIImage.init(named: "custtexture_bad")
                let slow = UIImage.init(named: "custtexture_slow")
                let green = UIImage.init(named: "custtexture_green")
                
                let imgs:Array<UIImage> = [bad!, slow!, green!]
                
                polylineRenderer.strokeTextureImages = imgs
                return polylineRenderer;
            }
            else
            {
                let polylineRenderer:MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer.init(multiPolyline: overlay as! MAMultiPolyline!)
                polylineRenderer.lineWidth    = 8.0;
                polylineRenderer.strokeColors = [UIColor.red, UIColor.green, UIColor.yellow]
                
                return polylineRenderer;
            }
        }
        
        
        if overlay.isKind(of: MAPolyline.self) {
            let polylineRenderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            
            
            if (index == OverlayType.OverlayTypeTexturePolyline.rawValue )
            {
                polylineRenderer.lineWidth    = 8.0;
                polylineRenderer.strokeImage = UIImage.init(named: "arrowTexture")
            }
            else if (index == OverlayType.OverlayTypeArrowPolyline.rawValue )
            {
                polylineRenderer.lineWidth    = 20.0;
                polylineRenderer.lineCapType  = kMALineCapArrow;
            }
            else
            {
                polylineRenderer.lineWidth    = 8.0;
                polylineRenderer.strokeColor  = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.6);
                polylineRenderer.lineJoinType = kMALineJoinRound;
                polylineRenderer.lineCapType  = kMALineCapRound;
            }
            
            return polylineRenderer
        }
        
        return nil
    }
}
