//
//  CoordinateSystemConvertViewController.swift
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/10/10.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

import UIKit

class CoordinateSystemConvertViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var tf_lat: UITextField!
    var tf_lng: UITextField!
    var chooseBtn: UIButton!
    var convertBtn: UIButton!
    var resultLabel: UILabel!
    var picker: UIPickerView!
    var otherCooridnateSystems: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        otherCooridnateSystems = NSArray.init(array: ["Baidu", "MapBar", "MapABC", "SoSoMap", "AliYun", "Google", "GPS"])
        
        tf_lat = UITextField.init(frame: CGRect.init(x: 15, y: 84, width: 200, height: 40))
        tf_lat.borderStyle = UITextBorderStyle.line
        tf_lat.clearButtonMode = UITextFieldViewMode.whileEditing
        tf_lat.text = "39.911004"
        tf_lat.placeholder = "维度"
        
        tf_lng = UITextField.init(frame: CGRect.init(x: 15, y: 134, width: 200, height: 40))
        tf_lng.borderStyle = UITextBorderStyle.line
        tf_lng.clearButtonMode = UITextFieldViewMode.whileEditing
        tf_lng.text = "116.405880"
        tf_lng.placeholder = "经度"
        
        self.view.addSubview(tf_lat)
        self.view.addSubview(tf_lng)
        
        
        chooseBtn = UIButton.init(frame: CGRect.init(x: 15, y: tf_lng.frame.origin.y + tf_lng.frame.size.height + 10, width: 160, height: 30))
        chooseBtn.layer.borderWidth = 1.0
        chooseBtn.layer.borderColor = UIColor.gray.cgColor
        chooseBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        chooseBtn.setTitle("选择坐标系", for: UIControlState.normal)
        chooseBtn.addTarget(self, action: #selector(self.chooseAction), for: UIControlEvents.touchUpInside)
        

        convertBtn = UIButton.init(frame: CGRect.init(x: 15, y: chooseBtn.frame.origin.y + chooseBtn.frame.size.height + 10, width: 160, height: 30))
        convertBtn.layer.borderWidth = 1.0
        convertBtn.layer.borderColor = UIColor.gray.cgColor
        convertBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        convertBtn.setTitle("转换", for: UIControlState.normal)
        convertBtn.addTarget(self, action: #selector(self.convertAction), for: UIControlEvents.touchUpInside)
        convertBtn.isEnabled = false
        
        self.view.addSubview(chooseBtn)
        self.view.addSubview(convertBtn)
        
        resultLabel = UILabel.init(frame: CGRect.init(x: 15, y: convertBtn.frame.origin.y + convertBtn.frame.size.height + 10, width: self.view.bounds.size.width - 30, height: 40))
        resultLabel.textColor = UIColor.black
        
        self.view.addSubview(resultLabel)
        
        picker = UIPickerView.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height - 162, width: self.view.bounds.size.width, height: 162))
        picker.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleTopMargin]
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        picker.isHidden = true
        
        self.view.addSubview(picker)
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
    
    @objc func chooseAction() {
        self.view.endEditing(true)
        self.picker.isHidden = false
    }
    
    @objc func convertAction() {
        self.view.endEditing(true)
        
        let latitude = (self.tf_lat.text as NSString!).doubleValue
        let longitude = (self.tf_lng.text as NSString!).doubleValue
        if(!CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(latitude, longitude)))
        {
            self.view.makeToast("无效的输入", duration: 1.0)
            return;
        }
        
        let fromSystem = self.chooseBtn.title(for: UIControlState.normal) as NSString!
        
        var type = AMapCoordinateType.GPS;
        //@[@"Baidu", @"MapBar", @"MapABC", @"SoSoMap", @"AliYun", @"Google", @"GPS"];
        if(fromSystem?.isEqual(to: "Baidu"))! {
            type = AMapCoordinateType.baidu;
        } else if(fromSystem?.isEqual(to: "MapBar"))! {
            type = AMapCoordinateType.mapBar;
        } else if(fromSystem?.isEqual(to: "MapABC"))! {
            type = AMapCoordinateType.mapABC;
        } else if(fromSystem?.isEqual(to: "SoSoMap"))! {
            type = AMapCoordinateType.soSoMap;
        } else if(fromSystem?.isEqual(to: "AliYun"))! {
            type = AMapCoordinateType.aliYun;
        } else if(fromSystem?.isEqual(to: "Google"))! {
            type = AMapCoordinateType.google;
        } else if(fromSystem?.isEqual(to: "GPS"))! {
            type = AMapCoordinateType.GPS;
        }
        
        let ret = AMapCoordinateConvert(CLLocationCoordinate2DMake(latitude, longitude), type);
        let result = String.init(format: "转换结果：{%.6f, %.6f}", ret.latitude, ret.longitude)
        self.resultLabel.text = result
    }
    
    //MARK:- picker delegate
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (self.otherCooridnateSystems.object(at: row) as? String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chooseBtn.setTitle((self.otherCooridnateSystems.object(at: row) as? String), for: UIControlState.normal)
        self.resultLabel.text = ""
        self.convertBtn.isEnabled = true
    }
    
    //MARK:- picker dataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
   
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.otherCooridnateSystems.count
    }
}
