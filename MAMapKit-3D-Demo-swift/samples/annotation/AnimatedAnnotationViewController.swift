//
//  AnimatedAnnotationViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by 翁乐 on 09/10/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

let kCalloutViewMargin: CGFloat = -8

import UIKit


class AnimatedAnnotationViewController: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView!
    var animatedCarAnnotation: AnimatedAnnotation!
    var animatedTrainAnnotation: AnimatedAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.retrunAction))
        
        mapView = MAMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        addCarAnnotationWithCoordinate(CLLocationCoordinate2D(latitude: 39.948691, longitude: 116.492479))
        addTrainAnnotationWithCoordinate(CLLocationCoordinate2D(latitude: 39.843349, longitude: 116.315633))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.selectAnnotation(animatedTrainAnnotation, animated: true)
    }
    
    @objc func retrunAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is AnimatedAnnotation {
            let animatedAnnotationIdentifier: String! = "AnimatedAnnotationIdentifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: animatedAnnotationIdentifier) as? AnimatedAnnotationView
            
            if annotationView == nil {
                annotationView = AnimatedAnnotationView(annotation: annotation, reuseIdentifier: animatedAnnotationIdentifier)
                
                annotationView?.canShowCallout = true
                annotationView?.isDraggable = true
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func addCarAnnotationWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        var carImages = Array<UIImage>()
        carImages.append(UIImage(named: "animatedCar_1.png")!)
        carImages.append(UIImage(named: "animatedCar_2.png")!)
        carImages.append(UIImage(named: "animatedCar_3.png")!)
        carImages.append(UIImage(named: "animatedCar_4.png")!)
        carImages.append(UIImage(named: "animatedCar_3.png")!)
        carImages.append(UIImage(named: "animatedCar_4.png")!)
        
        animatedCarAnnotation = AnimatedAnnotation(coordinate: coordinate)
        animatedCarAnnotation.animatedImages = carImages
        animatedCarAnnotation.title = "AutoNavi"
        animatedCarAnnotation.subtitle = String(format: "Car: %lu images", animatedCarAnnotation.animatedImages.count)
        
        mapView.addAnnotation(animatedCarAnnotation)
    }
    
    func addTrainAnnotationWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        var trainImages = Array<UIImage>()
        trainImages.append(UIImage(named: "animatedTrain_1.png")!)
        trainImages.append(UIImage(named: "animatedTrain_2.png")!)
        trainImages.append(UIImage(named: "animatedTrain_3.png")!)
        trainImages.append(UIImage(named: "animatedTrain_4.png")!)
        
        animatedTrainAnnotation = AnimatedAnnotation(coordinate: coordinate)
        animatedTrainAnnotation.animatedImages = trainImages
        animatedTrainAnnotation.title = "AutoNavi"
        animatedTrainAnnotation.subtitle = String(format: "Train: %lu images", animatedTrainAnnotation.animatedImages.count)
        
        mapView.addAnnotation(animatedTrainAnnotation)
    }
}
