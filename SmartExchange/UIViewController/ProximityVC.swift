//
//  ProximityVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 19/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftyJSON

class ProximityVC: UIViewController {
    
    var proximityRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var proximityTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    var resultJSON = JSON()
    var isComingFromTestResult = false

    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var proximityText: UILabel!
    //@IBOutlet weak var proximityImageView: UIImageView!
    @IBOutlet weak var skipBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.proximityText.isHidden = false
                
        //SAMEER on 27/6/23 due to crash -> ASan
        //proximityImageView.loadGif(name: "proximity")
        
        /*
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("proximity")
        self.proximityImageView.image = jeremyGifUp
        self.proximityImageView.stopAnimating()
        self.proximityImageView.startAnimating()
        */
        
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector((self.proximityChanged)), name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: device)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Proximity Sensor")
                
        //self.proximityText.text = self.getLocalizatioStringValue(key: "Place your palm over the Proximity Sensors and wave as shown in the image")
        
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: nil)
        
    }
    
    @IBAction func proXimitySkipPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Proximity Sensor Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            UserDefaults.standard.set(false, forKey: "proximity")
            self.resultJSON["Proximity"].int = 0
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: nil)
            
            if self.isComingFromTestResult {
              
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
            }else {
                                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeRockerVC") as! VolumeRockerVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
                /*
                self.dismiss(animated: false) {
                    guard let present = self.presentProximityTest else { return }
                    present(self.resultJSON)
                }*/
                
            }
            
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
            //Do Nothing
            popup.dismiss(animated: true, completion: nil)
        }
        
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: GlobalUtility().AppFontMedium, size: 20)!
        pv.messageFont  = UIFont(name: GlobalUtility().AppFontRegular, size: 16)!
        
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: GlobalUtility().AppFontMedium, size: 16)!
        
        
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: GlobalUtility().AppFontMedium, size: 16)!
        
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        */
    }
    
    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you sure?"
        popUpVC.strMessage = "If you skip this test there would be a substantial decline in the price offered."
        popUpVC.strBtnYesTitle = "Skip Test"
        popUpVC.strBtnNoTitle = "Don't Skip"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Proximity Skipped!")
                
                UserDefaults.standard.set(false, forKey: "proximity")
                self.resultJSON["Proximity"].int = -1
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: nil)
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            case 2:
                
                break
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    @objc func proximityChanged(notification: NSNotification) {
        
        if (notification.object as? UIDevice) != nil {
            print("Proximity test passed")
            
            UserDefaults.standard.set(true, forKey: "proximity")
            self.resultJSON["Proximity"].int = 1
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: nil)
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
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

}
