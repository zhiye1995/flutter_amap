//
//  MovingAnnotationViewController.swift
//  iOS-movingAnnotation
//
//  Created by shaobin on 16/11/28.
//  Copyright © 2016年 autonavi. All rights reserved.
//

import UIKit

class MovingAnnotationViewController: UIViewController, MAMapViewDelegate {

    var mapView : MAMapView!
    var movingAnnotation : MAAnimatedAnnotation!
    var coords1 : Array<CLLocationCoordinate2D> = []
    var coords2 : Array<CLLocationCoordinate2D> = []
    var coords3 : Array<CLLocationCoordinate2D> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self .initCoordinates()
        
        self.mapView = MAMapView.init(frame: self.view.bounds)
        self.mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        self.movingAnnotation = MAAnimatedAnnotation.init()
        self.movingAnnotation.coordinate = self.coords1.first!
        self.mapView.addAnnotation(self.movingAnnotation)
        
        //add overlay
        let polyline1:MAPolyline! =  MAPolyline.init(coordinates: &(self.coords1), count: UInt(self.coords1.count))
        let polyline2:MAPolyline! =  MAPolyline.init(coordinates: &(self.coords2), count: UInt(self.coords2.count))
        let polyline3:MAPolyline! =  MAPolyline.init(coordinates: &(self.coords3), count: UInt(self.coords3.count))
        self.mapView.addOverlays([polyline1, polyline2, polyline3])
        
        self.initButtons()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCoordinates() {
        ///1
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.852136, longitude: 116.30095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.852136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.932136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.932136, longitude: 116.40095))
        coords1.append(CLLocationCoordinate2D.init(latitude: 39.982136, longitude: 116.48095))
        
        ///2
        coords2.append(CLLocationCoordinate2D.init(latitude: 39.982136, longitude: 116.48095))
        coords2.append(CLLocationCoordinate2D.init(latitude: 39.832136, longitude: 116.42095))
        coords2.append(CLLocationCoordinate2D.init(latitude: 39.902136, longitude: 116.42095))
        coords2.append(CLLocationCoordinate2D.init(latitude: 39.902136, longitude: 116.44095))
        coords2.append(CLLocationCoordinate2D.init(latitude: 39.932136, longitude: 116.44095))
        
        ///3
        self.generateStarPoints(center: CLLocationCoordinate2DMake(39.800892, 116.293413))//生成多角星的坐标
        
        coords2.append(coords3.first!)
    }
    
    func generateStarPoints(center:CLLocationCoordinate2D) {
        let STAR_RADIUS = 0.05
        let PI = 3.1415926
        let starRaysCount = 5
        var i = 0
        
        while i < starRaysCount {
            var angle = 2.0 * Double.init(i) / Double.init(starRaysCount) * PI
            var index = 2 * i;
            
            coords3.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS * sin(angle) + center.latitude,
                                                        longitude: STAR_RADIUS * cos(angle) + center.longitude))
            
            index += 1
            angle = angle + 1.0/Double.init(starRaysCount) * PI
            
            coords3.append(CLLocationCoordinate2D.init(latitude: STAR_RADIUS/2.0 * sin(angle) + center.latitude,
                                                       longitude: STAR_RADIUS/2.0 * cos(angle) + center.longitude))
            
            i += 1
        }
    }

    func initButtons() {
        let button1 =  UIButton.init(type: UIButtonType.roundedRect)
        button1.frame = CGRect.init(x: 10, y: 100, width: 70, height: 25)
        button1.backgroundColor = UIColor.red
        button1.setTitle("Go", for: UIControlState.normal)
        button1.addTarget(self, action:#selector(self.button1), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button1)
        
        let button2 =  UIButton.init(type: UIButtonType.roundedRect)
        button2.frame = CGRect.init(x: 10, y: 150, width: 70, height: 25)
        button2.backgroundColor = UIColor.red
        button2.setTitle("Stop", for: UIControlState.normal)
        button2.addTarget(self, action:#selector(self.button2), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button2)
    }
    
    @objc func button1() {
        self.movingAnnotation.coordinate = coords1[0];
        
        self.movingAnnotation.addMoveAnimation(withKeyCoordinates:&(self.coords1), count: UInt(self.coords1.count), withDuration: 5, withName: nil, completeCallback:nil);
        
        self.movingAnnotation.addMoveAnimation(withKeyCoordinates:&(self.coords2), count: UInt(self.coords2.count), withDuration: 5, withName: nil, completeCallback:nil)
        
        self.movingAnnotation.addMoveAnimation(withKeyCoordinates:&(self.coords3), count: UInt(self.coords3.count), withDuration: 5, withName: nil, completeCallback:nil)
    }
    
    @objc func button2() {
        if(self.movingAnnotation.allMoveAnimations() == nil) {
            return;
        }
        
        for item in self.movingAnnotation.allMoveAnimations() {
            let animation = item 
            animation.cancel()
        }
        
        self.movingAnnotation.movingDirection = 0;
        self.movingAnnotation.coordinate = coords1[0];
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isKind(of: MAPointAnnotation.self))
        {
            let pointReuseIndetifier = "myReuseIndetifier"
            var annotationView:MAPinAnnotationView! = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView)
            if (annotationView == nil)
            {
                annotationView =  MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                
                let imge  =  UIImage.init(named: "userPosition")
                annotationView?.image =  imge
            }
            
            annotationView?.canShowCallout              = true
            annotationView.animatesDrop                 = false
            annotationView.isDraggable                   = false
            annotationView?.rightCalloutAccessoryView    = UIButton.init(type: UIButtonType.detailDisclosure)
            
            return annotationView;
        }
        
        return nil;
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: MAPolyline.self))
        {
            let polylineRenderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            polylineRenderer?.lineWidth = 8.0
            polylineRenderer?.strokeImage = UIImage.init(named: "arrowTexture")
            return polylineRenderer;
        }
        
        return nil;
    }

}
