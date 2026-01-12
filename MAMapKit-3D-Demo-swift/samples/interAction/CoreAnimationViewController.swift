//
//  CoreAnimationViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CoreAnimationViewController: UIViewController, MAMapViewDelegate, CAAnimationDelegate {
    
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "开始", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.flyAction))
        
        // Do any additional setup after loading the view.
        initMapView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        mapView.centerCoordinate = CLLocationCoordinate2DMake(39.907728, 116.397968)
        self.view.addSubview(mapView)
    }
    
    func centerMapPointAnimation() -> CAKeyframeAnimation! {
        let fromMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(39.989870, 116.480940))
        let toMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(31.232992, 121.476773))
        
        let RATIO = 100.0
        
        let mapSize = MAMapSizeMake((toMapPoint.x - fromMapPoint.x) / RATIO, (toMapPoint.y - fromMapPoint.y) / RATIO)
        
        let centerAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerCenterMapPointKey)
        centerAnimation.delegate = self
        centerAnimation.duration = 10.0
        centerAnimation.values =
            [NSValue.init(maMapPoint: fromMapPoint),
             NSValue.init(maMapPoint: MAMapPointMake(fromMapPoint.x + mapSize.width, fromMapPoint.y + mapSize.height)),
             NSValue.init(maMapPoint: MAMapPointMake(toMapPoint.x - mapSize.width, toMapPoint.y - mapSize.height)),
             NSValue.init(maMapPoint: toMapPoint)]
        centerAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn),
                                           CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear),
                                           CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)]
        centerAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0]
        
        return centerAnimation
    }
    
    /* 生成 地图缩放级别的 CAKeyframeAnimation. */
    func zoomLevelAnimation() -> CAKeyframeAnimation {
        let zoomLevelAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerZoomLevelKey)
        
        zoomLevelAnimation.delegate = self
        zoomLevelAnimation.duration = 10.0
        zoomLevelAnimation.values = [18, 5, 5, 18]
        zoomLevelAnimation.keyTimes = [0.0, 0.4, 0.6, 1.0]
        zoomLevelAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn),
                                              CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear),
                                              CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)]
        
        return zoomLevelAnimation
    }
    
    /* 生成 地图摄像机俯视角度的 CABasicAnimation. */
    func cameraDegreeAnimation() -> CAKeyframeAnimation {
        let cameraDegreeAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerCameraDegreeKey)
        cameraDegreeAnimation.delegate = self
        cameraDegreeAnimation.duration = 10.0
        cameraDegreeAnimation.values = [0, 45]
        cameraDegreeAnimation.keyTimes = [0.0, 1.0]
        cameraDegreeAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)]
        
        return cameraDegreeAnimation
    }
    
    /*生成 地图旋转角度的 CABasicAnimation. */
    func rotationDegreeKey() -> CAKeyframeAnimation {
        let rotationDegreeAnimation = CAKeyframeAnimation.init(keyPath: kMAMapLayerRotationDegreeKey)
        rotationDegreeAnimation.delegate = self
        rotationDegreeAnimation.duration = 10.0
        rotationDegreeAnimation.values = [0, 180]
        rotationDegreeAnimation.keyTimes = [0.0, 1.0]
        rotationDegreeAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)]
        
        return rotationDegreeAnimation
    }
 
    //MARK:- event handling
    @objc func flyAction(sender: UISwitch!) {
        self.mapView .addAnimation(with: self.centerMapPointAnimation(), zoom: self.zoomLevelAnimation(), rotateAnimation: self.rotationDegreeKey(), cameraDegreeAnimation: self.cameraDegreeAnimation())
    }
}
