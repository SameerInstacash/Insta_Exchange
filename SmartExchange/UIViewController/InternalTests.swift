//
//  InternalTestsVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 18/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import Luminous
import INTULocationManager
//import SwiftGifOrigin //SAMEER 27/6/23
import SwiftyJSON
import CoreBluetooth
//import CoreNFC
//import SwiftSpinner
import JGProgressHUD

class InternalTestsVC: UIViewController,CBCentralManagerDelegate {
    
    var backgroundRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var backgroundTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPlease: UILabel!
    @IBOutlet weak var btnStart: UIButton!

    @IBOutlet weak var internalImageView: UIImageView!
    
    var location = CLLocation()
    var wifiSSID = String()
    var mcc = String()
    var mnc = String()
    var networkName = String()
    var connection = true
    var manager:CBCentralManager!
    var resultJSON = JSON()
    var endPoint = "https://exchange.getinstacash.com.my/stores-asia/api/v1/public/"
    
    var isComingFromTestResult = false
    let hud = JGProgressHUD()
    
    let locationManager = CLLocationManager()
    var gpsTimer: Timer?
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //internalImageView.loadGif(name: "internal")
        
        /*
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("internal")
        self.internalImageView.image = jeremyGifUp
        self.internalImageView.stopAnimating()
        self.internalImageView.startAnimating()
        */
        
        // Sameer 8/4/21
        self.isLocationAccessEnabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       self.manager = CBCentralManager()
       self.manager.delegate = self
        
        //self.changeLanguageOfUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLanguageOfUI() {
        
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Connections")
         self.lblPlease.text = self.getLocalizatioStringValue(key: "Please make sure Bluetooth, GPS and Wifi are enabled on your device and press begin to start the tests.")

        self.btnStart.setTitle(self.getLocalizatioStringValue(key: "Begin Tests"), for: UIControlState.normal)
         
    }
    
    func isLocationAccessEnabled() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access of location")
                    
                    self.locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access of location")
                }
            } else {
                print("Location services not enabled")
                
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("on")
            self.resultJSON["Bluetooth"] = 1
            UserDefaults.standard.set(true, forKey: "Bluetooth")
            break
        case .poweredOff:
            print("off")
            self.resultJSON["Bluetooth"] = 0
            UserDefaults.standard.set(false, forKey: "Bluetooth")
            print("Bluetooth is Off.")
            break
        case .resetting:
            print("resetting")
            break
        case .unauthorized:
            print("unauthorized")
            break
        case .unsupported:
            print("unsupported")
            self.resultJSON["Bluetooth"] = -2
            UserDefaults.standard.set(false, forKey: "Bluetooth")
            break
        case .unknown:
            print("unknown")
            break
        default:
            self.resultJSON["Bluetooth"] = 1
            break
        }
    }
    
    @IBAction func beginInternalBtnClicked(_ sender: Any) {
        
        // ***** STARTING ALL TESTS ***** //
        
        self.resultJSON["GSM"].int = 0
        UserDefaults.standard.set(false, forKey: "GSM")
        
        self.resultJSON["Storage"].int = 0
        UserDefaults.standard.set(false, forKey: "Storage")
        
        self.resultJSON["GPS"].int = 0
        UserDefaults.standard.set(false, forKey: "GPS")
        
        self.resultJSON["Battery"].int = 1
        UserDefaults.standard.set(true, forKey: "Battery")
            
        /*
        // Check if NFC supported
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                // available
                self.resultJSON["NFC"].int = 1
                UserDefaults.standard.set(true, forKey: "NFC")
            }
            else {
                // not
                self.resultJSON["NFC"].int = 0
                UserDefaults.standard.set(false, forKey: "NFC")
            }
        } else {
            //iOS don't support
            self.resultJSON["NFC"].int = -2
            UserDefaults.standard.set(false, forKey: "NFC")
        }
        */
        
        
            
            
            // 1. GSM Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                //SwiftSpinner.show(progress: 0.2, title: "Checking_Network".localized)
                //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Network") + "..."
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                self.hud.progress = 0.2
                self.hud.show(in: self.view)
                
                if Luminous.System.Carrier.mobileCountryCode != nil {
                    self.mcc = Luminous.System.Carrier.mobileCountryCode!
                    //self.connection = true
                    self.resultJSON["GSM"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM")
                }
                
                if Luminous.System.Carrier.mobileNetworkCode != nil {
                    self.mnc = Luminous.System.Carrier.mobileNetworkCode!
                    //self.connection = true
                    self.resultJSON["GSM"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM")
                }
                
                /*
                if Luminous.System.Carrier.name != nil {
                    self.networkName = Luminous.System.Carrier.name!
                    //self.connection = true
                    self.resultJSON["GSM"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM")
                }
                */
                
                if Luminous.System.Carrier.ISOCountryCode != nil {
                    self.networkName = Luminous.System.Carrier.name!
                    //self.connection = true
                    self.resultJSON["GSM"].int = 1
                    UserDefaults.standard.set(true, forKey: "GSM")
                }
                
            }
            
            // 2. Bluetooth Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //SwiftSpinner.show(progress: 0.4, title: "Checking_Bluetooth".localized)
                //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Bluetooth") + "..."
                self.hud.progress = 0.4
                
                switch self.manager.state {
                case .poweredOn:
                    self.resultJSON["Bluetooth"].int = 1
                    UserDefaults.standard.set(true, forKey: "Bluetooth")
                    break
                case .poweredOff:
                    self.resultJSON["Bluetooth"].int = -1
                    UserDefaults.standard.set(false, forKey: "Bluetooth")
                    break
                case .resetting:
                    self.resultJSON["Bluetooth"].int = 0
                    UserDefaults.standard.set(false, forKey: "Bluetooth")
                    break
                case .unauthorized:
                    self.resultJSON["Bluetooth"].int = 0
                    UserDefaults.standard.set(false, forKey: "Bluetooth")
                    break
                case .unsupported:
                    self.resultJSON["Bluetooth"].int = 0
                    UserDefaults.standard.set(false, forKey: "Bluetooth")
                    break
                case .unknown:
                    break
                default:
                    break
                }
                
            }
            
            
            // 3. Storage Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                //SwiftSpinner.show(progress: 0.6, title: "Checking Storage...".localized)
                //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Storage") + "..."
                self.hud.progress = 0.6
                
                if Luminous.System.Hardware.physicalMemory(withSizeScale: LMSizeScale.kilobytes) > 1024.0 {
                    self.resultJSON["Storage"].int = 1
                    UserDefaults.standard.set(true, forKey: "Storage")
                }else {
                    self.resultJSON["Storage"].int = 0
                    UserDefaults.standard.set(false, forKey: "Storage")
                }
                
            }
                
            // 4. GPS Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.gpsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            }
    
            //UserDefaults.standard.set(self.connection, forKey: "connection")
        
    }
    
    
    @objc func runTimedCode() {
        
        self.count += 1
        
        //SwiftSpinner.show(progress: 0.8, title: "Checking_GPS".localized)
        //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
        
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking GPS") + "..."
        self.hud.progress = 0.8
        
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocation(withDesiredAccuracy: .city,
                                        timeout: 10.0,
                                        delayUntilAuthorized: true) { (currentLocation, achievedAccuracy, status) in
            
            if (status == INTULocationStatus.success) {
                //self.connection = self.connection && true
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location
                
                self.location = currentLocation!
                self.resultJSON["GPS"].int = 1
                UserDefaults.standard.set(true, forKey: "GPS")
                
            }
            else if (status == INTULocationStatus.timedOut) {
                //self.connection = false
                
                self.resultJSON["GPS"].int = 0
                UserDefaults.standard.set(false, forKey: "GPS")
                
                // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                // However, currentLocation contains the best location available (if any) as of right now,
                // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
            }
            else {
                //self.connection = false
                
                self.resultJSON["GPS"].int = 0
                UserDefaults.standard.set(false, forKey: "GPS")
                
                // An error occurred, more info is available by looking at the specific status returned.
            }
            
        }
        
        //if count > 2 {
        if count == 2 {
            DispatchQueue.main.async {
                //SwiftSpinner.show(progress: 1.0, title: "Tests_Complete".localized)
                //SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Tests Complete !")
                self.hud.progress = 1.0
                
            }
        }
        
        //if count > 3 {
        if count == 3 {
            DispatchQueue.main.async {
                locationManager.cancelLocationRequest(INTULocationRequestID.init())
                
                self.locationManager.stopUpdatingLocation()
                
                self.gpsTimer?.invalidate()
                self.navigateToBackgroundTestScreen()
            }
        }
        
    }
    
    func navigateToBackgroundTestScreen() {
        
        // 3/8/21 this code Move to priceVC
        
        /*
        let appCodeS = UserDefaults.standard.string(forKey: "appCodes")!
        var apps = appCodeS.split(separator: ";")
        
        var appCodestr = ""
        if (!UserDefaults.standard.bool(forKey: "deadPixel") && apps[1] != "SBRK01"){
            apps[1] = "SPTS03"
        }
        
        if (!UserDefaults.standard.bool(forKey: "screen") && apps[1] != "SBRK01"){
            apps[1] = "SBRK01"
        }
        
        appCodestr = "\(apps[0]);\(apps[1])"
        
        if (!UserDefaults.standard.bool(forKey: "rotation")){
            appCodestr = "\(appCodestr);CISS14"
        }
        
        if (!UserDefaults.standard.bool(forKey: "proximity")){
            appCodestr = "\(appCodestr);CISS15"
        }
        
        if(!UserDefaults.standard.bool(forKey: "volume")){
            appCodestr = "\(appCodestr);CISS02;CISS03"
        }
        
        if(!UserDefaults.standard.bool(forKey: "earphone")){
            appCodestr = "\(appCodestr);CISS11"
        }
        
        if(!UserDefaults.standard.bool(forKey: "charger")){
            appCodestr = "\(appCodestr);CISS05"
        }
        
        if(!UserDefaults.standard.bool(forKey: "camera")){
            appCodestr = "\(appCodestr);CISS01"
        }
        
        if(!UserDefaults.standard.bool(forKey: "fingerprint")){
            appCodestr = "\(appCodestr);CISS12"
        }
        
        if (!UserDefaults.standard.bool(forKey: "WIFI")) || (!UserDefaults.standard.bool(forKey: "Bluetooth")) || (!UserDefaults.standard.bool(forKey: "GPS")) {
            appCodestr = "\(appCodestr);CISS04"
        }
        
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            appCodestr = "\(appCodestr);CISS10"
        }
        
        if(!UserDefaults.standard.bool(forKey: "mic")){
            appCodestr = "\(appCodestr);CISS08"
        }
        
        if(!UserDefaults.standard.bool(forKey: "Speakers")){
            appCodestr = "\(appCodestr);CISS07"
        }
        
        if(!UserDefaults.standard.bool(forKey: "Vibrator")){
            appCodestr = "\(appCodestr);CISS13"
        }
        
        /* Sameer 17/4/21
        if(!UserDefaults.standard.bool(forKey: "NFC")){
            appCodestr = "\(appCodestr);CISS04"
        }
        */
        
        /* Sameer 17/4/21
        if(!UserDefaults.standard.bool(forKey: "connection")){
            appCodestr = "\(appCodestr);CISS04"
        }
        */
        
        /* Sameer 17/4/21
        if(!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            appCodestr = "\(appCodestr);CISS04"
        }
        
        if(!UserDefaults.standard.bool(forKey: "GPS")) {
            appCodestr = "\(appCodestr);CISS04"
        }
        */
        
        print(apps[0])
        for item in apps {
            print(item)
            if item != apps[0] && item != apps[1] {
                appCodestr = "\(appCodestr);\(item)"
            }
            print(appCodestr)
        }
        
        print(appCodestr)
        */
        
        // ***** FINALISING ALL TESTS ***** //

        DispatchQueue.main.async {
            //SwiftSpinner.hide()
            self.hud.dismiss()
            
            // Sameer 27/3/21
            /*
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            //vc.questionsString = data
            print("Result JSON: \(self.resultJSON)")
            vc.resultJOSN = self.resultJSON
            vc.appCodeStr = String(appCodestr)
            self.present(vc, animated: true, completion: nil)
            */
            
            /*
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
            print("Result JSON: \(self.resultJSON)")
            vc.resultJSON = self.resultJSON
            //vc.appCodeStr = String(appCodestr)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            */
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.backgroundRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.backgroundTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            
            
        }
        
    }
  
    
    func modifiersAPI()
    {
        self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        var request = URLRequest(url: URL(string: "\(endPoint)/getProductDetail")!)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let device = Luminous.System.Hardware.Device.current
        let preferences = UserDefaults.standard
        let productId = preferences.string(forKey: "product_id")
        let customerId = preferences.string(forKey: "customer_id")
//        let postString = "productId=\(productId!)&customerId=\(customerId!)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        var postString = ""
        if productId != nil && customerId != nil {
            postString = "productId=\(productId!)&customerId=\(customerId!)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        }else{
            postString = "productId=3138&customerId=4&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        }
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                /* SAMEER-14/6/22
                // check for fundamental networking error
                print("error=\(error.debugDescription)")
                //SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.view.makeToast("internet_prompt".localized, duration: 2.0, position: .bottom)
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    let productName = json["msg"]["name"].string ?? "productName"
                    let productImage = json["msg"]["image"].string ?? "productImage"
                    print(productName,productImage)
                    
                }else {
                    let msg = json["msg"].string ?? ""
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: msg), duration: 3.0, position: .bottom)
                    }
                }
            }catch {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 3.0, position: .bottom)
                }
                
            }
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                
                //SwiftSpinner.hide()
                self.hud.dismiss()
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            } else{
                do {
                    let json = try JSON(data: data)
                        if json["status"] == "Success" {
                            let productName = json["msg"]["name"].string!
                            let productImage = json["msg"]["image"].string!
                        }
                    }catch{
                }
                
            }*/
            
            
        }
        task.resume()
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
