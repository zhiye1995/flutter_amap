//
//  OfflineViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/11.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class OfflineViewController: UIViewController , MAMapViewDelegate {
    
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "城市列表", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.detailAction))
        
        initMapView()
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    @objc func detailAction() {
        guard let offlineViewController = MAOfflineMapViewController.sharedInstance() else {
            return;
        }
        navigationController?.pushViewController(offlineViewController, animated: true)
    }
    
}
