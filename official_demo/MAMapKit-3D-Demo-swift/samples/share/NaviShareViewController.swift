//
//  NaviShareViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class NaviShareViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var searchButton: UIButton!
    var sharedURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888)
        destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956)
        
        initMapView()
        initSearch()
        addDefaultAnnotations()
        
        initToolBar()
        initActionControl()
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
        button.setTitle("点击生成短串", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.blue, for: .highlighted)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.searchNaviShare), for: .touchUpInside)
        let item = UIBarButtonItem(customView: button)
        self.toolbarItems = [flexibleItem, item, flexibleItem]

        searchButton = button
    }
    
    func initActionControl() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(self.openURLAtSafari))
    }
    
    func addDefaultAnnotations() {
        
        let anno = MAPointAnnotation()
        anno.coordinate = startCoordinate
        anno.title = "起点"
        
        mapView.addAnnotation(anno)
        
        let annod = MAPointAnnotation()
        annod.coordinate = destinationCoordinate
        annod.title = "终点"
        
        mapView.addAnnotation(annod)
    }
    
    //MARK: - Action
    
    @objc func searchNaviShare() {
        let request = AMapNavigationShareSearchRequest()
        
        request.startCoordinate = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destinationCoordinate = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        
        search.aMapNavigationShareSearch(request)

    }
    
    @objc func openURLAtSafari() {
        if sharedURL != nil {
            UIApplication.shared.openURL(URL(string: sharedURL!)!)
        }
        else {
            print("sharedURL is nil")
        }
    }

    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            if annotation.title == "起点" {
                annotationView!.image = UIImage(named: "startPoint")
            }
            else if annotation.title == "终点" {
                annotationView!.image = UIImage(named: "endPoint")
            }
            
            return annotationView!
        }
        
        return nil
    }
    
    //MARK: - AMapSearchDelegate
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onShareSearchDone(_ request: AMapShareSearchBaseRequest!, response: AMapShareSearchResponse!) {
        
        print("shareURL:", response.shareURL)
        
        sharedURL = response.shareURL
        searchButton.setTitle("URL:"+sharedURL!, for: .normal)
        searchButton.sizeToFit()
    }
}
