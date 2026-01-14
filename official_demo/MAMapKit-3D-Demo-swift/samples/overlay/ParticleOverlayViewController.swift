//
//  ParticleOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/23.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class ParticleOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        initToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbar.isTranslucent   = true;
        self.navigationController?.toolbar.barStyle = UIBarStyle.black
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addWeatherOverlay(type: MAParticleOverlayType.sunny)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
    }
    
    func initToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let segmentControl = UISegmentedControl(items: ["晴天", "雨天", "雪天", "雾霾天"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action:#selector(self.weatherTypeAction(sender:)), for: UIControlEvents.valueChanged)
        let segmentItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems = [flexibleItem, segmentItem, flexibleItem]
    }
    
    //MARK: - Actions
    @objc func weatherTypeAction(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0:
            addWeatherOverlay(type: MAParticleOverlayType.sunny)
            
            break
        case 1:
            addWeatherOverlay(type: MAParticleOverlayType.rain)
            
            break
        case 2:
            addWeatherOverlay(type: MAParticleOverlayType.snowy)
            
            break
        case 3:
            addWeatherOverlay(type: MAParticleOverlayType.haze)
            
            break
        default:
            break;
        }
    }
    
    func addWeatherOverlay(type: MAParticleOverlayType) {
        mapView.removeOverlays(mapView.overlays)
        let results = MAParticleOverlayOptionsFactory.particleOverlayOptions(with: type)
        for option in results! {
            let overlay = MAParticleOverlay.init(option: option)
            mapView.add(overlay!)
        }
    }
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAParticleOverlay.self))
        {
            let particleOverlayRenderer = MAParticleOverlayRenderer.init(particleOverlay: (overlay as! MAParticleOverlay))
            return particleOverlayRenderer;
        }
        return nil;
    }
}



