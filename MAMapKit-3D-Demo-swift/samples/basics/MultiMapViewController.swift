//
//  MultiMapViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/18.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class MultiMapViewController: UIViewController, MAMapViewDelegate {
    var mapView1: MAMapView!
    var mapView2: MAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
        var rect = self.view.bounds;
        rect.origin.y = 64;
        rect.size.height = (rect.height - 64 - 10) / 2;
        mapView1 = MAMapView(frame: rect)
        mapView1.delegate = self
        self.view.addSubview(mapView1)
        
        rect.origin.y = rect.maxY + 10
        mapView2 = MAMapView(frame: rect)
        mapView2.delegate = self
        self.view.addSubview(mapView2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

