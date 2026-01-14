//
//  WeatherViewController.swift
//  MAMapKit_2D_Demo
//
//  Created by shaobin on 16/10/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, AMapSearchDelegate {
    
    var search: AMapSearchAPI!
    var liveWeatherView: MAWeatherLiveView!
    var forecastWeatherView: MAWeatherForecastView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        initSearch()
        
        self.view.backgroundColor = UIColor.init(red: 84/255.0, green: 142/255.0, blue: 212/255.0, alpha: 1)
        
        liveWeatherView = MAWeatherLiveView.init()
        liveWeatherView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height - 5) * 0.7)
        self.view.addSubview(liveWeatherView)
        
        liveWeatherView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleBottomMargin]
        
        forecastWeatherView = MAWeatherForecastView.init()
        forecastWeatherView.frame =  CGRect.init(x: 0, y: liveWeatherView.frame.maxY + 5, width: self.view.bounds.width, height: (self.view.bounds.height - 5) * 0.3)
        self.view.addSubview(forecastWeatherView)
        forecastWeatherView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleTopMargin]
        
        self.searchLiveWeather()
        self.searchForcastWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    //MARK: - Action
    func searchForcastWeather() {
        let req:AMapWeatherSearchRequest! = AMapWeatherSearchRequest.init()
        
        req.city = "北京"
        req.type = AMapWeatherType.forecast
        
        self.search.aMapWeatherSearch(req)
    }
    
    func searchLiveWeather() {
        let req:AMapWeatherSearchRequest! = AMapWeatherSearchRequest.init()
        
        req.city = "北京"
        req.type = AMapWeatherType.live
        
        self.search.aMapWeatherSearch(req)
    }
    
    
    //MARK: - AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        let nsErr:NSError? = error as NSError
        NSLog("Error:\(error) - \(ErrorInfoUtility.errorDescription(withCode: (nsErr?.code)!))")
    }
    
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        if (request.type == AMapWeatherType.live)
        {
            if (response.lives.count == 0)
            {
                return;
            }
            
            let liveWeather:AMapLocalWeatherLive! = response.lives.first
            if (liveWeather != nil)
            {
                self.liveWeatherView.updateWeather(withInfo: liveWeather)
            }
        }
        else
        {
            if (response.forecasts.count == 0)
            {
                return;
            }
            
            let forecast:AMapLocalWeatherForecast! = response.forecasts.first
            
            if (forecast != nil)
            {
                self.forecastWeatherView.updateWeather(withInfo: forecast)
            }
        }

    }
}
