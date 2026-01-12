//
//  RunningLineViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class RunningLineViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var line: MAMultiPolyline!
    var colors: Array<UIColor>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initLine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(line)
        
        mapView.showOverlays([line], edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: false)
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
    
    func initLine() {
        colors = Array()
        
        let data: Data? = try! Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "running_record", ofType: "json")!))
        
        if(data != nil) {
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
            
            
            var arr:Array<Int> = Array.init()
            let count = (jsonObj?.count)!
            let buffer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
            
            var i = 0
            for element in jsonObj! {
                let lat = element["latitude"] as! NSString
                let lon = element["longtitude"] as! NSString
                let speed = element["speed"] as! NSString
                
                buffer[i].latitude = lat.doubleValue
                buffer[i].longitude = lon.doubleValue
                
                colors.append(self.colorFromSpeed(speed: speed.doubleValue))
                arr.append(i)
                
                i += 1
            }
            
            line = MAMultiPolyline.init(coordinates: buffer, count: UInt(i), drawStyleIndexes:arr as [NSNumber])
            
            buffer.deallocate(capacity: count)
        }
    }
    
    func colorFromSpeed(speed: Double) -> UIColor {
        let lowSpeedTh = 2.0
        let highSpeedTh = 3.5
        let warmHue = 0.02 //偏暖色
        let coldHue = 0.4 //偏冷色
        
        let hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh)
        return UIColor.init(hue: CGFloat(hue), saturation: 1, brightness: 1, alpha: 1)
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAMultiPolyline.self))
        {
            let renderer = MAMultiColoredPolylineRenderer.init(multiPolyline: overlay as! MAMultiPolyline!)
            
            renderer?.lineWidth = 8.0
            renderer?.strokeColors = colors
            renderer?.isGradient = true
            
            return renderer;
        }
        
        return nil;
    }
}
