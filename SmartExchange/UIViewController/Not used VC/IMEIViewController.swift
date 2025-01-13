//
//  IMEIViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 04/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftOCR
import JGProgressHUD

class IMEIViewController: UIViewController,UITextFieldDelegate {
    
    var setBaseUrl : (()->(Void))?
    var baseDict = NPCountryModel(countryDict: [:])
    let reachability: Reachability? = Reachability()
    let hud = JGProgressHUD()
    
    var arrCountrylanguages = [CountryLanguages]()
    var isLanguageMatchAtLaunch = false
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPleaseEnter: UILabel!
    @IBOutlet weak var txtFieldIMEI: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()
               
        self.txtFieldIMEI.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        self.lblTitle.text = self.getLocalizatioStringValue(key: "IC Exchange")
        self.lblPleaseEnter.text = self.getLocalizatioStringValue(key: "Please Enter IMEI of your device")
        
        self.txtFieldIMEI.placeholder = self.getLocalizatioStringValue(key: "Dial *#06# for IMEI Number")
        self.continueButton.setTitle(self.getLocalizatioStringValue(key: "Continue"), for: .normal)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        
        if (imei?.count == 15){
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            vc.IMEINumber = imei ?? ""
            //self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            
            print("user defaults not present")
            
            
            //MARK: Sameer -> on 23/11/23 due to Remove firebase RT-DB
            self.downloadFirebaseRealTimeData()
            
            
            //MARK: Comment on 26/7/23 due to already fetch all data on StoreSlider page
            /*
            
            if reachability?.connection.description != "No Connection" {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                
                NPCountryModel.fetchCredentialsFromFireBase(isInterNet: true, getController: self) { (npCountry) in
                    
                    DispatchQueue.main.async() {
                        self.hud.dismiss()
                    }
                    
                    self.baseDict = npCountry
                    print("self.baseDict.debugUrl", self.baseDict.debugUrl)
                    print("self.baseDict.releaseUrl", self.baseDict.releaseUrl)
                    
                    //MARK: Save Live Credentials in UserDefaults
                    let userDefaults = UserDefaults.standard
                    
                    if let mode = userDefaults.value(forKey: "appTestMode") as? String {
                        if mode == "Release" {
                            
                            let dict = self.baseDict.releaseUrl
                            userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                            userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                            userDefaults.setValue(dict["base_url"], forKey: "App_BaseURL")
                            userDefaults.setValue(dict["url"], forKey: "App_TncUrl")
                            
                            print("Firebase DB dict is :",dict)
                            
                        }
                    }else {
                        
                        #if DEBUG
                        
                            let dict = self.baseDict.debugUrl
                            userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                            userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                            userDefaults.setValue(dict["base_url"], forKey: "App_BaseURL")
                            userDefaults.setValue(dict["url"], forKey: "App_TncUrl")
                            
                            print("Firebase DB dict is :",dict)
                        
                        #else
                        
                            let dict = self.baseDict.releaseUrl
                            userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                            userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                            userDefaults.setValue(dict["base_url"], forKey: "App_BaseURL")
                            userDefaults.setValue(dict["url"], forKey: "App_TncUrl")
                            
                            print("Firebase DB dict is :",dict)
                        
                        #endif
                        
                    }
                    
                }
            }else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast("No connection found", duration: 2.0, position: .bottom)
                }
                
            }
            */
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadFirebaseRealTimeData() {
        
        if reachability?.connection.description != "No Connection" {
            
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = ""
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.show(in: self.view)
                
                let url:URL = URL(string: "https://instacash.blob.core.windows.net/static/live/np/nayapurano_app_db.json")!
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
                                
                                //self.changeLanguageOfUI()
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
    
    
    //MARK: IBAction
    @IBAction func continueBtnPressed(_ sender: Any) {
        
        if self.txtFieldIMEI.text?.count == 15 {
            
            if self.isIMEIValid(imeiNumber: self.txtFieldIMEI.text ?? "") {
            //if (self.txtFieldIMEI.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) > 0 {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.IMEINumber = self.txtFieldIMEI.text ?? ""
                UserDefaults.standard.set("\(self.txtFieldIMEI.text ?? "")", forKey: "imei_number")
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Invalid IMEI Number Entered."), duration: 2.0, position: .top)
                }
                
            }
            
            
            /*
            if isIMEIValid(imeiNumber: txtFieldIMEI.text!){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
                vc.IMEINumber = txtFieldIMEI.text!
                UserDefaults.standard.set("\(txtFieldIMEI.text!)", forKey: "imei_number")
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                DispatchQueue.main.async {
                    self.view.makeToast("invalid_imei".localized, duration: 2.0, position: .top)
                }
            }
            */
            
            
        }else{
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a valid 15-digit IMEI Number"), duration: 2.0, position: .top)
            }
        }
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
        
        /*
        for languageCode in Bundle.main.localizations.filter({ $0 != "Base" }) {
            let langName = Locale.current.localizedString(forLanguageCode: languageCode)
            let action = UIAlertAction(title: langName, style: .default) { _ in
                self.changeToLanguage(languageCode) // see step #2
            }
            sheetCtrl.addAction(action)
        }
        */
        
        let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .cancel, handler: nil)
        sheetCtrl.addAction(cancelAction)
        
        sheetCtrl.popoverPresentationController?.sourceView = self.view
        //sheetCtrl.popoverPresentationController?.sourceRect = self.changeLanguageButton.frame
        sheetCtrl.popoverPresentationController?.sourceRect = self.continueButton.frame
        present(sheetCtrl, animated: true, completion: nil)
    }
    
    private func changeToLanguage(_ langCode: String) {
        if Bundle.main.preferredLocalizations.first != langCode {
            let message = self.getLocalizatioStringValue(key: "In order to change the language, the App must be closed and reopened by you.")
            let confirmAlertCtrl = UIAlertController(title: self.getLocalizatioStringValue(key: "App restart required"), message: message, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Close now"), style: .destructive) { _ in
                UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                exit(EXIT_SUCCESS)
            }
            confirmAlertCtrl.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .cancel, handler: nil)
            confirmAlertCtrl.addAction(cancelAction)
            
            present(confirmAlertCtrl, animated: true, completion: nil)
        }
    }
    
    func isIMEIValid(imeiNumber: String) -> Bool {
        var sum = 0;
        for i in (0..<15) {
            var number = Int(imeiNumber.substring(fromIndex: i, toIndex: i))
            if ((i+1)%2 == 0){
                number = (number ?? 0)*2;
                number = (number ?? 0)/10 + (number ?? 0)%10;
            }
            sum = sum+(number ?? 0)
        }
        
        if (sum%10 == 0) {
            return true
        }else{
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

       // YOU SHOULD FIRST CHECK FOR THE BACKSPACE. IF BACKSPACE IS PRESSED ALLOW IT

        if string == "" {
            return true
        }
        
        if UIDevice.current.model.hasPrefix("iPad") {
        
        }else {
            
            if let characterCount = textField.text?.count {
                // CHECK FOR CHARACTER COUNT IN TEXT FIELD
                if characterCount >= 15 {
                    // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                    return textField.resignFirstResponder()
                }
            }
            
        }
        
        return true
    }
    
    /*
    func isIMEIValid(imeiNumber: String) -> Bool {
        var sum = 0;
        for i in (0..<15){
            var number = Int(imeiNumber.substring(fromIndex: i, toIndex: i))
            if ((i+1)%2==0){
                number = number!*2;
                number = number!/10+number!%10;
            }
            sum=sum+number!
        }
        if(sum%10 == 0) {
            return true
        }else{
            return false
        }
    }
    */
    
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}


