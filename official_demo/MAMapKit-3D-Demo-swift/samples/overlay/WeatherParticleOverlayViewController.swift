//
//  WeatherParticleOverlayViewController.swift
//  MAMapKit-3D-Demo-swift
//
//  Created by zuola on 2019/4/23.
//  Copyright © 2019 Autonavi. All rights reserved.
//

import Foundation
class WeatherParticleOverlayViewController: UIViewController,  MAMapViewDelegate {
    
    var mapView: MAMapView!
    var currentShowIndex: Int = -1
    var _showDetailWeather: Bool = true
    var _provinceAnnotations: Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        currentShowIndex = -1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addPorvinceAnnotation()
        mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// pragma mark - Methods
    func addPorvinceAnnotation() {
        if _provinceAnnotations.count <= 0 {
            _provinceAnnotations = Array.init()
        }
        let count = 11
        var coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 39.920263, longitude: 116.399792),
            CLLocationCoordinate2D(latitude: 38.064304, longitude: 117.119396),
            CLLocationCoordinate2D(latitude: 34.276219, longitude: 108.942478),
            CLLocationCoordinate2D(latitude: 36.630675, longitude: 101.756733),
            CLLocationCoordinate2D(latitude: 30.663010, longitude: 104.073475),
            CLLocationCoordinate2D(latitude: 26.603562, longitude: 106.687534),
            CLLocationCoordinate2D(latitude: 31.224832, longitude: 121.416081),
            CLLocationCoordinate2D(latitude: 30.272996, longitude: 120.025967),
            CLLocationCoordinate2D(latitude: 23.146981, longitude: 113.226803),
            CLLocationCoordinate2D(latitude: 28.209643, longitude: 113.022354),
            CLLocationCoordinate2D(latitude: 33.005993, longitude: 112.610367)]
        for i in 0..<count {
            let anotaiton = MAPointAnnotation.init()
            anotaiton.coordinate = coordinates[i]
            _provinceAnnotations.append(anotaiton)
        }
        mapView.addAnnotations(_provinceAnnotations)
    }
    
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        mapView.mapType = MAMapType.standardNight
        self.view.addSubview(mapView)
    }

    func weatherTypeForIndex(index: NSInteger) -> MAParticleOverlayType {
        return MAParticleOverlayType(rawValue: index%4+1)!
    }
    
    func annotationImageForType(type: MAParticleOverlayType) -> UIImage {
        switch type {
        case MAParticleOverlayType.sunny:
            return UIImage.init(named: "weather_qing") ?? UIImage.init()
            break
        case MAParticleOverlayType.rain:
            return UIImage.init(named: "weather_baoyu") ?? UIImage.init()
            break
        case MAParticleOverlayType.snowy:
            return UIImage.init(named: "weather_daxue") ?? UIImage.init()
            break
        case MAParticleOverlayType.haze:
            return UIImage.init(named: "weather_wumai") ?? UIImage.init()
            break
        default:
            break;
        }
        return UIImage.init()
    }
    
    func addWeatherOverlayWithType(type: MAParticleOverlayType) {
        mapView.removeOverlays(mapView.overlays)
        let results = MAParticleOverlayOptionsFactory.particleOverlayOptions(with: type)
        for option in results! {
            let overlay = MAParticleOverlay.init(option: option)
            mapView.add(overlay!)
        }
    }
    
    func updateMapWeather(showDetailWeather: Bool) {
        _showDetailWeather = showDetailWeather
        if _showDetailWeather {
            if (mapView.annotations.count > 0) {
                mapView.removeAnnotations(mapView.annotations)
            }
            var indexToShow = currentShowIndex
            for i in 0..<_provinceAnnotations.count {
                let ano = _provinceAnnotations[i] as! MAPointAnnotation
                let mapPoint = MAMapPointForCoordinate(ano.coordinate)
                if (MAMapRectContainsPoint(mapView.visibleMapRect, mapPoint)){
                    indexToShow = i
                    break
                }
            }
            if currentShowIndex != indexToShow {
                currentShowIndex = indexToShow
                mapView.removeOverlays(mapView.overlays)
                addWeatherOverlayWithType(type: weatherTypeForIndex(index: currentShowIndex))
            }else{
                if (currentShowIndex >= 0){
                    let ano = _provinceAnnotations[currentShowIndex] as! MAPointAnnotation
                    let mapPoint = MAMapPointForCoordinate(ano.coordinate)
                    if (MAMapRectContainsPoint(mapView.visibleMapRect, mapPoint)){
                        currentShowIndex = -1
                        mapView.removeOverlays(mapView.overlays)
                    }
                }
            }
        }else{
            if (mapView.overlays.count > 0){
                mapView.removeOverlays(mapView.overlays)
                currentShowIndex = -1
            }
            if (mapView.annotations.count <= 0){
                addPorvinceAnnotation()
            }
        }
    }
    
    
    //MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        updateMapWeather(showDetailWeather: (mapView.zoomLevel > 8.0))
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        let annotation = view.annotation
        mapView.setCenter(annotation!.coordinate, animated: false)
        mapView.setZoomLevel(10.0, animated: false)
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isKind(of: MAPointAnnotation.self)) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if(annotationView == nil){
                annotationView = MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.canShowCallout = false
            annotationView.animatesDrop = false
            annotationView!.isDraggable = false
            var index = 0
            for i in 0..<_provinceAnnotations.count {
                let ele = _provinceAnnotations[i] as! MAAnnotation
                if (annotation.isEqual(ele)){
                    index = i
                    break;
                }
            }
            annotationView!.image = annotationImageForType(type: weatherTypeForIndex(index: index))
            return annotationView
        }
        return nil
    }
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAParticleOverlay.self))
        {
            let particleOverlayRenderer = MAParticleOverlayRenderer.init(particleOverlay: (overlay as! MAParticleOverlay))
            return particleOverlayRenderer;
        }
        return nil;
    }
}


