//
//  HeatMapViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class HeatMapViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var heatMap: MAHeatMapTileOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initOverlay()
        initToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.add(heatMap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initToolBar() {
        let height = self.mapView.bounds.size.height;
        let width = self.view.bounds.size.width;
        
        let flexbleItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        ///gradient
        let gradientTypeSegMentControl : UISegmentedControl = UISegmentedControl.init(items: ["蓝绿红","红蓝绿","灰棕蓝绿黄红"])
        gradientTypeSegMentControl.selectedSegmentIndex = 0
        gradientTypeSegMentControl.addTarget(self, action: #selector(self.gradientAction), for: UIControlEvents.valueChanged)
        
        let mayTypeItem = UIBarButtonItem.init(customView: gradientTypeSegMentControl)
        
        self.toolbarItems = [flexbleItem, mayTypeItem, flexbleItem];
        
        
        ///control
        let panelView = UIView.init(frame: CGRect.init(x: 20, y: height - 160, width: width-40, height: 110))
        panelView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]
        panelView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        
        ///opacity
        let opacity = UISlider.init(frame: CGRect.init(x: 85, y: 5, width: width - 40 - 70 - 30, height: 50))
        opacity.value = 0.6;
        
        let laOpacity = UILabel.init(frame: CGRect.init(x: 10, y: 10, width: 70, height: 40))
        laOpacity.text = "透明度："
        opacity.addTarget(self, action: #selector(self.opacityAction(slider:)), for: UIControlEvents.touchUpInside)
        
        ///radius
        let radius = UISlider.init(frame: CGRect.init(x: 85, y: 55, width: width - 40 - 70 - 30, height: 50))
        radius.value = 0.12;
        
        let laRadius = UILabel.init(frame: CGRect.init(x: 10, y: 60, width: 70, height: 40))
        laRadius.text = "半径："
        radius.addTarget(self, action: #selector(self.radiusAction(slider:)), for: UIControlEvents.touchUpInside)
        
        panelView.addSubview(opacity)
        panelView.addSubview(laOpacity)
        panelView.addSubview(radius)
        panelView.addSubview(laRadius)
        
        
        self.view.addSubview(panelView)
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func initOverlay() {
        heatMap = MAHeatMapTileOverlay.init()
        
        let data: Data? = try! Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "heatMapData", ofType: "json")!))
        
        if(data != nil) {
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
            
            
            var arr:Array<MAHeatMapNode> = Array.init()
            
            for element in jsonObj! {
                let lat = element["lat"]
                let lon = element["lng"]
                
                let node = MAHeatMapNode.init()
                node.coordinate = CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lon as! CLLocationDegrees)
                node.intensity = 1.0
                
                arr.append(node)
            }

            heatMap.data = arr
        }
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAHeatMapTileOverlay.self))
        {
            let renderer = MATileOverlayRenderer.init(tileOverlay: overlay as! MATileOverlay!)
            return renderer;
        }
        
        return nil;
    }
    
    //MARK: - event handling
    @objc func opacityAction(slider: UISlider) {
        heatMap.opacity = CGFloat(slider.value)
        
        let render:MATileOverlayRenderer! = self.mapView.renderer(for: self.heatMap) as! MATileOverlayRenderer
        
        render.reloadData()
    }
    
    @objc func radiusAction(slider: UISlider) {
        heatMap.radius = Int(slider.value * 100)
        
        let render:MATileOverlayRenderer! = self.mapView.renderer(for: self.heatMap) as! MATileOverlayRenderer
        
        render.reloadData()
    }
    
    @objc func gradientAction(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.heatMap.gradient = MAHeatMapGradient.init(color: [UIColor.blue, UIColor.green, UIColor.red], andWithStartPoints: [0.2, 0.5, 0.9])
            break
        case 1:
            self.heatMap.gradient = MAHeatMapGradient.init(color: [UIColor.red, UIColor.blue, UIColor.green], andWithStartPoints: [0.4, 0.6, 0.8])
            
            break
        case 2:
            self.heatMap.gradient = MAHeatMapGradient.init(color: [UIColor.gray, UIColor.brown, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.red ], andWithStartPoints: [0.1, 0.3, 0.5, 0.6, 0.8, 0.9])
            
            break
        default:
            break
        }
        
        let render:MATileOverlayRenderer! = self.mapView.renderer(for: self.heatMap) as! MATileOverlayRenderer
        render.reloadData()
    }
}
