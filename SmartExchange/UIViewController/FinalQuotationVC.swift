//
//  FinalQuotationVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 07/02/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import FloatingPanel
import Luminous
import DKCamera
import DateTimePicker
import SwiftyJSON
//import SwiftSpinner
import JGProgressHUD

class FinalQuotationVC: UIViewController, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var currentDeviceImgVW: UIImageView!
    @IBOutlet weak var lblUSDPrice: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblCurrentRefNum: UILabel!
    
    @IBOutlet weak var lblYouCan: UILabel!
    @IBOutlet weak var lblYourEmail: UILabel!
    
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDirection: UILabel!
    
    @IBOutlet weak var lblReferenceNumber: UILabel!
    @IBOutlet weak var lblRestartTest: UILabel!
    
    @IBOutlet weak var restartTestBtnView: UIView!
    @IBOutlet weak var restartTestBtn: UIButton!
    
    @IBOutlet weak var homeBtnView: UIView!
    @IBOutlet weak var homeBtn: UIButton!
    
    @IBOutlet weak var mapSubView: UIView!
    @IBOutlet weak var btnClickHere: UIButton!
    
    @IBOutlet weak var lblTip: UILabel!
    
    @IBOutlet weak var bottomToolView: UIView!
    
    var fpc: FloatingPanelController!
    var bottomSheetVC: BottomSheetVC!
    var isComeFromVC = ""
    
    //MARK: For FinalQuotation when order place
    var arrQuestionAnswerFinalData = [[String:Any]]()
    var arrFinalData = [[String:Any]]()
    var appPhysicalQuestionCodeStr = ""
    var appCodeStr = ""
    var resultJOSN = JSON()
    var deviceName = ""
    var metaDetails = JSON()
    var myArray: Array<String> = []
    var isSynced = false
    var orderId = ""
    let hud = JGProgressHUD()
    
    //MARK: For previouseSession
    var sessionDict = [String:Any]()
    var strProductSummary = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Common things for both VC
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        self.setBoldTextInString()
        
        //self.addBottomSheet()
        
        if self.isComeFromVC == "UserDetailsViewController" {
             
            self.restartTestBtnView.isHidden = false
            self.homeBtnView.isHidden = true
            
            self.combineAllAppCodeForServerSend()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.callAPI()
            }
            
            DispatchQueue.main.async {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    self.lblDeviceName.text = UIDevice.current.moName
                    self.deviceName = UIDevice.current.moName
                    self.currentDeviceImgVW.image = UIImage.init(named: "ipad_icon")
                    
                }else {
                    
                    self.lblDeviceName.text = UserDefaults.standard.string(forKey: "productName")
                    self.deviceName = UserDefaults.standard.string(forKey: "productName") ?? ""
                    let img = URL(string: UserDefaults.standard.string(forKey: "productImage") ?? "")
                    self.downloadImage(url: img ?? URL(fileURLWithPath: ""))
                    
                }
                
            }
            
            
            if appDelegate_Obj?.appStoreLatitude == "" || appDelegate_Obj?.appStoreLatitude == nil {
                self.mapSubView.isHidden = true
            }
            else {
                self.mapSubView.isHidden = false
            }
            
        }
        else {
            
            self.addBottomSheet()
            
            self.isSynced = true
            self.restartTestBtnView.isHidden = true
            self.homeBtnView.isHidden = false
            
            let img = URL(string: UserDefaults.standard.string(forKey: "productImage") ?? "")
            self.downloadImage(url: img ?? URL(fileURLWithPath: ""))
            
            self.lblDeviceName.text = self.sessionDict["productName"] as? String ?? ""
            
            //let price = CGFloat(Int(self.sessionDict["productPrice"] as? String ?? "") ?? 0)
            self.lblUSDPrice.text = (self.sessionDict["currencyCode"] as? String ?? "") + " " + (self.sessionDict["productPrice"] as? String ?? "")
            
            let imgurl = URL(string: self.sessionDict["productImage"] as? String ?? "")
            self.currentDeviceImgVW.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "smartphone"))
            
            self.lblCurrentRefNum.text = "Ref #" + (self.sessionDict["productRefNum"] as? String ?? "")
            
            self.orderId = self.sessionDict["productRefNum"] as? String ?? ""
            
            
            if self.sessionDict["storeLatitude"] as? String ?? "" == "" {
                self.mapSubView.isHidden = true
            }
            else {
                self.mapSubView.isHidden = false
            }
            
            
        }
                        
    }
    
    //MARK: custom methods
    func addBottomSheet() {
        
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.behavior = FloatingPanelStocksBehavior()
        
        
        // Initialize FloatingPanelController and add the view
        //fpc.surfaceView.backgroundColor = UIColor(displayP3Red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        //fpc.surfaceView.appearance.cornerRadius = 24.0
        //fpc.surfaceView.appearance.shadows = []
        //fpc.surfaceView.appearance.borderWidth = 1.0 / traitCollection.displayScale
        //fpc.surfaceView.appearance.borderColor = UIColor.black.withAlphaComponent(0.2)
                
        
        //fpc.surfaceView.appearance.cornerRadius = (self.view.bounds.width / 4)
        
        fpc.surfaceView.appearance.cornerRadius = (self.view.frame.height / 4.5)
        
        
        bottomSheetVC = storyboard?.instantiateViewController(withIdentifier: "BottomSheetVC") as? BottomSheetVC
        
        bottomSheetVC.isComeForVC = self.isComeFromVC
        if self.isComeFromVC == "UserDetailsViewController" {
            //bottomSheetVC.arrQuestionAnswerFinalData = self.arrQuestionAnswerFinalData
            
            bottomSheetVC.strProductDesc = self.strProductSummary
            
        }
        else {
            bottomSheetVC.sessionDict = self.sessionDict
        }
        
        // Set a content view controller
        fpc.set(contentViewController: bottomSheetVC)
        
        fpc.track(scrollView: bottomSheetVC.baseScrollView)
        
        fpc.addPanel(toParent: self, at: view.subviews.firstIndex(of: bottomToolView) ?? -1 , animated: false)
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.currentDeviceImgVW.image = UIImage(data: data)
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func copyCurrentRefNumBtnPressed(_ sender: UIButton) {
        
        if (isSynced){
            UIPasteboard.general.string = self.orderId
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "copied"), duration: 1.0, position: .bottom)
            }
            
        }else{
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please wait for the results to sync to the server!"), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    @IBAction func homeBtnPressed(_ sender: UIButton) {
        
        hardwareQuestionsCount = 0
        AppQuestionIndex = -1
        AppResultString = ""
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.navIntoApp()
        
    }
    
    @IBAction func restartTestBtnPressed(_ sender: UIButton) {
        
        if (self.isSynced) {
            
            self.ShowRestartPopUp()
            
        }else{
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please wait for the results to sync to the server!"), duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    @IBAction func tapToSlideBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func btnClickHerePressed(_ sender: UIButton) {
        
        if self.isComeFromVC == "UserDetailsViewController" {
                        
            if appDelegate_Obj?.appStoreLatitude == "" || appDelegate_Obj?.appStoreLatitude == nil {
                return
            }
            else {
                                
                if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                    
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(appDelegate_Obj?.appStoreLatitude ?? ""),\(appDelegate_Obj?.appStoreLongitude ?? "")&zoom=14&views=traffic&q=\(appDelegate_Obj?.appStoreLatitude ?? ""),\(appDelegate_Obj?.appStoreLongitude ?? "")")!, options: [:], completionHandler: nil)
                    
                } else {
                    
                    UIApplication.shared.open(URL(string: "http://maps.google.com/maps?q=loc:\(appDelegate_Obj?.appStoreLatitude ?? ""),\(appDelegate_Obj?.appStoreLongitude ?? "")&zoom=14&views=traffic&q=\(appDelegate_Obj?.appStoreLatitude ?? ""),\(appDelegate_Obj?.appStoreLongitude ?? "")")!, options: [:], completionHandler: nil)
                    
                }
                
            }
            
        }
        else {
            
            if self.sessionDict["storeLatitude"] as? String == "" {
                return
            }
            else {
                                
                if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                    
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(self.sessionDict["storeLatitude"] as? String ?? ""),\(self.sessionDict["storeLongitude"] as? String ?? "")&zoom=14&views=traffic&q=\(self.sessionDict["storeLatitude"] as? String ?? ""),\(self.sessionDict["storeLongitude"] as? String ?? "")")!, options: [:], completionHandler: nil)
                    
                } else {
                    
                    UIApplication.shared.open(URL(string: "http://maps.google.com/maps?q=loc:\(self.sessionDict["storeLatitude"] as? String ?? ""),\(self.sessionDict["storeLongitude"] as? String ?? "")&zoom=14&views=traffic&q=\(self.sessionDict["storeLatitude"] as? String ?? ""),\(self.sessionDict["storeLongitude"] as? String ?? "")")!, options: [:], completionHandler: nil)
                    
                }
                
            }
            
            
        }
        
    }
    
    func callAPI(){
        
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Getting Price") + "..."
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/priceCalcNew")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let store_code = UserDefaults.standard.string(forKey: "store_code") ?? ""
        let product_id = UserDefaults.standard.string(forKey: "product_id") ?? ""
        let postString = "isAppCode=1&str=\(self.appCodeStr)&storeCode=\(store_code)&userName=\(AppUserName)&apiKey=\(AppApiKey)&productId=\(product_id)"
        print("postString= \(postString)")
        request.httpBody = postString.data(using: .utf8)
        
        print("url is :",request,"\nParam is :",postString)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    print("Price Success Response is:", json)
                    
                    
                    DispatchQueue.main.async {
                        let productCurrency = json["currency"].string ?? ""
                        let productPrice = json["msg"].string ?? ""
                        let productDescription = json["productDescription"].string ?? ""
                        self.strProductSummary = productDescription
                        
                        self.lblUSDPrice.text = "\(productCurrency) \(productPrice)"
                        
                        self.addBottomSheet()
                    }
                    
                    
                    if  let offerpriceString = json["msg"].string {
                        
                        let jsonString = UserDefaults.standard.string(forKey: "currencyJson")
                        var multiplier:Float = 1.0
                        var symbol:String = "₹"
                        var curCode:String = "INR"
                        let symbolNew = json["currency"].string ?? ""
                        
                        if let dataFromString = jsonString?.data(using: .utf8, allowLossyConversion: false) {
                            print("currency JSON")
                            let currencyJson = try JSON(data: dataFromString)
                            multiplier = Float(currencyJson["Conversion Rate"].string ?? "")!
                            print("multiplier: \(multiplier)")
                            symbol = currencyJson["Symbol"].string ?? ""
                            curCode = currencyJson["Code"].string ?? ""
                        }else{
                            print("No values")
                        }
                        
                        var diagnosisChargeString = Float()
                        DispatchQueue.main.async() {
                            
                            if let type = UserDefaults.standard.value(forKey: "storeType") as? Int {
                                if type == 0 {
                                    diagnosisChargeString = Float(json["diagnosisCharges"].intValue)
                                }else {
                                    diagnosisChargeString = Float(json["pawn"].intValue)
                                }
                            }
                            
                            
                            if let online = UserDefaults.standard.value(forKey: "tradeOnline") as? Int {
                                if online == 0 {
                                    //self.tradeInBtn.isHidden = true
                                }else {
                                    //self.tradeInBtn.isHidden = false
                                }
                            }
                        }
                        
                        
                        if symbol != symbolNew {
                            diagnosisChargeString = diagnosisChargeString * multiplier
                        }
                        
                        var offer = Float(offerpriceString)!
                        if curCode != symbolNew {
                            offer = offer * multiplier
                        }
                        
                        let payable = offer - diagnosisChargeString
                        print("payable: \(offer - diagnosisChargeString) ")
                        
                        DispatchQueue.main.async() {
                            
                            self.saveResult(price: offerpriceString)
                            
                            if (json["deviceStatusFlag"].exists() && json["deviceStatusFlag"].intValue == 1) {
                                
                                //self.diagnosisChargesInfo.isHidden = true
                                //self.diagnosisCharges.isHidden = true
                                //self.payableAmount.isHidden = true
                                //self.payableBtnInfo.isHidden = true
                                
                                //self.offeredPriceInfo.text = self.getLocalizatioStringValue(key: "Device Status")
                                //self.offeredPrice.text = json["deviceStatus"].stringValue
                                
                            }else{
                                
                                if let type = UserDefaults.standard.value(forKey: "storeType") as? Int {
                                    if type == 0 {
                                        
                                        
                                    }else {
                                        //self.diagnosisChargesInfo.text = self.getLocalizatioStringValue(key: "Pawn")
                                        //self.payableBtnInfo.text = self.getLocalizatioStringValue(key: "Trade-In")
                                    }
                                }
                                
                                //self.payableAmount.text = "\(symbol) \(Int(payable))"
                                //self.diagnosisCharges.text = "\(symbol) \(Int(diagnosisChargeString))"
                                //self.offeredPrice.text = "\(symbol) \(Int(offer))"
                                //SwiftSpinner.hide()
                                self.hud.dismiss()
                                
                                //self.lblUSDPrice.text = "\(symbol) \(Int(offer))"
                                
                                
                                
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 2.0, position: .bottom)
                        }
                    }
                    
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
            
        }
        task.resume()
    }
    
    func saveResult(price: String) {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        //self.endPoint = UserDefaults.standard.string(forKey: "endpoint") ?? ""
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/savingResult")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        var netType = "Mobile"
        if Luminous.System.Network.isConnectedViaWiFi {
            netType = "Wifi"
        }
        metaDetails["currentCountry"].string = Luminous.System.Locale.currentCountry
        metaDetails["Internet  Type"].string = netType
        metaDetails["Internet  SSID"].string = Luminous.System.Network.SSID
        metaDetails["Internet Availability"].bool = Luminous.System.Network.isInternetAvailable
        metaDetails["Carrier Name"].string = Luminous.System.Carrier.name
        metaDetails["Carrier MCC"].string = Luminous.System.Carrier.mobileCountryCode
        metaDetails["Carrier MNC"].string = Luminous.System.Carrier.mobileNetworkCode
        metaDetails["Carrier Allows VOIP"].bool = Luminous.System.Carrier.allowsVOIP
        metaDetails["GPS Location"].string = Luminous.System.Locale.currentCountry
        metaDetails["Battery Level"].float = Luminous.System.Battery.level
        metaDetails["Battery State"].string = "\(Luminous.System.Battery.state)"
        metaDetails["currentCountry"].string = Luminous.System.Locale.currentCountry
        
        let customerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
        let resultCode = ""
        let imei = UserDefaults.standard.string(forKey: "imei_number") ?? ""
        let product_id = UserDefaults.standard.string(forKey: "product_id") ?? ""
        print("Result JSON 5: \(self.resultJOSN)")
        
        let postString = "customerId=\(customerId)&resultCode=\(resultCode)&resultJson=\(self.resultJOSN)&price=\(price)&deviceName=\(self.deviceName)&conditionString=\(self.appCodeStr)&metaDetails=\(metaDetails)&IMEINumber=\(imei)&userName=\(AppUserName)&apiKey=\(AppApiKey)&productId=\(product_id)"
        print("\(postString)")
        
        print("url is :",request,"\nParam is :",postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                //self.loaderImage.isHidden = true
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    print("savingResult Success Response is:", json)
                    
                    let msg = json["msg"]
                    self.orderId = msg["orderId"].string ?? ""
                    self.isSynced = true
                    
                    DispatchQueue.main.async{
                        //self.loaderImage.isHidden = true
                        //self.uploadIdBtn.isHidden = false
                        //self.refValueLabel.isHidden = false
                        //let refno = self.getLocalizatioStringValue(key: "Reference No")
                        let refno = self.getLocalizatioStringValue(key: "Ref #")
                        self.lblCurrentRefNum.text = "\(refno) \(self.orderId)"
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Details Synced to the server. Please contact Store Executive for further information"), duration: 1.0, position: .bottom)
                        }
                    }
                    
                }else {
                    let msg = json["msg"].string
                    DispatchQueue.main.async() {
                        self.view.makeToast(msg, duration: 3.0, position: .bottom)
                    }
                }
            }catch {
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 3.0, position: .bottom)
                }
            }
            
            
        }
        task.resume()
    }
    
    func ShowRestartPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you sure, you want to restart the process."
        popUpVC.strMessage = ""
        popUpVC.strBtnYesTitle = "No"
        popUpVC.strBtnNoTitle = "Yes"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                break
                
            case 2:
                
                hardwareQuestionsCount = 0
                AppQuestionIndex = -1
                AppResultString = ""
                
                let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.navIntoApp()
                
                /*
                 let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                 let centerVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                 appDel.window!.rootViewController = centerVC
                 appDel.window!.makeKeyAndVisible()
                 */
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    func combineAllAppCodeForServerSend() {
        
        let appCodeS = UserDefaults.standard.string(forKey: "appCodes") ?? ""
        let apps = appCodeS.split(separator: ";")
        print("apps are :",apps)
        
        var appCodestring = ""
        
        if (!UserDefaults.standard.bool(forKey: "screen")) {
            appCodestring = "\(appCodestring);SBRK01"
        }
        
        if (!UserDefaults.standard.bool(forKey: "deadPixel")) {
            appCodestring = "\(appCodestring);SPTS03"
        }
        
        if (!UserDefaults.standard.bool(forKey: "rotation")){
            appCodestring = "\(appCodestring);CISS14"
        }
        
        if (!UserDefaults.standard.bool(forKey: "proximity")){
            appCodestring = "\(appCodestring);CISS15"
        }
        
        if (!UserDefaults.standard.bool(forKey: "volume")){
            //appCodestring = "\(appCodestring);CISS02;CISS03"
            appCodestring = "\(appCodestring);CISS02"
        }
        
        /* MARK: Ajay told to Remove both test on 27/3/23
         if (!UserDefaults.standard.bool(forKey: "earphone")){
         appCodestring = "\(appCodestring);CISS11"
         }
         
         if (!UserDefaults.standard.bool(forKey: "charger")){
         appCodestring = "\(appCodestring);CISS05"
         }
         */
        
        if (!UserDefaults.standard.bool(forKey: "camera")){
            appCodestring = "\(appCodestring);CISS01"
        }
        
        if (!UserDefaults.standard.bool(forKey: "fingerprint")){
            appCodestring = "\(appCodestring);CISS12"
        }
        
        if (!UserDefaults.standard.bool(forKey: "WIFI")) || (!UserDefaults.standard.bool(forKey: "Bluetooth")) || (!UserDefaults.standard.bool(forKey: "GPS")) {
            appCodestring = "\(appCodestring);CISS04"
        }
        
        if (!UserDefaults.standard.bool(forKey: "GSM")) {
            appCodestring = "\(appCodestring);CISS10"
        }
        
        if (!UserDefaults.standard.bool(forKey: "mic")){
            appCodestring = "\(appCodestring);CISS08"
        }
        
        if (!UserDefaults.standard.bool(forKey: "Speakers")){
            appCodestring = "\(appCodestring);CISS07"
        }
        
        if(!UserDefaults.standard.bool(forKey: "Vibrator")){
            appCodestring = "\(appCodestring);CISS13"
        }
        
        if (!UserDefaults.standard.bool(forKey: "Battery")){
            appCodestring = "\(appCodestring);CISS06"
        }
        
        
        //let  = appCodestr.remove(at: appCodestr.startIndex)
        let testStr = appCodestring.dropFirst()
        
        self.appCodeStr = testStr + ";" + appCodeS
        
        if self.appPhysicalQuestionCodeStr != "" {
            self.appCodeStr += self.appPhysicalQuestionCodeStr
            //print("self.appPhysicalQuestionCodeStr",self.appPhysicalQuestionCodeStr)
        }
        
        if !self.appCodeStr.contains("STON01") {
            self.appCodeStr += "STON01"
        }
        
        //MARK: 15/10/22 As discussed with Vijay Bhai
        if self.appCodeStr.contains("SBRK01") {
            
            if self.appCodeStr.contains("SPTS01") {
                self.appCodeStr = self.appCodeStr.replacingOccurrences(of: "SPTS01", with: "")
            }
            
            if self.appCodeStr.contains("SPTS02") {
                self.appCodeStr = self.appCodeStr.replacingOccurrences(of: "SPTS02", with: "")
            }
            
            if self.appCodeStr.contains("SPTS03") {
                self.appCodeStr = self.appCodeStr.replacingOccurrences(of: "SPTS03", with: "")
            }
            
        }else if self.appCodeStr.contains("SPTS03") {
            
            if self.appCodeStr.contains("SPTS01") {
                self.appCodeStr = self.appCodeStr.replacingOccurrences(of: "SPTS01", with: "")
            }
            
            if self.appCodeStr.contains("SPTS02") {
                self.appCodeStr = self.appCodeStr.replacingOccurrences(of: "SPTS02", with: "")
            }
            
        }
        
        var arrSplitString = self.appCodeStr.split(separator: ";")
        //print("arrSplitString", arrSplitString)
        
        arrSplitString = self.unique(source: arrSplitString)
        //print("arrSplitString after duplicate remove", arrSplitString)
        
        self.appCodeStr = arrSplitString.joined(separator: ";")
        //print("arrSplitString after imploide", self.appCodeStr)
        //print("Final self.appCodeStr for server :",self.appCodeStr)
        
    }
    
    func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return FloatingPanelStocksLayout()
    }
    
    var minYsurface = CGFloat()
    var maxYsurface = CGFloat()
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
                
        if vc.isAttracting == false {
            let loc = vc.surfaceLocation
            let minY = vc.surfaceLocation(for: .full).y
            let maxY = vc.surfaceLocation(for: .tip).y
            vc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
            
            if minY > 0.0 {
                minYsurface = minY
            }
            
            if maxY > 0.0 {
                maxYsurface = maxY
            }
            
        }
        
        //print("minYsurface", minYsurface)
        //print("maxYsurface", maxYsurface)
        //print("vc.surfaceLocation.y", vc.surfaceLocation.y)
        
        if vc.surfaceLocation.y <= vc.surfaceLocation(for: .full).y + 100 {
            
            showStockTickerBanner()
            
            if vc.surfaceLocation.y == minYsurface {
                
                if let isArrowBtnSlide = bottomSheetVC.isArrowBtnSlide {
                    isArrowBtnSlide(true)
                }
                
            }
            
        } else {
            
            hideStockTickerBanner()
            
            if vc.surfaceLocation.y == maxYsurface {
                
                if let isArrowBtnSlide = bottomSheetVC.isArrowBtnSlide {
                    isArrowBtnSlide(false)
                }
                
            }
            
        }
    }
    
    private func showStockTickerBanner() {
        // Present top bar with dissolve animation
        UIView.animate(withDuration: 0.25) {
            //self.topBannerView.alpha = 1.0
            //self.labelStackView.alpha = 0.0
            //self.view.backgroundColor = .black
        }
    }
    
    private func hideStockTickerBanner() {
        // Dismiss top bar with dissolve animation
        UIView.animate(withDuration: 0.25) {
            //self.topBannerView.alpha = 0.0
            //self.labelStackView.alpha = 1.0
            //self.view.backgroundColor = .black
        }
    }
    
    func setBoldTextInString() {
        
        self.restartTestBtn.layer.cornerRadius = 5.0
        self.restartTestBtn.layer.borderWidth = 1.0
        self.restartTestBtn.layer.borderColor = UIColor.init(hexString: "#E63333").cgColor
        
        self.homeBtn.layer.cornerRadius = 5.0
        self.homeBtn.layer.borderWidth = 1.0
        self.homeBtn.layer.borderColor = UIColor.init(hexString: "#09805E").cgColor
        
        //For click here button
        let clickHereText = "Click here"
        let clickHereAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12),
                              NSAttributedString.Key.foregroundColor : UIColor.link,
                              NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let clickHereAttributedString = NSMutableAttributedString(string: clickHereText, attributes: clickHereAttrs)
        self.btnClickHere.titleLabel?.attributedText = clickHereAttributedString
        
        //1
        let YouCanBoldText = "copy icon"
        let YouCanArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let YouCanAttributedString = NSMutableAttributedString(string: YouCanBoldText, attributes: YouCanArattrs)
        
        let YouCanNormalText1 = "You can tap the "
        let YouCanNormalText2 = " to save it for future use."
        let YouCanNormalString1 = NSMutableAttributedString(string: YouCanNormalText1)
        let YouCanNormalString2 = NSMutableAttributedString(string: YouCanNormalText2)
        
        YouCanNormalString1.append(YouCanAttributedString)
        YouCanNormalString1.append(YouCanNormalString2)
        
        if self.lblYouCan != nil {
            self.lblYouCan.attributedText = YouCanNormalString1
        }
        
        
        //2
        let yourEmailBoldText = "email"
        let yourEmailArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let yourEmailAttributedString = NSMutableAttributedString(string: yourEmailBoldText, attributes: yourEmailArattrs)
        
        let yourEmailNormalText1 = "This reference number has also been sent to your "
        let yourEmailNormalText2 = " for Your convenience."
        let yourEmailNormalString1 = NSMutableAttributedString(string: yourEmailNormalText1)
        let yourEmailNormalString2 = NSMutableAttributedString(string: yourEmailNormalText2)
        
        yourEmailNormalString1.append(yourEmailAttributedString)
        yourEmailNormalString1.append(yourEmailNormalString2)
        
        if self.lblYourEmail != nil {
            self.lblYourEmail.attributedText = yourEmailNormalString1
        }
        
        //3
        let storeBoldText = "Store Name:"
        let storeAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let storeAttributedString = NSMutableAttributedString(string: storeBoldText, attributes: storeAttrs)
                
        var storeNormalText = ""
        if self.isComeFromVC == "UserDetailsViewController" {
            storeNormalText = " " + (appDelegate_Obj?.appStoreName ?? "")
        }else {
            storeNormalText = " " + (self.sessionDict["storeName"] as? String ?? "")
        }
                
        let storeNormalString = NSMutableAttributedString(string: storeNormalText)
        storeAttributedString.append(storeNormalString)
        
        if self.lblStoreName != nil {
            self.lblStoreName.attributedText = storeAttributedString
        }
        
        
        //4
        let addressBoldText = "Address:"
        let addressAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let addressAttributedString = NSMutableAttributedString(string: addressBoldText, attributes: addressAttrs)
                
        var addressNormalText = ""
        if self.isComeFromVC == "UserDetailsViewController" {
            addressNormalText = " " + (appDelegate_Obj?.appStoreAddress ?? "")
        }else {
            addressNormalText = " " + (self.sessionDict["storeAddress"] as? String ?? "")
        }
        
        let addressNormalString = NSMutableAttributedString(string: addressNormalText)
        addressAttributedString.append(addressNormalString)
        
        if self.lblAddress != nil {
            self.lblAddress.attributedText = addressAttributedString
        }
        
        
        //5
        let directionBoldText = "Directions:"
        let directionAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let directionAttributedString = NSMutableAttributedString(string: directionBoldText, attributes: directionAttrs)
        
        //let directionNormalText = " [Google Maps Link]"
        let directionNormalText = ""
        let directionNormalString = NSMutableAttributedString(string: directionNormalText)
        directionAttributedString.append(directionNormalString)
        
        if self.lblDirection != nil {
            self.lblDirection.attributedText = directionAttributedString
        }
        
        
        //6
        let ReferenceNumberBoldText = "Reference Number"
        let ReferenceNumberArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let ReferenceNumberAttributedString = NSMutableAttributedString(string: ReferenceNumberBoldText, attributes: ReferenceNumberArattrs)
        
        let ReferenceNumberNormalText1 = "Provide your "
        let ReferenceNumberNormalText2 = " to the store representative."
        let ReferenceNumberNormalString1 = NSMutableAttributedString(string: ReferenceNumberNormalText1)
        let ReferenceNumberNormalString2 = NSMutableAttributedString(string: ReferenceNumberNormalText2)
        
        ReferenceNumberNormalString1.append(ReferenceNumberAttributedString)
        ReferenceNumberNormalString1.append(ReferenceNumberNormalString2)
        
        if self.lblReferenceNumber != nil {
            self.lblReferenceNumber.attributedText = ReferenceNumberNormalString1
        }
        
        
        //7
        let restartTestBoldText = "Restart Tests"
        let restartTestArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let restartTestAttributedString = NSMutableAttributedString(string: restartTestBoldText, attributes: restartTestArattrs)
        
        let restartTestNormalText1 = "If you think there’s an issue with your diagnostics, tap " + "\""
        let restartTestNormalText2 = "\"" + " to re-run the evaluation."
        let restartTestNormalString1 = NSMutableAttributedString(string: restartTestNormalText1)
        let restartTestNormalString2 = NSMutableAttributedString(string: restartTestNormalText2)
        
        restartTestNormalString1.append(restartTestAttributedString)
        restartTestNormalString1.append(restartTestNormalString2)
        
        if self.lblRestartTest != nil {
            self.lblRestartTest.attributedText = restartTestNormalString1
        }
        
        
        //8
        let tipBoldText = "Tip:"
        let tipAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let tipAttributedString = NSMutableAttributedString(string: tipBoldText, attributes: tipAttrs)
        
        let tipNormalText = " Bring your device and any accessories to the store for a seamless trade-in experience."
        let tipNormalString = NSMutableAttributedString(string: tipNormalText)
        tipAttributedString.append(tipNormalString)
        
        if self.lblTip != nil {
            self.lblTip.attributedText = tipAttributedString
        }
        
    }
    
}

// MARK: - FloatingPanelLayout

class FloatingPanelStocksLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    
    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 56.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 262.0, edge: .bottom, referenceGuide: .safeArea),
        /* Visible + ToolView */
        //.tip: FloatingPanelLayoutAnchor(absoluteInset: 85.0 + 44.0, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 160.0, edge: .bottom, referenceGuide: .safeArea),
    ]
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
}


// MARK: - FloatingPanelBehavior

class FloatingPanelStocksBehavior: FloatingPanelBehavior {
    let springDecelerationRate: CGFloat = UIScrollView.DecelerationRate.fast.rawValue
    let springResponseTime: CGFloat = 0.25
}
