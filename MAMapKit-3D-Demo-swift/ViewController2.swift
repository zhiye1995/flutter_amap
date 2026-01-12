//
//  ViewController.swift
//  MAMapKit_3D_Swift
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016 Autonavi. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, ViewControllerDelegate {
    
    var maps: Dictionary<String, UIViewController.Type>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "高德地图API-3D-Swift"
        
        maps = ["UserLocationViewController":LocationViewController.self,
                "CustomUserLocationViewController":CustomUserLocationViewController.self,
                "CustomUserLoactionViewController2":UIViewController.self,
                "IndoorMapViewController":IndoorMapViewController.self,
                "MapTypeViewController":ShowMapViewController.self,
                "OfflineViewController":OfflineViewController.self,
                "TrafficViewController":UIViewController.self,
                "AddControlsViewController":AddControlsViewController.self,
                "ChangeLogoPositionViewController":UIViewController.self,
                "OperateMapViewController":OperateMapViewController.self,
                "MapEventCallbackViewController":MapEventCallbackViewController.self,
                "TouchPoiViewController":TouchPOIViewController.self,
                "ChangeCenterViewController":ChangeCenterViewController.self,
                "ChangeZoomViewController":ChangeZoomViewController.self,
                "CoreAnimationViewController":CoreAnimationViewController.self,
                "ScreenshotViewController":ScreenShotViewController.self,
                "MapBoundaryViewController":MapBoundaryViewController.self,
                "MapZoomByScreenAnchor":MapZoomByScreenAnchor.self,
                "AnnotationViewController":AnnotationViewController.self,
                "CustomAnnotationViewController":CustomAnnotationViewController.self,
                "AnimatedAnnotationViewController":AnimatedAnnotationViewController.self,
                "LockedAnnotationViewController":LockedAnnotationViewController.self,
                "LinesOverlayViewController":ColoredLinesViewController.self,
                "CircleOverlayViewController":CircleOverlayViewController.self,
                "PolygonOverlayViewController":OverlayViewController.self,
                "MATraceCorrectViewController":CorrectTraceViewController.self,
                "MovingAnnotationViewController":MovingAnnotationViewController.self,
                "CustomMapStyleViewController":CustomMapStyleViewController.self,
                "MultiPointOverlayViewController":MultiPointOverlayViewController.self,
                "ColoredLinesOverlayViewController":ColoredLinesViewController.self,
                "GeodesicViewController":GeodesicViewController.self,
                "RunningLineViewController":RunningLineViewController.self,
                "HeatMapVectorOverlayViewController":HeatMapVectorOverlayViewController.self,
                "HeatMapTileOverlayViewController":HeatMapViewController.self,
                "HeatMapVectorGridOverlayViewController":HeatMapVectorGridOverlayViewController.self,
                "MVTTileOverlayViewController":MVTTileOverlayViewController.self,
                "TexturedLineOverlayViewController":TexturedLineViewController.self,
                "CustomOverlayViewController":CustomOverlayViewController.self,
                "OpenGLCubeOverlayViewController":OpenGLCubeOverlayViewController.self,
                "MetalCubeOverlayViewController":MetalCubeOverlayViewController.self,
                "TileOverlayViewController":TileOverlayViewController.self,
                "GroundOverlayViewController":GroundOverlayViewController.self,
                "TraceReplayOverlayViewController":TraceReplayOverlayViewController.self,
                "CustomBuildingOverlayViewController":CustomBuildingOverlayViewController.self,
                "Cross180LongitudeViewController":Cross180LongitudeViewController.self,
                "ParticleOverlayViewController":ParticleOverlayViewController.self,
                "WeatherParticleOverlayViewController":WeatherParticleOverlayViewController.self,
                "PoiSearchPerKeywordController":POIKeywordSearchViewController.self,
                "PoiSearchPerIdController":UIViewController.self,
                "PoiSearchNearByController":UIViewController.self,
                "PoiSearchWithInPolygonController":UIViewController.self,
                "TipViewController":TipViewController.self,
                "GeoViewController":GeocodeViewController.self,
                "InvertGeoViewController":ReGeocodeViewController.self,
                "DistrictViewController":DistrictViewController.self,
                "BusLineViewController":BuslineViewController.self,
                "BusStopViewController":BusstopViewController.self,
                "WeatherViewController":WeatherViewController.self,
                "CloudPOIAroundSearchViewController":CloudLocalSearchViewController.self,
                "CloudPOIIDSearchViewController":CloudLocalSearchViewController.self,
                "CloudPOILocalSearchViewController":CloudLocalSearchViewController.self,
                "CloudPOIPolygonSearchViewController":CloudLocalSearchViewController.self,
                
                "RoutePlanDriveViewController":DriveRoutePlanningViewController.self,
                "RoutePlanWalkViewController":DriveRoutePlanningViewController.self,
                "RoutePlanBusViewController":DriveRoutePlanningViewController.self,
                "RoutePlanRideViewController":DriveRoutePlanningViewController.self,
                "RoutePlanBusCrossCityViewController":DriveRoutePlanningViewController.self,
                "RoutePlanTruckViewController":DriveRoutePlanningViewController.self,
                "RouteDetailTruckViewController":RouteDetailTruckViewController.self,
                "CommutingCardViewController":CommutingCardViewController.self,
                "DistanceSearchViewController":DistanceSearchViewController.self,
                "RoutePlanFutureDriveViewController":RoutePlanFutureDriveViewController.self,
                "CooridinateSystemConvertController":CoordinateSystemConvertViewController.self,
                "DistanceCalculateViewController":DistanceCalculateViewController.self,
                "DistanceCalculateViewController2":DistanceCalculateViewController2.self,
                "InsideTestViewController":InsideTestViewController.self,
                
                "LocationShareViewController":UIViewController.self,
                "RouteShareViewController":UIViewController.self,
                "POIShareViewController":UIViewController.self,
                "NaviShareViewController":NaviShareViewController.self,
                
                "NearbyVewController":UIViewController.self,
        ];
        
        let vc = ViewController.init();
        vc.delegate = self;
        vc.view.bounds = self.view.bounds;
        vc.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth];
        self.view.addSubview(vc.view);
        self.addChildViewController(vc)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewController(_ vc: ViewController!, itemSelected itemClassName: String!, title: String!) -> Bool {
        let vcClass = self.maps[itemClassName];
        if(vcClass != nil) {
            if(vcClass == UIViewController.self) {
                return true;
            }
            
            let vcInstance = vcClass!.init()
            vcInstance.title = title
            
            self.navigationController?.pushViewController(vcInstance, animated: true)
        }
        
        return true;
    }
    
    func viewController(_ vc: ViewController!, displayTileOf itemClassName: String!) -> String! {
        let vcClass = self.maps[itemClassName];
        if(vcClass != nil) {
            if(vcClass == UIViewController.self) {
                return nil;
            }
            
            return NSStringFromClass(vcClass!);
        }
        
        return nil;
    }
}

