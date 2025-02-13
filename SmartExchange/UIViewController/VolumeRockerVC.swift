//
//  VolumeRockerVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 19/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import JPSVolumeButtonHandler
import PopupDialog
import SwiftyJSON

class VolumeRockerVC: UIViewController {

    var volumeRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var volumeTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var lblVolumeBtnInfo: UILabel!
    
    @IBOutlet weak var lblVolumeUp: UILabel!
    @IBOutlet weak var lblVolumeDown: UILabel!
    
    @IBOutlet weak var volumeUpImg: UIImageView!
    @IBOutlet weak var volumeDownImg: UIImageView!
    @IBOutlet weak var skipBtn: UIButton!
    
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    private var audioLevel : Float = 0.0
    //var audioSession = AVAudioSession.sharedInstance()
    var audioSession : AVAudioSession?
    
    var volDown = false
    var volUp = false
    private var volumeButtonHandler: JPSVolumeButtonHandler?
    //lazy private var volumeButtonHandler: JPSVolumeButtonHandler? = JPSVolumeButtonHandler()
    private var isVolumeBtnPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        //*
        self.volumeButtonHandler = JPSVolumeButtonHandler(
            up: {
                
                print("Volume up pressed")
                self.volumeUpImg.image = UIImage(named: "volume_up_green")
                self.volUp = true
                
                if (self.volDown == true) {
                    
                    print("Volume test passed")
                    self.tearDown()
                    
                    UserDefaults.standard.set(true, forKey: "volume")
                    self.resultJSON["Hardware Buttons"].int = 1
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                self.action()
                //self.actionUp()
                
            }, downBlock: {
                
                print("Volume down pressed")
                self.volumeDownImg.image = UIImage(named: "volume_down_green")
                self.volDown = true
                
                if (self.volUp == true) {
                    
                    print("Volume test passed")
                    self.tearDown()
                    
                    UserDefaults.standard.set(true, forKey: "volume")
                    self.resultJSON["Hardware Buttons"].int = 1
                    
                    //UserDefaults.standard.set(true, forKey: "charger")
                    //UserDefaults.standard.set(true, forKey: "earphone")
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                self.action()
                //self.actionDown()
                
            })
        
        let handler = volumeButtonHandler
        handler!.start(true)
        //*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // SAM comment on 18/4/22
        // self.listenVolumeButton()
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Hardware Buttons")
                
        //self.lblVolumeBtnInfo.text = self.getLocalizatioStringValue(key: "Please press the following buttons or keys on your phone.")
        
        self.lblVolumeUp.text = self.getLocalizatioStringValue(key: "Press Volume up button").removingPercentEncoding
        self.lblVolumeDown.text = self.getLocalizatioStringValue(key: "Press Volume down button").removingPercentEncoding
        
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // SAM comment on 18/4/22
        //self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
        
        /*
        //if let observerAdded = self.audioSession?.observationInfo {
         if (self.audioSession?.observationInfo) != nil {
            self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
            print("now added outputVolume observer remove", observerAdded)
         
            self.audioSession = nil
            self.audioLevel = nil
        }
        */
        
    }
    
    
    var action: (() -> Void) = {} {
        didSet {
            // Is the handler already there, that is, is this module already in use?..
            if let handler = self.volumeButtonHandler {
                // ..If so, then add the action to the handler right away.
                handler.upBlock = action
                handler.downBlock = action
            }
            // Otherwise, just save the action here and see it added when the handler is created when the module goes into use (isInUse = true).
        }
    }
    
    func tearDown() {
        if let handler = volumeButtonHandler {
            handler.stop()
            self.volumeButtonHandler = nil
        }
    }
    
    var actionUp: (() -> Void) = {} {
        didSet {
            // Is the handler already there, that is, is this module already in use?..
            if let handler = self.volumeButtonHandler {
                // ..If so, then add the action to the handler right away.
                handler.upBlock = actionUp
                //handler.downBlock = action
            }
            // Otherwise, just save the action here and see it added when the handler is created when the module goes into use (isInUse = true).
        }
    }
    
    var actionDown: (() -> Void) = {} {
        didSet {
            // Is the handler already there, that is, is this module already in use?..
            if let handler = self.volumeButtonHandler {
                // ..If so, then add the action to the handler right away.
                //handler.upBlock = action
                handler.downBlock = actionDown
            }
            // Otherwise, just save the action here and see it added when the handler is created when the module goes into use (isInUse = true).
        }
    }
    
    //MARK: IBAction
    @IBAction func volumeRockerSkipPressed(_ sender: Any) {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Hardware Button Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            //self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
            
            self.tearDown()
            
            UserDefaults.standard.set(false, forKey: "volume")
            self.resultJSON["Hardware Buttons"].int = 0
          
            if self.isComingFromTestResult {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                /* MARK: Ajay told to Remove both test on 27/3/23
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneJackVC") as! EarphoneJackVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                */
                
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
                /*
                self.dismiss(animated: false) {
                    guard let present = self.presentVolumeTest else { return }
                    present(self.resultJSON)
                }
                */
                
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
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func listenVolumeButton() {
        
        //let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try self.audioSession?.setActive(true, options: [])
            self.audioSession?.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            self.audioLevel = (self.audioSession?.outputVolume ?? 0.0)
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        /*
        //DispatchQueue.main.async {
            
            if keyPath == "outputVolume" {
                
                //let audioSession = AVAudioSession.sharedInstance()
                
                if (self.audioSession?.outputVolume ?? 0.0) > self.audioLevel {
                    
                    print("Volume up pressed")
                    self.volumeUpImg.image = UIImage(named: "volume_up_green")
                    self.volUp = true
                    
                    if (self.volDown == true) {
                        
                        //self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                        
                        print("Volume test passed")
                        
                        UserDefaults.standard.set(true, forKey: "volume")
                        self.resultJSON["Hardware Buttons"].int = 1
                        
                        if self.isComingFromTestResult {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            
                        }else {
                            
                            /* MARK: Ajay told to Remove both test on 27/3/23
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneJackVC") as! EarphoneJackVC
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            */
                            
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
                if (self.audioSession?.outputVolume ?? 0.0) < self.audioLevel {
                    
                    print("Volume down pressed")
                    self.volumeDownImg.image = UIImage(named: "volume_down_green")
                    self.volDown = true
                    
                    if (self.volUp == true) {
                        
                        //self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                        
                        print("Volume test passed")
                        
                        UserDefaults.standard.set(true, forKey: "volume")
                        self.resultJSON["Hardware Buttons"].int = 1
                        
                        if self.isComingFromTestResult {
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            
                        }else {
                            
                            /* MARK: Ajay told to Remove both test on 27/3/23
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneJackVC") as! EarphoneJackVC
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            */
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                            vc.resultJSON = self.resultJSON
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
                self.audioLevel = (self.audioSession?.outputVolume ?? 0.0)
                print("self.audioSession.outputVolume is:", self.audioSession?.outputVolume ?? 0.0)
                
            }
        //}
        */
        
    }
    
    
    func goNext() {
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    func ShowTestPassFailPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Alert!"
        popUpVC.strMessage = "Are the volume buttons loose/hard to press."
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                UserDefaults.standard.set(false, forKey: "volume")
                self.resultJSON["Hardware Buttons"].int = 0
                
                self.goNext()
                                
            case 2:
                
                UserDefaults.standard.set(true, forKey: "volume")
                self.resultJSON["Hardware Buttons"].int = 1
                
                self.goNext()
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
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
                
                //self.audioSession?.removeObserver(self, forKeyPath: "outputVolume", context: nil)
                
                print("Hardware Buttons Skipped!")
                
                self.tearDown()
                UserDefaults.standard.set(false, forKey: "volume")
                self.resultJSON["Hardware Buttons"].int = -1
              
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.volumeRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.volumeTestDiagnosis else { return }
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

}
