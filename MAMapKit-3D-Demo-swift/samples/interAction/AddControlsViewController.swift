//
//  AddControlsViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class AddControlsViewController: UIViewController , MAMapViewDelegate {
    
    var mapView: MAMapView!
    var gpsButton: UIButton!
    var logoCenterX: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initMapView()
        
        let zoomPannelView = self.makeZoomPannelView()
        zoomPannelView.center = CGPoint.init(x: self.view.bounds.size.width -  zoomPannelView.bounds.width/2 - 10, y: self.view.bounds.size.height -  zoomPannelView.bounds.width/2 - 30)
        
        zoomPannelView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin , UIViewAutoresizing.flexibleLeftMargin]
        self.view.addSubview(zoomPannelView)
        
        gpsButton = self.makeGPSButtonView()
        gpsButton.center = CGPoint.init(x: gpsButton.bounds.width / 2 + 10, y:self.view.bounds.size.height -  gpsButton.bounds.width / 2 - 20)
        self.view.addSubview(gpsButton)
        gpsButton.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin , UIViewAutoresizing.flexibleRightMargin]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "改变logo位置" , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.changeLogoPosition(sender:)))

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func makeGPSButtonView() -> UIButton! {
        let ret = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        ret.backgroundColor = UIColor.white
        ret.layer.cornerRadius = 4
        
        ret.setImage(UIImage.init(named: "gpsStat1"), for: UIControlState.normal)
        ret.addTarget(self, action: #selector(self.gpsAction), for: UIControlEvents.touchUpInside)
        
        return ret
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
    
    func initMapView() {
        mapView = MAMapView(frame: CGRect(x: 0, y: 90, width: self.view.bounds.width, height: self.view.bounds.height - 90))
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
        self.logoCenterX = self.mapView.logoCenter.x
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
    
    //定位按钮点击
    @objc func gpsAction() {
        if(self.mapView.userLocation.isUpdating && self.mapView.userLocation.location != nil) {
            self.mapView.setCenter(self.mapView.userLocation.location.coordinate, animated: true)
            self.gpsButton.isSelected = true
        }
    }
    
    //改变logo位置
    @objc func changeLogoPosition(sender: UISwitch) {
        let oldCenter = self.mapView.logoCenter
        self.mapView.logoCenter = CGPoint.init(x: oldCenter.x > self.view.bounds.size.width / 2 ? self.logoCenterX : self.mapView.bounds.size.width - self.logoCenterX, y: oldCenter.y)
    }
    
    //MARK:- xib btn click
    
    //是否显示比例尺，此外还可以改变比例尺原点位置，比例尺的最大宽高，详见MAMapView头文件
    @IBAction func switchShowScale(_ sender: UISwitch) {
        self.mapView.showsScale = sender.isOn
    }
    
    //是否显示指南针，此外还可以改变指南针原点位置，指南针的宽高，详见MAMapView头文件
    @IBAction func switchShowCompass(_ sender: UISwitch) {
        self.mapView.showsCompass = sender.isOn
    }
    
    //是否显示3D楼块
    @IBAction func switchShowBuilding(_ sender: UISwitch) {
        self.mapView.isShowsBuildings = sender.isOn
    }
    
    //是否显示底图标注
    @IBAction func switchShowLabels(_ sender: UISwitch) {
        self.mapView.isShowsLabels = sender.isOn
    }
    
    
}
