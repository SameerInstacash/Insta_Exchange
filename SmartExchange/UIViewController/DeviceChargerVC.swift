//
//  DeviceChargerVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
//import DKCamera //SAMEER 27/6/23
//import SwiftGifOrigin //SAMEER 27/6/23
import SwiftyJSON

class DeviceChargerVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var chargerRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var chargerTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var lblPleasePlugIn: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var chargerInfoImage: UIImageView!
    
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //chargerInfoImage.loadGif(name: "charging")
        
        /*
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("charging")
        self.chargerInfoImage.image = jeremyGifUp
        self.chargerInfoImage.stopAnimating()
        self.chargerInfoImage.startAnimating()
        */
        
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Camera Autofocus")
                
        //self.lblPleasePlugIn.text = self.getLocalizatioStringValue(key: "Please plug-in/plug-out the charger of your device.")
        
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chargerSkipPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Device Charger Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            DispatchQueue.main.async() {
                
                UserDefaults.standard.set(false, forKey: "charger")
                self.resultJSON["USB"].int = 0
                
                if self.isComingFromTestResult {
                   
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
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
                
                print("charger Skipped!")
                
                UserDefaults.standard.set(false, forKey: "charger")
                self.resultJSON["USB"].int = -1
              
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.chargerRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.chargerTestDiagnosis else { return }
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
    
    @objc func batteryStateDidChange(notification: NSNotification){
        // The stage did change: plugged, unplugged, full charge...
        print("Device plugged in.")
        
        DispatchQueue.main.async() {
            UserDefaults.standard.set(true, forKey: "charger")
            self.resultJSON["USB"].int = 1
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.chargerRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.chargerTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    @objc func batteryLevelDidChange(notification: NSNotification){
        // The battery's level did change (98%, 99%, ...)
    }
    
}
