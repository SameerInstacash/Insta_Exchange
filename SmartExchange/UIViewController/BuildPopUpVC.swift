//
//  BuildPopUpVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 07/04/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit
import JGProgressHUD

class BuildPopUpVC: UIViewController {
    
    var setBaseUrl : (()->(Void))?
    var baseDict = NPCountryModel(countryDict: [:])
    let reachability: Reachability? = Reachability()
    
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()

        if reachability?.connection.description != "No Connection" {
            
            /*
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
            
            }
            */
            
            self.downloadFirebaseRealTimeData()
            
        }else {
           
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "No connection found"), duration: 2.0, position: .bottom)
            }
           
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
                                                                        
                                }
                                
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
    

    //MARK: Button Action Methods
    @IBAction func btnDebugPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            
            let userDefaults = UserDefaults.standard
            
            userDefaults.removeObject(forKey: "appTestMode")
            
            let dict = self.baseDict.debugUrl
            print("selected mode dict", dict)
            
            userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
            userDefaults.setValue(dict["userName"], forKey: "App_UserName")
            userDefaults.setValue(dict["base_url"], forKey: "App_BaseURL")
            userDefaults.setValue(dict["url"], forKey: "App_TncUrl")
            
            if let url = self.setBaseUrl {
                url()
            }
            
        }
        
    }
    
    @IBAction func btnReleasePressed(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            
            let userDefaults = UserDefaults.standard
            
            userDefaults.setValue("Release", forKey: "appTestMode")
           
            let dict = self.baseDict.releaseUrl
            print("selected mode dict", dict)
            
            userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
            userDefaults.setValue(dict["userName"], forKey: "App_UserName")
            userDefaults.setValue(dict["base_url"], forKey: "App_BaseURL")
            userDefaults.setValue(dict["url"], forKey: "App_TncUrl")
            
            if let url = self.setBaseUrl {
                url()
            }
            
        }
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
