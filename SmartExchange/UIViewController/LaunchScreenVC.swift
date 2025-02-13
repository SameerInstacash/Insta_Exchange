//
//  LaunchScreenVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 07/04/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigateIntoApp()
        
         /*
         #if DEBUG
         
         DispatchQueue.main.async {
         
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "BuildPopUpVC") as! BuildPopUpVC
         vc.modalPresentationStyle = .overCurrentContext
         vc.modalTransitionStyle = .crossDissolve
         
         vc.setBaseUrl = {
         self.navigateIntoApp()
         }
         
         self.present(vc, animated: true, completion: nil)
         
         }
         
         #else
         
         self.navigateIntoApp()
         
         #endif
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        //self.navigateIntoApp()
        
    }
    
    func navigateIntoApp() {
        
        DispatchQueue.main.async {
            
            let imei = UserDefaults.standard.string(forKey: "imei_number") ?? ""
            
            if (imei.count == 15) {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.IMEINumber = imei
                
                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryVC
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImeiFetchVC") as! ImeiFetchVC
                vc.isComeFrom = ""
                self.navigationController?.pushViewController(vc, animated: true)
                
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
