//
//  ViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 15/02/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import Luminous
import QRCodeReader
import SwiftyJSON
import Toast_Swift
//import Sparrow
//import Crashlytics
import JGProgressHUD
import FirebaseDatabase
import MessageUI
import CoreTelephony

class HomeVC: UIViewController, QRCodeReaderViewControllerDelegate {
    
    let reachability: Reachability? = Reachability()
    let hud = JGProgressHUD()
    var arrStoreUrlData = [StoreUrlData]()
    var IMEINumber = String()
    
    @IBOutlet weak var gradientBGView: UIView!
    
    @IBOutlet weak var shadowBtmView: UIView!
    @IBOutlet weak var deviceMismatchView: UIView!
    @IBOutlet weak var deviceMismatchViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblMismatch: UILabel!
    
    @IBOutlet weak var noDeviceView: UIView!
    @IBOutlet weak var noDeviceImgVW: UIImageView!
    @IBOutlet weak var lblNoDeviceName: UILabel!
    @IBOutlet weak var lblNoDeviceIMEI: UILabel!
    
    @IBOutlet weak var deviceNotBuyView: UIView!
    @IBOutlet weak var deviceNotBuyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbldeviceNotBuy: UILabel!
    
    @IBOutlet weak var notifyView: UIView!
    @IBOutlet weak var txtFieldEmailToNotify: UITextField!
    
    @IBOutlet weak var qrBaseView: UIView!
    @IBOutlet weak var shadowBtmView2: UIView!
        
    @IBOutlet weak var storeTokenEdit: UITextField!
    @IBOutlet weak var submitStoreBtn: UIButton!
    @IBOutlet weak var scanQRBtn: UIButton!
    
    @IBOutlet weak var currentDeviceImgVW: UIImageView!
    @IBOutlet weak var lblCurrentDeviceName: UILabel!
    @IBOutlet weak var imeiLabel: UILabel!
    
    //@IBOutlet weak var lblPleaseClick: UILabel!
    //@IBOutlet weak var lblImeiSerial: UILabel!
    //@IBOutlet weak var previousBtn: UIButton!
    //@IBOutlet weak var findNearByBtn: UIButton!
    //@IBOutlet weak var lblCurrentVersion: UILabel!
    //@IBOutlet weak var storeImage: UIImageView!
    //@IBOutlet weak var smartExLoadingImage: UIImageView!
    //@IBOutlet weak var retryBtn: UIButton!
    //@IBOutlet weak var tradeInOnlineBtn: UIButton!
    
    
    var productId: String = ""
    var appCodes: String = ""
    var storeToken: String = ""
    var hasScanned = false
    
    var arrCountrylanguages = [CountryLanguages]()
    var isLanguageMatchAtLaunch = false
    
    //@IBOutlet weak var floatTableView: UITableView!
    //@IBOutlet weak var floatTableViewHeightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var btnFloating: UIButton!
    //@IBOutlet weak var FloatBGView: UIView!
    
    var touchGest = UITapGestureRecognizer()
    var floatingItemsArrayIN:[String] = ["Call","Mail","Chat"]
    var floatingImageArrayIN:[UIImage] = [#imageLiteral(resourceName: "callSupport"),#imageLiteral(resourceName: "mailSupport"),#imageLiteral(resourceName: "chatSupport")]
        
    
    //var endPoint = "https://exchange.getinstacash.in/stores-asia/api/v1/public/"
    //var endPoint = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.UISetUp()            
            self.getProductIdCurrentDeviceWebServiceCall()
        }
        
        //self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        
        //MARK: Commemt on 15/12/22 due to no use
        //self.fetchStoreDataFromFirebase()
        
        //self.submitStoreBtn.isHidden = true
        //self.storeTokenEdit.isHidden = true
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            
            if (key != "imei_number"){
                if (key != "App_ApiKey"){
                    if (key != "App_UserName"){
                        if (key != "App_BaseURL"){
                            if (key != "App_TncUrl"){
                                
                                
                                if (key != "userChangeLanguage") {
                                    if (key != "AppCurrentLanguage") {
                                        if (key != "AppLanguage") {
                                            
                                            
                                            if (key != "LanguageName") {
                                                if (key != "LanguageVersion") {
                                                    if (key != "LanguageSymbol") {
                                                        if (key != "LanguageUrl") {
                                                            
                                                            //print("key to remove from userDefaults",key)
                                                            defaults.removeObject(forKey: key)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            
            defaults.synchronize()
        }
        
        self.hideKeyboardWhenTappedAround()
        
        
        let currentIMEI = UserDefaults.standard.string(forKey: "imei_number") ?? IMEINumber
        imeiLabel.text = "Your IMEI:" + IMEINumber
        imeiLabel.text = "Your IMEI:" + currentIMEI
        
        imeiLabel.text = currentIMEI
        
        /*
         let boxBoldText = currentIMEI
         let attrsBox = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
         let boxAttributedString = NSMutableAttributedString(string: boxBoldText, attributes: attrsBox)
         let boxNormalText = "Your IMEI: "
         let boxNormalString = NSMutableAttributedString(string: boxNormalText)
         boxNormalString.append(boxAttributedString)
         self.imeiLabel.attributedText = boxNormalString
         */
        
        
        let uuid = UUID().uuidString
        print(uuid)
        
        //smartExLoadingImage.isHidden = true
        //floatTableView.register(UINib(nibName: "FloatingItemCell", bundle: nil), forCellReuseIdentifier: "FloatingItemCell")
        
        
        /*
         if reachability?.connection.description != "No Connection" {
         
         self.fireWebServiceForSupportDetails()
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
         
         self.downloadFirebaseRealTimeData()
         
         })
         
         
         }else {
         
         DispatchQueue.main.async() {
         self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
         }
         
         }
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable the left swipe gesture to dismiss
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
        
        //touchGest = UITapGestureRecognizer(target: self, action: #selector(HomeVC.myviewTapped(_:)))
        //touchGest.numberOfTapsRequired = 1
        //touchGest.numberOfTouchesRequired = 1
        //FloatBGView.addGestureRecognizer(touchGest)
        //FloatBGView.isUserInteractionEnabled = true
        
        ////self.changeLanguageOfUI()
    }
    
    
    
    func UISetUp() {
        
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async(execute: {
            
            self.gradientBGView.cornerRadius(usingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 50.0, height: 50.0))
            UIView.addShadowOn4side(baseView: self.shadowBtmView)
            UIView.addShadowOn4side(baseView: self.shadowBtmView2)
        })
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    func changeLanguageOfUI() {
        
        //self.lblPleaseClick.text = self.getLocalizatioStringValue(key: "Please click ‘Scan QR Code’ to begin Diagnostics. To view previous results, click on ‘Previous Quotation’")
        
        self.storeTokenEdit.placeholder = self.getLocalizatioStringValue(key: "Find Nearby Store to get Store Token")
        self.submitStoreBtn.setTitle(self.getLocalizatioStringValue(key: "Submit"), for: .normal)
        
        //self.lblImeiSerial.text = self.getLocalizatioStringValue(key: "IMEI/Serial:")
        
        self.scanQRBtn.setTitle(self.getLocalizatioStringValue(key: "SCAN QR CODE"), for: .normal)
        //self.previousBtn.setTitle(self.getLocalizatioStringValue(key: "PREVIOUS QUOTATION"), for: .normal)
        //self.findNearByBtn.setTitle(self.getLocalizatioStringValue(key: "FIND NEARBY STORE"), for: .normal)
        
        //self.lblCurrentVersion.text = self.getLocalizatioStringValue(key: "Version") + " " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         if !SPRequestPermission.isAllowPermissions([.camera,.locationWhenInUse,.microphone,.photoLibrary]){
         SPRequestPermission.dialog.interactive.present(on: self, with: [.camera,.microphone,.photoLibrary,.locationWhenInUse], dataSource: DataSource())
         }
         */
        
    }
    
    func getProductIdCurrentDeviceWebServiceCall() {
        
        //IMEINumber parameter add
        
        //isMatch = 1 to thik h
        //if 0 aata h & data bhi aata h mismatch wala popop
        //if 0 & no data then we're not buying
        //if -1 aata h & data aata h to no thing to do/ no pop
        //if -1 aata h & data nahi aata h to not buying wala popup
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/getProductIdCurrentDevice")!)
        
        let preferences = UserDefaults.standard
        preferences.set(AppBaseUrl, forKey: "endpoint")
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let deviceName = UIDevice.current.moName
        let modelCapacity = getTotalSize()
        let IMEI = UserDefaults.standard.string(forKey: "imei_number") ?? IMEINumber
        let ram =  ProcessInfo.processInfo.physicalMemory
        
        var postString = ""
        
        // not iPad (iPhone, mac, tv, carPlay, unspecified)
        postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&productName=\(deviceName)&memory=\(modelCapacity)&ram=\(ram)&IMEINumber=\(IMEI)"
        
        print("url in getProductIdCurrentDevice :", request,"\n Param in getProductIdCurrentDevice:", postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                return
            }
            
            do {
                let json = try JSON(data: data)
                print("response json in  getProductIdCurrentDevice:","\(json)")
                
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        
                        var currentDeviceData = json["msg"].dictionary
                        var isIMEIMatch = json["isIMEIMatch"].int
                        
                        //isIMEIMatch = -1
                        //currentDeviceData = nil
                                                
                        let imgurl = URL(string: currentDeviceData?["image"]?.string ?? "")
                        self.currentDeviceImgVW.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "phone_Placeholder"))
                        
                        self.lblCurrentDeviceName.text = currentDeviceData?["name"]?.string ?? ""
                        self.imeiLabel.text = IMEI
                        
                        self.noDeviceImgVW.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "phone_Placeholder"))
                        
                        
                        if let matchValue = isIMEIMatch {
                            
                            if matchValue == 1 {
                                
                                //Nothing to do here
                                
                            }
                            else if matchValue == 0 {
                                
                                if currentDeviceData != nil {
                                    //if 0 aata h & data bhi aata h mismatch wala popop
                                    
                                    UIView.animate(withDuration: 0.2) {
                                        self.deviceMismatchViewHeightConstraint.constant = 30
                                        self.lblMismatch.text = "Device Mismatch Found"
                                    } completion: { _ in
                                            
                                        DispatchQueue.main.async {
                                            self.deviceMismatchView.cornerRadius(usingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
                                            self.shadowBtmView.layer.shadowPath = UIBezierPath(rect: self.shadowBtmView.bounds).cgPath
                                        }
                                        
                                    }
                                    
                                }
                                else {
                                    //if 0 & no data then we're not buying
                                    
                                    DispatchQueue.main.async() {
                                        
                                        self.noDeviceView.isHidden = false
                                        self.notifyView.isHidden = false
                                        self.shadowBtmView.isHidden = true
                                        self.qrBaseView.isHidden = true
                                        
                                        UIView.addShadowOn4side(baseView: self.noDeviceView)
                                        UIView.addShadowOn4side(baseView: self.notifyView)
                                        
                                        self.lblNoDeviceName.text = deviceName
                                        self.lblNoDeviceIMEI.text = String(IMEI.suffix(4))
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                            
                                            UIView.animate(withDuration: 0.2) {
                                                self.deviceNotBuyViewHeightConstraint.constant = 30
                                                self.lbldeviceNotBuy.text = "We're Not Buying This Device Yet"
                                            } completion: { _ in
                                                
                                                DispatchQueue.main.async {
                                                    self.deviceNotBuyView.cornerRadius(usingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
                                                    self.noDeviceView.layer.shadowPath = UIBezierPath(rect: self.noDeviceView.bounds).cgPath
                                                }
                                                
                                            }
                                            
                                        })
                                        
                                    }
                                    
                                                                        
                                }
                                
                            }
                            else if matchValue == -1 {
                                
                                if currentDeviceData != nil {
                                    
                                    //if -1 aata h & data aata h to no thing to do/ no pop
                                    
                                }
                                else {
                                    //if -1 aata h & data nahi aata h to not buying wala popup
                                    
                                    DispatchQueue.main.async() {
                                        
                                        self.noDeviceView.isHidden = false
                                        self.notifyView.isHidden = false
                                        self.shadowBtmView.isHidden = true
                                        self.qrBaseView.isHidden = true
                                        
                                        UIView.addShadowOn4side(baseView: self.noDeviceView)
                                        UIView.addShadowOn4side(baseView: self.notifyView)
                                        
                                        self.lblNoDeviceName.text = deviceName
                                        self.lblNoDeviceIMEI.text = String(IMEI.suffix(4))

                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        
                                        UIView.animate(withDuration: 0.2) {
                                            self.deviceNotBuyViewHeightConstraint.constant = 30
                                            self.lbldeviceNotBuy.text = "We're Not Buying This Device Yet"
                                        } completion: { _ in
                                                
                                            DispatchQueue.main.async {
                                                self.deviceNotBuyView.cornerRadius(usingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
                                                self.noDeviceView.layer.shadowPath = UIBezierPath(rect: self.noDeviceView.bounds).cgPath
                                            }
                                            
                                        }
                                        
                                    })
                                                                        
                                    
                                }
                                
                            }
                            else {
                                
                            }
                            
                        }
                                                                                                    
                        
                    }
                    
                }else{
                   
                    DispatchQueue.main.async() {
                        
                        self.view.makeToast(self.getLocalizatioStringValue(key: json["msg"].string ?? ""), duration: 2.0, position: .bottom)
                        
                        self.noDeviceView.isHidden = false
                        self.shadowBtmView.isHidden = true
                        self.qrBaseView.isHidden = true
                        
                        UIView.addShadowOn4side(baseView: self.noDeviceView)
                        
                        self.lblNoDeviceName.text = "Your Device: " + deviceName
                        self.lblNoDeviceIMEI.text = "Your IMEI: " + IMEI
                        
                    }
                    
                }
                
                
                /* To hide on 6/2/25 as after discuss with Ajay on call
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        
                        let currentDeviceData = json["msg"]
                        
                        let imgurl = URL(string: currentDeviceData["image"].string ?? "")
                        self.currentDeviceImgVW.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "smartphone"))
                        
                        self.lblCurrentDeviceName.text = currentDeviceData["name"].string ?? ""
                        self.imeiLabel.text = IMEI
                        
                    }
                    
                }else{
                   
                    DispatchQueue.main.async() {
                        
                        self.view.makeToast(self.getLocalizatioStringValue(key: json["msg"].string ?? ""), duration: 2.0, position: .bottom)
                        
                        self.noDeviceView.isHidden = false
                        self.shadowBtmView.isHidden = true
                        self.qrBaseView.isHidden = true
                        
                        UIView.addShadowOn4side(baseView: self.noDeviceView)
                        
                        self.lblNoDeviceName.text = "Your Device: " + deviceName
                        self.lblNoDeviceIMEI.text = "Your IMEI: " + IMEI
                        
                    }
                    
                }
                */
                
            }catch {
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 3.0, position: .bottom)
                }
            }
            
        }
        task.resume()
    }
    
    func emailSubscribeForNewModelApiCall() {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
                        
        let preferences = UserDefaults.standard
        preferences.set(AppBaseUrl, forKey: "endpoint")
        
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/emailSubscribeForNewModel")!)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                
        let IMEI = UserDefaults.standard.string(forKey: "imei_number") ?? IMEINumber
        let notiEmail = self.txtFieldEmailToNotify.text ?? ""
        
        var postString = ""
        
        // not iPad (iPhone, mac, tv, carPlay, unspecified)
        postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&email=\(notiEmail)&IMEINumber=\(IMEI)"
        
        print("url in emailSubscribeForNewModel :", request,"\n Param in emailSubscribeForNewModel:", postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                return
            }
            
            do {
                let json = try JSON(data: data)
                print("response json in  emailSubscribeForNewModel:","\(json)")
                
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: json["msg"].string ?? ""), duration: 2.0, position: .bottom)
                    }
                    
                }else{
                   
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: json["msg"].string ?? ""), duration: 2.0, position: .bottom)
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK: button action methods
    @IBAction func notifyBtnClicked(_ sender: UIButton) {
        
        if self.txtFieldEmailToNotify.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a email Id"), duration: 2.0, position: .bottom)
            }
            
        }
        else if !self.isValidEmail(self.txtFieldEmailToNotify.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a valid email Id"), duration: 2.0, position: .bottom)
            }
            
        }
        else {
            
            self.emailSubscribeForNewModelApiCall()
            
        }
        
    }
    
    @IBAction func imeiChangeBtnClicked(_ sender: UIButton) {
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImeiFetchVC") as! ImeiFetchVC
        vc.isComeFrom = "ImeiFetchVC"
        self.navigationController?.pushViewController(vc, animated: true)
        
        

        /*
        if sender.isSelected {
            sender.isSelected = !sender.isSelected
            
            UIView.animate(withDuration: 0.2) {
                self.deviceMismatchViewHeightConstraint.constant = 0
            } completion: { _ in
                
                DispatchQueue.main.async {
                    self.shadowBtmView.layer.shadowPath = UIBezierPath(rect: self.shadowBtmView.bounds).cgPath
                }
                
            }
                       
        }
        else {
            sender.isSelected = !sender.isSelected
            
            UIView.animate(withDuration: 0.2) {
                self.deviceMismatchViewHeightConstraint.constant = 30
            } completion: { _ in
                    
                DispatchQueue.main.async {
                    self.deviceMismatchView.cornerRadius(usingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
                    self.shadowBtmView.layer.shadowPath = UIBezierPath(rect: self.shadowBtmView.bounds).cgPath
                }
                
            }
                       
        }
        */
        
    }
    
    @IBAction func howToFindQRBtnClicked(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindQRPopUpVC") as! FindQRPopUpVC
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
        
    }
    
    @IBAction func onClickCustomSupport(_ sender: UIButton) {
        /*
         if sender.isSelected {
         sender.isSelected = !sender.isSelected
         
         self.floatTableView.alpha = 1
         UIView.animate(withDuration: 0.3, animations: {
         self.floatTableViewHeightConstraint.constant = 0.0
         self.view.layoutIfNeeded()
         self.floatTableView.alpha = 0
         self.FloatBGView.isHidden = true
         })
         }else {
         sender.isSelected = !sender.isSelected
         
         self.floatTableView.alpha = 0
         UIView.animate(withDuration: 0.3, animations: {
         
         self.floatTableViewHeightConstraint.constant = 150.0
         
         self.view.layoutIfNeeded()
         self.floatTableView.alpha = 1
         self.FloatBGView.isHidden = false
         })
         }
         */
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        /*
         btnFloating.isSelected = !btnFloating.isSelected
         
         self.floatTableView.alpha = 1
         UIView.animate(withDuration: 0.3, animations: {
         self.floatTableViewHeightConstraint.constant = 0.0
         self.view.layoutIfNeeded()
         self.floatTableView.alpha = 0
         self.FloatBGView.isHidden = true
         })
         */
    }
    
    func fetchStoreDataFromFirebase() {
        
        if reachability?.connection.description != "No Connection" {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            StoreUrlData.fetchStoreUrlsFromFireBase(isInterNet: true, getController: self) { (storeData) in
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                if storeData.count > 0 {
                    
                    self.arrStoreUrlData = storeData
                    
                }else {
                    //DispatchQueue.main.async() {
                    //self.view.makeToast("No Data Found".localized, duration: 2.0, position: .bottom)
                    //}
                }
                
            }
            
        }else {
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    var responseData = " "
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader          = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - checkScanPermissions
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: self.getLocalizatioStringValue(key: "Error"), message: self.getLocalizatioStringValue(key: "This app is not authorized to use Back Camera."), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: self.getLocalizatioStringValue(key: "Setting"), style: .default, handler: { (_) in
                    
                    DispatchQueue.main.async {
                        
                        /*
                         if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                         UIApplication.shared.openURL(settingsURL)
                         }*/
                        
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                
                                UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                                    
                                }
                                
                            } else {
                                // Fallback on earlier versions
                                
                                UIApplication.shared.openURL(settingsUrl)
                            }
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .cancel, handler: nil))
                
            default:
                alert = UIAlertController(title: self.getLocalizatioStringValue(key: "Error"), message: self.getLocalizatioStringValue(key: "Reader not supported by the current device"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: self.getLocalizatioStringValue(key: "OK"), style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    @IBAction func submitStoreToken(_ sender: Any) {
        
        if self.storeTokenEdit.text?.isEmpty ?? false {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Token"), duration: 2.0, position: .bottom)
            }
            
        }else if (self.storeTokenEdit.text?.count ?? 0) < 4 {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Valid Token"), duration: 2.0, position: .bottom)
            }
            
        }
        
        /* //MARK: Commemt on 15/12/22 due to no use
         else {
         self.fireWebServiceForQuoteId(quoteID: self.storeTokenEdit.text ?? "")
         }
         
         return
         */
        
        else {
            
            self.storeToken = String(self.storeTokenEdit.text ?? "0")
            
            if self.storeToken.count >= 4 {
                
                print("self.storeToken submit", self.storeToken)
                
                /* //MARK: Commemt on 15/12/22 due to no use
                 let enteredToken = self.storeToken.prefix(4)
                 
                 for tokens in self.arrStoreUrlData {
                 if tokens.strPrefixKey == enteredToken {
                 
                 self.endPoint = tokens.strUrl
                 print("self.endPoint submit", self.endPoint)
                 
                 let preferences = UserDefaults.standard
                 preferences.setValue(tokens.strTnc, forKey: "tncendpoint")
                 preferences.setValue(tokens.strType, forKey: "storeType")
                 preferences.setValue(tokens.strIsTradeOnline, forKey: "tradeOnline")
                 
                 self.verifyUserSmartCode()
                 
                 UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                 
                 //break
                 return
                 }
                 }*/
                
                                
                let preferences = UserDefaults.standard
                preferences.setValue(AppBaseTnc, forKey: "tncendpoint")
                
                preferences.setValue(0, forKey: "storeType")
                preferences.setValue(0, forKey: "tradeOnline")
                
                if reachability?.connection.description != "No Connection" {
                    
                    self.verifyUserSmartCode()
                    
                }else {
                    
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
                    }
                }
                
                //MARK: Commemt on 15/12/22 due to no use
                //UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                
            }else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Valid Store Token"), duration: 2.0, position: .bottom)
                }
                
            }
            
        }
        
    }
    
    func verifyUrl (urlString: String?) -> Bool {
       if let urlString = urlString {
           if let url  = URL(string: urlString) {
               return UIApplication.shared.canOpenURL(url)
           }
       }
       return false
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        
        self.hasScanned = !self.hasScanned
        
        DispatchQueue.main.async {
            
            guard self.checkScanPermissions() else { return }
            
            //self.readerVC.modalPresentationStyle = .formSheet
            self.readerVC.modalPresentationStyle = .overFullScreen
            self.readerVC.delegate               = self
            
            self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                if let result = result {
                    
                    let completeResult = String(result.value)
                    print("completeResult is:-",completeResult)
                    
                    guard self.hasScanned else {
                        return
                    }
                    
                    self.hasScanned = !self.hasScanned
                    
                    /*
                     if self.hasScanned {
                     print("self.hasScanned = !self.hasScanned", self.hasScanned)
                     self.hasScanned = !self.hasScanned
                     self.fireWebServiceForQuoteId(quoteID: completeResult)
                     }
                     
                     return
                     */
                    
                    if self.verifyUrl(urlString: completeResult) {
                        
                        let token = self.getQueryStringParameter(url: completeResult, param: "storeToken")
                        //print("tokenvaa ...",token ?? "")
                        self.storeToken = token ?? ""
                        self.productId = ""
                        self.appCodes = ""
                    }
                    else {
                        
                        let values = completeResult.components(separatedBy: "@@@")
                        print(values)
                        
                        if values.count > 2 {
                            
                            self.storeToken = String(values[0])
                            self.productId = values[1]
                            self.appCodes = values[2]
                            
                        }else{
                            
                            self.storeToken = String(values[0])
                            self.productId = ""
                            self.appCodes = ""
                            
                        }
                        
                    }
                
                    
                    if self.storeToken.count >= 4 {
                        print("self.storeToken", self.storeToken)
                        
                        /* //MARK: Commemt on 15/12/22 due to no use
                         let enteredToken = self.storeToken.prefix(4)
                         
                         for tokens in self.arrStoreUrlData {
                         
                         if tokens.strPrefixKey == enteredToken {
                         
                         self.endPoint = tokens.strUrl
                         print("self.endPoint", self.endPoint)
                         
                         let preferences = UserDefaults.standard
                         preferences.setValue(tokens.strTnc, forKey: "tncendpoint")
                         preferences.setValue(tokens.strType, forKey: "storeType")
                         preferences.setValue(tokens.strIsTradeOnline, forKey: "tradeOnline")
                         
                         self.verifyUserSmartCode()
                         
                         UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                         
                         //break
                         return
                         }
                         }*/
                        
                                                
                        let preferences = UserDefaults.standard
                        preferences.setValue(AppBaseTnc, forKey: "tncendpoint")
                        
                        preferences.setValue(0, forKey: "storeType")
                        preferences.setValue(0, forKey: "tradeOnline")
                        
                        
                        if self.reachability?.connection.description != "No Connection" {
                            
                            self.verifyUserSmartCode()
                            
                        }else {
                            DispatchQueue.main.async() {
                                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
                            }
                        }
                        
                        //MARK: Commemt on 15/12/22 due to no use
                        //UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                        
                    }else {
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Store Token Not Valid"), duration: 2.0, position: .bottom)
                        }
                    }
                    
                }
            }
        }
        
        present(readerVC, animated: true, completion: nil)
        
    }
    
    @IBAction func previousQuotationBtnPressed(_ sender: Any) {
        
        /*
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviousQuotationsViewController") as! PreviousQuotationsViewController
         vc.modalPresentationStyle = .overFullScreen
         self.present(vc, animated: true)
         */
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviousQuotePopUp") as! PreviousQuotePopUp
                
        /*
        vc.popupDismiss = { productDict in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviousSessionVC") as! PreviousSessionVC
            vc.sessionDict = productDict
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        */
        
        vc.popupDismiss = { productDict in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalQuotationVC") as! FinalQuotationVC
            vc.isComeFromVC = "HomeVC"
            vc.sessionDict = productDict
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
    }
    
    @IBAction func findNearByStoreBtnPressed(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindStoreVC") as! FindStoreVC
        //self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
    }
    
    func verifyUserSmartCode() {
        
        let device = UIDevice.current.moName
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        var typeOfDevice = ""
        
        if UIDevice.current.model.hasPrefix("iPad") {
            
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier: CTCarrier? = networkInfo.serviceSubscriberCellularProviders?.first?.value
            let code: String? = carrier?.isoCountryCode
            
            if (code != nil) {
                typeOfDevice = "gsm"
            }
            else {
                typeOfDevice = "wifi"
            }
            
        }else {
            typeOfDevice = "gsm"
        }
        
        
        //var request = URLRequest(url: URL(string: "\(self.endPoint)/startSession")!)
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/startSession")!)
        let preferences = UserDefaults.standard
        //preferences.set(self.endPoint, forKey: "endpoint")
        preferences.set(AppBaseUrl, forKey: "endpoint")
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        //let mName = UIDevice.current.modelName
        let modelCapacity = getTotalSize()
        
        //let IMEI = imeiLabel.text
        let IMEI = UserDefaults.standard.string(forKey: "imei_number") ?? IMEINumber
        let ram =  ProcessInfo.processInfo.physicalMemory
        //let ram = 3221223823
        
        var postString = ""
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            // iPad
            //postString = "IMEINumber=\(IMEI ?? "")&device=\("iPhone XR")&memory=\(128)&userName=\(AppUserName)&apiKey=\(AppApiKey)&ram=\(2976153600)&storeToken=\(self.storeToken)"
            
            postString = "IMEINumber=\(IMEI)&device=\(device)&memory=\(modelCapacity)&userName=\(AppUserName)&apiKey=\(AppApiKey)&ram=\(ram)&storeToken=\(self.storeToken)&deviceType=\(typeOfDevice)"
            
        } else {
            
            // not iPad (iPhone, mac, tv, carPlay, unspecified)
            postString = "IMEINumber=\(IMEI)&device=\(device)&memory=\(modelCapacity)&userName=\(AppUserName)&apiKey=\(AppApiKey)&ram=\(ram)&storeToken=\(self.storeToken)&deviceType=\(typeOfDevice)"
        }
                
        print("url is :",request,"\nParam is :", postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
                        
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    print("response json is :","\(json)")
                    
                    let responseString = String(data: data, encoding: .utf8)
                    self.responseData = responseString ?? ""
                    let preferences = UserDefaults.standard
                    var productIdenti = "0"
                    let productData = json["productData"]
                    
                    if productData["id"].string ?? "" != "" {
                        
                        productIdenti = productData["id"].string ?? ""
                        
                        let productName = productData["name"].string ?? ""
                        let productImage = productData["image"].string ?? ""
                        preferences.set(productIdenti, forKey: "product_id")
                        preferences.set("\(productName)", forKey: "productName")
                        preferences.set("\(self.appCodes)", forKey: "appCodes")
                        preferences.set("\(productImage)", forKey: "productImage")
                        
                        preferences.set(json["customerId"].string ?? "", forKey: "customer_id")
                        preferences.set(self.storeToken, forKey: "store_code")
                        let serverData = json["serverData"]
                        print("\n\n\(serverData["currencyJson"])")
                        let jsonEncoder = JSONEncoder()
                        
                        let currencyJSON = serverData["currencyJson"]
                        let jsonData = try jsonEncoder.encode(currencyJSON)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        preferences.set(jsonString, forKey: "currencyJson")
                        let priceData = json["priceData"]
                        let uptoPrice = priceData["msg"].string ?? ""
                        print("uptoPrice", uptoPrice)
                                                
                        //MARK: Comment here & create function for diagnostic flow smooth run on 5/8/23
                        
                        DispatchQueue.main.async() {
                            
                            appDelegate_Obj?.appStoreName = serverData["storeName"].string ?? ""
                            appDelegate_Obj?.appStoreAddress = serverData["storeAddress"].string ?? ""
                            appDelegate_Obj?.appStoreContactNumber = serverData["storeMobileNumber"].string ?? ""
                            let storeGeoCordinate = serverData["geoCoordinates"].string ?? ""
                            let arrStoreGeoCordinate = storeGeoCordinate.components(separatedBy: ",")
                            appDelegate_Obj?.appStoreLatitude = arrStoreGeoCordinate[0]
                            appDelegate_Obj?.appStoreLongitude = arrStoreGeoCordinate[1]
                            
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewInstructionVC") as! NewInstructionVC
                            
                            vc.strIMEI = UserDefaults.standard.string(forKey: "imei_number") ?? self.IMEINumber
                            vc.strDeviceName = productName
                            vc.strDeviceImg = productImage
                            
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(vc, animated: true, completion: nil)
                            
                            //self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                        
                        //self.StartDiagnosticFlow()
                        
                    }else{
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Device not found!"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                    
                }else{
                    
                    DispatchQueue.main.async {
                        
                        //self.view.makeToast(self.getLocalizatioStringValue(key: "Please make sure you've entered the details in the POS."), duration: 2.0, position: .bottom)
                        
                        self.view.makeToast(self.getLocalizatioStringValue(key: json["msg"].stringValue), duration: 2.0, position: .bottom)
                        
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
        
    func StartDiagnosticFlow() {
        
        //MARK: 5/8/23 Add due to diagnose process start from begning
        
        /*
         // 1. DeadPixel Test
         let deadPVC = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelVC") as! DeadPixelVC
         deadPVC.presentDeadPixelTest = { deadPixelResult in
         
         // 2. Screen Calibration Test
         let scrnVC = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
         scrnVC.presentScreenTest = { screenResult in
         
         // 3. AutoRotation Test
         let rotaVC = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
         rotaVC.presentRotationTest = { rotationResult in
         
         // 4. Proximity Test
         let proxiVC = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
         proxiVC.presentProximityTest = { proximityResult in
         
         // 5. Volume Test
         let volumeVC = self.storyboard?.instantiateViewController(withIdentifier: "VolumeRockerVC") as! VolumeRockerVC
         volumeVC.presentVolumeTest = { volumeResult in
         
         // 6. Camera Test
         let CameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
         CameraViewController.presentCameraTest = { cameraResult in
         
         // 7. Biometric Test
         let biometricVC = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
         biometricVC.presentBiometricTest = { biometricResult in
         
         // 8. WiFi Test
         let wifiVC = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
         wifiVC.presentWifiTest = { wifiResult in
         
         // 9. BackGround Test
         let bgVC = self.storyboard?.instantiateViewController(withIdentifier: "InternalTestsVC") as! InternalTestsVC
         bgVC.presentBackgroundTest = { bgResult in
         
         // 10. Result Summary VC
         let summaryVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
         summaryVC.presentDiagnoseResultVC = { summaryResult in
         
         }
         
         summaryVC.resultJSON = bgResult
         self.navigationController?.pushViewController(summaryVC, animated: true)
         
         }
         
         bgVC.resultJSON = wifiResult
         bgVC.modalPresentationStyle = .fullScreen
         self.present(bgVC, animated: true)
         
         }
         
         wifiVC.resultJSON = biometricResult
         wifiVC.modalPresentationStyle = .fullScreen
         self.present(wifiVC, animated: true)
         
         }
         
         biometricVC.resultJSON = cameraResult
         biometricVC.modalPresentationStyle = .fullScreen
         self.present(biometricVC, animated: true)
         
         }
         
         CameraViewController.resultJSON = volumeResult
         CameraViewController.modalPresentationStyle = .fullScreen
         self.present(CameraViewController, animated: true)
         
         }
         
         volumeVC.resultJSON = proximityResult
         volumeVC.modalPresentationStyle = .fullScreen
         self.present(volumeVC, animated: true)
         
         }
         
         proxiVC.resultJSON = rotationResult
         proxiVC.modalPresentationStyle = .fullScreen
         self.present(proxiVC, animated: true)
         
         }
         
         rotaVC.resultJSON = screenResult
         rotaVC.modalPresentationStyle = .fullScreen
         self.present(rotaVC, animated: true)
         
         }
         
         scrnVC.resultJSON = deadPixelResult
         scrnVC.modalPresentationStyle = .fullScreen
         self.present(scrnVC, animated: true, completion: nil)
         
         }
         
         deadPVC.modalPresentationStyle = .fullScreen
         self.present(deadPVC, animated: true, completion: nil)
         */
    }
    
    func getTotalSize() -> Int64 {
        var space: Int64 = 0
        do {
            
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            space = ((systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value)!
            space = space/1000000000
            if space<8 {
                space = 8
            } else if space<16 {
                space = 16
            } else if space<32 {
                space = 32
            } else if space<64 {
                space = 64
            } else if space<128 {
                space = 128
            } else if space<256 {
                space = 256
            } else if space<512 {
                space = 512
            }
            
        } catch {
            space = 0
        }
        return space
    }
    
    // MARK: QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        self.readerVC.dismiss(animated: true)
        
        /*
         reader.dismiss(animated: true) {
         
         }*/
        
        /*
         dismiss(animated: true) { [weak self] in
         //            let alert = UIAlertController(
         //                title: "QRCodeReader",
         //                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
         //                preferredStyle: .alert
         //            )
         //            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
         //
         //            self?.present(alert, animated: true, completion: nil)
         }
         */
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        self.readerVC.dismiss(animated: true)
        
        /*
         reader.dismiss(animated: true) {
         
         }*/
        
        //dismiss(animated: true, completion: nil)
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
                //self.storeImage.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func tradeInOnlineBtnClicked(_ sender: Any) {
        
        let ref = Database.database().reference(withPath: "trade_in_online")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                return
            }
            
            let tempDict = snapshot.value as? NSDictionary
            print(tempDict ?? [:])
            
            DispatchQueue.main.async {
                self.storeToken = (tempDict?.value(forKey: "token") as? String) ?? ""
                
                let preferences = UserDefaults.standard
                preferences.setValue(AppBaseTnc, forKey: "tncendpoint")
                
                self.verifyUserSmartCode()
                
                UserDefaults.standard.setValue(true, forKey: "Trade_In_Online")
            }
            
        })
        
    }
    
    func QuoteIdPost(strURL : String , parameters:NSDictionary, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let web = WebServies()
        web.postRequest(urlString: strURL, paramDict: (parameters as! Dictionary<String, AnyObject>), completionHandler: completionHandler)
    }
    
    func fireWebServiceForQuoteId(quoteID:String)
    {
        var parameters = [String: Any]()
        //let strUrl = "\(self.endPoint)/getQuoteIdData"
        //let strUrl = "https://exchange.buyblynk.com/api/v1/public/getQuoteIdData" // Blynk
        
        let strUrl = AppBaseUrl + "getQuoteIdData"
        
        parameters  = [
            "userName" : AppUserName,
            "apiKey" : AppApiKey,
            "quoteId" : quoteID,
        ]
        
        print("url is :", strUrl, "quote id is  \(quoteID)" , parameters)
        
        //self.smartExLoadingImage.isHidden = false
        //self.smartExLoadingImage.rotate360Degrees()
        
        hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        hud.show(in: self.view)
        
        self.QuoteIdPost(strURL: strUrl, parameters: parameters as NSDictionary, completionHandler: {responseObject , error in
            
            self.hasScanned = !self.hasScanned
            //print(responseObject ?? [:])
            
            DispatchQueue.main.async {
                //self.smartExLoadingImage.layer.removeAllAnimations()
                //self.smartExLoadingImage.isHidden = true
                
                self.hud.dismiss()
            }
            
            if error == nil {
                
                if responseObject?["status"] as? String == "Success" {
                    
                    print(responseObject?["msg"] as? String ?? "")
                    
                    let values = (responseObject?["msg"] as? String ?? "").components(separatedBy: "@@@")
                    print(values)
                    
                    if values.count > 2 {
                        self.storeToken = String(values[0])
                        self.productId = values[1]
                        self.appCodes = values[2]
                    }else{
                        self.storeToken = String(values[0])
                        self.productId = ""
                        self.appCodes = ""
                    }
                    
                    
                    if self.storeToken.count >= 4 {
                        print("self.storeToken", self.storeToken)
                        
                        let enteredToken = self.storeToken.prefix(4)
                        
                        for tokens in self.arrStoreUrlData {
                            if tokens.strPrefixKey == enteredToken {
                                
                                //self.endPoint = tokens.strUrl
                                //print("self.endPoint", self.endPoint)
                                
                                let preferences = UserDefaults.standard
                                preferences.setValue(tokens.strTnc, forKey: "tncendpoint")
                                preferences.setValue(tokens.strType, forKey: "storeType")
                                preferences.setValue(tokens.strIsTradeOnline, forKey: "tradeOnline")
                                
                                self.verifyUserSmartCode()
                                
                                UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                                
                                //break
                                return
                            }
                        }
                        
                        // If Store Token not add in firebase
                        //self.endPoint = "https://exchange.buyblynk.com/api/v1/public" // Blynk
                        
                        
                        
                        let preferences = UserDefaults.standard
                        //preferences.setValue("https://exchange.buyblynk.com/tnc.php", forKey: "tncendpoint") // Blynk
                        
                        preferences.setValue(AppBaseTnc, forKey: "tncendpoint")
                        
                        
                        preferences.setValue(0, forKey: "storeType")
                        preferences.setValue(0, forKey: "tradeOnline")
                        
                        self.verifyUserSmartCode()
                        
                        UserDefaults.standard.setValue(false, forKey: "Trade_In_Online")
                        
                    }else {
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Store Token Not Valid"), duration: 2.0, position: .bottom)
                        }
                    }
                    
                }
                else{
                    
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: responseObject?["msg"] as? String ?? "Error"), duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }
            else
            {
                // check for fundamental networking error
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 2.0, position: .bottom)
                }
                
            }
        })
        
    }
    
    func supportDetailsApiPost(strURL : String , parameters:NSDictionary, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let web = WebServies()
        web.postRequest(urlString: strURL, paramDict: (parameters as! Dictionary<String, AnyObject>), completionHandler: completionHandler)
    }
    
    func fireWebServiceForSupportDetails()
    {
        var parameters = [String: Any]()
        
        let strUrl = AppBaseUrl + "instacashInformation"
        
        parameters  = [
            "userName" : AppUserName,
            "apiKey" : AppApiKey,
        ]
        
        print("url is :", strUrl , parameters)
        
        hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        hud.show(in: self.view)
        
        self.supportDetailsApiPost(strURL: strUrl, parameters: parameters as NSDictionary, completionHandler: {responseObject , error in
            
            print("responseObject of instacashInformation",responseObject ?? [:])
            
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
            if error == nil {
                
                if responseObject?["status"] as? String == "Success" {
                    
                    print(responseObject?["msg"] as? [String:Any] ?? [:])
                    if let respObj = responseObject?["msg"] as? [String : Any] {
                        
                        appDelegate_Obj?.supportEmailAddress = (respObj["contact_detail"] as? NSDictionary)?.value(forKey: "email") as? String ?? "support@nayapurano.shop"
                        
                        let num = (respObj["contact_detail"] as? NSDictionary)?.value(forKey: "phone") as? String ?? "+9779802344846"
                        appDelegate_Obj?.supportPhoneNumber = num.replacingOccurrences(of: " ", with: "")
                        
                        let chatnum = (respObj["contact_detail"] as? NSDictionary)?.value(forKey: "whatsapp") as? String ?? "+9779802344846"
                        appDelegate_Obj?.supportChatNumber = chatnum.replacingOccurrences(of: " ", with: "")
                        
                        
                        print("appDelegate_Obj?.supportEmailAddress",appDelegate_Obj?.supportEmailAddress ?? "")
                        print("appDelegate_Obj?.supportPhoneNumber",appDelegate_Obj?.supportPhoneNumber ?? "")
                        print("appDelegate_Obj?.supportChatNumber",appDelegate_Obj?.supportChatNumber ??  "")
                    }
                    
                }
                else{
                    
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: responseObject?["msg"] as? String ?? ""), duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }
            else
            {
                // check for fundamental networking error
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 2.0, position: .bottom)
                }
                
            }
        })
        
    }
    
    @IBAction func didPressChangeLanguageButton(_ sender: Any) {
        
        let message = self.getLocalizatioStringValue(key: "Change language of this app including its content.")
        let sheetCtrl = UIAlertController(title: self.getLocalizatioStringValue(key: "Choose language"), message: message, preferredStyle: .actionSheet)
        
        for language in arrCountrylanguages {
            
            let action = UIAlertAction(title: self.getLocalizatioStringValue(key: language.strLanguageName), style: .default) { _ in
                
                AppUserDefaults.setValue(language.strLanguageSymbol, forKey: "userChangeLanguage")
                
                AppUserDefaults.setValue(language.strLanguageName, forKey: "LanguageName")
                AppUserDefaults.setValue(language.strLanguageUrl, forKey: "LanguageUrl")
                AppUserDefaults.setValue(language.strLanguageSymbol, forKey: "LanguageSymbol")
                AppUserDefaults.setValue(language.strLanguageVersion, forKey: "LanguageVersion")
                
                self.downloadSelectedLanguage(language.strLanguageUrl, language.strLanguageSymbol)
                
            }
            
            sheetCtrl.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .cancel, handler: nil)
        sheetCtrl.addAction(cancelAction)
        
        sheetCtrl.popoverPresentationController?.sourceView = self.view
        sheetCtrl.popoverPresentationController?.sourceRect = self.submitStoreBtn.frame
        present(sheetCtrl, animated: true, completion: nil)
    }
    
    //MARK: Sameer -> on 23/11/23 due to Remove firebase RT-DB
    func downloadFirebaseRealTimeData() {
        
        if reachability?.connection.description != "No Connection" {
            
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                let url:URL = URL(string: "https://instacash.blob.core.windows.net/static/live/np/nayapurano_app_db.json")!
                
                //let url:URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/nayapurana-a10af.appspot.com/o/np_nepali_eng.json?alt=media&token=546d6ab2-f144-47f1-bc2b-23a45735e434")!
                
                let session = URLSession.shared
                
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "GET"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    
                    DispatchQueue.main.async {
                        self.hud.dismiss()
                    }
                    
                    guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast( self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 2.0, position: .bottom)
                        }
                        
                        return
                    }
                    
                    
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? NSDictionary {
                            
                            print("json download of Firebase RT-DB", jsonDict)
                            
                            
                            //MARK: Language JSON Data
                            //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            DispatchQueue.main.async {
                                
                                CountryLanguages.getStoreLanguagesFromJSON(arrInputJSON: jsonDict["language_np_exchange"] as? [[String : Any]?] ?? []) { languages in
                                    
                                    if languages.count > 0 {
                                        
                                        self.arrCountrylanguages = []
                                        self.arrCountrylanguages = languages
                                        
                                        //if let langCodeAvail = AppUserDefaults.value(forKey: "LanguageSymbol") as? String {
                                        
                                        if let langCodeAvail = AppUserDefaults.value(forKey: "userChangeLanguage") as? String {
                                            
                                            print("langCodeAvail is :-", langCodeAvail)
                                            
                                            for lang in self.arrCountrylanguages {
                                                if lang.strLanguageSymbol == langCodeAvail {
                                                    
                                                    if let langNameAvail = AppUserDefaults.value(forKey: "LanguageName") as? String {
                                                        
                                                        if lang.strLanguageName == langNameAvail {
                                                            
                                                            print("current language is selected : \(lang.strLanguageName)")
                                                            
                                                            //MARK: Save Here Language Details
                                                            AppUserDefaults.setValue(lang.strLanguageName, forKey: "LanguageName")
                                                            AppUserDefaults.setValue(lang.strLanguageUrl, forKey: "LanguageUrl")
                                                            AppUserDefaults.setValue(lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                                            AppUserDefaults.setValue(lang.strLanguageVersion, forKey: "LanguageVersion")
                                                            
                                                            self.downloadSelectedLanguage(lang.strLanguageUrl, lang.strLanguageSymbol)
                                                            
                                                            break
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                        }else {
                                            
                                            //MARK: Language is not depend on current language of device
                                            /*
                                             let preferredLanguage = NSLocale.preferredLanguages[0]
                                             let preferredLanguageCode = preferredLanguage.components(separatedBy: "-").first ?? ""
                                             let firstCode = preferredLanguage.components(separatedBy: "-")
                                             print("preferredLanguage",preferredLanguage)
                                             print("preferredLanguageCode", preferredLanguageCode)
                                             print("firstCode", firstCode)
                                             
                                             
                                             //MARK: 1. Save Here Language
                                             for lang in languages {
                                             
                                             print("current lang.strLanguageSymbol in first case  \(lang.strLanguageSymbol.lowercased())")
                                             
                                             if lang.strLanguageSymbol.lowercased() == preferredLanguageCode.lowercased() {
                                             
                                             print("current language is \(lang.strLanguageName)")
                                             
                                             AppUserDefaults.setValue(lang.strLanguageName, forKey: "LanguageName")
                                             AppUserDefaults.setValue(lang.strLanguageUrl, forKey: "LanguageUrl")
                                             AppUserDefaults.setValue(lang.strLanguageSymbol, forKey: "LanguageSymbol")
                                             AppUserDefaults.setValue(lang.strLanguageVersion, forKey: "LanguageVersion")
                                             
                                             self.downloadSelectedLanguage(lang.strLanguageUrl, lang.strLanguageSymbol)
                                             
                                             self.isLanguageMatchAtLaunch = true
                                             
                                             break
                                             
                                             }
                                             
                                             }
                                             */
                                            
                                            
                                            //MARK: 2. Default NP-English
                                            if !self.isLanguageMatchAtLaunch {
                                                
                                                print("current lang.strLanguageSymbol.lowercased() \(languages[0].strLanguageSymbol.lowercased())")
                                                
                                                AppUserDefaults.setValue(languages[0].strLanguageName, forKey: "LanguageName")
                                                AppUserDefaults.setValue(languages[0].strLanguageUrl, forKey: "LanguageUrl")
                                                AppUserDefaults.setValue(languages[0].strLanguageSymbol, forKey: "LanguageSymbol")
                                                AppUserDefaults.setValue(languages[0].strLanguageVersion, forKey: "LanguageVersion")
                                                
                                                self.downloadSelectedLanguage(languages[0].strLanguageUrl, languages[0].strLanguageSymbol)
                                                
                                                self.isLanguageMatchAtLaunch = true
                                            }
                                            
                                        }
                                                                                
                                    }
                                    else{
                                        
                                        DispatchQueue.main.async() {
                                            self.view.makeToast(self.getLocalizatioStringValue(key: "Sorry! No Language Available"), duration: 2.0, position: .bottom)
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            //})
                            
                        }
                        
                    } catch {
                        print("JSON serialization failed: ", error)
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "JSON serialization failed"), duration: 2.0, position: .bottom)
                        }
                    }
                    
                })
                task.resume()
                
            }
            
        }else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    func downloadSelectedLanguage(_ strUrl: String, _ strLangSymbol: String) {
        
        if reachability?.connection.description != "No Connection" {
            
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                let url:URL = URL(string: strUrl)!
                
                //let url:URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/smartexchnage-revamp.appspot.com/o/np_nepali_eng.json?alt=media&token=140fa2e3-ee2c-4488-990d-0d995abd7723")!
                
                let session = URLSession.shared
                
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "GET"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    
                    DispatchQueue.main.async {
                        self.hud.dismiss()
                    }
                    
                    guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? NSDictionary {
                            
                            print("Download json of language",json)
                            
                            DispatchQueue.main.async {
                                self.saveLocalizationString(json)
                                //AppUserDefaults.setCountryLanguage(data: json)
                                
                                ////self.changeLanguageOfUI()
                            }
                        }
                        
                    } catch {
                        print("JSON serialization failed: ", error)
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "JSON serialization failed"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                    
                })
                task.resume()
                
            }
            
        }else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Check Internet connection."), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
}

/*
 class DataSource: SPRequestPermissionDialogInteractiveDataSource {
 
 //override title in dialog view
 override func headerTitle() -> String {
 return "Blynk Exchange"
 }
 
 override func headerSubtitle() -> String {
 return "header_title".localized
 }
 
 }
 */

import Alamofire
class WebServies: NSObject {
    
    func postRequest(urlString: String, paramDict:Dictionary<String, AnyObject>? = nil,
                     completionHandler:@escaping (NSDictionary?, NSError?) -> ()) {
        
        Alamofire.request(urlString, method: .post, parameters: paramDict, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                //                if let data = response.result.value{
                //                    print(data)
                //                }
                completionHandler(response.result.value as! NSDictionary?, nil)
            case .failure(_):
                //                if let data = response.result.value{
                //                    print(data)
                //                }
                completionHandler(nil, response.result.error as NSError?)
                break
                
            }
        }
        
    }
    
    func getRequest(urlString: String, paramDict:Dictionary<String, AnyObject>? = nil,
                    completionHandler:@escaping (NSDictionary?, NSError?) -> ()) {
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            if response.response?.statusCode == 200
            {
                switch(response.result) {
                case .success(_):
                    
                    completionHandler(response.result.value as! NSDictionary?, nil)
                    
                case .failure(_):
                    
                    completionHandler(nil, response.result.error as NSError?)
                    break
                    
                }
            }
            else
            {
                completionHandler(nil, response.result.error as NSError?)
                
            }
        }
    }
    
}

extension HomeVC : UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.floatingItemsArrayIN.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let floatingItemCell = tableView.dequeueReusableCell(withIdentifier: "FloatingItemCell", for: indexPath) as! FloatingItemCell
        
        floatingItemCell.itemImgView.image = floatingImageArrayIN[indexPath.row]
        floatingItemCell.itemDescriptionLbl.text = "  " + self.getLocalizatioStringValue(key: floatingItemsArrayIN[indexPath.row]) + "  "
        
        return floatingItemCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            self.onClickCallButton()
        case 1:
            self.onClickEmailButton()
        default:
            
            guard let url = URL(string: "https://wa.me/\(appDelegate_Obj?.supportChatNumber ?? "")") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }
        
        /*
         btnFloating.isSelected = !btnFloating.isSelected
         
         self.floatTableView.alpha = 1
         UIView.animate(withDuration: 0.3, animations: {
         self.floatTableViewHeightConstraint.constant = 0.0
         self.view.layoutIfNeeded()
         self.floatTableView.alpha = 0
         self.FloatBGView.isHidden = true
         })
         */
        
    }
    
    func onClickEmailButton() {
        
        if !MFMailComposeViewController.canSendMail() {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Oops! Mail Service not available."), duration: 2.0, position: .bottom)
            }
            
        }
        else{
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            //composeVC.setToRecipients([emailAddress])
            composeVC.setToRecipients([appDelegate_Obj?.supportEmailAddress ?? ""])
            composeVC.setSubject("Message Subject")
            composeVC.setMessageBody("Message content.", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func onClickCallButton() {
        
        if let url = URL(string: "tel://\(appDelegate_Obj?.supportPhoneNumber ?? "")"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Your device doesn't support this feature."), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
}
