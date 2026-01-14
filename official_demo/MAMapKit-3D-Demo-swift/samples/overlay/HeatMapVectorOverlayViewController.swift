//
//  HeatMapVectorOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by ldj on 2019/10/14.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import UIKit

class HeatMapVectorOverlayViewController: UIViewController,MAMapViewDelegate {

    var mapView: MAMapView?
    var overlay: MAHeatMapVectorOverlay?
    var data: Array<MAHeatMapVectorNode>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MAMapView(frame: view.bounds)
        mapView?.delegate = self

        if let mapView = mapView {
            view.addSubview(mapView)
        }
        mapView?.zoomLevel = 8
        mapView?.centerCoordinate = CLLocationCoordinate2DMake(35.683927, 119.518251)
        // Do any additional setup after loading the view.
        
        let file = Bundle.main.path(forResource: "honeycomb", ofType: "txt")
        var locationString: String? = nil
        do {
            locationString = try String(contentsOfFile: file ?? "", encoding: .utf8)
        } catch {
        }
        let locations = locationString?.components(separatedBy: "\n")
        data = Array()
        for i in 0..<(locations?.count ?? 0) {
            autoreleasepool {
                //MAMultiPointItem *item = [[MAMultiPointItem alloc] init];

                let coordinate = locations?[i].components(separatedBy: ",")

                if coordinate?.count == 3 {
                    let node = MAHeatMapVectorNode()
                    node.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(Double(coordinate?[1] ?? "") ?? 0.0), CLLocationDegrees(Double(coordinate?[0] ?? "") ?? 0.0))
                    node.weight = 1
                    data?.append(node)
                }
            }
        }

        let option = MAHeatMapVectorOverlayOptions()
        option.inputNodes = data
        option.size = 3000
        option.gap = 5
        option.type = MAHeatMapType.honeycomb
        option.opacity = 0.8
        option.maxIntensity = 0
        var colors: [UIColor]? = []
        if let conversion = conversionStrColor(colorStr: "ecda9a") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "efc47e") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "f3ad6a") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "f7945d") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "f97b57") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "f66356") {
            colors?.append(conversion)
        }
        if let conversion = conversionStrColor(colorStr: "ee4d5a") {
            colors?.append(conversion)
        }
        option.colors = colors

        var startPoints: [NSNumber]? = []
        for i in 0..<(colors?.count ?? 0) {
            startPoints?.append(NSNumber(value: Double(i) * 1.0 / Double(colors?.count ?? Int(0.0))))
        }
        option.startPoints = startPoints

        overlay = MAHeatMapVectorOverlay.heatMapOverlay(withOption: option)
        mapView?.add(overlay!)
    }
    
   func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
       
       if (overlay.isKind(of: MAHeatMapVectorOverlay.self))
       {
        let renderer = MAHeatMapVectorOverlayRender.init(heat: overlay as? MAHeatMapVectorOverlay)
           return renderer;
       }
       
       return nil;
   }

    func conversionStrColor(colorStr: String?) -> UIColor? {
        var colorStr = colorStr
        if (colorStr?.count ?? 0) == 0 {
            return nil
        }
        var outColor: UIColor? = nil
        if colorStr?.hasPrefix("#") ?? false {
            colorStr = (colorStr as NSString?)?.substring(from: 1)
        }
        if (colorStr?.count ?? 0) > 0 {
            var color: UInt32 = 0
            (Scanner(string: colorStr ?? "")).scanHexInt32(&color)
            outColor = UIColor(red: CGFloat((Float(color >> 16 & 0xff)) / 255), green: CGFloat((Float(color >> 8 & 0xff)) / 255), blue: CGFloat((Float(color & 0xff)) / 255), alpha: 1.0)
        }
        return outColor
    }
}
