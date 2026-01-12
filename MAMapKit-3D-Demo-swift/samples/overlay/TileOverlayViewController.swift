//
//  TileOverlayViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class TileOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var tileOverlay: MATileOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addTileOverlayAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.zoomLevel = 13
        self.view.addSubview(mapView)
    }
    
    func buildOverlay() -> MATileOverlay! {
        var tileOverlay:MATileOverlay!
        tileOverlay = LocalTileOverlay.init()
        tileOverlay.minimumZ = 4;
        tileOverlay.maximumZ = 17;
        return tileOverlay;
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MATileOverlay.self))
        {
            let renderer = MATileOverlayRenderer.init(tileOverlay: overlay as! MATileOverlay!)
            return renderer;
        }
        
        return nil;
    }
    
    //MARK: - event handling
    @objc func addTileOverlayAction() {
        /* 删除之前的楼层. */
        self.mapView.remove(self.tileOverlay)
        
        /* 添加新的楼层. */
        self.tileOverlay = self.buildOverlay()
        
        
        self.mapView.add(self.tileOverlay)
    }
}

