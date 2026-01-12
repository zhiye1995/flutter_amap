//
//  RoutePlanFutureDriveViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by ldj on 2019/5/10.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import UIKit

class RoutePlanFutureDriveViewController: UIViewController , MAMapViewDelegate, AMapSearchDelegate ,UITableViewDataSource,UITableViewDelegate,MANaviDatePickerDelegate
{
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var startCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var naviRoute: MANaviRoute?
    var route: AMapRoute?
    var timeInfos: Array<AMapFutureTimeInfo>?
    var currentCourse : NSInteger!
    var startTime : NSString!
    var timeListTableView : UITableView!
    var bottomView : UIView!
    var leftView : MANaviTimeInfoView!
    var middleView : MANaviTimeInfoView!
    var rightView : MANaviTimeInfoView!
    var datePickerView : MANaviDatePicker!
    var isFirstLoad : Bool = false
    var isClickedArrivalTime : Bool = false
    var arrivalTime : NSInteger = 0

    var currentSearchType: AMapRoutePlanningType = AMapRoutePlanningType.drive
    
    let cellID = "mapCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "到达时间", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.arrivalTimeAction))
        
        startCoordinate        = CLLocationCoordinate2DMake(39.993291, 116.473188)
        destinationCoordinate  = CLLocationCoordinate2DMake(39.940474, 116.355426)
        
        initMapView()
        initBottomView()
        initSearch()
        addDefaultAnnotations()
        currentCourse = 0
        initTableView()
        searchRoutePlanningDrive(timeDate: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setToolbarHidden(false, animated: true)
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
    
    func initBottomView() {
        //let ret = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))

        bottomView = UIView(frame: CGRect.init(x: 0, y: view.frame.height - 250, width: view.frame.width, height: 250))
        bottomView.backgroundColor = UIColor.white
        bottomView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        view.addSubview(bottomView)
        
        let width = bottomView.frame.width/3
        leftView = MANaviTimeInfoView(frame: CGRect.init(x: 0, y: 0, width: width, height: 70))
        bottomView.addSubview(leftView)
        middleView = MANaviTimeInfoView(frame: CGRect.init(x: width, y: 0, width: width, height: 70))
        bottomView.addSubview(middleView)
        rightView = MANaviTimeInfoView(frame: CGRect.init(x: width*2, y: 0, width: width, height: 70))
        bottomView.addSubview(rightView)
        
        let timeButton =  UIButton.init(type: UIButtonType.roundedRect)
        timeButton.frame = leftView.frame
        timeButton.backgroundColor = UIColor.clear
        timeButton.addTarget(self, action:#selector(self.btnAction), for: UIControlEvents.touchUpInside)
        bottomView.addSubview(timeButton)
    }
    
    @objc func btnAction() {
        MANaviDatePicker.showCustomDatePicker(at: view, delegate: self)
    }
    
    func choosedDate(_ date: Date!) {
        if isClickedArrivalTime {
            presentArrivalRoute(date: date! as NSDate)
            return
        }
        searchRoutePlanningDrive(timeDate : date as NSDate?)
    }
    
    @objc func arrivalTimeAction()
    {
        isClickedArrivalTime = true
        MANaviDatePicker.showCustomDatePicker(at: view, delegate: self)
    }
    
    func presentArrivalRoute(date : NSDate?){
        let info = timeInfos?.first;
        var duration = 30
        if (info?.elements.count)! > 0{
            duration = (info?.elements[0].duration)!
        }
        let a = date?.timeIntervalSince1970;
        self.arrivalTime = Int(a!)
        let deta = Int(a!) - (duration + 10) * 60
        let arrivalTime = NSDate.init(timeIntervalSince1970: TimeInterval(deta))
        searchRoutePlanningDrive(timeDate: arrivalTime)
    }
    
    func updateBottomView()
    {
        let info = timeInfos?[currentCourse]
        if ((info?.elements.count) == nil) {
            return;
        }
        let time = info?.startTime
        leftView.updateTime(getCurrentTime(timestamp: time! as NSString) as String, timeLabelStr: "出发时间")
        leftView.timeLabel.textColor = UIColor.blue
        let hour = info?.elements.first?.duration
        //let startTime = info?.startTime

        var allTime = (info?.startTime as! NSString).doubleValue
        
        allTime = allTime + Double(hour! * 60)
        middleView.updateTime(getCurrentTime(timestamp: NSString(format: "%f", allTime)) as String, timeLabelStr: "预计到达")
        let pathIndex = info?.elements.first?.pathindex
        let distance = self.route?.paths[pathIndex ?? 0].distance
        rightView.updateTime(NSString(format: "%ld公里", distance!/1000) as String, timeLabelStr: "总里程")
    }
    
    func initTableView()
    {
        let width = (bottomView.frame.width - 180) / 2
        timeListTableView = UITableView(frame: CGRect.init(x: width, y: 70 - width, width: 180, height: view.frame.width), style: UITableViewStyle.plain)
        timeListTableView.delegate = self
        timeListTableView.dataSource = self
        timeListTableView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi / 2));
        timeListTableView.showsVerticalScrollIndicator = false
        timeListTableView.separatorStyle =  UITableViewCellSeparatorStyle.none
        timeListTableView.register(TimerInfoCell.self, forCellReuseIdentifier: cellID)
        bottomView.addSubview(timeListTableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeInfos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = TimerInfoCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        }
        if indexPath.row < self.timeInfos?.count ?? 0 {
            let timerInfo = self.timeInfos?[indexPath.row]
            (cell  as! TimerInfoCell).updateTime((timerInfo?.elements.first?.duration)!, startTime: getCurrentTime(timestamp: timerInfo?.startTime as! NSString) as String)
        }
        if indexPath == tableView.indexPathForSelectedRow {
            (cell  as! TimerInfoCell).timeView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 1)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentCourse != indexPath.row {
            currentCourse = indexPath.row
            presentCurrentCourse()
        }
        let  cell = tableView.cellForRow(at: indexPath)
        if cell != nil {
            (cell  as! TimerInfoCell).timeView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 1)
            if isFirstLoad {
                let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0))
                (cell  as! TimerInfoCell).timeView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.4)
                isFirstLoad = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isClickedArrivalTime {
            return nil;
        }
        return indexPath;
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell != nil ){
            (cell  as! TimerInfoCell).timeView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.4)
        }
    }
    
    func getCurrentTime(timestamp : NSString) -> NSString {
        if timestamp.length == 0 {
            return "";
        }
        let date = NSDate(timeIntervalSince1970:timestamp.doubleValue)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.string(from: date as Date)
        return dateString as NSString
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
    
    func searchRoutePlanningDrive(timeDate : NSDate?) {
        let request = AMapFutureRouteSearchRequest()
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        request.destinationId = "BV10001595"
        request.destinationtype = "150500"
        
        let nowTime = timeDate == nil ? Date().timeIntervalSince1970 : timeDate?.timeIntervalSince1970
        var timeStamp = Int(nowTime!)
        if(timeDate == nil){
            timeStamp += 3600;
        }
        let timeStr = String(timeStamp)

        request.beginTime = timeStr
        request.interval = 900
        request.timeCount = 10
        
        
        search.aMapFutureRouteSearch(request)
    }
    
    func presentCurrentCourse() {
        updateBottomView()
        let start = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
        let end = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
        let type = MANaviAnnotationType.futureDrive
        let element = timeInfos?[currentCourse].elements.first
        naviRoute = MANaviRoute.init(forFuturePath: element, withNaviType: type, showTraffic: true, start: start, end: end)
        naviRoute?.add(to: mapView)
        mapView.showOverlays((naviRoute?.routePolylines)!, edgePadding: UIEdgeInsetsMake(20, 20, 200, 20), animated: true)

    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onFutureRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapFutureRouteSearchResponse!) {
        
        if response.paths.count == 0 || response.timeInfos.count == 0 {
            return
        }
        
        let route = AMapRoute.init()
        let allPaths = NSMutableArray.init()
        let paths = NSMutableArray.init(array: response.paths)
        for timeInfo in response.timeInfos {
            if timeInfo.elements.count == 0{
            continue
            }
            let element = timeInfo.elements.first
            let pathIndex = element?.pathindex
            if pathIndex! >= paths.count{
                continue
            }
            let amapPath = paths[pathIndex!]
            allPaths.add(amapPath)
        }
        route.paths = allPaths as? [AMapPath]
        self.route = route
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        addDefaultAnnotations()
        
        timeInfos = response.timeInfos
        if response.timeInfos.count > 0 {
            presentCurrentCourse()
        }
        timeListTableView.reloadData()
        var path = NSIndexPath.init(row: 0, section: 0)
        
        if isClickedArrivalTime {
            path = searchProperRouteForArrivalTime()
        }
        
        self.timeListTableView.selectRow(at: path as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        self.timeListTableView.delegate?.tableView!(timeListTableView, didSelectRowAt: path as IndexPath)
        isFirstLoad = true
    }
    
    func searchProperRouteForArrivalTime() -> NSIndexPath {
        var pathIndex = 0
        var index = 0
        var dela = NSInteger.min
        for info in timeInfos! {
            let allTime = Double(info.startTime)! + Double(info.elements.first!.duration) * 60.0
            if Int(allTime) <= arrivalTime {
                let difference = arrivalTime - Int(allTime)
                if index == 0 || dela >= difference {
                    dela = difference
                    pathIndex = index
                }
            } else {
                break
            }
            index = index + 1
        }
        let path = NSIndexPath.init(row: pathIndex, section: 0)
        return path
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            renderer.strokeColor = UIColor.red
            renderer.lineDashType = kMALineDashTypeSquare
            
            return renderer
        }
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 8.0
            
            if naviPolyline.type == MANaviAnnotationType.walking {
                renderer.strokeColor = naviRoute?.walkingColor
            }
            else if naviPolyline.type == MANaviAnnotationType.railway {
                renderer.strokeColor = naviRoute?.railwayColor;
            }
            else {
                renderer.strokeColor = naviRoute?.routeColor;
            }
            
            return renderer
        }
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline!)
            renderer.lineWidth = 8.0
            renderer.strokeColors = naviRoute?.multiPolylineColors
            
            return renderer
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView!.canShowCallout = true
                annotationView!.isDraggable = false
            }
            
            annotationView!.image = nil
            
            if annotation.isKind(of: MANaviAnnotation.self) {
                let naviAnno = annotation as! MANaviAnnotation
                
                switch naviAnno.type {
                case MANaviAnnotationType.railway:
                    annotationView!.image = UIImage(named: "railway_station")
                    break
                case MANaviAnnotationType.drive:
                    annotationView!.image = UIImage(named: "car")
                    break
                case MANaviAnnotationType.riding:
                    annotationView!.image = UIImage(named: "ride")
                    break
                case MANaviAnnotationType.walking:
                    annotationView!.image = UIImage(named: "man")
                    break
                case MANaviAnnotationType.bus:
                    annotationView!.image = UIImage(named: "bus")
                    break
                case .truck:
                    annotationView!.image = UIImage(named: "truck")
                    break
                case .futureDrive:
                    annotationView!.image = UIImage(named: "car")
                    break
                }
            }
            else {
                if annotation.title == "起点" {
                    annotationView!.image = UIImage(named: "startPoint")
                }
                else if annotation.title == "终点" {
                    annotationView!.image = UIImage(named: "endPoint")
                }
            }
            return annotationView!
        }
        
        return nil
    }
}
