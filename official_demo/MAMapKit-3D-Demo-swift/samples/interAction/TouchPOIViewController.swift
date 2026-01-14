//
//  TouchPOIViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class TouchPOIViewController: UIViewController, MAMapViewDelegate {
    
    var mapView: MAMapView!
    var poiAnnotation: MAPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let touchPOIEnabledSwitch = UISwitch.init()
        touchPOIEnabledSwitch.addTarget(self, action: #selector(self.touchPOIEanbledAction), for: UIControlEvents.valueChanged)
        touchPOIEnabledSwitch.isOn = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: touchPOIEnabledSwitch)
        
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
        mapView.zoomLevel = 17
        mapView.showsUserLocation = false
        mapView.touchPOIEnabled = true
        self.view.addSubview(mapView)
    }
    
    func annotationForPoi(touchPoi:MATouchPoi?) -> MAPointAnnotation! {
        if (touchPoi == nil)
        {
            return nil;
        }
        
        let annotation = MAPointAnnotation.init()
        
        annotation.coordinate = touchPoi!.coordinate
        annotation.title      = touchPoi!.name
        
        return annotation;
    }
    
    //MARK: - mapview delegate
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView)
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.isDraggable = false
            annotationView!.pinColor = MAPinAnnotationColor.red
            
            return annotationView!
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        if (pois.count == 0)
        {
            return;
        }

        let poi = pois.first
        
        let annotation = self.annotationForPoi(touchPoi: (poi as! MATouchPoi?))
        
        /* Remove prior annotation. */
        self.mapView.removeAnnotation(self.poiAnnotation)
        self.mapView.addAnnotation(annotation!)
        self.mapView.selectAnnotation(annotation!, animated: true)
        
        self.poiAnnotation = annotation;
    }

    
    //MARK:- event handling
    @objc func touchPOIEanbledAction(sender: UISwitch!) {
        self.mapView.touchPOIEnabled = sender.isOn
    }
}
