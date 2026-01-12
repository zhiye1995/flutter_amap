//
//  ChangeZoomViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/22.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class ChangeZoomViewController: UIViewController,MAMapViewDelegate {
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        let zoomPannelView = self.makeZoomPannelView()
        zoomPannelView.center = CGPoint.init(x: self.view.bounds.size.width -  zoomPannelView.bounds.width/2 - 10, y: self.view.bounds.size.height -  zoomPannelView.bounds.width/2 - 30)
        
        zoomPannelView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin , UIViewAutoresizing.flexibleLeftMargin]
        self.view.addSubview(zoomPannelView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    func makeZoomPannelView() -> UIView {
        let ret = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 98))
        
        let incBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 49))
        incBtn.setImage(UIImage.init(named: "increase"), for: UIControlState.normal)
        incBtn.sizeToFit()
        incBtn.addTarget(self, action: #selector(self.zoomPlusAction), for: UIControlEvents.touchUpInside)
        
        let decBtn = UIButton.init(frame: CGRect.init(x: 0, y: 49, width: 53, height: 49))
        decBtn.setImage(UIImage.init(named: "decrease"), for: UIControlState.normal)
        decBtn.sizeToFit()
        decBtn.addTarget(self, action: #selector(self.zoomMinusAction), for: UIControlEvents.touchUpInside)
        
        ret.addSubview(incBtn)
        ret.addSubview(decBtn)

        return ret
    }
    
    
    //MARK:- event handling
    //放大
    @objc func zoomPlusAction() {
        let oldZoom = self.mapView.zoomLevel
        self.mapView.setZoomLevel(oldZoom+1, animated: true)
    }
    
    //缩小
    @objc func zoomMinusAction() {
        let oldZoom = self.mapView.zoomLevel
        self.mapView.setZoomLevel(oldZoom-1, animated: true)
    }
}
