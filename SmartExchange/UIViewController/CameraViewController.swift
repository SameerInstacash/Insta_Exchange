//
//  CameraViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 21/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import AVFoundation
import DKCamera
import PopupDialog
import SwiftyJSON

class CameraViewController: UIViewController {
    
    var cameraRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var cameraTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var lblClick: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!

    var resultJSON = JSON()
    var isFrontClick = false
    var isBackClick = false
    var isComingFromTestResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Camera Autofocus")
                
        //self.lblClick.text = self.getLocalizatioStringValue(key: "Click on “Start Test” and take a picture from your camera to run auto-focus test")
                
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start Test"), for: .normal)
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    
    }
    
    @IBAction func clickPictureBtnPressed(_ sender: Any) {
        
        let camera = DKCamera()
        
        DispatchQueue.main.async {
            camera.cameraSwitchButton.isUserInteractionEnabled = false
            camera.cameraSwitchButton.isHidden = true
        }
        
        camera.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        
        camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
            
            let isFront = camera.currentDevice == camera.captureDeviceFront
            if isFront {
                self.isFrontClick = true
            }
            else {
                self.isBackClick = true
                if self.isFrontClick == false {
                    camera.currentDevice = camera.currentDevice == camera.captureDeviceRear ?
                        camera.captureDeviceFront : camera.captureDeviceRear
                    camera.setupCurrentDevice()
                }
            }
            
            if self.isFrontClick == true && self.isBackClick == true {
                
                self.dismiss(animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: "camera")
                self.resultJSON["Camera"].int = 1
                
                if self.isComingFromTestResult {
                    
                    camera.dismiss(animated: false) {
                        
                        guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    
                    camera.dismiss(animated: false) {
                        
                        guard let didFinishTestDiagnosis = self.cameraTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                
            }
        }
        
        self.present(camera, animated: true, completion: nil)
    }
    
    /*
    @IBAction func clickPictureBtnPressed(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraLayerVC") as! CameraLayerVC
        vc.modalPresentationStyle = .overFullScreen
        
        vc.isBothCameraClicked = {
            print("Camera Test Passed via AVCaptureSession !!")
            
            UserDefaults.standard.set(true, forKey: "camera")
            self.resultJSON["Camera"].int = 1
            
            if self.isComingFromTestResult {
                
                vc.dismiss(animated: true) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            }
            else{
                
                vc.dismiss(animated: true) {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    */
    
    
    @IBAction func skipPictureBtnPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Camera Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            DispatchQueue.main.async() {
                
                UserDefaults.standard.set(false, forKey: "camera")
                self.resultJSON["Camera"].int = 0
                
                if self.isComingFromTestResult {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                    /*
                    self.dismiss(animated: false) {
                        guard let present = self.presentCameraTest else { return }
                        present(self.resultJSON)
                    }
                    */
                    
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
                
                print("Both Camera tests Skipped!")
                
                UserDefaults.standard.set(false, forKey: "camera")
                self.resultJSON["Camera"].int = -1
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.cameraRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.cameraTestDiagnosis else { return }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func clickPictureBtnPressed(_ sender: Any) {
        let camera = DKCamera()
        
        camera.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        
        camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
            print("didFinishCapturingImage")
            self.dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "camera")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
            self.resultJSON["Camera"].int = 1
            vc.resultJSON = self.resultJSON
            self.present(vc, animated: true, completion: nil)
        }
        
        self.present(camera, animated: true, completion: nil)
    }
    */
    
}
