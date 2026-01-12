//
//  HeatMapVectorGridOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by linshiqing on 2022/4/14.
//  Copyright © 2022 Autonavi. All rights reserved.
//

import UIKit

class HeatMapVectorGridOverlayViewController: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView?
    var overlay: MAHeatMapVectorGridOverlay?
    var data: Array<MAHeatMapVectorGrid>!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MAMapView(frame: view.bounds)
        mapView?.delegate = self
        mapView?.zoomLevel = 14
        mapView?.centerCoordinate = CLLocationCoordinate2DMake(39.993733, 116.473581)
        if let mapView = mapView {
            view.addSubview(mapView)
        }

        initButton()
    }

    func initButton() {
        let button1 = UIButton(type: UIButtonType.roundedRect)
        button1.frame = CGRect(x: 10, y: 50, width: 70, height: 25)
        button1.backgroundColor = UIColor.red
        button1.setTitle("蜂窝", for: UIControlState.normal)
        button1.addTarget(self, action: #selector(honeycomb), for: UIControlEvents.touchUpInside)
        view.addSubview(button1)

        let button2 = UIButton(type: UIButtonType.roundedRect)
        button2.frame = CGRect(x: 10, y: 100, width: 70, height: 25)
        button2.backgroundColor = UIColor.red
        button2.setTitle("网格", for: UIControlState.normal)
        button2.addTarget(self, action: #selector(square), for: UIControlEvents.touchUpInside)
        view.addSubview(button2)
    }

    /// 蜂窝热力图（六边形）
    @objc func honeycomb() {
        generateDataWithType(type: MAHeatMapType.honeycomb)
    }

    /// 网格热力图（四边形）
    @objc func square() {
        generateDataWithType(type: MAHeatMapType.square)
    }

    /// 生成数据
    /// @param type 热力图类型
    func generateDataWithType(type: MAHeatMapType!) {
        mapView?.remove(overlay)
        let file = Bundle.main.path(forResource: "grid", ofType: "txt")
        var locationString: String?
        do {
            locationString = try String(contentsOfFile: file ?? "", encoding: .utf8)
        } catch {
        }
        let locations = locationString?.components(separatedBy: "\n")

        data = Array()
        let nodeNum = (type == MAHeatMapType.honeycomb) ? 6 : 4
        for i in 0 ..< (locations?.count ?? 0) {
            autoreleasepool {
                let lineArr = locations?[i].components(separatedBy: ",")
                let nodes = NSMutableArray()
                if lineArr?.count == 12 {
                    for i in stride(from: 0, to: lineArr?.count ?? 0, by: 2) {
                        let node = MAHeatMapVectorGridNode()
                        node.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(Double(lineArr?[i] ?? "") ?? 0.0), CLLocationDegrees(Double(lineArr?[i + 1] ?? "") ?? 0.0))
                        nodes.add(node)
                        if nodes.count == nodeNum {
                            break
                        }
                    }
                }

                let grid = MAHeatMapVectorGrid()
                grid.inputNodes = nodes.copy() as? [MAHeatMapVectorGridNode]
                let color: Double = drand48()
                grid.color = UIColor(red: 1, green: color, blue: color / 3.0, alpha: color)
                data?.append(grid)
            }
        }
        let options = MAHeatMapVectorGridOverlayOptions()
        options.inputGrids = data
        options.type = type

        overlay = MAHeatMapVectorGridOverlay.heatMapOverlay(withOption: options)
        mapView?.add(overlay!)
    }

    // MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAHeatMapVectorGridOverlay.self) {
            let renderer = MAHeatMapVectorGridOverlayRenderer(heat: overlay as? MAHeatMapVectorGridOverlay)
            return renderer
        }

        return nil
    }
}
