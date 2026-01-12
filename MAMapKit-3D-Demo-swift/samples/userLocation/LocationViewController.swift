//
//  LocationViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, MAMapViewDelegate {

    var locationSegmentControl: UISegmentedControl!
    var modeSegmentControl: UISegmentedControl!
    var mapView: MAMapView!
    
    deinit {
        mapView.removeObserver(self, forKeyPath: "showsUserLocation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initToolBar()
        initObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 开启定位
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
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
    
    func initToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let locationSegmentControl = UISegmentedControl(items: ["Start", "Stop"])
        locationSegmentControl.addTarget(self, action:#selector(self.locationAction(sender:)), for: UIControlEvents.valueChanged)
        locationSegmentControl.selectedSegmentIndex = 1
        let locationSegmentItem = UIBarButtonItem(customView: locationSegmentControl)
        
        let modeSegmentControl = UISegmentedControl(items: ["None", "Follow", "Heading"])
        modeSegmentControl.addTarget(self, action:#selector(self.modeAction(sender:)), for: UIControlEvents.valueChanged)
        modeSegmentControl.selectedSegmentIndex = 0
        let modeSegmentItem = UIBarButtonItem(customView: modeSegmentControl)
        
        self.toolbarItems = [flexibleItem, locationSegmentItem, flexibleItem, modeSegmentItem, flexibleItem]
        
        self.locationSegmentControl = locationSegmentControl
        self.modeSegmentControl = modeSegmentControl
        
    }
    
    func initObserver() {
        mapView.addObserver(self, forKeyPath: "showsUserLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    //MARK: - Actions
    @objc func locationAction(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0 {
            mapView.showsUserLocation = true
        }
        else {
            mapView.showsUserLocation = false
        }
    }
    
    @objc func modeAction(sender: UISegmentedControl)
    {
        mapView.userTrackingMode = MAUserTrackingMode(rawValue: sender.selectedSegmentIndex)!
    }
    
    //MARK: - MAMapViewDelegate
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func mapView(_ mapView: MAMapView!, didChange mode: MAUserTrackingMode, animated: Bool) {
        self.modeSegmentControl.selectedSegmentIndex = mode.rawValue
    }
    
    //MARK: - NSKeyValueObservering
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath != nil) && (keyPath == "showsUserLocation") {
            let locationValue: NSNumber? = change?[NSKeyValueChangeKey.newKey] as! NSNumber?
            if locationValue != nil && locationValue!.boolValue {
                locationSegmentControl.selectedSegmentIndex = 0
            }
            else {
                locationSegmentControl.selectedSegmentIndex = 1
            }
            
        }
    }
}
