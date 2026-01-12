//
//  ScreenShotViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class ScreenShotViewController: UIViewController, MAMapViewDelegate, UIGestureRecognizerDelegate {
    
    var mapView: MAMapView!
    var pan: UIPanGestureRecognizer!
    var shapeLayer: CAShapeLayer!
    var pointAnnotation: MAPointAnnotation!
    var circle: MACircle!
    var started: Bool = false
    var startPoint: CGPoint = CGPoint.zero
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initMapView()
        
        let title = started ? "停止" : "开始"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.startAction))
        
        initAnnotationAndOverlay()
        initToolbar()
        initGestureRecognizer()
        initShapeLayer()
        
        startAction()
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
        self.view.addSubview(mapView)
    }
    
    func initShapeLayer() {
        shapeLayer = CAShapeLayer.init()
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        shapeLayer.lineDashPattern = [5, 5]
        
        let path = CGPath.init(rect: self.view.bounds.insetBy(dx: self.view.bounds.width / 4, dy: self.view.bounds.height / 4), transform: nil)
        shapeLayer.path = path
        
        self.view.layer.addSublayer(shapeLayer)
    }
    
    func initToolbar() {
        let flexbleItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let tipLabel = UILabel.init()
        tipLabel.backgroundColor = UIColor.clear
        tipLabel.textColor = UIColor.gray
        tipLabel.text = "滑动屏幕重新设置截图区域"
        tipLabel.sizeToFit()
        
        let tipItem = UIBarButtonItem.init(customView: tipLabel)
        
        let captureItem = UIBarButtonItem.init(title: "点击截取", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.captureAction))
        
        self.toolbarItems = [flexbleItem, tipItem, flexbleItem, captureItem, flexbleItem]
    }
 
    func initGestureRecognizer() {
        pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGesture(sender:)))
        pan.delegate = self
        pan.maximumNumberOfTouches = 1
            
        self.view.addGestureRecognizer(pan)
    }
    
    func initAnnotationAndOverlay() {
        pointAnnotation = MAPointAnnotation.init()
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.911447, 116.406026)
        pointAnnotation.title = "Why not!"
        
        circle = MACircle.init(center: pointAnnotation.coordinate, radius: 5000)
    }

    //MARK: - MAMapviewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if(overlay.isKind(of: MACircle.self)) {
            let render = MACircleRenderer.init(overlay: overlay)
            
            render?.lineWidth = 4
            render?.strokeColor = UIColor.blue
            render?.fillColor = UIColor.green.withAlphaComponent(0.3)
            
            return render
        }
        
        return nil
    }
    
    //MARK:- gesture
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(pan == gestureRecognizer) {
            return started
        }
        
        return true
    }
    
    @objc func panGesture(sender:UIPanGestureRecognizer!) {
        if(sender.state == UIGestureRecognizerState.began) {
            shapeLayer.path = nil
            
            startPoint = pan.location(in: self.view)
        } else if(sender.state == UIGestureRecognizerState.changed) {
            let curPoint = pan.location(in: self.view)
            let path = CGPath.init(rect: CGRect.init(x: startPoint.x, y: startPoint.y, width: curPoint.x - startPoint.x, height: curPoint.y - startPoint.y), transform: nil)
            
            shapeLayer.path = path
        }
    }
    
    //MARK: - event handling
    @objc func startAction() {
        started = !started
        
        self.navigationItem.rightBarButtonItem?.title = started ? "停止" : "开始"
        self.navigationController?.setToolbarHidden(!started, animated: true)
        
        self.mapView.isScrollEnabled = !started
        self.shapeLayer.isHidden = !started
    }
    
    @objc func captureAction() {
        if(self.shapeLayer.path == nil) {
            return
        }
        
        let inRect = self.view.convert((self.shapeLayer.path?.boundingBox)!, to: self.mapView)
        
        let screenshotImage = self.mapView.takeSnapshot(in: inRect)
        
        let detailViewController = ScreenshotDetailViewController.init()
        detailViewController.screenshotImage = screenshotImage;
        detailViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
        
        let navi = UINavigationController.init(rootViewController: detailViewController)
        self.present(navi, animated: true) {
            
        }
    }
}
