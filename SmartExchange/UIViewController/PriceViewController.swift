//
//  PriceViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 24/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import Luminous
import DKCamera
import DateTimePicker
import SwiftyJSON
//import SwiftSpinner
import JGProgressHUD

extension UIView {
    func rotate360DegreesAgain(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

class PriceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    let hud = JGProgressHUD()
    
    //@IBOutlet weak var tradeInOnlineView: UIView!
    //@IBOutlet weak var tradeInOnlineMessageTxtView: UITextView!
    
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var refValueLabel: UILabel!
    
    @IBOutlet weak var offeredPriceInfo: UILabel!
    @IBOutlet weak var diagnosisChargesInfo: UILabel!
    @IBOutlet weak var payableBtnInfo: UILabel!
    
    @IBOutlet weak var uploadIdBtn: UIButton!
    //@IBOutlet weak var buySmartPhoneBtn: UIButton!
    //@IBOutlet weak var lblCheckout: UILabel!
    
    @IBOutlet weak var offeredPrice: UILabel!
    @IBOutlet weak var diagnosisCharges: UILabel!
    @IBOutlet weak var payableAmount: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var loaderImage: UIImageView!

    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    
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
    //var endPoint = "http://exchange.getinstacash.in/stores-asia/api/v1/public/"
    var photoAvailable = false
    
    let XtraCoverSupportNumber = "8860396039"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        DispatchQueue.main.async {
            //self.createTableUsingMyArray()
            //self.combineAllAppCodeForServerSend()
            
            self.createPhysicalDataTableUsingFinalArray()
            
            self.myTableView.layer.cornerRadius = 5
        }
        
        self.combineAllAppCodeForServerSend()
        
        
        /* //MARK: Commemt on 15/12/22 due to no use
        let isTradeInOnline = UserDefaults.standard.value(forKey: "Trade_In_Online") as? Bool ?? false
        print("isTradeInOnline value is :", isTradeInOnline)
        
        if isTradeInOnline {
            self.addInfoToTextView()
            self.tradeInOnlineView.isHidden = false
            UIView.addShadow(baseView: self.tradeInOnlineView)
        }else {
            self.tradeInOnlineMessageTxtView.text = ""
            self.tradeInOnlineView.isHidden = true
        }
        */
        
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        
        self.loaderImage.isHidden = false
        //let yourImage: UIImage = UIImage(named: "ic_load") ?? UIImage()
        //self.loaderImage.image = yourImage
        //self.loaderImage.rotate360DegreesAgain()
        
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //self.loaderImage.loadGif(name: "loader")
        
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("loader")
        self.loaderImage.image = jeremyGifUp
        self.loaderImage.stopAnimating()
        self.loaderImage.startAnimating()
                
        
        //let uploadText = "upload_btn_text".localized
        //let scheduleText = "schedule_btn_text".localized
        //self.uploadIdBtn.setTitle(uploadText, for: .normal)
        //scheduleVisitBtn.setTitle(scheduleText, for: .normal)
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        let heightForTable = (self.payableBtnInfo.frame.maxY + 20)
        print(barHeight, displayWidth, displayHeight, heightForTable)
        
        /*
         myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
         myTableView.dataSource = self
         myTableView.delegate = self
         self.view.addSubview(myTableView)
         */
        
        
        //self.endPoint = UserDefaults.standard.string(forKey: "endpoint") ?? ""
        
        //SwiftSpinner.show("Getting Price...")
        
        /*
         if self.appCodeStr != "" {
         callAPI()
         }else {
         DispatchQueue.main.async {
         self.loaderImage.isHidden = true
         self.view.makeToast("Device Condition Not Found.", duration: 5.0, position: .bottom)
         }
         }
         */
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.callAPI()
        }
        
        //}
        
        DispatchQueue.main.async {
            
            //let imgDEf = URL(string: "https://instacash.blob.core.windows.net/static/img/products/default.png")
            //print("productName: \(self.deviceName), productImage: \(img ?? imgDEf)")
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                self.productName.text = UIDevice.current.moName
                self.deviceName = UIDevice.current.moName
                self.productImage.image = UIImage.init(named: "ipad_icon")
        
                self.refValueLabel.isHidden = true
                
            }else {
                self.productName.text = UserDefaults.standard.string(forKey: "productName")
                self.deviceName = UserDefaults.standard.string(forKey: "productName") ?? ""
                let img = URL(string: UserDefaults.standard.string(forKey: "productImage") ?? "")
                self.downloadImage(url: img ?? URL(fileURLWithPath: ""))
        
                self.refValueLabel.isHidden = true
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myTableView.register(UINib(nibName: "QuestAnsrTblCell", bundle: nil), forCellReuseIdentifier: "QuestAnsrTblCell")
        
        self.myTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
                
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Quotation")
        
        self.offeredPriceInfo.text = self.getLocalizatioStringValue(key: "Offered Price")
        self.diagnosisChargesInfo.text = self.getLocalizatioStringValue(key: "Diagnosis Charges")
        self.payableBtnInfo.text = self.getLocalizatioStringValue(key: "Estimated Amount")
        
        self.uploadIdBtn.setTitle(self.getLocalizatioStringValue(key: "Scan Identity Card (IC) to proceed"), for: UIControlState.normal)
        //self.buySmartPhoneBtn.setTitle(self.getLocalizatioStringValue(key: "BUY A SMARTPHONE"), for: UIControlState.normal)
        
        //self.lblCheckout.text = self.getLocalizatioStringValue(key: "Checkout our Refurb Phones")
         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.myTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "contentSize") {
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.myTableViewHeightConstraint.constant = newsize.height + 10.0
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            }
        }
        
    }
    
    //override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        
        //self.myTableView.dataSource = self
        //self.myTableView.delegate = self
        
        //self.view.addSubview(self.myTableView)
        //DispatchQueue.main.asyncAfter(deadline: .now()) {
        //self.myTableViewHeightConstraint.constant = self.myTableView.contentSize.height
        //}
    //}
    
    func addInfoToTextView()  {
        
        /*
        let strMessage = "Your sell back request has been registered with us and we will be calling you shortly to confirm an appointment for pickup.\nor you may call us on \(self.XtraCoverSupportNumber) for more details."

        let attributedString = NSMutableAttributedString(string: strMessage, attributes: [NSAttributedStringKey.font: UIFont(name: "Poppins-Medium", size: 14) ?? UIFont()])
        let foundRange = attributedString.mutableString.range(of: self.XtraCoverSupportNumber)

        attributedString.addAttribute(NSAttributedString.Key.link, value: self.XtraCoverSupportNumber, range: foundRange)
        
        self.tradeInOnlineMessageTxtView.attributedText = attributedString
        
        self.tradeInOnlineMessageTxtView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.init(hexString: "#FC5400")]
        self.tradeInOnlineMessageTxtView.textColor = UIColor.init(hexString: "#101010")
        self.tradeInOnlineMessageTxtView.textAlignment = .center
        self.tradeInOnlineMessageTxtView.isEditable = false
        self.tradeInOnlineMessageTxtView.dataDetectorTypes = UIDataDetectorTypes.all
        self.tradeInOnlineMessageTxtView.delegate = self
        */
        
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        if URL.absoluteString == "Nutzungsbedingungen" {
            print("nutzung")
        }else if URL.absoluteString == "Datenschutzrichtlinien" {
            print("daten")
        }
        
        
        if let url = Foundation.URL(string: "tel://\(URL.absoluteString)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Your device doesn't Support this Feature."), duration: 3.0, position: .bottom)
            }
        }

        return true
    }

    func callAPI(){
        
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Getting Price") + "..."
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        //self.endPoint = UserDefaults.standard.string(forKey: "endpoint") ?? ""
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
                
                /*
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    // check for fundamental networking error
                    print("error=\(error.debugDescription)")
                    self.view.makeToast("Please Check Internet conection.", duration: 2.0, position: .bottom)
                    
                    do{
                        let json = try JSON(data: data ?? Data())
                        print(" Price Error Response is:", json)
                        
                        let msg = json["msg"].string
                        self.view.makeToast(msg, duration: 3.0, position: .bottom)
                    }catch {
                        DispatchQueue.main.async() {
                            self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                        }
                    }
                    
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    print("Price Success Response is:", json)
                    
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
                        
                        /*
                        var diagnosisChargeString: Float
                        if ( UserDefaults.standard.string(forKey: "store_code") == "6307") {
                            diagnosisChargeString = Float(json["pawn"].intValue)
                        }else{
                            diagnosisChargeString = Float(json["diagnosisCharges"].intValue)
                        }
                        */
                        
                        
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
                        
                        //self.saveResult(price: offerpriceString)
                        DispatchQueue.main.async() {
                            
                            self.saveResult(price: offerpriceString)
                            
                            if (json["deviceStatusFlag"].exists() && json["deviceStatusFlag"].intValue == 1) {
                                
                                self.diagnosisChargesInfo.isHidden = true
                                self.diagnosisCharges.isHidden = true
                                self.payableAmount.isHidden = true
                                self.payableBtnInfo.isHidden = true
                                
                                self.offeredPriceInfo.text = self.getLocalizatioStringValue(key: "Device Status")
                                self.offeredPrice.text = json["deviceStatus"].stringValue
                                
                            }else{
                                /*
                                if (UserDefaults.standard.string(forKey: "store_code") == "6307"){
                                    self.payableAmount.isHidden = true
                                    self.payableBtnInfo.isHidden = true
                                    self.offeredPriceInfo.text = "Trade-In"
                                    self.diagnosisChargesInfo.text = "Pawn"
                                }
                                */
                                
                                if let type = UserDefaults.standard.value(forKey: "storeType") as? Int {
                                    if type == 0 {
                                        
                                        
                                    }else {
                                        self.diagnosisChargesInfo.text = self.getLocalizatioStringValue(key: "Pawn")
                                        self.payableBtnInfo.text = self.getLocalizatioStringValue(key: "Trade-In")
                                    }
                                }

                                self.payableAmount.text = "\(symbol) \(Int(payable))"
                                self.diagnosisCharges.text = "\(symbol) \(Int(diagnosisChargeString))"
                                self.offeredPrice.text = "\(symbol) \(Int(offer))"
                                //SwiftSpinner.hide()
                                self.hud.dismiss()
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
                                
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                //
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                do{
                    let json = try JSON(data: data ?? Data())
                    print(" Price Response is:", json)
                    
                    let msg = json["msg"].string
                    self.view.makeToast(msg, duration: 3.0, position: .bottom)
                }catch {
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                    }
                }
                
                //check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            } else{
                print("response = \(response ?? URLResponse())")
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                do {
                    let json = try JSON(data: dataThis)
                    print(" Price Success Response is:", json)
                    
                    if  let offerpriceString = json["msg"].string {
                        
                        let jsonString = UserDefaults.standard.string(forKey: "currencyJson")
                        var multiplier:Float = 1.0
                        var symbol:String = "₹"
                        var curCode:String = "INR"
                        let symbolNew = json["currency"].string
                        
                        if let dataFromString = jsonString?.data(using: .utf8, allowLossyConversion: false) {
                            print("currency JSON")
                            let currencyJson = try JSON(data: dataFromString)
                            multiplier = Float(currencyJson["Conversion Rate"].string!)!
                            print("multiplier: \(multiplier)")
                            symbol = currencyJson["Symbol"].string!
                            curCode = currencyJson["Code"].string!
                        }else{
                            print("No values")
                        }
                        
                        /*
                        var diagnosisChargeString: Float
                        if ( UserDefaults.standard.string(forKey: "store_code") == "6307") {
                            diagnosisChargeString = Float(json["pawn"].intValue)
                        }else{
                            diagnosisChargeString = Float(json["diagnosisCharges"].intValue)
                        }
                        */
                        
                        
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
                        
                        //self.saveResult(price: offerpriceString)
                        DispatchQueue.main.async() {
                            
                            self.saveResult(price: offerpriceString)
                            
                            if (json["deviceStatusFlag"].exists() && json["deviceStatusFlag"].intValue == 1) {
                                
                                self.diagnosisChargesInfo.isHidden = true
                                self.diagnosisCharges.isHidden = true
                                self.payableAmount.isHidden = true
                                self.payableBtnInfo.isHidden = true
                                
                                self.offeredPriceInfo.text = "Device Status"
                                self.offeredPrice.text = json["deviceStatus"].stringValue
                                
                            }else{
                                /*
                                if (UserDefaults.standard.string(forKey: "store_code") == "6307"){
                                    self.payableAmount.isHidden = true
                                    self.payableBtnInfo.isHidden = true
                                    self.offeredPriceInfo.text = "Trade-In"
                                    self.diagnosisChargesInfo.text = "Pawn"
                                }
                                */
                                
                                if let type = UserDefaults.standard.value(forKey: "storeType") as? Int {
                                    if type == 0 {
                                        
                                        
                                    }else {
                                        self.diagnosisChargesInfo.text = "Pawn"
                                        self.payableBtnInfo.text = "Trade-In"
                                    }
                                }

                                self.payableAmount.text = "\(symbol) \(Int(payable))"
                                self.diagnosisCharges.text = "\(symbol) \(Int(diagnosisChargeString))"
                                self.offeredPrice.text = "\(symbol) \(Int(offer))"
                                //SwiftSpinner.hide()
                                self.hud.dismiss()
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                        }
                    }
                    
                }catch {
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }*/
            
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
                self.loaderImage.isHidden = true
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                /*
                DispatchQueue.main.async {
                    //SwiftSpinner.hide()
                    self.hud.dismiss()
                    // check for fundamental networking error
                    //self.view.makeToast("Please Check Internet conection.", duration: 2.0, position: .bottom)
                    
                    do{
                        let json = try JSON(data: data ?? Data())
                        print(" savingResult Error Response is:", json)
                        
                        let msg = json["msg"].string
                        self.view.makeToast(msg, duration: 3.0, position: .bottom)
                    }catch {
                        DispatchQueue.main.async() {
                            self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                        }
                    }
                    
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    print("savingResult Success Response is:", json)
                    
                    let msg = json["msg"]
                    self.orderId = msg["orderId"].string ?? ""
                    self.isSynced = true
                    
                    DispatchQueue.main.async{
                        self.loaderImage.isHidden = true
                        self.uploadIdBtn.isHidden = false
                        self.refValueLabel.isHidden = false
                        //let refno = self.getLocalizatioStringValue(key: "Reference No")
                        let refno = self.getLocalizatioStringValue(key: "Ref# ")
                        self.refValueLabel.text = "\(refno): \(self.orderId)"
                        
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
            
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                
                DispatchQueue.main.async {
                    //SwiftSpinner.hide()
                    self.hud.dismiss()
                }
                
                // check for http errors
                
                do{
                    let json = try JSON(data: data ?? Data())
                    print(" savingResult Error Response is:", json)
                    
                    let msg = json["msg"].string
                    DispatchQueue.main.async() {
                        self.view.makeToast(msg, duration: 3.0, position: .bottom)
                    }
                }catch {
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                    }
                }
                
            } else{
                do{
                    let json = try JSON(data: dataThis)
                    print(" savingResult Success Response is:", json)
                    
                    let msg = json["msg"]
                    self.orderId = msg["orderId"].string ?? ""
                    self.isSynced = true
                    
                    DispatchQueue.main.async{
                        self.loaderImage.isHidden = true
                        self.uploadIdBtn.isHidden = false
                        self.refValueLabel.isHidden = false
                        let refno = "reference_no".localized
                        self.refValueLabel.text = "\(refno): \(self.orderId)"
                        
                        DispatchQueue.main.async {
                            self.view.makeToast("Details Synced to the server. Please contact Store Executive for further information", duration: 1.0, position: .bottom)
                        }
                    }
                }catch {
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                    }
                }
            }*/
            
            
        }
        task.resume()
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
                self.productImage.image = UIImage(data: data)
            }
        }
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
    
    @IBAction func copyBtnTapped(_ sender:UIButton) {
        
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
    
    @IBAction func buySmartPhoneBtnTapped(_ sender:UIButton) {
        
        if (isSynced){
            
            if let url = URL(string: "https://nayapurano.shop/") {
                UIApplication.shared.open(url)
            }
            
        }else{
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please wait for the results to sync to the server!"), duration: 2.0, position: .bottom)
            }
            
        }
                
    }
    
    @IBAction func restartTestsBtnClicked(_ sender: UIButton) {
        
        if (self.isSynced) {
            
            self.ShowRestartPopUp()
            
        }else{
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please wait for the results to sync to the server!"), duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    @IBAction func uploadIdBtnClicked(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "UPLOAD ID") {
            
            if (isSynced){
                let camera = DKCamera()
                camera.didCancel = {
                    self.dismiss(animated: true, completion: nil)
                }
                camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
                    self.dismiss(animated: true, completion: nil)
                    let newImage = self.resizeImage(image: image ?? UIImage(), newWidth: 800)
                    
                    
                    let backgroundImage = newImage
                    let watermarkImage = #imageLiteral(resourceName: "watermark")
                    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
                    backgroundImage.draw(in: CGRect(x: 0.0, y: 0.0, width: backgroundImage.size.width, height: backgroundImage.size.height))
                    watermarkImage.draw(in: CGRect(x: 0, y: 0, width: watermarkImage.size.width, height: backgroundImage.size.height))
                    
                    
                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let imageData:NSData = UIImagePNGRepresentation(result ?? newImage) as! NSData
                    
                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)

                    var request = URLRequest(url: URL(string: "\(AppBaseUrl)/idProof")!)
                    
                    request.httpMethod = "POST"
                    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                    
                    let customerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
                    let postString = "customerId=\(customerId)&orderId=\(self.orderId)&photo=\(strBase64)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
                    
                    //print("idProof url is :",request,"\nParam is :",postString)
                    print("idProof url is :",request,"\nParam is :")
                    
                    //SwiftSpinner.show("")
                    self.hud.textLabel.text = ""
                    self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                    self.hud.show(in: self.view)

                    request.httpBody = postString.data(using: .utf8)
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        
                        //let respjson = try? JSON(data: data ?? Data())
                        //print("respjson",respjson ?? "nothing")
                        
                        DispatchQueue.main.async {
                            self.hud.dismiss()
                        }
                        
                        guard let dataThis = data, error == nil else {
                            
                            DispatchQueue.main.async() {
                                self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                            }
                            
                            /* SAMEER-14/6/22
                            do{
                                let json = try JSON(data: data ?? Data())
                                print(" idProof Error Response is:", json)
                                
                                let msg = json["msg"].string
                                DispatchQueue.main.async() {
                                    self.view.makeToast(msg, duration: 3.0, position: .bottom)
                                }
                            }catch {
                                DispatchQueue.main.async() {
                                    self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                                }
                            }*/
                          
                            return
                        }
                        
                        //* SAMEER-14/6/22
                        do {
                            let json = try JSON(data: dataThis)
                            if json["status"] == "Success" {
                                
                                DispatchQueue.main.async() {
                                    //self.uploadIdBtn.setTitle(self.getLocalizatioStringValue(key: "Back to home"), for: .normal)
                                    self.view.makeToast(self.getLocalizatioStringValue(key: "Photo Id uploaded successfully!"), duration: 1.0, position: .bottom)
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
                        
                        
                        /* SAMEER-14/6/22
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           //
                            //SwiftSpinner.hide()
                            
                            do{
                                let json = try JSON(data: data ?? Data())
                                print(" idProof Error Response is:", json)
                                
                                let msg = json["msg"].string
                                DispatchQueue.main.async() {
                                    self.view.makeToast(msg, duration: 3.0, position: .bottom)
                                }
                            }catch {
                                DispatchQueue.main.async() {
                                    self.view.makeToast("JSON Exception", duration: 3.0, position: .bottom)
                                }
                            }
                            
                            //DispatchQueue.main.async {
                                //self.hud.dismiss()
                                // check for http errors
                            //}

                        } else{
                            DispatchQueue.main.async {
                                //SwiftSpinner.hide()
                                self.hud.dismiss()
                                
                                do {
                                    let resp = try (JSONSerialization.jsonObject(with: dataThis, options: []) as? [String:Any] ?? [:])
                                    print(" Form Response is:", resp)
                                }catch let error as NSError {
                                    print(error)
                                    self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                                }
                                
                                self.view.makeToast("Photo Id uploaded successfully!", duration: 1.0, position: .bottom)
                                
                            }

                        }*/

                    }

                    task.resume()
                }
                self.present(camera, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please wait for the results to sync to the server!"), duration: 2.0, position: .bottom)
                }
            }
            
        }else {
            
            hardwareQuestionsCount = 0
            AppQuestionIndex = -1
            AppResultString = ""
            
            // Navigate to home page
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            appDel.window!.rootViewController = centerVC
            appDel.window!.makeKeyAndVisible()
           
        }
        
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
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let centerVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                appDel.window!.rootViewController = centerVC
                appDel.window!.makeKeyAndVisible()
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTableViewHeightConstraint: NSLayoutConstraint!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Num: \(indexPath.row)")
        //print("Value: \(self.myArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.myArray.count
        
        return self.arrFinalData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        //cell.textLabel!.text = "\(self.myArray[indexPath.row])"
        //cell.textLabel?.sizeToFit()
        //cell.textLabel?.layoutIfNeeded()
        //return cell
        
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let lblTitle : UILabel = cell.viewWithTag(10) as! UILabel
        let lblSubTitle : UILabel = cell.viewWithTag(20) as! UILabel
        
        let str = self.myArray[indexPath.row]
        let arrStr = str.components(separatedBy: ":")
        
        lblTitle.text = arrStr[0]
        lblSubTitle.text = arrStr[1]
        */
        
        
        let QuestAnsrTblCell = tableView.dequeueReusableCell(withIdentifier: "QuestAnsrTblCell", for: indexPath) as! QuestAnsrTblCell
        
        let finalDict = self.arrFinalData[indexPath.row]
        
        QuestAnsrTblCell.lblQuestion.text = self.getLocalizatioStringValue(key: finalDict.keys.first ?? "")
        QuestAnsrTblCell.lblAnswer.text = self.getLocalizatioStringValue(key: finalDict.values.first as? String ?? "")
        
        if (indexPath.row == self.arrFinalData.count - 1) {
            QuestAnsrTblCell.lblSeperator.isHidden = true
        }else {
            QuestAnsrTblCell.lblSeperator.isHidden = false
        }
        
        
        return QuestAnsrTblCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func removeDuplicate(list: [[String:Any]]) -> [[String:Any]] {
        var alreadyKnowKeys: [String] = []
        var newArray: [[String:Any]] = []

        list.forEach { (item) in
            if let key = item.keys.first {
                if !alreadyKnowKeys.contains(key) {
                    newArray.append(item)
                    alreadyKnowKeys.append(key)
                }
            }

        }

        return newArray
    }
    
    func createPhysicalDataTableUsingFinalArray() {
                        
        print("self.arrQuestionAnswerFinalData is : ", self.arrQuestionAnswerFinalData)
        
        for dict in self.arrQuestionAnswerFinalData {
            let key = dict.keys.first
            let val = dict.values.first
            
            if (key != "" && (val as? String ?? "") != "") {
                self.arrFinalData.append(dict)
                print("self.arrFinalData", self.arrFinalData)
            }
        }
        
        
        
        let arrRemoveDuplicate = self.removeDuplicate(list: self.arrFinalData)
        self.arrFinalData = []
        self.arrFinalData = arrRemoveDuplicate
        
        
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.reloadData()
        
    }
    
    func combineAllAppCodeForServerSend() {
        
        let appCodeS = UserDefaults.standard.string(forKey: "appCodes") ?? ""
        let apps = appCodeS.split(separator: ";")
        print("apps are :",apps)
        
        var appCodestring = ""
        
        /*
        if (!UserDefaults.standard.bool(forKey: "deadPixel") && apps[1] != "SBRK01"){
            apps[1] = "SPTS03"
        }
        
        if (!UserDefaults.standard.bool(forKey: "screen") && apps[1] != "SBRK01"){
            apps[1] = "SBRK01"
        }
        
        appCodestr = "\(apps[0]);\(apps[1])"
        */
        
        
        /*
        if (!UserDefaults.standard.bool(forKey: "deadPixel") && apps[1] != "SBRK01"){
            appCodestring = "\(appCodestring);SPTS03"
        }
        
        if (!UserDefaults.standard.bool(forKey: "screen") && apps[1] != "SBRK01"){
            appCodestring = "\(appCodestring);SBRK01"
        }
        */
        
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
        
        /*
        print(apps[0])
        for item in apps {
            print(item)
            if item != apps[0] && item != apps[1] {
                appCodestr = "\(appCodestr);\(item)"
            }
            print(appCodestr)
        }
        */
        
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
    
    
    func createTableUsingMyArray() {
                
        let appCodeS = UserDefaults.standard.string(forKey: "appCodes") ?? ""
        
        var functional = "Functional Issue: "
        //var start = 0;
        
        //MARK: Ist
        var l = UserDefaults.standard.string(forKey: "lcd") ?? ""
        
        if (appCodeS.contains("SPTS01")) {
            //l = "flawless".localized
            l = "Flawless"
        }
        if(appCodeS.contains("SPTS02")) {
            //l = "Minor_Scratches".localized
            l = "2-3 Minor Scratches"
        }
        if(appCodeS.contains("SPTS03")) {
            //l = "Heavily_Scratched".localized
            l = "Heavily Scratched"
        }
        if(appCodeS.contains("SPTS04")) {
            //l = "cracked".localized
            l = "Cracked"
        }
        if(appCodeS.contains("SBRK01")) {
            //l = "Not_Working".localized
            l = "Not Working"
        }
        
        //let lc = "lcd".localized
        let lc = "LCD/Screen Glass"
        let lcd = "\(lc) : \(l)"
        
        
        //MARK: 2nd
        //let db = "device_body".localized
        let db = "Device Body"
    
        var b = UserDefaults.standard.string(forKey: "back") ?? ""
        print("devie body: \(b)")
        
        if(appCodeS.contains("CPBP01")){
            //b = "flawless".localized
            b = "Flawless"
        }
        if(appCodeS.contains("CPBP02")){
            //b = "Minor_Scratches".localized
            b = "2-3 Minor Scratches"
        }
        if(appCodeS.contains("CPBP03")){
            //b = "Heavily_Scratched".localized
            b = "Heavily Scratched"
        }
        if(appCodeS.contains("CPBP05")){
            //b = "cracked".localized
            b = "Cracked"
        }
        if(appCodeS.contains("CPBP04")){
            //b = "Dented".localized
            b = "Dented"
        }
                
        let body = "\(db) : \(b)"
        
        
        var myarray: Array = [lcd, body]
        
        if (!UserDefaults.standard.bool(forKey: "rotation")){
            //functional = "rotation_info".localized
            
            functional = "Auto Roatation : Defective"
            myarray.append(functional)
        }
        
        if ((!UserDefaults.standard.bool(forKey: "proximity"))){
            //functional = "Proximity_info".localized
            
            functional = "Proximity Sensor : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "volume")){
            //functional = "hardware_info".localized
            
            functional = "Hardware Buttons : Defective"
            myarray.append(functional)
        }
        
        /*
        if (!UserDefaults.standard.bool(forKey: "connection")){
            //functional = "Wifi_info".localized
         
            functional = "WIFI: Defective"
            myarray.append(functional)
        }
        */
 
        /* MARK: Ajay told to Remove both test on 27/3/23
        if (!UserDefaults.standard.bool(forKey: "earphone")){
            //functional = "earphone_info".localized
            
            functional = "Earphone Jack : Defective"
            myarray.append(functional)
        }

        if (!UserDefaults.standard.bool(forKey: "charger")){
            //functional = "charger_info".localized
            
            functional = "Device Charger : Defective"
            myarray.append(functional)
        }
        */
        
        if (!UserDefaults.standard.bool(forKey: "camera")){
            //functional = "camera_info".localized
            
            functional = "Camera : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "fingerprint")){
            //functional = "fingerprint_info".localized
            
            functional = "Device Biometrics : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "WIFI")){
            //functional = "wifi_info".localized
            
            functional = "WIFI : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "GSM")) {
            //functional = "gsm_info".localized
            
            functional = "GSM : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            //functional = "bluetooth_info".localized
            
            functional = "Bluetooth : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "GPS")) {
            //functional = "gps_info".localized
            
            functional = "GPS : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "mic")){
            //functional = "mic_info".localized
            
            functional = "Microphone : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Speakers")) {
            //functional = "speakers_info".localized
            
            functional = "Speakers : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Vibrator")) {
            //functional = "vibrator_info".localized
            
            functional = "Vibrator : Defective"
            myarray.append(functional)
        }
        
        /*
        if(!UserDefaults.standard.bool(forKey: "NFC")) {
            //functional = "nfc_info".localized
         
         functional = "nfc_info".localized
            myarray.append(functional)
        }
        */
        
        self.myArray = myarray
        print("self.myArray is : ", self.myArray)
        
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        self.myTableView.reloadData()
        
    }
    
    
}

