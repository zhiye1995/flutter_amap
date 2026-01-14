//
//  TipViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by xiaoming han on 16/10/8.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class TipViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var searchController: UISearchController!
    var tableView: UITableView!
    
    var tableData: Array<AMapTip>!
    var search: AMapSearchAPI!
    var mapView: MAMapView!
    var currentRequest: AMapInputTipsSearchRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        tableData = Array()
        
        initMapView()
        initSearch()
        
        initTableView()
        initSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        searchController.isActive = false
        searchController.searchBar.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initTableView() {
        
        let tableY = self.navigationController!.navigationBar.frame.maxY
        tableView = UITableView(frame: CGRect(x: 0, y: tableY, width: self.view.bounds.width, height: self.view.bounds.height - tableY), style: UITableViewStyle.plain)
        tableView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        self.view.addSubview(tableView)
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
    
    func initSearchController() {
        searchController = UISearchController(searchResultsController: nil)

        searchController.searchResultsUpdater = self;
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "请输入关键字"
        searchController.searchBar.sizeToFit()

        // fix the warning for [Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior]
        if #available(iOS 9.0, *) {
            self.searchController.loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
            let _ = self.searchController.view
        }
        
        
        self.navigationItem.titleView = searchController.searchBar
    }

    //MARK: - Action
    
    func searchTip(withKeyword keyword: String?) {
        
        print("keyword \(String(describing: keyword))")
        if keyword == nil || keyword! == "" {
            return
        }
        
        let request = AMapInputTipsSearchRequest()
        request.keywords = keyword
        
        currentRequest = request
        search.aMapInputTipsSearch(request)
    }
    
    //MARK:- UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        print("begin")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        print("search")
    }
    
    //MARK:- UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update active \(searchController.isActive)")
        tableView.isHidden = !searchController.isActive
        searchTip(withKeyword: searchController.searchBar.text)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            searchController.searchBar.placeholder = searchController.searchBar.text
        }
    }

    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        print("name: \(String(describing: view.annotation.title))")
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView)
            
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
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
     
        if currentRequest == nil || currentRequest! != request {
            return
        }
        
        if response.count == 0 {
            return
        }
        
        tableData.removeAll()
        for aTip in response.tips {
            tableData.append(aTip)
        }
        tableView.reloadData()
    }
    
    //MARK:- TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let tip = tableData[indexPath.row]
        
        if tip.location != nil {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(tip.location.latitude), longitude: CLLocationDegrees(tip.location.longitude))
            let anno = MAPointAnnotation()
            anno.coordinate = coordinate
            anno.title = tip.name
            anno.subtitle = tip.address
            
            mapView.addAnnotation(anno)
            mapView.selectAnnotation(anno, animated: true)
        }
        
        searchController.isActive = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    //MARK:- TableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "demoCellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if !tableData.isEmpty {
            
            let tip = tableData[indexPath.row]
            
            cell!.textLabel?.text = tip.name
            cell!.detailTextLabel?.text = tip.address
        }
        
        return cell!
    }
    
}
