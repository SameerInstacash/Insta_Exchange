//
//  AutoRotationVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog

class AutoRotationVC: UIViewController {
    
    var rotationRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var rotationTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var lblAutoRotationDetail: UILabel!
    //@IBOutlet weak var AutoRotationText: UITextView!
    //@IBOutlet weak var screenRotationInfo: UITextView!
    @IBOutlet weak var beginBtn: UIButton!
    //@IBOutlet weak var AutoRotationImage: UIImageView!
    //@IBOutlet weak var AutoRotationImageView: UIImageView!
    
    @IBOutlet weak var rotationImgVW: UIImageView!
    
    var hasStarted = false
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //self.AutoRotationImage.loadGif(name: "rotation")
        
        /*
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("rotation")
        self.AutoRotationImage.image = jeremyGifUp
        self.AutoRotationImage.stopAnimating()
        self.AutoRotationImage.startAnimating()
        */
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Screen Rotation")
                
        //self.lblAutoRotationDetail.text = self.getLocalizatioStringValue(key: "Turn on screen auto-rotation, then click “Start Test” and rotate your device from Portrait to Landscape view")
        
        self.beginBtn.setTitle(self.getLocalizatioStringValue(key: "Start Test"), for: .normal)
    
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBACtion
    @IBAction func beginBtnClicked(_ sender: UIButton) {
        
        self.hasStarted = true
                    
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        /*
        if self.hasStarted {
            
            // Prepare the popup assets
            let title = self.getLocalizatioStringValue(key: "Auto Rotation Diagnosis")
            let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
                
                UserDefaults.standard.set(false, forKey: "rotation")
                self.resultJSON["Rotation"].int = 0
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                
                if self.isComingFromTestResult {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                
                    /*
                    self.dismiss(animated: false) {
                        guard let present = self.presentRotationTest else { return }
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
            
        }else {
            
            self.hasStarted = true
            //self.lblAutoRotationDetail.text = self.getLocalizatioStringValue(key: "Please switch the Device to Landscape View.")
            //self.beginBtn.setTitle(self.getLocalizatioStringValue(key: "skip"),for: .normal)
            //self.AutoRotationImage.isHidden = true
            //self.AutoRotationImageView.isHidden = false
            //self.AutoRotationImageView.image = UIImage(named: "landscape_image")!
                        
            NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
        }
        */
        
    }
    
    @IBAction func skipBtnClicked(_ sender: UIButton) {
        self.ShowGlobalPopUp()
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
                
                print("Rotation Skipped!")
                
                UserDefaults.standard.set(false, forKey: "rotation")
                self.resultJSON["Rotation"].int = -1
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.rotationRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.rotationTestDiagnosis else { return }
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
    
    @objc func rotated()
    {
        if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            print("LandScape")
            //self.lblAutoRotationDetail.text = self.getLocalizatioStringValue(key: "Now rotate your device back to Portrait view.")
            //self.AutoRotationImageView.image = UIImage(named: "portrait_image")!
            
            self.rotationImgVW.image = UIImage(named: "ic_portrait")
        }
        
        if (UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            self.rotationImgVW.image = UIImage(named: "ic_landscape")
            
            print("Portrait")
            UserDefaults.standard.set(true, forKey: "rotation")
            self.resultJSON["Rotation"].int = 1
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.rotationRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.rotationTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            
            
        }
        
    }
    
    
}
