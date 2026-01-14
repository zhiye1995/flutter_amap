//
//  CustomMapStyleViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/12/13.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CustomMapStyleViewController: UIViewController, MAMapViewDelegate {
    
    var changleStyleBtn:UIButton!
    var mapView: MAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.gray
        
        self.initMapView()
        
        changleStyleBtn = UIButton.init(frame: CGRect.init(x: 10, y: 70, width: 80, height: 25))
        changleStyleBtn.addTarget(self, action: #selector(self.changeMapStyle(button:)), for: UIControlEvents.touchUpInside)
        changleStyleBtn.backgroundColor = UIColor.red
        changleStyleBtn.setTitle("Set", for: UIControlState.normal)
        self.view.addSubview(changleStyleBtn)
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
    
    @objc func changeMapStyle(button:UIButton) {
        let title = button.title(for: UIControlState.normal);
        if(title == "Set") {
            
            var path = Bundle.main.bundlePath
            path.append("/my_style_new.data")
            let data = NSData.init(contentsOfFile: path)
            let options = MAMapCustomStyleOptions.init()
            options.styleData = data! as Data
            self.mapView.customMapStyleEnabled = true;
            self.mapView.setCustomMapStyleOptions(options)
            
            self.changleStyleBtn.setTitle("Cancel", for: UIControlState.normal)
        } else {
            self.mapView.customMapStyleEnabled = false;
            
            self.changleStyleBtn.setTitle("Set", for: UIControlState.normal)
        }
    }
    
    // MAKR: - MAMapViewDelegate
    func mapInitComplete(_ mapView: MAMapView!) {
        self.changeMapStyle(button: self.changleStyleBtn)
    }

}
