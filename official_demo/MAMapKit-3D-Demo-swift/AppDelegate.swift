//
//  AppDelegate.swift
//  MAMapKit_2D_Swift
//
//  Created by xiaoming han on 16/9/23.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func addAlertController(){
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let message : NSMutableAttributedString = NSMutableAttributedString.init(string: "\n亲，感谢您对XXX一直以来的信任！我们依据最新的监管要求更新了XXX《隐私权政策》，特向您说明如下\n1.为向您提供交易相关基本功能，我们会收集、使用必要的信息；\n2.基于您的明示授权，我们可能会获取您的位置（为您提供附近的商品、店铺及优惠资讯等）等信息，您有权拒绝或取消授权；\n3.我们会采取业界先进的安全措施保护您的信息安全；\n4.未经您同意，我们不会从第三方处获取、共享或向提供您的信息；", attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle])
        
        
        message.setAttributes([NSAttributedStringKey.foregroundColor:UIColor.blue], range: message.mutableString.range(of: "《隐私权政策》"))
        
        let alert : UIAlertController = UIAlertController.init(title: "温馨提示(隐私合规示例)", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.setValue(message, forKey: "attributedMessage")
        
        let conform : UIAlertAction = UIAlertAction.init(title: "同意", style: UIAlertActionStyle.default) { UIAlertAction in
            UserDefaults.standard.set(true, forKey: "agreeStatus")
            UserDefaults.standard.synchronize()
            //更新用户授权高德SDK隐私协议状态. since 8.1.0
            MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        }
        
        let cancel : UIAlertAction = UIAlertAction.init(title: "不同意", style: UIAlertActionStyle.default) { UIAlertAction in
            UserDefaults.standard.set(false, forKey: "agreeStatus")
            UserDefaults.standard.synchronize()
            //更新用户授权高德SDK隐私协议状态. since 8.1.0
            MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.notAgree)
        }
        
        alert.addAction(conform)
        alert.addAction(cancel)
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AMapServices.shared().apiKey = APIKey
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = UINavigationController.init(rootViewController: ViewController2())
        self.window?.makeKeyAndVisible()
        //判断是否是首次启动
        if !UserDefaults.standard.bool(forKey: "agreeStatus") {
            //添加隐私合规弹窗
            self.addAlertController()
            //更新App是否显示隐私弹窗的状态，隐私弹窗是否包含高德SDK隐私协议内容的状态. since 8.1.0
            MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

