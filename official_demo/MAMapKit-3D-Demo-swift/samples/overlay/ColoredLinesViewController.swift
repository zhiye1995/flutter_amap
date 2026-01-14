//
//  ColoredLinesViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class ColoredLinesViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    var lines: Array<MAOverlay>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initLines()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.addOverlays(lines)
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
    
    func initLines() {
        lines = Array()
        
        /* Colored Polyline. */
        var coloredPolylineCoords:[CLLocationCoordinate2D] = [CLLocationCoordinate2DMake(39.938698, 116.275177),
                                                              CLLocationCoordinate2DMake(39.966069, 116.289253),
                                                              CLLocationCoordinate2DMake(39.944226, 116.306076),
                                                              CLLocationCoordinate2DMake(39.966069, 116.322899),
                                                              CLLocationCoordinate2DMake(39.938698, 116.336975)];
        

        let coloredPolyline = MAMultiPolyline.init(coordinates: &coloredPolylineCoords, count: UInt(coloredPolylineCoords.count), drawStyleIndexes: [1, 3])
        
        lines.append(coloredPolyline!)
        
        /* Gradient Polyline. */
        var gradientPolylineCoords:[CLLocationCoordinate2D] = [CLLocationCoordinate2DMake(39.938698, 116.351051),
                                                              CLLocationCoordinate2DMake(39.966069, 116.366844),
                                                              CLLocationCoordinate2DMake(39.938698, 116.381264),
                                                              CLLocationCoordinate2DMake(39.938698, 116.395683),
                                                              CLLocationCoordinate2DMake(39.950067, 116.395683),
                                                              CLLocationCoordinate2DMake(39.950437, 116.423449),
                                                              CLLocationCoordinate2DMake(39.966069, 116.423449),
                                                              CLLocationCoordinate2DMake(39.966069, 116.395683)];
        
        
        let gradientPolyline = MAMultiPolyline.init(coordinates: &gradientPolylineCoords, count: UInt(gradientPolylineCoords.count), drawStyleIndexes: [0,2,3,7])
        
        lines.append(gradientPolyline!)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAMultiPolyline.self))
        {
            let renderer = MAMultiColoredPolylineRenderer.init(multiPolyline: overlay as! MAMultiPolyline!)
            
            renderer?.lineWidth = 10.0
            
            let index = lines.index(where: {$0 === overlay})
            
            if(index == 0) {
                renderer?.strokeColors = [UIColor.blue, UIColor.white, UIColor.black, UIColor.green];
                renderer?.isGradient = true
            } else {
                renderer?.strokeColors = [UIColor.red, UIColor.yellow, UIColor.green]
                renderer?.isGradient = false
            }
            
            return renderer;
        }
        
        return nil;
    }
}
