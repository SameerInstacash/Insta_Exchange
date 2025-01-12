//
//  DeadPixelVC.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 18/03/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import PopupDialog
import QRCodeReader
import AVFoundation
//import SwiftGifOrigin //SAMEER 27/6/23
import AudioToolbox
import SwiftyJSON
import CoreMotion
import AVFoundation

class DeadPixelVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var deadPixelRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var deadPixelTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    //@IBOutlet weak var deadPixelNavBar: UINavigationBar!
    //@IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var deadPixelInfoImage: UIImageView!
    //@IBOutlet weak var deadPixelInfo: UILabel!
    @IBOutlet weak var startTestBtn: UIButton!
    
    //@IBOutlet weak var pixelView: UIView!
    
    var testPixelView = UIView()
    var pixelTimer : Timer?
    var pixelTimerIndex = 0
    var resultJSON = JSON()
    //var audioPlayer = AVAudioPlayer()
    
    var audioPlayer : AVAudioPlayer?
    
    var recordingSession : AVAudioSession!
    var isComingFromTestResult = false
    
    //let audioSession = AVAudioSession.sharedInstance()
    var audioSession : AVAudioSession? = nil
    
    //MARK: SAMEER 7/6/23
    //var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    //var audioPlayer:AVAudioPlayer!
    //var audioSession : AVAudioSession? = nil
    private var timer: Timer?
    private var timerCount = 0
    //
    
    ////var recording: Recording?
    ////var recordDuration = 0
    ////var isBitRate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        
        //SAMEER on 27/6/23 due to crash -> ASan
        //deadPixelInfoImage.loadGif(name: "dead_pixel")
        
        
        // Load GIF In Image view
        //let jeremyGifUp = UIImage.gifImageWithName("dead_pixel")
        //self.deadPixelInfoImage.image = jeremyGifUp
        //self.deadPixelInfoImage.stopAnimating()
        //self.deadPixelInfoImage.startAnimating()
        
        
        //self.checkMicrophone()
        //self.checkVibrator()
        //self.playSound()
        
        //MARK: SAMEER 27/6/23
        //DispatchQueue.main.async {
        //self.configureAudioSessionCategory()
        //self.playSound()
        //}
        
        
        //MARK: SAMEER 27/6/23
        // MARK: Speaker & Microphone
        DispatchQueue.main.async {
            self.testSpeakerAndMicrophone()
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkVibrator()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
        
    }
    
    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Dead Pixel")
        
        //self.deadPixelInfo.text = self.getLocalizatioStringValue(key: "Click ‘Start test’. Test will begin and different coloured screens will appear for 12 seconds. If you see any black or white spot/spots on your screen, please click ‘Yes’.")
        
        //self.deadPixelInfo.text = self.getLocalizatioStringValue(key: "Click “Start Test”. Test will begin and different colored screens will be displayed.If you see any white or black spots on your screen, please click “Yes”")
        
        //"Click “Start Test”. Test will begin and different colored screens will be displayed.If you see any white or black spots on your screen, please click “Yes”" : "Click “Start Test”. Test will begin and different colored screens will be displayed.If you see any white or black spots on your screen, please click “Yes”\n स्टार्ट क्लि क गर्नुसर्नु । अनि टेस्ट सरुु हुनेछ र वि भि न्न रंगीन स्क्रि नहरू प्रदर्शनर्श गरि नेछ। यदि तपाईंले आफ्नो स्क्रि नमा कुनैसेतो वा कालो दागहरू देख्नभु यो भने, कृपया “एस” मा क्लि क गर्नुहर्नुोस ्"
                
        self.startTestBtn.setTitle(self.getLocalizatioStringValue(key: "Start Test"), for: .normal)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureAudioSessionCategory() {
        //print("Configuring audio session")
        do {
            
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession?.setActive(true)
            try audioSession?.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            //print("AVAudio Session out options: ", audioSession?.currentRoute ?? 0)
            //print("Successfully configured audio session.")
            
        } catch (let error) {
            print("Error while configuring audio session: \(error)")
        }
    }
        
    @IBAction func startDeadPixelTest(_ sender: AnyObject) {
                
        //self.deadPixelNavBar.isHidden = true
        
        // Sameer
        //self.resultJSON["Speakers"].int = 1
        //self.resultJSON["MIC"].int = 1
        //UserDefaults.standard.set(true, forKey: "mic")
        
        /* Sameer 2/9/23
        pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.startTestBtn.isHidden = true
        self.deadPixelInfo.isHidden = true
        self.deadPixelInfoImage.isHidden = true
        */
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.testPixelView.frame = screenSize
        self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(self.testPixelView)
        
        DispatchQueue.main.async {
            self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        }
        
    }
    
    @IBAction func skipBtnPressed(_ sender: UIButton) {
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
                
                print("Dead Pixel Skipped!")
                
                self.resultJSON["Dead Pixels"].int = -1
                UserDefaults.standard.set(false, forKey: "deadPixel")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
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
    
    @objc func setRandomBackgroundColor() {
        self.pixelTimerIndex += 1
        
        let colors = [
            #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.003921568627, blue: 0.9843137255, alpha: 1),#colorLiteral(red: 0.003921568627, green: 0.003921568627, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 1, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ]
        
        switch self.pixelTimerIndex {
            
        case 5:
            
            self.testPixelView.removeFromSuperview()
            
            //self.view.backgroundColor = colors[pixelTimerIndex]
            self.pixelTimer?.invalidate()
            self.pixelTimer = nil
            
            self.ShowPopUpForDeadPixel()
                        
            /*
            // Prepare the popup assets
            let title = self.getLocalizatioStringValue(key: "Dead Pixel Test")
            //let message = self.getLocalizatioStringValue(key: "Did you see any black or white spots on the screen?")
            let message = self.getLocalizatioStringValue(key: "Did you find any spot?")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
                
                self.secondConfirmationPopUpShow()
                
                //MARK: Comment on 18/11/23 due to Ajay ask to add second confirmation popUp
                /*
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                if self.isComingFromTestResult {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                                      
                }
                */
                
            }
            
            let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
                
                //MARK: Add on 1/12/23
                //self.deadPixelInfoImage.stopAnimating()
                //self.deadPixelInfoImage = nil
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                if self.isComingFromTestResult {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                    /*
                    self.dismiss(animated: false) {
                        guard let present = self.presentDeadPixelTest else { return }
                        present(self.resultJSON)
                    }
                    */
                              
                    
                }
                
            }
            
            let buttonThree = DefaultButton(title: self.getLocalizatioStringValue(key: "Retry")) {
                
                self.pixelTimerIndex = 0
                
                let screenSize: CGRect = UIScreen.main.bounds
                self.testPixelView.frame = screenSize
                self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.view.addSubview(self.testPixelView)
                
                DispatchQueue.main.async {
                    self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
                }
                
                /*
                self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
                self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.startTestBtn.isHidden = true
                self.deadPixelInfo.isHidden = true
                self.deadPixelInfoImage.isHidden = true
                self.pixelTimerIndex = 0
                */
                
            }
            
                        
            // Add buttons to dialog
            // Alternatively, you can use popup.addButton(buttonOne)
            // to add a single button
            popup.addButtons([buttonOne, buttonTwo,buttonThree])
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
            
            break
            
        default:
            //self.view.backgroundColor = colors[0]
            
            if self.pixelTimerIndex < colors.count {
                DispatchQueue.main.async {
                    self.testPixelView.backgroundColor = colors[self.pixelTimerIndex]
                }
            }
            
        }
        
    }
    
    func ShowPopUpForDeadPixel() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        popUpVC.strTitle = "Dead Pixels"
        popUpVC.strMessage = "Did you find any spot?"
        popUpVC.strBtnYesTitle = "Yes"
        popUpVC.strBtnNoTitle = "No"
        popUpVC.strBtnRetryTitle = "Retry"
        popUpVC.isShowThirdBtn = true
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            case 2:
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = false
                    //self.view.makeToast("Test Passed!", duration: 1.0, position: .bottom)
                }
                
                //DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    if self.isComingFromTestResult {
                        
                        guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                        didFinishRetryDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    else{
                        
                        guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                        didFinishTestDiagnosis(self.resultJSON)
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                    
                //}
                
            default:
                
                self.pixelTimerIndex = 0
                self.startDeadPixelTest(UIButton())
                                
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }

    func secondConfirmationPopUpShow() {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Dead Pixel Test")
        let message = self.getLocalizatioStringValue(key: "Please confirm, you got the spot on the screen?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            //MARK: Add on 1/12/23
            //self.deadPixelInfoImage.stopAnimating()
            //self.deadPixelInfoImage = nil
            
            self.resultJSON["Dead Pixels"].int = 0
            UserDefaults.standard.set(false, forKey: "deadPixel")
            print("Dead Pixel Failed!")
            
            if self.isComingFromTestResult {
                                    
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                vc.resultJSON = self.resultJSON
                self.present(vc, animated: true, completion: nil)
                                  
            }
            
        }
        
        
        let buttonThree = DefaultButton(title: self.getLocalizatioStringValue(key: "Retry")) {
            
            self.pixelTimerIndex = 0
            
            let screenSize: CGRect = UIScreen.main.bounds
            self.testPixelView.frame = screenSize
            self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.view.addSubview(self.testPixelView)
            
            DispatchQueue.main.async {
                self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
            }
            
        }
                    
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne,buttonThree])
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
    
    
//    func playUsingAVAudioPlayer(url: URL) {
//        var audioPlayer: AVAudioPlayer?
//        self.resultJSON["Speakers"].int = 1
//        self.resultJSON["MIC"].int = 1
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.play()
//            print("playing audio")
//        } catch {
//            print(error)
//        }
//    }
    

    func checkVibrator() {
        
        self.resultJSON["Vibrator"].int = 0
        UserDefaults.standard.set(false, forKey: "Vibrator")
        
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let x = data?.userAcceleration.x,
                    x > 0.03 {
                    
                    print("Device Vibrated at: \(x)")
                    self?.resultJSON["Vibrator"].int = 1
                    UserDefaults.standard.set(true, forKey: "Vibrator")
                    
                    manager.stopDeviceMotionUpdates()
                }
            }
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
        
    //MARK: SAMEER 27/6/23
    func testSpeakerAndMicrophone() {
        
        //self.configureAudioSessionCategory()
        
        //setup Recorder
        self.setupView()
        
    }
    
    func setupView() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        //self.loadRecordingUI()
                        self?.recordAudioButtonTapped()
                        
                    } else {
                        // failed to record
                        
                        self?.failMarkSpeakerAndMicTest()
                        
                        DispatchQueue.main.async() {
                            self?.view.makeToast(self?.getLocalizatioStringValue(key: "Please give microphone permission"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                }
            }
        } catch {
            // failed to record
            
            self.failMarkSpeakerAndMicTest()
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "failed to record!"), duration: 2.0, position: .bottom)
            }
            
        }
    }
    
    func failMarkSpeakerAndMicTest() {
        
        self.resultJSON["Speakers"].int = 0
        UserDefaults.standard.set(false, forKey: "Speakers")
        
        self.resultJSON["MIC"].int = 0
        UserDefaults.standard.set(false, forKey: "mic")
        
    }
    
    func recordAudioButtonTapped() {
        if audioRecorder == nil {
            
            self.failMarkSpeakerAndMicTest()
            
            self.startRecording()
            
        } else {
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        
        let audioFilename = getFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            //audioRecorder.record()
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(DeadPixelVC.updateAudioMeter(timer:)), userInfo: nil, repeats: true)
            
            audioRecorder.record()
            
           
            // SAM START
            
            self.audioSession = AVAudioSession.sharedInstance()
            
            do {
                
                try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession?.setActive(true)
                try audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                //print("AVAudio Session out options: ", audioSession?.currentRoute ?? 0)
                print("Successfully configured audio session.")
                
            } catch let error as NSError {
                print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
            }
            
            guard let filePath = Bundle.main.path(forResource: "whistle", ofType: "mp3") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                self.audioPlayer?.play()
            }catch {
                print("error.localizedDescription",error.localizedDescription)
            }
            
            // SAM END
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }
    
    //var arrWorking = [String]()
    //var arrNotWorking = [String]()
    
    @objc func updateAudioMeter(timer: Timer) {
        
        if (audioRecorder.isRecording == true) {
            
            // update power values
            audioRecorder.updateMeters()
            
            let peak0 = audioRecorder.peakPower(forChannel: 0)
            print("peak0 = \(peak0)")
            
            
            if peak0 <= 0 && peak0 >= -19 {
                // Speaker is working
                 print("Speaker is working")
                // self.arrWorking.append("Speaker is working")
                
                self.resultJSON["Speakers"].int = 1
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                self.resultJSON["MIC"].int = 1
                UserDefaults.standard.set(true, forKey: "mic")
                                
                
            }else {
                 print("Speaker is not working")
                // self.arrNotWorking.append("Speaker is not working")
            }            
                                
            
            timerCount += 1
            //print("timerCount",timerCount)
            
            if timerCount == 50 {
                timer.invalidate()
                
                self.finishRecording(success: true)
                
            }
                        
        }
    }
    
    //MARK: Delegates
    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    @objc func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //recordButton.isEnabled = true
        //playButton.setTitle("Play", for: .normal)
    }
    
    @objc func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
        
    
    //MARK: UnUsed Methods
    func playSound() {

            guard let url = Bundle.main.path(forResource: "whistle", ofType: "mp3") else {
                print("not found")
                return
            }
            
            
            // 8/10/21
            // This is to audio output from bottom (main) speaker
            do {
                try self.audioSession?.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try self.audioSession?.setActive(true)
                //print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",self.audioSession?.currentRoute.outputs)
            } catch let error as NSError {
                print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
            }
            
            
            do {
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
                self.audioPlayer?.play()
                
                let outputVol = AVAudioSession.sharedInstance().outputVolume
                
                if(outputVol > 0.20) {
                    self.resultJSON["Speakers"].int = 1
                    UserDefaults.standard.set(true, forKey: "Speakers")
                    
                    //self.resultJSON["MIC"].int = 1
                }else{
                    self.resultJSON["Speakers"].int = 0
                    UserDefaults.standard.set(false, forKey: "Speakers")
                    
                    //self.resultJSON["MIC"].int = 0
                }
            } catch let error {
                self.resultJSON["Speakers"].int = 0
                UserDefaults.standard.set(false, forKey: "Speakers")
                
                //self.resultJSON["MIC"].int = 0
                print(error.localizedDescription)
            }
        
    }
    
    @objc func setRandomBackgroundColor_old() {
       
        pixelTimerIndex += 1
        
        let colors = [
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        ]
        
        switch pixelTimerIndex {
        case 5:
            self.view.backgroundColor = colors[0]
            pixelTimer?.invalidate()
            pixelTimer = nil
            
            
            // Prepare the popup assets
            let title = self.getLocalizatioStringValue(key: "Dead Pixel Test")
            //let message = self.getLocalizatioStringValue(key: "Did you see any black or white spots on the screen?")
            let message = self.getLocalizatioStringValue(key: "Did you find any spot?")
            
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
                
                //MARK: Add on 1/12/23
                //self.deadPixelInfoImage.stopAnimating()
                //self.deadPixelInfoImage = nil
                
                self.resultJSON["Dead Pixels"].int = 0
                UserDefaults.standard.set(false, forKey: "deadPixel")
                print("Dead Pixel Failed!")
                
                if self.isComingFromTestResult {
                                        
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                    /*
                    self.dismiss(animated: false) {
                        guard let present = self.presentDeadPixelTest else { return }
                        present(self.resultJSON)
                    }*/
                    
                }
                
            }
            
            let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
                
                self.resultJSON["Dead Pixels"].int = 1
                UserDefaults.standard.set(true, forKey: "deadPixel")
                print("Dead Pixel Passed!")
                
                if self.isComingFromTestResult {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                    vc.resultJSON = self.resultJSON
                    self.present(vc, animated: true, completion: nil)
                    
                    /*
                    self.dismiss(animated: false) {
                        guard let present = self.presentDeadPixelTest else { return }
                        present(self.resultJSON)
                    }
                    */
                                        
                }
                
            }
            
            let buttonThree = DefaultButton(title: self.getLocalizatioStringValue(key: "Retry")) {
                
                self.pixelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
                self.view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.startTestBtn.isHidden = true
                //self.deadPixelInfo.isHidden = true
                //self.deadPixelInfoImage.isHidden = true
                self.pixelTimerIndex = 0
                
            }
            
                        
            // Add buttons to dialog
            // Alternatively, you can use popup.addButton(buttonOne)
            // to add a single button
            popup.addButtons([buttonOne, buttonTwo,buttonThree])
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
            break
            
        default:
            self.view.backgroundColor = colors[0]
        }
        
    }
    
    @objc func updateAudioMeter_OLD(timer: Timer) {
        
        if (audioRecorder.isRecording == true) {
            
            // update power values
            audioRecorder.updateMeters()
            
            let peak0 = audioRecorder.peakPower(forChannel: 0)
            print("peak0 = \(peak0)")
            
            
            //let peak1 = audioRecorder.peakPower(forChannel: 1)
            //print("peak1 = \(peak1)")
            //self.meterView.peak = CGFloat(0.8 - peak / -60.0)
            
            
            if peak0 <= 0 && peak0 >= -20 {
                // Speaker is working
                 print("Speaker is working")
                // self.arrWorking.append("Speaker is working")
                
                self.resultJSON["Speakers"].int = 1
                UserDefaults.standard.set(true, forKey: "Speakers")
                
                self.resultJSON["MIC"].int = 1
                UserDefaults.standard.set(true, forKey: "mic")
                
            }else {
                 print("Speaker is not working")
                // self.arrNotWorking.append("Speaker is not working")
            }
                                
            
            timerCount += 1
            //print("timerCount",timerCount)
            
            
            if timerCount == 50 {
                timer.invalidate()
                
                self.finishRecording(success: true)
                
                /*
                if self.arrWorking.count > self.arrNotWorking.count {
                    print("Speaker is working")
                }else {
                    print("Speaker is not working")
                }*/
                
            }
            
        }
    }
    
}
