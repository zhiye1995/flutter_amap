//
//  CorrectTraceViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by shaobin on 16/9/27.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CorrectTraceViewController: UIViewController, MAMapViewDelegate {
    var mapView1: MAMapView!
    var mapView2: MAMapView!
    var origTrace: Array<MAPolyline>!
    var processedTrace: Array<MAPolyline>!
    var targetInputFile: NSString!
    var queryOperation: Operation!

    override func viewDidLoad() {
        self.origTrace = Array.init()
        self.processedTrace = Array.init()
        
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
        var rect = self.view.bounds;
        rect.origin.y = 64;
        rect.size.height = (rect.height - 64 - 10) / 2;
        mapView1 = MAMapView(frame: rect)
        mapView1.delegate = self
        self.view.addSubview(mapView1)
        
        rect.origin.y = rect.maxY + 10
        mapView2 = MAMapView(frame: rect)
        mapView2.delegate = self
        self.view.addSubview(mapView2)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.returnAction))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.queryAction()
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
    
    func addTrace(points:Array<MATracePoint>!, mapview:MAMapView!) {
        let polyline = self.makePolyline(points: points)
        
        if(polyline == nil) {
            return
        }
        
        if(mapview == self.mapView1) {
            mapview .removeOverlays(self.origTrace)
            self.origTrace.removeAll()
            self.origTrace.append(polyline!)
            mapview .addOverlays(self.origTrace)
        } else {
            mapview.removeOverlays(self.processedTrace)
            self.processedTrace.removeAll()
            
            self.processedTrace.append(polyline!)
            mapview.addOverlays(self.processedTrace)
        }
        
        mapview.setVisibleMapRect((polyline?.boundingMapRect)!, animated:false)
    }
    
    func addSubTrace(points:Array<MATracePoint>!, mapview:MAMapView!) {
        let polyline = self.makePolyline(points: points)
        
        if(polyline == nil) {
            return
        }
        
        let visibleRect = mapview.visibleMapRect
        if (!MAMapRectContainsRect(visibleRect, polyline!.boundingMapRect)) {
            let newRect = MAMapRectUnion(visibleRect, polyline!.boundingMapRect)
            mapview.setVisibleMapRect(newRect, animated: false)
        }
        
        if(mapview == self.mapView1) {
            mapview .removeOverlays(self.origTrace)
            self.origTrace.append(polyline!)
        } else {
            self.processedTrace.append(polyline!)
        }
        mapview.addOverlays([polyline as Any])
    }
    
    func clear() {
        self.mapView1 .removeOverlays(self.origTrace)
        self.mapView2 .removeOverlays(self.processedTrace)
        self.origTrace.removeAll()
        self.processedTrace.removeAll()
    }
    
    func makePolyline(points:Array<MATracePoint>!) -> MAPolyline! {
        if(points.count == 0) {
            return nil
        }
        
        let buffer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: points.count)
        var i = 0;
        for element in points {
            buffer[i].latitude = element.latitude;
            buffer[i].longitude = element.longitude;
            i += 1
        }
        
        let ret = MAPolyline.init(coordinates: buffer, count: UInt(i))
        
        buffer.deallocate(capacity: points.count)
        
        return ret
    }
    
    func allTestFiles() -> Array<String> {
        var path = Bundle.main.bundlePath
        path.append("/traceRecordData/")
        
        let arr = try? FileManager.default.contentsOfDirectory(atPath: path)
        
        return arr!
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            
            if(mapView == mapView1) {
                renderer.lineWidth = 8.0
                renderer.strokeColor = UIColor.blue
            } else {
                renderer.lineWidth = 16.0
                renderer.strokeImage = UIImage(named: "custtexture")
            }
            
            
            return renderer
        }
        
        return nil
    }
    
    //MARK: - event handling
    @objc func returnAction() {
        if(queryOperation != nil) {
            queryOperation.cancel();
            queryOperation = nil;
        }
        
        self.navigationController!.popViewController(animated: true)
    }
    
    func queryAction() {
        var bundlePath = Bundle.main.bundlePath
//        let str = "/traceRecordData/AMapTrace01.txt"
        let str = "/traceRecordData/AMapTrace04.txt"

        bundlePath.append(str)
        
        targetInputFile = bundlePath as NSString!
        
        if(targetInputFile.length <= 0) {
            return
        }
        
        var data = Data.init()
        data .append("[".data(using: String.Encoding.utf8)!)
        
        data.append(try! Data.init(contentsOf: URL.init(fileURLWithPath: targetInputFile as String), options: Data.ReadingOptions.uncachedRead))
        data .append("]".data(using: String.Encoding.utf8)!)
        
        let jsonObj = try? JSONSerialization .jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
        var type = AMapCoordinateType.aMap;

        if (str.hasPrefix("Baidu")) {
            type = AMapCoordinateType.baidu
        }else if(str.hasPrefix("GPS")){
            type = AMapCoordinateType.GPS
        }
        let traceManager = MATraceManager.init()
        
        var arr:Array<MATraceLocation> = Array.init()
        var arr2:Array<MATracePoint> = Array.init()
        
        for element in jsonObj! {
            let lat = element["lat"]
            let lon = element["lon"]
            let t = element["loctime"]
            let bearing = element["bearing"]
            let speed = element["speed"]
            
            let temp = MATraceLocation.init()
            temp.loc = CLLocationCoordinate2D.init(latitude: lat as! CLLocationDegrees, longitude: lon as! CLLocationDegrees)
            temp.time = t as! Double;
            temp.angle = bearing as! Double;
            temp.speed = speed as! Double * 3.6;
            arr.append(temp)
            
            let temp2 = MATracePoint.init()
            
            if(type.rawValue <= AMapCoordinateType.GPS.rawValue) {
                //坐标转换
                let l = AMapCoordinateConvert(temp.loc, type)
                temp2.latitude = l.latitude//lat as! CLLocationDegrees
                temp2.longitude = l.longitude//lon as! CLLocationDegrees
            } else {
                temp2.latitude = temp.loc.latitude;
                temp2.longitude = temp.loc.longitude;
            }
            if (fabs(temp2.longitude - 0) < 0.0001 && fabs(temp2.latitude - 0) < 0.0001) {
                continue;
            }
            arr2.append(temp2)
        }
        
        self.clear()

        self.addTrace(points: arr2, mapview: self.mapView1)
        
        queryOperation = traceManager.queryProcessedTrace(with: arr, type: AMapCoordinateType(rawValue: Int.max)!, processingCallback: { (index:Int32, arr:[MATracePoint]?) in
                self.addSubTrace(points: arr, mapview: self.mapView2)
            }, finishCallback: { (arr:[MATracePoint]?, distance:Double) in
                NSLog("distance=%f", distance)
                
                self.addTrace(points: arr, mapview: self.mapView2)
                
                self.queryOperation = nil;
            }, failedCallback: { (errCode:Int32, errDesc:String?) in
                print(errDesc!)
                self.queryOperation = nil
        })
    }
    
    
}
