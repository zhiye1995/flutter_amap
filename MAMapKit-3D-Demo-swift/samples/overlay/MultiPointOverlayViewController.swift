//
//  MultiPointOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by hanxiaoming on 2017/5/22.
//  Copyright © 2017年 Autonavi. All rights reserved.
//

import UIKit

class MultiPointOverlayViewController: UIViewController, MAMapViewDelegate, MAMultiPointOverlayRendererDelegate {
    
    var mapView: MAMapView!
    var overlay: MAMultiPointOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
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
        self.view.addSubview(mapView)
    }
    
    func initOverlay() {
        
        let file = Bundle.main.path(forResource: "10w", ofType: "txt")
        guard let locationString = try? String(contentsOfFile: file!) else {
            return
        }
        
        let locations = locationString.components(separatedBy: "\n")
        
        
        var items = [MAMultiPointItem]()
        
        for oneLocation in locations {
            let item = MAMultiPointItem()
            
            let coordinate = oneLocation.components(separatedBy: ",")
            
            if (coordinate.count == 2)
            {
                item.coordinate = CLLocationCoordinate2D(latitude: Double(coordinate[1])!, longitude: Double(coordinate[0])!)
                items.append(item)
            }

        }
        
        self.overlay = MAMultiPointOverlay(multiPointItems: items)
        self.mapView.add(self.overlay)
        self.mapView.setVisibleMapRect(self.overlay.boundingMapRect, animated: false)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAMultiPointOverlay.self))
        {
            let renderer = MAMultiPointOverlayRenderer(multiPointOverlay: overlay as! MAMultiPointOverlay!)
            renderer!.delegate = self
            renderer!.icon = UIImage(named: "marker_blue")
            return renderer;
        }
        
        return nil;
    }
    
    //MARK: - MAMultiPointOverlayRendererDelegate
    
    func multiPointOverlayRenderer(_ renderer: MAMultiPointOverlayRenderer!, didItemTapped item: MAMultiPointItem!) {
        print("item :\(item) <\(item.coordinate)>")
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(item)
    }
}
