//
//  OperateMapViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class OperateMapViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMapView()
        
        
        let sws = makeSwitchsPannelView()
        sws.center = CGPoint.init(x: sws.bounds.midX + 10, y: self.view.bounds.height - sws.bounds.midY - 20)
        
        sws.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleRightMargin]
        self.view.addSubview(sws)
        
        let cameraPanel = makeMapDegreePannelView()
        cameraPanel.center = CGPoint.init(x: self.view.bounds.width - cameraPanel.bounds.midX - 10,
                                          y: self.view.bounds.height - cameraPanel.bounds.midY - 10)
        
        cameraPanel.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin , UIViewAutoresizing.flexibleLeftMargin]
        self.view.addSubview(cameraPanel)
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
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        
        //使用手势不能改变camera的角度，但通过接口还是可以改变的
        mapView.isRotateCameraEnabled = false;
    }
    
    func makeMapDegreePannelView() -> UIView {
        let ret = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 98))
        
        let incBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 49))
        incBtn.setImage(UIImage.init(named: "increase"), for: UIControlState.normal)
        incBtn.sizeToFit()
        incBtn.addTarget(self, action: #selector(self.cameraDegreePlusAction), for: UIControlEvents.touchUpInside)
        
        let decBtn = UIButton.init(frame: CGRect.init(x: 0, y: 49, width: 53, height: 49))
        decBtn.setImage(UIImage.init(named: "decrease"), for: UIControlState.normal)
        decBtn.sizeToFit()
        decBtn.addTarget(self, action: #selector(self.cameraDegreeMinusAction), for: UIControlEvents.touchUpInside)
        
        ret.addSubview(incBtn)
        ret.addSubview(decBtn)
        
        return ret
    }
    
    func makeSwitchsPannelView() -> UIView {
        let ret = UIView.init()
        ret.backgroundColor = UIColor.white
        
        let sw1 = UISwitch.init()
        let sw2 = UISwitch.init()
        let sw3 = UISwitch.init()
        
        let l1 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: sw1.bounds.height))
        l1.textColor = UIColor.black
        l1.text = "拖拽:"
        
        let l2 = UILabel.init(frame: CGRect.init(x: 0, y: l1.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l2.textColor = UIColor.black
        l2.text = "缩放:"
        
        let l3 = UILabel.init(frame: CGRect.init(x: 0, y: l2.frame.maxY + 5, width: 70, height: sw1.bounds.height))
        l3.textColor = UIColor.black
        l3.text = "旋转:"
        
        ret.addSubview(l1)
        ret.addSubview(sw1)
        ret.addSubview(l2)
        ret.addSubview(sw2)
        ret.addSubview(l3)
        ret.addSubview(sw3)
        
        var temp = sw1.frame
        temp.origin.x = l1.frame.maxX + 5
        sw1.frame = temp
        
        temp = sw2.frame
        temp.origin.x = l2.frame.maxX + 5
        temp.origin.y = l2.frame.minY
        sw2.frame = temp
        
        temp = sw3.frame
        temp.origin.x = l3.frame.maxX + 5
        temp.origin.y = l3.frame.minY
        sw3.frame = temp
        
        sw1.addTarget(self, action: #selector(self.enableDrag(sender:)), for: UIControlEvents.valueChanged)
        sw2.addTarget(self, action: #selector(self.enableZoom(sender:)), for: UIControlEvents.valueChanged)
        sw3.addTarget(self, action: #selector(self.enableRotate(sender:)), for: UIControlEvents.valueChanged)
        
        sw1.isOn = mapView.isScrollEnabled
        sw2.isOn = mapView.isZoomEnabled
        sw3.isOn = mapView.isRotateEnabled
        
        ret.bounds = CGRect.init(x: 0, y: 0, width: sw3.frame.maxX, height: l3.frame.maxY)
        
        return ret
    }
    
    //MARK: - event handling
    @objc func enableDrag(sender:UISwitch) {
        mapView.isScrollEnabled = sender.isOn
    }
    
    @objc func enableZoom(sender:UISwitch) {
        mapView.isZoomEnabled = sender.isOn
    }
    
    @objc func enableRotate(sender:UISwitch) {
        mapView.isRotateEnabled = sender.isOn
    }
    
    @objc func cameraDegreePlusAction() {
        mapView.cameraDegree += 5
    }
    
    @objc func cameraDegreeMinusAction() {
        mapView.cameraDegree -= 5
    }
}
