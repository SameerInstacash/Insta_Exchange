//
//  StoreSliderVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 26/07/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import JGProgressHUD

class StoreSliderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var storeSliderCollectionView: UICollectionView!
    @IBOutlet weak var sliderPageControl: UIPageControl!
    
    @IBOutlet weak var btnSkip: UIButton!
    
    var baseDict = NPCountryModel(countryDict: [:])
    let reachability: Reachability? = Reachability()
    let hud = JGProgressHUD()
    
    var arrStoreImg : [String]?
    
    var arrCountrylanguages = [CountryLanguages]()
    var isLanguageMatchAtLaunch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.storeSliderCollectionView.register(UINib(nibName: "StoreSliderCVCell", bundle: nil), forCellWithReuseIdentifier: "StoreSliderCVCell")

        self.sliderPageControl.isHidden = true
        
        //self.getCountriesDataFromFirebase()
                
        self.downloadFirebaseRealTimeData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
        
    }
    
    func changeLanguageOfUI() {
                
        self.btnSkip.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: UIControlState.normal)
         
    }
    
    //MARK: Button Action Methods
    @IBAction func skipBtnPressed(_ sender: UIButton) {
        
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        
        if (imei?.count == 15){
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.IMEINumber = imei ?? ""
                //self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else {
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "IMEIVC") as! IMEIViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    //MARK: UICollectionView DataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrStoreImg?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let StoreSliderCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreSliderCVCell", for: indexPath as IndexPath) as! StoreSliderCVCell
        
        if let imgURL = URL(string: self.arrStoreImg?[indexPath.item] ?? "") {
            //StoreSliderCVCell.imgStore.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "location"))
            StoreSliderCVCell.imgStore.af_setImage(withURL: imgURL)
        }
                
        return StoreSliderCVCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.sliderPageControl.currentPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: Web Service Methods
    func storeImgApiPost(strURL : String , parameters:NSDictionary, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        
        let web = WebServies()
        web.postRequest(urlString: strURL, paramDict: (parameters as! Dictionary<String, AnyObject>), completionHandler: completionHandler)
    }
    
    func fireWebServiceForFetchStoreImage()
    {
        if reachability?.connection.description != "No Connection" {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            #if DEBUG
            
                //let strUrl = "https://nayapurana-uat.getinstacash.in/npapi/api/v5/public/appSlider"
            
                let strUrl = AppBaseUrl + "appSlider"
            
            #else
            
                let strUrl = AppBaseUrl + "appSlider"
            
            #endif
                        
            var parameters = [String: Any]()
            
            parameters  = [
                "userName" : AppUserName,
                "apiKey" : AppApiKey,
            ]
            
            print("strUrl is:" , strUrl)
            print("parameters are:" , parameters)
            
            self.storeImgApiPost(strURL: strUrl, parameters: parameters as? NSDictionary ?? [:], completionHandler: { responseObject , error in
                
                DispatchQueue.main.async() {
                    self.hud.dismiss()
                }
                
                print(responseObject ?? [:])
                
                if error == nil {
                    
                    if responseObject?["status"] as! String == "Success" {
                        
                        if let arrStoreList = (responseObject?["msg"]) as? NSArray {
                            
                            print("arrStoreList" , arrStoreList.count, arrStoreList)
                            
                            self.arrStoreImg = []
                            
                            for i in 0..<arrStoreList.count {
                                self.arrStoreImg?.append(arrStoreList[i] as? String ?? "")
                            }
                            
                            
                            if (self.arrStoreImg?.count ?? 0) > 0 {
                                
                                self.storeSliderCollectionView.dataSource = self
                                self.storeSliderCollectionView.delegate = self
                                
                                self.storeSliderCollectionView.reloadData()
                                
                                self.sliderPageControl.isHidden = true
                            }
                            
                            
                            if (self.arrStoreImg?.count ?? 0) > 1 {
                                
                                self.sliderPageControl.isHidden = false
                                self.sliderPageControl.numberOfPages = self.arrStoreImg?.count ?? 0
                            }
                            
                            
                            /*
                            if (self.arrStoreImg?.count == 0) {
                                let vc = LaunchScreenVC()
                                self.navigationController?.pushViewController(vc, animated: true)
                            }*/
                            
                        }
                        
                    } else {

                        self.view.makeToast(self.getLocalizatioStringValue(key: responseObject?["msg"] as? String ?? ""), duration: 2.0, position: .bottom)
                        
                    }
                    
                }
                else
                {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "oops,something went wrong"), duration: 2.0, position: .bottom)
                    
                }
                
            })
            
        }
        else {
            
            self.view.makeToast(self.getLocalizatioStringValue(key: "No connection found"), duration: 2.0, position: .bottom)
        }
        
    }
    
    
    // MARK: Fetch Data from URL , not from Firebase DB
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
                            
                            
                            DispatchQueue.main.async {
                                
                                NPCountryModel.getStoreCredentialsFromJSON(dicInputJSON: jsonDict["ios_c2b2b"] as? [String : Any]? ?? [:]) { (npCountry) in
                                    
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
                                    
                                    
                                    //MARK: Get slider images from WebService
                                    self.fireWebServiceForFetchStoreImage()
                                    
                                }
                                
                            }
                            
                            
                            //MARK: Language JSON Data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                
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
                                                            
                            })
                            
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
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // MARK: Not Used
    func getCountriesDataFromFirebase() {
        
        //MARK: Get country from Firebase
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
                
                
                //MARK: Get slider images from WebService
                self.fireWebServiceForFetchStoreImage()
                
            }
        }else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "No connection found"), duration: 2.0, position: .bottom)
            }
            
        }

    }
    
}
