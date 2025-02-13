//
//  EarphoneJackVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 20/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import AVFoundation
import PopupDialog
//import SwiftGifOrigin //SAMEER 27/6/23
import SwiftyJSON

class EarphoneJackVC: UIViewController {
    
    var earphoneRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var earphoneTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPleaseInsert: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var earphoneInfoImage: UIImageView!
    
    var resultJSON = JSON()
    var isComingFromTestResult = false
    
    let session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //earphoneInfoImage.loadGif(name: "earphone_jack")
        
        // Load GIF In Image view
        let jeremyGifUp = UIImage.gifImageWithName("earphone_jack")
        self.earphoneInfoImage.image = jeremyGifUp
        self.earphoneInfoImage.stopAnimating()
        self.earphoneInfoImage.startAnimating()
        
        
        let currentRoute = self.session.currentRoute
        if currentRoute.outputs.count != 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSession.Port.headphones {
                    print("headphone plugged in")
                } else {
                    print("headphone pulled out")
                }
            }
        } else {
            print("requires connection to device")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChangeListener),
            name: AVAudioSession.routeChangeNotification,
            object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Earphone")
                
        self.lblPleaseInsert.text = self.getLocalizatioStringValue(key: "Please plug-in/plug-out your earphones.")
        
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func earphoneSkipPressed(_ sender: Any) {
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Earphone Jack Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            UserDefaults.standard.set(false, forKey: "earphone")
            self.resultJSON["Earphone"].int = 0
            
            if self.isComingFromTestResult {
                                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
            }else {
                                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
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
    }
    

    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
        
        DispatchQueue.main.async {
            let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
            
            switch audioRouteChangeReason {
            case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
                print("headphone plugged in")
                UserDefaults.standard.set(true, forKey: "earphone")
                self.resultJSON["Earphone"].int = 1
                
                if self.isComingFromTestResult {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }
                break
            case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
                print("headphone pulled out")
                UserDefaults.standard.set(true, forKey: "earphone")
                self.resultJSON["Earphone"].int = 1
                
                if self.isComingFromTestResult {
                  
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
                break
            default:
                break
            }
        }
    }

}
