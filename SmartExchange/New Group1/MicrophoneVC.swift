//
//  MicrophoneVC.swift
//  InstaCash
//
//  Created by Sameer Khan on 04/03/21.
//  Copyright © 2021 Prakhar Gupta. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog
import AVFoundation
import AudioToolbox
//import SwiftGifOrigin //SAMEER 27/6/23

class MicrophoneVC: UIViewController, AVAudioRecorderDelegate, RecorderDelegate {
    
    var micRetryDiagnosis: ((_ testJSON: JSON) -> Void)?
    var micTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var testProgress: UIProgressView!
    @IBOutlet weak var lblTestNum: UILabel!
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCheckingMicrophone: UILabel!
    @IBOutlet weak var lblPleaseEnsure: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var speechImgView: UIImageView!

    var resultJSON = JSON()
    var gameTimer: Timer?
    var runCount = 0
    
    var isComingFromTestResult = false
    var isComingFromProductquote = false
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var recording: Recording?
    var recordDuration = 0
    var isBitRate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        self.hideKeyboardWhenTappedAround()

        //self.setStatusBarColor()
        
        if isComingFromTestResult == false && isComingFromProductquote == false {
            //userDefaults.removeObject(forKey: "Microphone")
            //userDefaults.setValue(false, forKey: "Microphone")
        }
        
        // Recording audio requires a user's permission to stop malicious apps doing malicious things, so we need to request recording permission from the user.
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.loadRecordingUI()
                        
                        //DispatchQueue.main.async() {
                            //self.btnStart.isHidden = false
                        //}
                        
                        self?.createRecorder()
                        
                    } else {
                        // failed to record!
                        DispatchQueue.main.async() {
                            //self?.view.makeToast("failed to record!", duration: 2.0, position: .bottom)
                            self?.view.makeToast(self?.getLocalizatioStringValue(key: "Please give microphone permission"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                }
            }
        } catch {
            // failed to record!
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "failed to record!"), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //AppOrientationUtility.lockOrientation(.portrait)
        
        //self.changeLanguageOfUI()
    }

    func changeLanguageOfUI() {
  
        //self.lblTitle.text = self.getLocalizatioStringValue(key: "Microphone")
        self.lblCheckingMicrophone.text = self.getLocalizatioStringValue(key: "Checking Microphone")
        self.lblPleaseEnsure.text = self.getLocalizatioStringValue(key: "Click to start button. after that microphone will listen your voice for 4 seconds to check your microphone is working or not")
        
        self.btnStart.setTitle(self.getLocalizatioStringValue(key: "Start"), for: .normal)
        self.btnSkip.setTitle(self.getLocalizatioStringValue(key: "Skip"), for: .normal)
    }
    
    open func createRecorder() {
        recording = Recording(to: "recording.m4a")
        recording?.delegate = self
        
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.
        
        DispatchQueue.global().async {
            // Background thread
            do {
                try self.recording?.prepare()
            } catch {
                
            }
        }
    }
    
    open func startRecording(url: URL) {
        recordDuration = 0
        do {
            Timer.scheduledTimer(timeInterval: 5,
                                 target: self,
                                 selector: #selector(self.stopRecording),
                                 userInfo: nil,
                                 repeats: false)
            
            try recording?.record()
            //self.playUsingAVAudioPlayer(url: url)
        } catch {
        }
    }
    
    @objc func stopRecording() {
        recordDuration = 0
        recording?.stop()
        
        if isBitRate {
            self.finishRecording(success: isBitRate)
        }else {
            self.finishRecording(success: isBitRate)
        }
    
        
        /*
        do {
            //try recording.play()
        } catch {
            
        }*/
    }
        
    func audioMeterDidUpdate(_ db: Float) {
        
        self.recording?.recorder?.updateMeters()
        
        let ALPHA = 0.05
        let peakPower = pow(10, (ALPHA * Double((self.recording?.recorder?.peakPower(forChannel: 0))!)))
        var rate: Double = 0.0
        
        if (peakPower <= 0.2) {
            rate = 0.2
        //} else if (peakPower > 0.9) {
        } else if (peakPower > 0.6) {
            rate = 1.0
            self.isBitRate = true
        } else {
            rate = peakPower
        }
        
        print("peakPower",peakPower)
        print("rate",rate)
        recordDuration += 1
    }

    //MARK: button action methods
    @IBAction func onClickStart(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "START") {
            //sender.setTitle("SKIP", for: .normal)
            //self.startTest()
            
            guard recording != nil else {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please give microphone permission"), duration: 2.0, position: .bottom)
                }
                
                return
            }
            
            
            sender.isHidden = true
            self.speechImgView.isHidden = false
            
            /*
            // Load GIF In Image view
            let jeremyGif = UIImage.gifImageWithName("speech")
            self.speechImgView.image = jeremyGif
            self.speechImgView.stopAnimating()
            self.speechImgView.startAnimating()
            */
            
            
            
            //SAMEER on 27/6/23 due to crash -> ASan
            //self.speechImgView.loadGif(name: "speech")
            
            // Load GIF In Image view
            let jeremyGifUp = UIImage.gifImageWithName("speech")
            self.speechImgView.image = jeremyGifUp
            self.speechImgView.stopAnimating()
            self.speechImgView.startAnimating()
            
            
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            self.startRecording(url: audioFilename)
            
        }else {
            self.skipTest()
        }
    
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: false)
        }
        
        
        //Run Timer for 4 Seconds to record the audio
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        runCount += 1
        
        if runCount > 4 {
            self.finishRecording(success: self.isBitRate)
        }
    }
    
    func finishRecording(success: Bool) {
        //audioRecorder.stop()
        audioRecorder = nil
        
        self.gameTimer?.invalidate()
        recording?.recorder?.deleteRecording()
        recording = nil

        if success {
            
            self.resultJSON["MIC"].int = 1
            UserDefaults.standard.set(true, forKey: "mic")
            
            self.goNext()
            
        } else {
            
            self.resultJSON["MIC"].int = 0
            UserDefaults.standard.set(false, forKey: "mic")
            
            self.goNext()
            
        }
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func goNext() {
        /*
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        vc.resultJSON = self.resultJSON
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        */
        
        if self.isComingFromTestResult {
            
            guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
            didFinishRetryDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        else{
            
            guard let didFinishTestDiagnosis = self.micTestDiagnosis else { return }
            didFinishTestDiagnosis(self.resultJSON)
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    func skipTest() {
        
        self.ShowGlobalPopUp()
        
        /*
        // Prepare the popup assets
        
        //let title = "Microphone Test".localized
        let title = self.getLocalizatioStringValue(key: "Microphone Diagnosis")
        let message = self.getLocalizatioStringValue(key: "If you skip this test, there would be a reduction in the price offered. Are You Sure?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {

            if self.isComingFromTestResult {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
                
                self.resultJSON["MIC"].int = -1
                UserDefaults.standard.set(false, forKey: "mic")
                
                vc.resultJSON = self.resultJSON
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
          
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
            //Do Nothing
            //self.btnStart.setTitle("Start".localized, for: .normal)
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
                
                print("Mic Skipped!")
                
                self.resultJSON["MIC"].int = -1
                UserDefaults.standard.set(false, forKey: "mic")
                
                if self.isComingFromTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.micRetryDiagnosis else { return }
                    didFinishRetryDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.micTestDiagnosis else { return }
                    didFinishTestDiagnosis(self.resultJSON)
                    self.dismiss(animated: false, completion: nil)
                    
                }
                                
            case 2:
                
                self.btnStart.setTitle("START", for: .normal)
                
            default:
                                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

