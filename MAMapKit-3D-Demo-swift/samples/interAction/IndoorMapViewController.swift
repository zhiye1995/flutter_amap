//
//  IndoorMapViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 2017/6/27.
//  Copyright © 2017年 Autonavi. All rights reserved.
//

import UIKit

class IndoorMapViewController: UIViewController {
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MAMapView(frame: view.bounds)
        view.addSubview(mapView)
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.992856,116.468982);
        self.mapView.zoomLevel = 20;
        self.mapView.isShowsIndoorMap = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "隐藏室内图", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.hideAction))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hideAction() {
        self.mapView.isShowsIndoorMap = false;
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
