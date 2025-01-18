//
//  SummaryVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 14/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import BiometricAuthentication
import JGProgressHUD

class SummaryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var testResultTestDiagnosis: ((_ testJSON: JSON) -> Void)?
    
    @IBOutlet weak var failSkipCollectionView: UICollectionView!
    @IBOutlet weak var connectivityCollectionView: UICollectionView!
    @IBOutlet weak var audioCollectionView: UICollectionView!
    @IBOutlet weak var sensorCollectionView: UICollectionView!
    @IBOutlet weak var screenCollectionView: UICollectionView!
    @IBOutlet weak var hardwareCollectionView: UICollectionView!
    
    @IBOutlet weak var lblFailSkipTest: UILabel!
    @IBOutlet weak var lblFailSkipHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPassedTest: UILabel!
    @IBOutlet weak var lblPassedHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var failSkipCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectivityCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sensorCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var screenCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hardwareCollectionViewHeightConstraint: NSLayoutConstraint!
    
    /*
     let arrFailSkipTest = ["Camera","Torch","Autofocus","microusb slot"]
     let arrConnectivityTests = ["GSM Network","Wifi","Bluetooth","GPS","NFC"]
     let arrAudioTests = ["Speaker","Microphone"]
     let arrSensorTests = ["Vibrator","Auto Rotation","Proximity","fingerprint scanner"]
     let arrScreenTests = ["Screen","Dead Pixels"]
     let arrHardwareTests = ["Battery","Storage","Device Buttons"]
     */
    
    // ["wifi", "bluetooth", "earphone jack", "battery", "storage", "gps", "nfc", "gsm network", "vibrator", "auto rotation", "proximity", "fingerprint scanner", "dead pixels", "screen", "microusb slot", "autofocus", "camera", "torch", "device buttons", "speaker", "microphone"]
    
    var arrFailSkipTest = [ModelCompleteDiagnosticFlow]()
    var arrConnectivityTests = [ModelCompleteDiagnosticFlow]()
    var arrAudioTests = [ModelCompleteDiagnosticFlow]()
    var arrSensorTests = [ModelCompleteDiagnosticFlow]()
    var arrScreenTests = [ModelCompleteDiagnosticFlow]()
    var arrHardwareTests = [ModelCompleteDiagnosticFlow]()
    
    let greenBaseColor = #colorLiteral(red: 0.8862745098, green: 0.9882352941, blue: 0.9254901961, alpha: 1)
    let yellowBaseColor = #colorLiteral(red: 1, green: 0.9843137255, blue: 0.9137254902, alpha: 1)
    let redBaseColor = #colorLiteral(red: 1, green: 0.9294117647, blue: 0.9529411765, alpha: 1)
    
    var resultJSON = JSON()
    var appCodeStr = ""
    
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("rsltJson on Summary page in ViewDidLoad:", self.resultJSON)
        
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        registerCVCellForTests()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.arrFailSkipTest.count > 0 {
            self.failSkipCollectionView.removeObserver(self, forKeyPath: "contentSize")
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "contentSize") {
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.failSkipCollectionViewHeightConstraint.constant = newsize.height + 60.0
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("rsltJson on Summary page in viewWillDisappear:", self.resultJSON)
        
        self.arrFailSkipTest = []
        self.arrConnectivityTests = []
        self.arrAudioTests = []
        self.arrSensorTests = []
        self.arrScreenTests = []
        self.arrHardwareTests = []
        
        //MARK: arrConnectivityTests
        
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GSM Network"
            
            if self.resultJSON["GSM"].int == 0 {
                model.strTestIconName = "icon_mobile_network_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_mobile_network_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GSM Network"
            model.strTestIconName = "icon_mobile_network_green"
            model.bgColor = greenBaseColor
            arrConnectivityTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "WIFI")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "WIFI"
            
            if self.resultJSON["WIFI"].int == 0 {
                model.strTestIconName = "icon_wifi_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_wifi_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "WIFI"
            model.strTestIconName = "icon_wifi_green"
            model.bgColor = greenBaseColor
            arrConnectivityTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Bluetooth"
            
            if self.resultJSON["Bluetooth"].int == 0 {
                model.strTestIconName = "icon_bluetooth_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_bluetooth_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Bluetooth"
            model.strTestIconName = "icon_bluetooth_green"
            model.bgColor = greenBaseColor
            arrConnectivityTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "GPS")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GPS"
            
            if self.resultJSON["GPS"].int == 0 {
                model.strTestIconName = "icon_gps_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_gps_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "GPS"
            model.strTestIconName = "icon_gps_green"
            model.bgColor = greenBaseColor
            arrConnectivityTests.append(model)
        }
        
        //MARK: arrAudioTests
        
        if(!UserDefaults.standard.bool(forKey: "Speakers")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Speaker"
            
            if self.resultJSON["Speakers"].int == 0 {
                model.strTestIconName = "icon_speaker_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_speaker_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Speaker"
            model.strTestIconName = "icon_speaker_green"
            model.bgColor = greenBaseColor
            arrAudioTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "mic")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Microphone"
            
            if self.resultJSON["MIC"].int == 0 {
                model.strTestIconName = "icon_mic_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_mic_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Microphone"
            model.strTestIconName = "icon_mic_green"
            model.bgColor = greenBaseColor
            arrAudioTests.append(model)
        }
        
        //MARK: arrSensorTests
        
        if(!UserDefaults.standard.bool(forKey: "Vibrator")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Vibrator"
            
            if self.resultJSON["Vibrator"].int == 0 {
                model.strTestIconName = "icon_vibration_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_vibration_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Vibrator"
            model.strTestIconName = "icon_vibration_green"
            model.bgColor = greenBaseColor
            arrSensorTests.append(model)
            
            self.resultJSON["Vibrator"].int = 1
        }
        
        if(!UserDefaults.standard.bool(forKey: "rotation")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Rotation"
            
            if self.resultJSON["Rotation"].int == 0 {
                model.strTestIconName = "icon_screen_rotation_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_screen_rotation_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Rotation"
            model.strTestIconName = "icon_screen_rotation_green"
            model.bgColor = greenBaseColor
            arrSensorTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "proximity")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Proximity"
            
            if self.resultJSON["Proximity"].int == 0 {
                model.strTestIconName = "icon_proximity_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_proximity_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Proximity"
            model.strTestIconName = "icon_proximity_green"
            model.bgColor = greenBaseColor
            arrSensorTests.append(model)
        }
        
        var biometricTest = ""
        var biometricIcon = ""
        if BioMetricAuthenticator.canAuthenticate() {
            
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                biometricTest = "Face-Id Scanner"
            }else {
                biometricTest = "Fingerprint Scanner"
            }
            
            if(!UserDefaults.standard.bool(forKey: "fingerprint")) {
                let model = ModelCompleteDiagnosticFlow()
                model.strTestName = biometricTest
                
                if self.resultJSON["Fingerprint Scanner"].int == 0 {
                    
                    model.bgColor = redBaseColor
                    
                    if biometricTest == "Face-Id Scanner" {
                        model.strTestIconName = "icon_faceid_red"
                    }else {
                        model.strTestIconName = "icon_fingerprint_red"
                    }
                    
                }else {
                    //model.strTestIconName = "icon_fingerprint_yellow"
                    model.bgColor = yellowBaseColor
                    
                    if biometricTest == "Face-Id Scanner" {
                        model.strTestIconName = "icon_faceid_yellow"
                    }else {
                        model.strTestIconName = "icon_fingerprint_yellow"
                    }
                }
                
                arrFailSkipTest.append(model)
            }
            else{
                let model = ModelCompleteDiagnosticFlow()
                model.strTestName = biometricTest
                //model.strTestIconName = "icon_fingerprint_green"
                                
                if biometricTest == "Face-Id Scanner" {
                    model.strTestIconName = "icon_faceid_green"
                }else {
                    model.strTestIconName = "icon_fingerprint_green"
                }
                
                model.bgColor = greenBaseColor
                arrSensorTests.append(model)
            }
            
        }else {
            biometricTest = "Biometric Authentication"
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = biometricTest
            model.strTestIconName = "icon_fingerprint_red"
            model.bgColor = redBaseColor
            arrFailSkipTest.append(model)
        }
        
        //MARK: arrScreenTests
        
        if(!UserDefaults.standard.bool(forKey: "screen")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Screen"
            
            if self.resultJSON["Screen"].int == 0 {
                model.strTestIconName = "icon_screen_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_screen_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Screen"
            model.strTestIconName = "icon_screen_green"
            model.bgColor = greenBaseColor
            arrScreenTests.append(model)
        }
        
        if (!UserDefaults.standard.bool(forKey: "deadPixel")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Dead Pixels"
            
            if self.resultJSON["Dead Pixels"].int == 0 {
                model.strTestIconName = "icon_dead_pixel_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_dead_pixel_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Dead Pixels"
            model.strTestIconName = "icon_dead_pixel_green"
            model.bgColor = greenBaseColor
            arrScreenTests.append(model)
        }
        
        //MARK: arrHardwareTests
        
        if(!UserDefaults.standard.bool(forKey: "camera")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Camera"
            
            if self.resultJSON["Camera"].int == 0 {
                model.strTestIconName = "icon_camera_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_camera_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Camera"
            model.strTestIconName = "icon_camera_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "camera")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Autofocus"
            
            if self.resultJSON["Camera"].int == 0 {
                model.strTestIconName = "icon_battery_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_battery_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Autofocus"
            model.strTestIconName = "icon_battery_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "charger")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Charger"
            
            if self.resultJSON["USB"].int == 0 {
                model.strTestIconName = "icon_usb_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_usb_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Charger"
            model.strTestIconName = "icon_usb_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "volume")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Device Button"
            
            if self.resultJSON["Hardware Buttons"].int == 0 {
                model.strTestIconName = "icon_button_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_button_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Device Button"
            model.strTestIconName = "icon_button_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Battery")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Battery"
            
            if self.resultJSON["Battery"].int == 0 {
                model.strTestIconName = "icon_battery_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_battery_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Battery"
            model.strTestIconName = "icon_battery_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Storage")) {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Storage"
            
            if self.resultJSON["Storage"].int == 0 {
                model.strTestIconName = "icon_sim_red"
                model.bgColor = redBaseColor
            }else {
                model.strTestIconName = "icon_sim_yellow"
                model.bgColor = yellowBaseColor
            }
            
            arrFailSkipTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.strTestName = "Storage"
            model.strTestIconName = "icon_sim_green"
            model.bgColor = greenBaseColor
            arrHardwareTests.append(model)
        }
        
        DispatchQueue.main.async {
            
            //1.
            if self.arrFailSkipTest.count > 0 {
                
                self.failSkipCollectionView.delegate = self
                self.failSkipCollectionView.dataSource = self
                self.failSkipCollectionView.reloadData()
                
                self.failSkipCollectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            }
            else {
                self.failSkipCollectionViewHeightConstraint.constant = 0
            }
            
            //2.
            if self.arrConnectivityTests.count > 0 {
                
                self.connectivityCollectionView.delegate = self
                self.connectivityCollectionView.dataSource = self
                self.connectivityCollectionView.reloadData()
                
                self.connectivityCollectionViewHeightConstraint.constant = 200
                
            }else {
                self.connectivityCollectionViewHeightConstraint.constant = 0
            }
            
            //3.
            if self.arrAudioTests.count > 0 {
                
                self.audioCollectionView.delegate = self
                self.audioCollectionView.dataSource = self
                self.audioCollectionView.reloadData()
                
                self.audioCollectionViewHeightConstraint.constant = 200
                
            }else {
                self.audioCollectionViewHeightConstraint.constant = 0
            }
            
            //4.
            if self.arrSensorTests.count > 0 {
                
                self.sensorCollectionView.delegate = self
                self.sensorCollectionView.dataSource = self
                self.sensorCollectionView.reloadData()
                
                self.sensorCollectionViewHeightConstraint.constant = 200
                
            }else {
                self.sensorCollectionViewHeightConstraint.constant = 0
            }
            
            //5.
            if self.arrScreenTests.count > 0 {
                
                self.screenCollectionView.delegate = self
                self.screenCollectionView.dataSource = self
                self.screenCollectionView.reloadData()
                
                self.screenCollectionViewHeightConstraint.constant = 200
                
            }else {
                self.screenCollectionViewHeightConstraint.constant = 0
            }
            
            //6.
            if self.arrHardwareTests.count > 0 {
                
                self.hardwareCollectionView.delegate = self
                self.hardwareCollectionView.dataSource = self
                self.hardwareCollectionView.reloadData()
                
                self.hardwareCollectionViewHeightConstraint.constant = 200
                
            }else {
                self.hardwareCollectionViewHeightConstraint.constant = 0
            }
            
        }
        
        
        /*
         if(!UserDefaults.standard.bool(forKey: "Torch")) {
         let model = ModelCompleteDiagnosticFlow()
         model.priority = 18
         model.strTestName = "Torch"
         arrFailSkipTest.append(model)
         }
         else{
         let model = ModelCompleteDiagnosticFlow()
         model.priority = 0
         model.strTestName = "Torch"
         arrFunctionalTest.append(model)
         }
         */
        
    }
    
    //MARK: IBAction
    @IBAction func continueBtnPressed(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CrackCheckVC") as! CrackCheckVC
        print("Result JSON before CrackCheckVC page: \(self.resultJSON)")
        vc.resultJSON = self.resultJSON
        vc.appCodeStr = self.appCodeStr
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //MARK: Custom Methods
    func registerCVCellForTests() {
        
        self.failSkipCollectionView.register(UINib(nibName: "testTableCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testTableCollectionVWCell")
        
        self.connectivityCollectionView.register(UINib(nibName: "testCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testCollectionVWCell")
        self.audioCollectionView.register(UINib(nibName: "testCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testCollectionVWCell")
        self.sensorCollectionView.register(UINib(nibName: "testCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testCollectionVWCell")
        self.screenCollectionView.register(UINib(nibName: "testCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testCollectionVWCell")
        self.hardwareCollectionView.register(UINib(nibName: "testCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "testCollectionVWCell")
        
    }
    
    //MARK: UICollectionView DataSource & Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case self.failSkipCollectionView:
            
            return self.arrFailSkipTest.count
            
        case self.connectivityCollectionView:
            
            return self.arrConnectivityTests.count
            
        case self.audioCollectionView:
            
            return self.arrAudioTests.count
            
        case self.sensorCollectionView:
            
            return self.arrSensorTests.count
            
        case self.screenCollectionView:
            
            return self.arrScreenTests.count
            
        default:
            //self.hardwareCollectionView
            
            return self.arrHardwareTests.count
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case self.failSkipCollectionView:
            
            let testTableCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testTableCollectionVWCell", for: indexPath) as! testTableCollectionVWCell
            
            testTableCollectionVWCell.testImgBaseVW.layer.cornerRadius = testTableCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testTableCollectionVWCell.testImgBaseVW.backgroundColor = self.arrFailSkipTest[indexPath.item].bgColor
            
            testTableCollectionVWCell.testImgVW.image = UIImage(named: self.arrFailSkipTest[indexPath.item].strTestIconName)
            testTableCollectionVWCell.lblTestName.text = self.arrFailSkipTest[indexPath.item].strTestName
            
            return testTableCollectionVWCell
            
        case self.connectivityCollectionView:
            
            let testCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCollectionVWCell", for: indexPath) as! testCollectionVWCell
            
            testCollectionVWCell.testImgBaseVW.layer.cornerRadius = testCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testCollectionVWCell.testImgBaseVW.backgroundColor = self.arrConnectivityTests[indexPath.item].bgColor
            
            testCollectionVWCell.testImgVW.image = UIImage(named: self.arrConnectivityTests[indexPath.item].strTestIconName)
            testCollectionVWCell.lblTestName.text = self.arrConnectivityTests[indexPath.item].strTestName
            
            return testCollectionVWCell
            
        case self.audioCollectionView:
            
            let testCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCollectionVWCell", for: indexPath) as! testCollectionVWCell
            
            testCollectionVWCell.testImgBaseVW.layer.cornerRadius = testCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testCollectionVWCell.testImgBaseVW.backgroundColor = self.arrAudioTests[indexPath.item].bgColor
            
            testCollectionVWCell.testImgVW.image = UIImage(named: self.arrAudioTests[indexPath.item].strTestIconName)
            testCollectionVWCell.lblTestName.text = self.arrAudioTests[indexPath.item].strTestName
            
            return testCollectionVWCell
            
        case self.sensorCollectionView:
            
            let testCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCollectionVWCell", for: indexPath) as! testCollectionVWCell
            
            testCollectionVWCell.testImgBaseVW.layer.cornerRadius = testCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testCollectionVWCell.testImgBaseVW.backgroundColor = self.arrSensorTests[indexPath.item].bgColor
            
            testCollectionVWCell.testImgVW.image = UIImage(named: self.arrSensorTests[indexPath.item].strTestIconName)
            testCollectionVWCell.lblTestName.text = self.arrSensorTests[indexPath.item].strTestName
            
            return testCollectionVWCell
            
        case self.screenCollectionView:
            
            let testCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCollectionVWCell", for: indexPath) as! testCollectionVWCell
            
            testCollectionVWCell.testImgBaseVW.layer.cornerRadius = testCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testCollectionVWCell.testImgBaseVW.backgroundColor = self.arrScreenTests[indexPath.item].bgColor
            
            testCollectionVWCell.testImgVW.image = UIImage(named: self.arrScreenTests[indexPath.item].strTestIconName)
            testCollectionVWCell.lblTestName.text = self.arrScreenTests[indexPath.item].strTestName
            
            return testCollectionVWCell
            
        default:
            //self.hardwareCollectionView
            
            let testCollectionVWCell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCollectionVWCell", for: indexPath) as! testCollectionVWCell
            
            testCollectionVWCell.testImgBaseVW.layer.cornerRadius = testCollectionVWCell.testImgBaseVW.bounds.size.width/2
            testCollectionVWCell.testImgBaseVW.backgroundColor = self.arrHardwareTests[indexPath.item].bgColor
            
            testCollectionVWCell.testImgVW.image = UIImage(named: self.arrHardwareTests[indexPath.item].strTestIconName)
            testCollectionVWCell.lblTestName.text = self.arrHardwareTests[indexPath.item].strTestName
            
            return testCollectionVWCell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.failSkipCollectionView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.width/4)
        }
        else {
            return CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.width/3)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.arrFailSkipTest.count > 0 {
            
            if collectionView == self.failSkipCollectionView {
                
                if self.arrFailSkipTest[indexPath.row].strTestName == "Dead Pixels" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelVC") as! DeadPixelVC
                    vc.isComingFromTestResult = true
                    
                    vc.deadPixelRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else if self.arrFailSkipTest[indexPath.row].strTestName == "Screen" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                    vc.isComingFromTestResult = true
                    
                    vc.screenRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  self.arrFailSkipTest[indexPath.row].strTestName == "Rotation" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.isComingFromTestResult = true
                    
                    vc.rotationRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  self.arrFailSkipTest[indexPath.row].strTestName == "Proximity" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.isComingFromTestResult = true
                    
                    vc.proximityRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  self.arrFailSkipTest[indexPath.row].strTestName == "Device Button" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeRockerVC") as! VolumeRockerVC
                    vc.isComingFromTestResult = true
                    
                    vc.volumeRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                /*
                 else if  self.arrFailSkipTest[indexPath.row].strTestName == "Earphone" {
                 
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneJackVC") as! EarphoneJackVC
                 vc.isComingFromTestResult = true
                 
                 vc.earphoneRetryDiagnosis = { retryJSON in
                 self.resultJSON = retryJSON
                 }
                 
                 vc.resultJSON = self.resultJSON
                 vc.modalPresentationStyle = .fullScreen
                 self.present(vc, animated: true, completion: nil)
                 
                 }
                 */
                else if  self.arrFailSkipTest[indexPath.row].strTestName == "Charger" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
                    vc.isComingFromTestResult = true
                    
                    vc.chargerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  self.arrFailSkipTest[indexPath.row].strTestName == "Camera" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if self.arrFailSkipTest[indexPath.row].strTestName == "Fingerprint Scanner" || self.arrFailSkipTest[indexPath.row].strTestName == "Face-Id Scanner" || self.arrFailSkipTest[indexPath.row].strTestName == "Biometric Authentication" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
                    vc.isComingFromTestResult = true
                    
                    vc.biometricRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if self.arrFailSkipTest[indexPath.row].strTestName == "Bluetooth" || arrFailSkipTest[indexPath.row].strTestName == "GPS" ||  arrFailSkipTest[indexPath.row].strTestName == "GSM Network" || arrFailSkipTest[indexPath.row].strTestName == "SMS Verification" || arrFailSkipTest[indexPath.row].strTestName == "NFC" || arrFailSkipTest[indexPath.row].strTestName == "Battery" || arrFailSkipTest[indexPath.row].strTestName == "Storage" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalTestsVC") as! InternalTestsVC
                    vc.isComingFromTestResult = true
                    
                    vc.backgroundRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if self.arrFailSkipTest[indexPath.row].strTestName == "WIFI" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                    vc.isComingFromTestResult = true
                    
                    vc.wifiRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if self.arrFailSkipTest[indexPath.row].strTestName == "Microphone" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
                    vc.isComingFromTestResult = true
                    
                    vc.micRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else if self.arrFailSkipTest[indexPath.row].strTestName == "Speaker" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.isComingFromTestResult = true
                    
                    vc.speakerRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else if self.arrFailSkipTest[indexPath.row].strTestName == "Vibrator" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.isComingFromTestResult = true
                    
                    vc.vibratorRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else if self.arrFailSkipTest[indexPath.row].strTestName == "Torch" {
                    
                    //let vc  = TorchVC()
                    //vc.isComingFromTestResult = true
                    //vc.resultJSON = self.resultJSON
                    //vc.modalPresentationStyle = .fullScreen
                    //self.present(vc, animated: true, completion: nil)
                    
                }else if self.arrFailSkipTest[indexPath.row].strTestName == "Autofocus" {
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                    vc.isComingFromTestResult = true
                    
                    vc.cameraRetryDiagnosis = { retryJSON in
                        self.resultJSON = retryJSON
                    }
                    
                    vc.resultJSON = self.resultJSON
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
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
