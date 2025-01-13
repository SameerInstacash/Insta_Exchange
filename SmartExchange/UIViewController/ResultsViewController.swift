//
//  ResultsViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 05/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import BiometricAuthentication
import Alamofire
import JGProgressHUD

class ModelCompleteDiagnosticFlow: NSObject {
    var priority = 0
    var strTestType = ""
    var strSucess = ""
}

class ResultsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var testResultTestDiagnosis: ((_ testJSON: JSON) -> Void)?

    @IBOutlet weak var lblTitleTests: UILabel!
    @IBOutlet weak var tableViewTests: UITableView!
    //@IBOutlet weak var heightOfTblTests: NSLayoutConstraint!
    @IBOutlet weak var btnContinue: UIButton!
    
    var arrFailedAndSkipedTest = [ModelCompleteDiagnosticFlow]()
    var arrFunctionalTest = [ModelCompleteDiagnosticFlow]()
    var section = [""]
    var resultJSON = JSON()
    
    var appCodeStr = ""
    
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        
        self.tableViewTests.register(UINib(nibName: "TestResultCell", bundle: nil), forCellReuseIdentifier: "testResultCell")
        self.tableViewTests.register(UINib(nibName: "TestResultTitleCell", bundle: nil), forCellReuseIdentifier: "TestResultTitleCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tableViewTests.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
                
        self.lblTitleTests.text = self.getLocalizatioStringValue(key: "Summary of Test Results")

        self.btnContinue.setTitle(self.getLocalizatioStringValue(key: "Continue"), for: UIControlState.normal)
         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //self.tableViewTests.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        /*
        if (keyPath == "contentSize") {
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightOfTblTests.constant = newsize.height + 20.0
            }
        }
        */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.arrFailedAndSkipedTest.removeAll()
        self.arrFunctionalTest.removeAll()
        
        if (!UserDefaults.standard.bool(forKey: "deadPixel")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 1
            model.strTestType = "Dead Pixels"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Dead Pixels"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "screen")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 1
            model.strTestType = "Screen"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Screen"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "rotation")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 2
            model.strTestType = "Rotation"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Rotation"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "proximity")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 3
            model.strTestType = "Proximity"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Proximity"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "volume")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 4
            model.strTestType = "Hardware Buttons"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Hardware Buttons"
            arrFunctionalTest.append(model)
        }
        
        /* MARK: Ajay told to Remove both test on 27/3/23
        if(!UserDefaults.standard.bool(forKey: "earphone")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 5
            model.strTestType = "Earphone"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Earphone"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "charger")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 6
            model.strTestType = "Charger"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Charger"
            arrFunctionalTest.append(model)
        }
        */
        
        if(!UserDefaults.standard.bool(forKey: "camera")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 7
            model.strTestType = "Camera"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Camera"
            arrFunctionalTest.append(model)
        }
        
        /*
        var biometricTest = ""
        switch UIDevice.current.moName {
            
        case "iPhone X","iPhone XR","iPhone XS","iPhone XS Max","iPhone 11","iPhone 11 Pro","iPhone 11 Pro Max","iPhone 12 mini","iPhone 12","iPhone 12 Pro","iPhone 12 Pro Max":
            
            print("hello faceid available")
            // device supports face id recognition.
            
            biometricTest = "Face-Id Scanner"
            
        default:
            biometricTest = "Fingerprint Scanner"
            
        }
        
        if(!UserDefaults.standard.bool(forKey: "fingerprint")) {
            //if self.resultJSON["Fingerprint Scanner"].int != 0  {
                //if self.resultJSON["Fingerprint Scanner"].int != -2 {
                    let model = ModelCompleteDiagnosticFlow()
                    model.priority = 8
                    //model.strTestType = "Fingerprint Scanner"
                    model.strTestType = biometricTest
                    arrFailedAndSkipedTest.append(model)
                //}
            //}
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            //model.strTestType = "Fingerprint Scanner"
            model.strTestType = biometricTest
            arrFunctionalTest.append(model)
        }
        */
        
        var biometricTest = ""
        if BioMetricAuthenticator.canAuthenticate() {
            
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                biometricTest = "Face-Id Scanner"
            }else {
                biometricTest = "Fingerprint Scanner"
            }
            
            if(!UserDefaults.standard.bool(forKey: "fingerprint")) {
                let model = ModelCompleteDiagnosticFlow()
                model.priority = 8
                //model.strTestType = "Fingerprint Scanner"
                model.strTestType = biometricTest
                arrFailedAndSkipedTest.append(model)
            }
            else{
                let model = ModelCompleteDiagnosticFlow()
                model.priority = 0
                //model.strTestType = "Fingerprint Scanner"
                model.strTestType = biometricTest
                arrFunctionalTest.append(model)
            }
            
        }else {
            print("Device Biometric not support")
            print("Device does not have Biometric Authentication Method")
            
            biometricTest = "Biometric Authentication"
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = biometricTest
            self.arrFailedAndSkipedTest.append(model)
        }
        
        
        if(!UserDefaults.standard.bool(forKey: "WIFI")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 9
            model.strTestType = "WIFI"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "WIFI"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "GPS")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 10
            model.strTestType = "GPS"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "GPS"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 11
            model.strTestType = "Bluetooth"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Bluetooth"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 12
            model.strTestType = "GSM"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "GSM"
            arrFunctionalTest.append(model)
        }
                    
        if(!UserDefaults.standard.bool(forKey: "mic")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 15
            model.strTestType = "Microphone"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Microphone"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Speakers")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 16
            model.strTestType = "Speaker"
            
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Speaker"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Vibrator")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 17
            model.strTestType = "Vibrator"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Vibrator"
            arrFunctionalTest.append(model)
            
            self.resultJSON["Vibrator"].int = 1
        }
        
        /*
        if(!UserDefaults.standard.bool(forKey: "Torch")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 18
            model.strTestType = "Torch"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Torch"
            arrFunctionalTest.append(model)
        }
        */
        
        /*
        if(!UserDefaults.standard.bool(forKey: "Autofocus")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 19
            model.strTestType = "Autofocus"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Autofocus"
            arrFunctionalTest.append(model)
        }
        */
        
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 20
            model.strTestType = "SMS Verification"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "SMS Verification"
            arrFunctionalTest.append(model)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Storage")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 21
            model.strTestType = "Storage"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Storage"
            arrFunctionalTest.append(model)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Battery")) {
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 21
            model.strTestType = "Battery"
            arrFailedAndSkipedTest.append(model)
        }
        else{
            let model = ModelCompleteDiagnosticFlow()
            model.priority = 0
            model.strTestType = "Battery"
            arrFunctionalTest.append(model)
        }
        
        if arrFailedAndSkipedTest.count > 0 {
            section = ["Failed and Skipped Tests", "Functional Checks"]
        }
        else{
            section = ["Functional Checks"]
        }
        
        //self.lblTests.text = "YOUR DEVICE PASSED".localized + " \(arrFunctionalTest.count)" + "/\(arrFunctionalTest.count + arrFailedAndSkipedTest.count) TESTS!".localized
       
        self.tableViewTests.dataSource = self
        self.tableViewTests.delegate = self
        
        self.tableViewTests.reloadData()
                
    }
    
    //MARK: IBAction
    @IBAction func continueBtnPressed(_ sender: UIButton) {
        
        /*
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Q1VC") as! FirstQViewController
        print("Result JSON: \(self.resultJSON)")
        vc.resultJSON = self.resultJSON
        self.present(vc, animated: true, completion: nil)
        */
        
        
        /* //MARK: Commemt on 15/12/22 due to no use
         
        let isTradeInOnline = UserDefaults.standard.value(forKey: "Trade_In_Online") as! Bool
        print("isTradeInOnline value is :", isTradeInOnline)
        
        if isTradeInOnline {
            
            DispatchQueue.main.async() {
                self.getProductsDetailsQuestions()
            }
        
        }else {
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsVC") as! UserDetailsVC
            print("Result JSON: \(self.resultJSON)")
            vc.resultJOSN = self.resultJSON
            vc.appCodeStr = self.appCodeStr
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        */
        
        
        /*
        DispatchQueue.main.async() {
            self.getProductsDetailsQuestions()
        }
        */
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CrackCheckVC") as! CrackCheckVC
        print("Result JSON before CrackCheckVC page: \(self.resultJSON)")
        vc.resultJSON = self.resultJSON
        vc.appCodeStr = self.appCodeStr
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //MARK: tableview Delegates methods
    
    //func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //    return self.section[section]
    //}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if self.arrFailedAndSkipedTest.count > 0 {
                return  self.arrFailedAndSkipedTest.count + 1
            }
            else {
                return self.arrFunctionalTest.count + 1
            }
        }
        else {
            return self.arrFunctionalTest.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.arrFailedAndSkipedTest.count > 0 {
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Failed and Skipped Tests")
                    cellfailed.lblTitle.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                    cellfailed.lblSeperator.isHidden = true
                    
                    return cellfailed
                    
                }else {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    cellfailed.imgReTry.image = UIImage(named: "unverified")
                    cellfailed.lblName.text = self.getLocalizatioStringValue(key: self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType)
                    cellfailed.imgReTry.isHidden = true
                    cellfailed.lblReTry.isHidden = false
                    cellfailed.lblReTry.text = self.getLocalizatioStringValue(key: "ReTry")
                    
                 
                    DispatchQueue.main.async {
                        cellfailed.lblSeperator.isHidden = false
                        
                        if indexPath.row == 1 {
                            //cellfailed.roundCorners([.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFailedAndSkipedTest.count {
                            //cellfailed.roundCorners([.bottomLeft,.bottomRight], radius: 10.0)
                            cellfailed.lblSeperator.isHidden = true
                        }
                    }
                                        
                    return cellfailed
                    
                }
                
            }
            else{
                
                if indexPath.row == 0 {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                    cellfailed.lblTitle.textColor = #colorLiteral(red: 0.4156862745, green: 0.1058823529, blue: 0.6039215686, alpha: 1)
                    cellfailed.lblSeperator.isHidden = true
                    
                    return cellfailed
                }else {
                    
                    let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                    cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                    cellFunction.imgReTry.isHidden = false
                    cellFunction.lblReTry.isHidden = true
                    
                    
                    DispatchQueue.main.async {
                        cellFunction.lblSeperator.isHidden = false
                        
                        if indexPath.row == 1 {
                            //cellFunction.roundCorners([.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFunctionalTest.count {
                            //cellFunction.roundCorners([.bottomLeft,.bottomRight], radius: 10.0)
                            cellFunction.lblSeperator.isHidden = true
                        }
                    }
                    
                    return cellFunction
                    
                }
                
                
            }
        }
        else{
            
            if indexPath.row == 0 {
                
                let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                cellfailed.lblSeperator.isHidden = true
                cellfailed.lblTitle.textColor = #colorLiteral(red: 0.4156862745, green: 0.1058823529, blue: 0.6039215686, alpha: 1)
                
                return cellfailed
            }else {
                
                let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                cellFunction.imgReTry.isHidden = false
                cellFunction.lblReTry.isHidden = true
                
            
                DispatchQueue.main.async {
                    cellFunction.lblSeperator.isHidden = false
                    
                    if indexPath.row == 1 {
                        //cellFunction.roundCorners([.topLeft,.topRight], radius: 10.0)
                    }
                    
                    if indexPath.row == self.arrFunctionalTest.count {
                        //cellFunction.roundCorners([.bottomLeft,.bottomRight], radius: 10.0)
                        cellFunction.lblSeperator.isHidden = true
                    }
                }
                                
                return cellFunction
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arrFailedAndSkipedTest.count > 0 {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                }else {
                    
                    if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Dead Pixels" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelVC") as! DeadPixelVC
                        vc.isComingFromTestResult = true
                        
                        vc.deadPixelRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                                           
                    }else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Screen" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
                        vc.isComingFromTestResult = true
                        
                        vc.screenRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Rotation" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                        vc.isComingFromTestResult = true
                        
                        vc.rotationRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Proximity" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                        vc.isComingFromTestResult = true
                        
                        vc.proximityRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Hardware Buttons" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeRockerVC") as! VolumeRockerVC
                        vc.isComingFromTestResult = true
                        
                        vc.volumeRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    /* MARK: Ajay told to Remove both test on 27/3/23
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Earphone" {
                        
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
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Charger" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
                        vc.isComingFromTestResult = true
                        
                        vc.chargerRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if  self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Camera" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                        vc.isComingFromTestResult = true
                        
                        vc.cameraRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Fingerprint Scanner" || self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Face-Id Scanner" || self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Biometric Authentication" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
                        vc.isComingFromTestResult = true
                        
                        vc.biometricRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Bluetooth" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GPS" ||  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GSM" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "SMS Verification" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "NFC" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Battery" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Storage" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalTestsVC") as! InternalTestsVC
                        vc.isComingFromTestResult = true
                        
                        vc.backgroundRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "WIFI" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
                        vc.isComingFromTestResult = true
                        
                        vc.wifiRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }
                    else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Microphone" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
                        vc.isComingFromTestResult = true
                        
                        vc.micRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Speaker" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                        vc.isComingFromTestResult = true
                        
                        vc.speakerRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Vibrator" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                        vc.isComingFromTestResult = true
                        
                        vc.vibratorRetryDiagnosis = { retryJSON in
                            self.resultJSON = retryJSON
                        }
                        
                        vc.resultJSON = self.resultJSON
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    }else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Torch" {
                        
                        //let vc  = TorchVC()
                        //vc.isComingFromTestResult = true
                        //vc.resultJSON = self.resultJSON
                        //vc.modalPresentationStyle = .fullScreen
                        //self.present(vc, animated: true, completion: nil)
                        
                    }else if self.arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Autofocus" {
                        
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
        
    }
    
    //MARK: Web Service Methods
   
    func getProductsDetailsQuestions() {
        
        var productId = ""
        var customerId = ""
        
        if let pId = UserDefaults.standard.string(forKey: "product_id") {
            productId = pId
        }
        
        if let cId = UserDefaults.standard.string(forKey: "customer_id") {
            customerId = cId
        }
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
              
        var request = URLRequest(url: URL(string: AppBaseUrl + "getProductDetail")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData

        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&productId=\(productId)&customerId=\(customerId)&device=\(UIDevice.current.moName)"

        print("url is :",request, "\nParam is :",postString)
        
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 2.0, position: .bottom)
                }
                return
            }
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    print("Question data is:","\(json)")
                    
                    AppHardwareQuestionsData = CosmeticQuestions.init(json: json)
                    
                    arrAppHardwareQuestions = [Questions]()
                    arrAppQuestionsAppCodes = [String]()
                    
                    arrAppQuestAnswr = [[String:Any]]()
                    
                    for enableQuestion in AppHardwareQuestionsData?.msg?.questions ?? [] {
                        if enableQuestion.isInput == "1" {
                            arrAppHardwareQuestions?.append(enableQuestion)
                            //print("AppHardwareQuestions are ", arrAppHardwareQuestions ?? [])
                            hardwareQuestionsCount += 1
                            print("hardwareQuestionsCount is ", hardwareQuestionsCount)
                        }
                    }
                    
                    DispatchQueue.main.async() {
                        self.CosmeticHardwareQuestions()
                    }
                    
                }else {
                    let msg = json["msg"].string ?? ""
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: msg), duration: 3.0, position: .bottom)
                    }
                }
            }catch {
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Something went wrong!!"), duration: 3.0, position: .bottom)
                }
            }
            
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response?.description ?? "")")
                
                DispatchQueue.main.async() {
                    self.view.makeToast(response?.description, duration: 2.0, position: .bottom)
                }
                
            } else{
                
                do {
                    let json = try JSON(data: data)
                    if json["status"] == "Success" {
                        print("Question data is:","\(json)")
                        
                        AppHardwareQuestionsData = CosmeticQuestions.init(json: json)
                        
                        arrAppHardwareQuestions = [Questions]()
                        arrAppQuestionsAppCodes = [String]()
             
                        arrAppQuestAnswr = [[String:Any]]()
                        
                        for enableQuestion in AppHardwareQuestionsData?.msg?.questions ?? [] {
                            if enableQuestion.isInput == "1" {
                                arrAppHardwareQuestions?.append(enableQuestion)
                                //print("AppHardwareQuestions are ", arrAppHardwareQuestions ?? [])
                                hardwareQuestionsCount += 1
                                print("hardwareQuestionsCount is ", hardwareQuestionsCount)
                            }
                        }
                        
                        DispatchQueue.main.async() {
                            self.CosmeticHardwareQuestions()
                        }
                        
                    }else{
                        DispatchQueue.main.async() {
                            self.hud.dismiss()
                            self.view.makeToast(json["msg"].stringValue, duration: 2.0, position: .bottom)
                        }
                    }
                }catch{
                    DispatchQueue.main.async() {
                        self.hud.dismiss()
                        self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                    }
                }
            }*/
            
        }
        task.resume()
    }
    
    func CosmeticHardwareQuestions() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
        
        hardwareQuestionsCount -= 1
        AppQuestionIndex += 1
        
        // To Handle forward case
        vc.TestDiagnosisForward = {
            DispatchQueue.main.async() {
               
                if hardwareQuestionsCount > 0 {
                    self.CosmeticHardwareQuestions()
                }else {
                    
                    for appCode in arrAppQuestionsAppCodes ?? [] {
                        AppResultString = AppResultString + appCode + ";"
                        print("AppResultString is :", AppResultString)
                    }
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
                    
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsVC") as! UserDetailsVC
                    
                    print("Result JSON: \(self.resultJSON)")
                    
                    //vc.resultJOSN = self.resultJSON
                    //vc.appCodeStr = self.appCodeStr
                    
                    print("AppResultString is Before: ", AppResultString)
                    
                    
                    if AppResultString.contains(";;;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;;", with: ";")
                    }else if AppResultString.contains(";;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;", with: ";")
                    }else {
                        
                    }
                    
                    
                    print("AppResultString is After: ", AppResultString)
                    
                    vc.resultJOSN = self.resultJSON
                    //vc.appCodeStr = AppResultString
                    vc.questionAppCodeStr = AppResultString
                    
                    vc.arrQuestionAnswerData = arrAppQuestAnswr ?? []
                    print("arrAppQuestAnswr data is:",(arrAppQuestAnswr?.count ?? 0), arrAppQuestAnswr ?? [])
                    
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)                    
                    
                }
                
            }
        }
        
        vc.modalPresentationStyle = .overFullScreen
        
        if arrAppHardwareQuestions?[AppQuestionIndex].isInput == "1" {
            vc.arrQuestionAnswer = arrAppHardwareQuestions?[AppQuestionIndex]
            self.present(vc, animated: true, completion: nil)
        }else {
            self.CosmeticHardwareQuestions()
        }
           
        /*
        if AppHardwareQuestionsData?.msg?.questions?[AppQuestionIndex].isInput == "1" {
            vc.arrQuestionAnswer = AppHardwareQuestionsData?.msg?.questions?[AppQuestionIndex]
            self.present(vc, animated: true, completion: nil)
        }else {
            self.CosmeticHardwareQuestions()
        }
        */
                
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
