//
//  CoordinateConvertViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CoordinateConvertViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMapView()
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 64, width: self.view.bounds.size.width, height: 40))
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textColor = UIColor.white
        label.text = "点击地图显示屏幕坐标"
        label.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleBottomMargin]
        self.view.addSubview(label)
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

    //MARK: - mapview delegate
    func mapView(_ mapView:MAMapView, didSingleTappedAt coordinate:CLLocationCoordinate2D) {
        let point = mapView.convert(coordinate, toPointTo: self.view)
        
        self.view.makeToast(String.init(format: "screenPoint =  {%f, %f}", point.x, point.y), duration: 1.5)
    }
}
