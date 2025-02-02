//
//  ScreenViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 11/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
//import SwiftGifOrigin //SAMEER 27/6/23
import PopupDialog
import SwiftyJSON
import AVKit
import SwiftGifOrigin

class ScreenViewController: UIViewController {
    
    var screenRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var screenTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    //@IBOutlet weak var screenNavBar: UINavigationBar!
    //@IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    @IBOutlet weak var startScreenBtn: UIButton!
    @IBOutlet weak var screenImageView: UIImageView!
    @IBOutlet weak var screenText: UILabel!
    
    var isComingFromTestResult = false
    
    var obstacleViews : [UIView] = []
    var flags: [Bool] = []
    var countdownTimer: Timer!
    var totalTime = 60
    var startTest = false
    var resultJSON = JSON()
    
    var touchDownTimer: Timer!
    var touchTimeCount = 0
    
    var recordingSession: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.screenImageView.setImageColor(color: #colorLiteral(red: 0.9882352941, green: 0.3294117647, blue: 0, alpha: 1))
        
        //MARK: SAMEER 27/6/23
        //DispatchQueue.main.async {
        //self.checkMicrophone()
        //}
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Load GIF In Image view
        //let jeremyGifUp = UIImage.gifImageWithName("screen-calibration")
        //self.screenImageView.image = jeremyGifUp
        //self.screenImageView.stopAnimating()
        //self.screenImageView.startAnimating()
        
        //self.screenImageView.loadGif(name: "screen-calibration")
        
    }
    
    func changeLanguageOfUI() {
        
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Touch Screen")
        //self.screenText.text = self.getLocalizatioStringValue(key: "Click 'Start Test', then swipe along the squares")
        self.screenText.text = self.getLocalizatioStringValue(key: "Click “Start Test” then swipe along the grey squares")
        
        self.startScreenBtn.setTitle(self.getLocalizatioStringValue(key: "Start Test"), for: .normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func beginScreenBtnClicked(_ sender: Any) {
        drawScreenTest()
    }
    
    func drawScreenTest() {
        
        startScreenBtn.isHidden = true
        screenImageView.isHidden = true
        //screenNavBar.isHidden = true
        screenText.isHidden = true
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth:Int = Int(screenSize.width)
        let screenHeight:Int = Int(screenSize.height)
        let widthPerimeterImage:Int =  Int(screenWidth/9)
        let heightPerimeterImage:Int = Int((screenHeight)/14)
        
        var l = 0
        var t = 20
        
        for var _ in (0..<14).reversed()
        {
            for var _ in (0..<9).reversed()
            {
                let view = LevelView(frame: CGRect(x: l, y: t, width: widthPerimeterImage, height: heightPerimeterImage))
                l = l+widthPerimeterImage
                
                obstacleViews.append(view)
                flags.append(false)
                self.view.addSubview(view)
            }
            l=0
            t=t+heightPerimeterImage
        }
        startTest = true
        startTimer()
        
        //MARK: Add on 1/2/25
        startTouchTimer()
    }
    
    func checkMicrophone() {
        // Recording audio requires a user's permission to stop malicious apps doing malicious things, so we need to request recording permission from the user.
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.createRecorder()
                        
                        self.resultJSON["MIC"].int = 1
                        UserDefaults.standard.set(true, forKey: "mic")
                        
                    } else {
                        // failed to record!
                        //self.showaAlert(message: "failed to record!")
                        
                        self.resultJSON["MIC"].int = 0
                        UserDefaults.standard.set(false, forKey: "mic")
                    }
                }
            }
        } catch {
            // failed to record!
            //self.showaAlert(message: "failed to record!")
            
            self.resultJSON["MIC"].int = 0
            UserDefaults.standard.set(false, forKey: "mic")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.touchDownTimer.invalidate()
        self.touchTimeCount = 0
        
        startTouchTimer()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testTouches(touches: touches)
        
        
        self.touchDownTimer.invalidate()
        self.touchTimeCount = 0
        
        
        //        if let layer = self.view.layer.hitTest(point!) as? CAShapeLayer { // If you hit a layer and if its a Shapelayer
        //            if CGPathContainsPoint(layer.path, nil, point, false) { // Optional, if you are inside its content path
        //                println("Hit shapeLayer") // Do something
        //            }
        //        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!) {
        testTouches(touches: touches)
        
        self.touchDownTimer.invalidate()
        self.touchTimeCount = 0
    }
    
    func testTouches(touches: Set<UITouch>) {
        // Get the first touch and its location in this view controller's view coordinate system
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self.view)
        var finalFlag = true
        
        for (index,obstacleView) in obstacleViews.enumerated() {
            // Convert the location of the obstacle view to this view controller's view coordinate system
            let obstacleViewFrame = self.view.convert(obstacleView.frame, from: obstacleView.superview)
            
            // Check if the touch is inside the obstacle view
            if obstacleViewFrame.contains(touchLocation) {
                flags[index] = true
                let levelLayer = CAShapeLayer()
                levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: obstacleViewFrame.width + 10,
                                                                   height: obstacleViewFrame.height),
                                               cornerRadius: 0).cgPath
                
                //levelLayer.fillColor = UIColor.init(hexString: "#ED1C24").cgColor
                //levelLayer.fillColor = UIColor.init(hexString: "#6A1B9A").cgColor
                //levelLayer.fillColor = UIColor.init(hexString: "#65FF00").cgColor
                //levelLayer.fillColor = UIColor.init(hexString: "#FC5400").cgColor
                
                levelLayer.fillColor = UIColor.init(hexString: "#52A68E").cgColor
                //28B03D
                
                //FFC4A7
                obstacleView.layer.addSublayer(levelLayer)
                
            }
            finalFlag = flags[index]&&finalFlag
        }
        
        if finalFlag && startTest{
            endTimer(type: 1)
        }
    }
    
    func startTouchTimer() {
        DispatchQueue.main.async {
            self.touchDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTouchTime), userInfo: nil, repeats: true)
        }
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer(type: 0)
        }
    }
    
    @objc func updateTouchTime() {
        touchTimeCount += 1
        
        if touchTimeCount == 5 {
            self.ShowTouchPopUp()
        }
        else {
            
        }
        
    }
    
    func endTimer(type: Int) {
        
        self.touchDownTimer.invalidate()
        self.touchTimeCount = 0
        
        countdownTimer.invalidate()
        if type == 1 {
            UserDefaults.standard.set(true, forKey: "screen")
            resultJSON["Screen"].int = 1
            
             /*
             if self.isComingFromTestResult {
             
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
             vc.resultJSON = self.resultJSON
             self.present(vc, animated: true, completion: nil)
             
             }else {
             
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
             vc.resultJSON = self.resultJSON
             self.present(vc, animated: true, completion: nil)
             
             }
             */
            
            if self.isComingFromTestResult {
                
                guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                didFinishRetryDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
                didFinishTestDiagnosis(self.resultJSON)
                self.dismiss(animated: false, completion: nil)
                
            }
            
        }else{
            
            self.ShowGlobalPopUp()
            
            /*
             let title = self.getLocalizatioStringValue(key: "Screen Diagnosis Test Failed!")
             let message = self.getLocalizatioStringValue(key: "Do you want to retry the test?")
             
             
             // Create the dialog
             let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
             
             // Create buttons
             let buttonOne = DefaultButton(title: self.getLocalizatioStringValue(key: "Yes")) {
             popup.dismiss(animated: true, completion: nil)
             
             
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
             vc.resultJSON = self.resultJSON
             self.present(vc, animated: true, completion: nil)
             
             }
             
             let buttonTwo = CancelButton(title: self.getLocalizatioStringValue(key: "No")) {
             //Do Nothing
             UserDefaults.standard.set(false, forKey: "screen")
             self.resultJSON["Screen"].int = 0
             
             if self.isComingFromTestResult {
             
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
             vc.resultJSON = self.resultJSON
             self.present(vc, animated: true, completion: nil)
             
             }else {
             
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
             vc.resultJSON = self.resultJSON
             self.present(vc, animated: true, completion: nil)
             
             /*
              self.dismiss(animated: false) {
              guard let present = self.presentScreenTest else { return }
              present(self.resultJSON)
              }
              */
             
             }
             
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
             */
            
        }
        
    }
    
    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Test Failed!"
        popUpVC.strMessage = "Do you want to retry the test?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("Screen Test Retry!")
                self.totalTime = 60
                
                self.startTest = true
                self.startTimer()
                
                
                self.touchDownTimer.invalidate()
                self.touchTimeCount = 0
                self.startTouchTimer()
                
                
                /*
                 self.startScreenBtn.isHidden = false
                 
                 DispatchQueue.main.async {
                 for v in self.obstacleViews{
                 v.removeFromSuperview()
                 }
                 self.obstacleViews = []
                 self.flags = []
                 self.totalTime = 40
                 self.startTest = false
                 //self.resultJSON = JSON()
                 //self.startScreenBtn.isHidden = false
                 self.screenImageView.isHidden = false
                 }*/
                
            case 2:
                
                print("Screen Test Failed!")
                
                UserDefaults.standard.set(false, forKey: "screen")
                self.resultJSON["Screen"].int = 0
                
                self.touchDownTimer.invalidate()
                self.touchTimeCount = 0
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    @IBAction func skipbuttonPressed(_ sender: UIButton) {
        
        self.touchDownTimer.invalidate()
        self.touchTimeCount = 0
        
        
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
                
                print("Screen Skipped!")
                
                self.resultJSON["Screen"].int = -1
                UserDefaults.standard.set(false, forKey: "screen")
                
                self.touchDownTimer.invalidate()
                self.touchTimeCount = 0
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.screenRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.screenTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            case 2:
                
                self.startTouchTimer()
                
                break
                
            default:
                
                break
                
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    func ShowTouchPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Are you there?"
        popUpVC.strMessage = "You've been inactive for a while."
        popUpVC.strBtnYesTitle = "Cancel"
        popUpVC.strBtnNoTitle = "Ok"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowFirstBtn = false
        popUpVC.isShowSecondBtn = true
        popUpVC.isShowThirdBtn = false
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("cancel clicked")
                
            case 2:
                
                print("ok clicked")
                
                DispatchQueue.main.async {
                    self.touchDownTimer.invalidate()
                    self.touchTimeCount = 0
                    self.startTouchTimer()
                }
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
}

class LevelView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
        let levelLayer = CAShapeLayer()
        levelLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                           y: 0,
                                                           width: frame.width,
                                                           height: frame.height),
                                       cornerRadius: 0).cgPath
        
        levelLayer.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(levelLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required, but Will not be called in a Playground")
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
