//
//  WiFiTestVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 10/04/21.
//  Copyright © 2021 Prakhar Gupta. All rights reserved.
//

import UIKit
import Luminous
import SwiftyJSON
import PopupDialog
//import SwiftSpinner
import JGProgressHUD

class WiFiTestVC: UIViewController {
    
    var wifiRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var wifiTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTestWiFi: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    //@IBOutlet weak var btnSkip: UIButton!
    
    
    let hud = JGProgressHUD()
    var resultJSON = JSON()
    
    var isComingFromTestResult = false
    var iscomingFromHome = false
    var wifiTimer: Timer?
    var count = 0
    var isWiFiPass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLanguageOfUI() {
        
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "WiFi")
         self.lblTestWiFi.text = self.getLocalizatioStringValue(key: "Testing WiFi")
         self.lblDesc.text = self.getLocalizatioStringValue(key: "To test WIFI, turn WIFI on and connect to your preferred network then Press “START“")
        self.btnStart.setTitle(self.getLocalizatioStringValue(key: "Start"), for: UIControl.State.normal)
         
    }
    
    // MARK: Custom Methods
    
    @objc func runTimedCode() {
        
        self.count += 1
        
        //DispatchQueue.main.async {
            //SwiftSpinner.show(progress: Double(self.count)*0.25, title: "Checking WiFi...".localized)
            //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
        
            self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking WiFi") + "..."
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.indicatorView = JGProgressHUDRingIndicatorView()
            self.hud.progress = Float(self.count)*0.25
            self.hud.show(in: self.view)
        //}
        
        if Luminous.System.Network.isConnectedViaWiFi {
            
            self.resultJSON["WIFI"].int = 1
            UserDefaults.standard.setValue(true, forKey: "WIFI")
            
            isWiFiPass = true
        }
        else{
            self.resultJSON["WIFI"].int = 0
            UserDefaults.standard.setValue(false, forKey: "WIFI")
            
            isWiFiPass = false
        }
        
        //if count > 3 {
        if count == 3 {
            
            DispatchQueue.main.async {
                //SwiftSpinner.hide()
                self.hud.dismiss()
            }
            
            UserDefaults.standard.setValue(true, forKey: "WIFI_complete")
            
            self.wifiTimer?.invalidate()
            
            self.navigateToBackgroundTestScreen()
        }
        
    }
    
    func navigateToBackgroundTestScreen() {
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    // MARK: IBActions
    @IBAction func btnStartWiFiTestClicked(_ sender: UIButton) {
      
        wifiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
