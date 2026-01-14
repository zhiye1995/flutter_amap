//
//  ShowMapViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class ShowMapViewController: UIViewController, MAMapViewDelegate {

    var mapView: MAMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        initToolBar()
        
        initActionControl()
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
    
    func initToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let segmentControl = UISegmentedControl(items: ["标准", "卫星","黑夜","导航","公交"])
        segmentControl.selectedSegmentIndex = mapView.mapType.rawValue
        segmentControl.addTarget(self, action:#selector(self.mapTypeAction(sender:)), for: UIControlEvents.valueChanged)
        let segmentItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems = [flexibleItem, segmentItem, flexibleItem]
    }
    
    func initActionControl() {
        let trafficSwitch: UISwitch = UISwitch()
        trafficSwitch.addTarget(self, action:#selector(self.trafficAction(sender:)), for: UIControlEvents.valueChanged)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trafficSwitch)
    }
    
    //MARK: - Actions
    @objc func mapTypeAction(sender: UISegmentedControl)
    {
        mapView.mapType = MAMapType(rawValue: sender.selectedSegmentIndex)!
    }

    @objc func trafficAction(sender: UISwitch)
    {
        mapView.isShowTraffic = sender.isOn
    }
}
