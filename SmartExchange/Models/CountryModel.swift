//
//  CountryModel.swift
//  InspecTec
//
//  Created by InspecTec on 11/09/18.
//  Copyright © 2018 Prakhar Gupta. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class NPCountryModel {
    
    var debugUrl = [String:String]()
    var releaseUrl = [String:String]()
    
    init(countryDict: [String: Any]) {
        
        self.debugUrl = countryDict["debug"] as? [String:String] ?? [:]
        self.releaseUrl = countryDict["release"] as? [String:String] ?? [:]
        
    }
    
    static func getStoreCredentialsFromJSON(dicInputJSON : [String:Any]?, completion: @escaping (NPCountryModel) -> Void ) {
                
        let countryList = NPCountryModel(countryDict: dicInputJSON ?? [:])
        
        DispatchQueue.main.async {
            completion(countryList)
        }
        
    }
    
    static func fetchCredentialsFromFireBase(isInterNet:Bool, getController:UIViewController, completion: @escaping (NPCountryModel) -> Void ) {
        
        let ref = Database.database().reference(withPath: "ios_base_url")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            //print(snapshot.value as! NSDictionary)
            let tempDicts = snapshot.value as? [String:Any] ?? [:]
            let countryList = NPCountryModel(countryDict: tempDicts)
            
            DispatchQueue.main.async {
                completion(countryList)
            }
            
        })
        
    }
    
}

