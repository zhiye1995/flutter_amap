//
//  GeocodeViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/10/9.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class GeocodeViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initSearch()
        initToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    func initToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let button = UIButton(type: UIButtonType.custom)
        button.setTitle("北京市朝阳区阜荣街10号(点击进行搜索)", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.blue, for: .highlighted)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.searchGeocode(sender:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: button)
        self.toolbarItems = [flexibleItem, item, flexibleItem]
    }
    
    //MARK: - Action
    
    @objc func searchGeocode(sender: UIButton) {
        
        let address = sender.title(for: .normal)
        
        let request = AMapGeocodeSearchRequest()
        request.address = address
        
        search.aMapGeocodeSearch(request)
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        print("address: \(String(describing: view.annotation.title))\(String(describing: view.annotation.subtitle))")
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = true
            annotationView!.isDraggable = false
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            
            return annotationView!
        }
        
        return nil
    }
    
    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        
        if response.geocodes == nil {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let geocode = response.geocodes.first {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(geocode.location.latitude), longitude: CLLocationDegrees(geocode.location.longitude))
            let anno = MAPointAnnotation()
            anno.coordinate = coordinate
            anno.title = geocode.formattedAddress
            anno.subtitle = geocode.location.description
            
            mapView.addAnnotation(anno)
            mapView.selectAnnotation(anno, animated: false)
        }
        
        
        
       
    }

}
