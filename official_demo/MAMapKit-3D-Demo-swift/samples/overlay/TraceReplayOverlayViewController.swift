//
//  TraceReplayOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/22.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class TraceReplayOverlayViewController: UIViewController, MAMapViewDelegate, MAMultiPointOverlayRendererDelegate {
    
    var mapView: MAMapView!
    var overlay: MATraceReplayOverlay!
    var overlayRenderer: MATraceReplayOverlayRenderer!
    deinit {
        overlay.removeObserver(self, forKeyPath: "isPaused")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initMapView()
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            var bundlePath = Bundle.main.bundlePath
            let str = "/traceRecordData/TraceReplay.txt"
            bundlePath.append(str)
            let fileFullPath = bundlePath as NSString
            if(fileFullPath.length <= 0) {
                return
            }
            var data = Data.init()
            data.append(try! Data.init(contentsOf: URL.init(fileURLWithPath: fileFullPath as String), options: Data.ReadingOptions.uncachedRead))
            let jsonObj = try? JSONSerialization .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]

            let count = (jsonObj?.count)!
            let p = UnsafeMutablePointer<MAMapPoint>.allocate(capacity: count)
            
            var index = 0
            for element in jsonObj! {
                let lat = element["lat"]
                let lon = element["lon"]
                let point = MAMapPointForCoordinate(CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lon as! CLLocationDegrees))
                
                p[index].x = point.x
                p[index].y = point.y
                index += 1
            }
            
            
            self.overlay = MATraceReplayOverlay.init()
            self.overlay.enableAutoCarDirection = true
            self.overlay.speed = 1000000
            self.overlay.setWithPoints(p, count: index)
            p.deallocate()
            
            let mainQueue = DispatchQueue.main
            mainQueue.async {
                self.mapView.addOverlays([self.overlay])
                self.mapView.showOverlays([self.overlay], animated: false)
                
                self.overlay.addObserver(self, forKeyPath: "isPaused", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
                self.initToolBar()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let segmentControl = UISegmentedControl(items: ["paused", "go","reset"])
        segmentControl.selectedSegmentIndex = mapView.mapType.rawValue
        segmentControl.addTarget(self, action:#selector(self.mapTypeAction(sender:)), for: UIControlEvents.valueChanged)
        let segmentItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems = [flexibleItem, segmentItem, flexibleItem]
    }
    
    //MARK: - Actions
    @objc func mapTypeAction(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0:
            self.overlay.isPaused = true
            self.overlayRenderer.reset()
            break
        case 1:
            self.overlay.isPaused = false
            self.overlayRenderer.reset()
            break
        case 2:
            self.overlay.reset()
            self.overlayRenderer.reset()
            break
        default:
            break;
        }
    }
    
    
    //MARK: - NSKeyValueObservering
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath != nil) && (keyPath == "isPaused") {
            let locationValue: Bool? = change?[NSKeyValueChangeKey.newKey] as! Bool?
            self.mapView.isAllowDecreaseFrame = locationValue!;
        }
    }
    
    //#pragma mark - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, didAddOverlayRenderers overlayRenderers: [Any]!) {
        
    }
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: MATraceReplayOverlay.self))
        {
            let ret = MATraceReplayOverlayRenderer.init(overlay: overlay as? MATraceReplayOverlay)
            ret?.lineWidth = 4.0
            ret!.strokeColors = [UIColor.gray.withAlphaComponent(0.6), UIColor.red]
            self.overlayRenderer = ret
            return ret;
        }
        
        return nil;
    }
  
}
