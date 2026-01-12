//
//  MapEventCallbackViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class MapEventCallbackViewController: UIViewController , MAMapViewDelegate , UIGestureRecognizerDelegate {
    
    var mapView: MAMapView!
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        
        setupGestures()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    //如果开发者觉得地图内部手势的回调不够用，也可自行添加手势，但需要做一些额外的处理，才能保证地图内部的手势和自行添加的手势都能工作
    func setupGestures() {
        self.doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleDoubleTap(theDoubleTap:)))
        self.doubleTap.delegate = self
        self.doubleTap.numberOfTapsRequired = 2
        self.mapView.addGestureRecognizer(self.doubleTap)
        
        self.singleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleSingleTap(theSingleTap:)))
        self.singleTap.delegate = self
        self.singleTap.require(toFail: self.doubleTap)
        self.mapView.addGestureRecognizer(self.singleTap)
    }
    
    //MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /**
     返回NO，就是自行添加的手势不触发，返回YES就是触发
     比如，地图上有AnnotationView，单击了AnnotationView，既可以只相应地图内部的手势，也可以都响应，开发者可以根据需要，自行进行条件的组合来判断
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer == self.singleTap && ((touch.view?.isKind(of: UIColor.self))! || (touch.view?.isKind(of: MAAnnotationView.self))!) {
            return false
        }
        
        if gestureRecognizer == self.doubleTap && (touch.view?.isKind(of: UIControl.self))! {
            return false
        }
        
        return true
    }
    
    //MARK: - 自行添加的手势的回调
    @objc func handleSingleTap(theSingleTap: UITapGestureRecognizer!) {
        print("my singl tap")
    }
    
    @objc func handleDoubleTap(theDoubleTap: UITapGestureRecognizer!) {
        print("my double tap")
    }
    
    //MARK: - MAMapviewDelegate
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        self.view.makeToast(String.init(format: "coordinate =  {%f, %f}", coordinate.latitude,
                                        coordinate.longitude), duration: 1.5)
    }
    
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        self.view.makeToast(String.init(format: "new zoomLevel = %.2f", self.mapView.zoomLevel), duration: 1.5)
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        self.view.makeToast(String.init(format: "did moved, newCenter = {%f, %f}", self.mapView.centerCoordinate.latitude,
            self.mapView.centerCoordinate.longitude), duration: 1.5)
    }
    
    func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
        let msg = String.init(format: "coordinate =  {%f, %f}", coordinate.latitude, coordinate.longitude)
        let alert = UIAlertView.init(title: "", message: msg, delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles:"Cancel")
        alert.show()
    }
}

