//
//  CrackCheckVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 12/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import BiometricAuthentication
import Alamofire
import JGProgressHUD

class CrackCheckVC: UIViewController {
    
    @IBOutlet weak var qrImgView: UIImageView!
    @IBOutlet weak var btnManualProcess: UIButton!
    @IBOutlet weak var loaderImgView: UIImageView!
    
    @IBOutlet weak var lblPrepare: UILabel!
    @IBOutlet weak var lblClean: UILabel!
    @IBOutlet weak var lblRemove: UILabel!
    @IBOutlet weak var lblDonotClose: UILabel!
    @IBOutlet weak var lblAvoid: UILabel!
    
    @IBOutlet weak var lblHelper: UILabel!
    @IBOutlet weak var lblEnsure: UILabel!
    @IBOutlet weak var lblMaintain: UILabel!
    @IBOutlet weak var lblKeep: UILabel!
    
    var resultJSON = JSON()    
    var appCodeStr = ""
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    var statusTimer: Timer?
    var loaderTimer: Timer?
    
    var strAppCodeInQrStatus = ""
    var arrAppCodeInQrStatus = [String]()
    var arrAppQuesAns = [[String:Any]]()
    
    var strCrackCheckQR = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBoldTextInString()
        
        setQrCodeWithBase64()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stratCrackCheckSession()
    }
    
    //MARK: Custom Methods
    func setQrCodeWithBase64() {
        
        let baseUrl = "https://phone-grading-app.web.app/?customerData="
        let IMEI = UserDefaults.standard.string(forKey: "imei_number") ?? ""
        let customerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
        
        var strCombine = ""
        var strImeiCustID = ""
        
        let longstring = IMEI + "," + customerId
        if let data = (longstring).data(using: String.Encoding.utf8) {
            let base64 = data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            print(base64)// dGVzdDEyMw==\n
            strImeiCustID = base64
        }
        
        strCombine = baseUrl + strImeiCustID
        print("strCombine" , strCombine)
        
        strCrackCheckQR = strCombine
        
        self.qrImgView.image = generateQRCode(from: strCombine)
        
        /*
        if let qrCodeImage = decodeBase64ToImage(base64String: strCombine) {
            self.qrImgView.image = qrCodeImage
        } else {
            print("Failed to decode Base64 string into an image.")
        }
        */
        
    }
    
    private func decodeBase64ToImage(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func stratCrackCheckSession() {
                
        var customerId = ""
        
        if let cId = UserDefaults.standard.string(forKey: "customer_id") {
            customerId = cId
        }
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
              
        var request = URLRequest(url: URL(string: "https://exchange.getinstacash.com.my/us/api/v1/public/startCrackSession")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData

        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&customerId=\(customerId)"

        print("url in startCrackSession api :",request, "\nParam is :",postString)
        
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
            
            //let responseString = String(data: data, encoding: .utf8)
            //print("responseString",responseString ?? "")
                        
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    print("startCrackSession response is:","\(json)")
                    
                    DispatchQueue.main.async {
                        self.statusTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.runStatusTimer), userInfo: nil, repeats: true)
                    }
                                        
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        //self.checkCrackCheckQRStatus()
                    //})
                                        
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
                                   
        }
        task.resume()
    }
    
    func checkCrackCheckQRStatus() {
                
        var customerId = ""
        
        if let cId = UserDefaults.standard.string(forKey: "customer_id") {
            customerId = cId
        }
        
        //self.hud.textLabel.text = ""
        //self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        //self.hud.show(in: self.view)
              
        var request = URLRequest(url: URL(string: "https://exchange.getinstacash.com.my/us/api/v1/public/checkCrackQRStatus")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData

        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&customerId=\(customerId)"

        print("url in checkCrackQRStatus api :",request, "\nParam is :",postString)
        
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                //self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 2.0, position: .bottom)
                }
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString",responseString ?? "")
                        
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    print("checkCrackQRStatus response is:","\(json)")
                    
                    let msgDict = json["msg"]
                    let currentStatus = msgDict["status"].string ?? ""
                    
                    if currentStatus.lowercased() == "open" {
                        //self.btnManualProcess.isHidden = false
                    }
                    else if currentStatus.lowercased() == "processing" {
                        
                        DispatchQueue.main.async {
                            self.btnManualProcess.isHidden = true
                            
                            self.loaderImgView.isHidden = false
                            // Load GIF In Image view
                            let jeremyGifUp = UIImage.gifImageWithName("loader")
                            self.loaderImgView.image = jeremyGifUp
                            self.loaderImgView.stopAnimating()
                            self.loaderImgView.startAnimating()
                            
                            //DispatchQueue.main.async {
                                //self.loaderTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.runLoaderTimer), userInfo: nil, repeats: true)
                            //}
                            
                        }
                        
                    }
                    else {
                        
                        self.strAppCodeInQrStatus = msgDict["appCodes"].string ?? ""
                        print("self.strAppCodeInQrStatus", self.strAppCodeInQrStatus)
                        
                        //self.arrAppCodeInQrStatus = ["SPTS01", "CPBP01"]
                        self.arrAppCodeInQrStatus = self.strAppCodeInQrStatus.components(separatedBy: ";")
                        print("self.arrAppCodeInQrStatus", self.arrAppCodeInQrStatus)
                        
                        DispatchQueue.main.async() {
                            self.getProductsDetailsQuestions()
                        }
                        
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
                                   
        }
        task.resume()
    }
    
    @objc func runStatusTimer() {
                
        DispatchQueue.main.async() {
            self.checkCrackCheckQRStatus()
        }
        
    }
    
    @objc func runLoaderTimer() {
                
        DispatchQueue.main.async() {
            self.loaderImgView.isHidden = !self.loaderImgView.isHidden
        }
        
    }
    
    //MARK: IBAction
    @IBAction func qrLinkCopyBtnTapped(_ sender:UIButton) {
        
        UIPasteboard.general.string = self.strCrackCheckQR
        
        DispatchQueue.main.async() {
            self.view.makeToast(self.getLocalizatioStringValue(key: "copied"), duration: 1.0, position: .bottom)
        }
        
    }
    
    @IBAction func manualProcessBtnTapped(_ sender:UIButton) {
        
        arrAppCodeInQrStatus = []
        
        DispatchQueue.main.async() {
            self.getProductsDetailsQuestions()
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: Web Service Methods
    
    func getProductsDetailsQuestions() {
        
        self.statusTimer?.invalidate()
        self.statusTimer = nil
        
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
                    //AppHardwareQuestionsData = try CosmeticQuestions.init(from: json as! Decoder)
                    
                    arrAppHardwareQuestions = [Questions]()
                    arrAppQuestionsAppCodes = [String]()
                    
                    arrAppQuestAnswr = [[String:Any]]()
                    
                    var selectedDict = ["" : ""]
                    
                    //self.arrAppCodeInQrStatus.append("SPTS03")
                    //self.arrAppCodeInQrStatus.append("CPBP02")
                    
                    for enableQuestion in AppHardwareQuestionsData?.msg?.questions ?? [] {
                        if enableQuestion.isInput == "1" {
                            
                            //MARK: 1st Condition to check for specificationValue
                            if let val = enableQuestion.specificationValue {
                                
                                var isSpecificationValueAppCodeFound = false
                                
                                for appCD in val {
                                    print("appCD.appCode in specificationValue" , appCD.appCode ?? "")
                                 
                                    if self.arrAppCodeInQrStatus.contains(appCD.appCode ?? "") {
                                        
                                        //MARK: Need to append this Question-answer
                                        selectedDict = [:]
                                        selectedDict = [(enableQuestion.specificationName ?? "") : (appCD.value ?? "")]
                                        //arrAppQuestAnswr?.append(selectedDict)
                                        //hardwareQuestionsCount += 1
                                        
                                        self.arrAppQuesAns.append(selectedDict)
                                        
                                        isSpecificationValueAppCodeFound = true
                                                                                
                                        //break
                                    }
                                    /*
                                    else {
                                        if enableQuestion.isInput == "1" {
                                            arrAppHardwareQuestions?.append(enableQuestion)
                                            hardwareQuestionsCount += 1
                                            break
                                        }
                                    }
                                    */
                                    
                                }
                                
                                if !isSpecificationValueAppCodeFound {
                                                                        
                                    arrAppHardwareQuestions?.append(enableQuestion)
                                    hardwareQuestionsCount += 1
                                    
                                    isSpecificationValueAppCodeFound = true
                                }
                                
                            }
                            
                            
                            //MARK: 2nd Condition to check for conditionValue
                            
                            if let val = enableQuestion.conditionValue {
                                
                                var isConditionValueAppCodeFound = false
                                
                                for appCD in val {
                                    print("appCD.appCode in conditionValue" , appCD.appCode ?? "")
                                    
                                    if self.arrAppCodeInQrStatus.contains(appCD.appCode ?? "") {
                                        
                                        //MARK: Need to append this Question-answer
                                        selectedDict = [:]
                                        selectedDict = [(enableQuestion.conditionSubHead ?? "") : (appCD.value ?? "")]
                                        //arrAppQuestAnswr?.append(selectedDict)
                                        //hardwareQuestionsCount += 1
                                        
                                        self.arrAppQuesAns.append(selectedDict)
                                        
                                        isConditionValueAppCodeFound = true
                                                                                
                                        //break
                                    }
                                    /*
                                    else {
                                        
                                        if enableQuestion.isInput == "1" {
                                            
                                            arrAppHardwareQuestions?.append(enableQuestion)
                                            hardwareQuestionsCount += 1
                                            
                                            break
                                        }
                                        
                                    }
                                    */
                                                                        
                                }
                                
                                if !isConditionValueAppCodeFound {
                                                                        
                                    arrAppHardwareQuestions?.append(enableQuestion)
                                    hardwareQuestionsCount += 1
                                    
                                    isConditionValueAppCodeFound = true
                                }
                                
                            }
                            
                            

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
                    
                    DispatchQueue.main.async() {
                        self.CosmeticHardwareQuestions()
                    }
                    
                }else {
                    
                    for appCode in arrAppQuestionsAppCodes ?? [] {
                        AppResultString = AppResultString + appCode + ";"
                        //print("AppResultString is :", AppResultString)
                    }
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
                                        
                    if AppResultString.contains(";;;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;;", with: ";")
                    }else if AppResultString.contains(";;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;", with: ";")
                    }else {
                        
                    }
                    
                    //print("Result JSON: \(self.resultJSON)")
                    //print("AppResultString is After: ", AppResultString)
                    
                    vc.resultJOSN = self.resultJSON
                    //vc.appCodeStr = AppResultString
                    //vc.questionAppCodeStr = AppResultString
                    vc.questionAppCodeStr = self.strAppCodeInQrStatus + ";" + AppResultString
                    
                    for quesAns in arrAppQuestAnswr ?? [] {
                        self.arrAppQuesAns.append(quesAns)
                    }
                    
                    //print("self.arrAppQuesAns data is:",(self.arrAppQuesAns.count), self.arrAppQuesAns)
                    
                    //vc.arrQuestionAnswerData = arrAppQuestAnswr ?? []
                    vc.arrQuestionAnswerData = self.arrAppQuesAns
                    //print("arrAppQuestAnswr data is:",(arrAppQuestAnswr?.count ?? 0), arrAppQuestAnswr ?? [])
                    
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
            
            DispatchQueue.main.async() {
                self.CosmeticHardwareQuestions()
            }
            
        }
        
    }
    
    func setBoldTextInString() {
        
        //1
        let prepareboldText = "(to be sold)"
        let prepareattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let prepareattributedString1 = NSMutableAttributedString(string: prepareboldText, attributes: prepareattrs)
        
        let preparenormalText = "Prepare Your Device "
        let preparenormalString = NSMutableAttributedString(string: preparenormalText)
        //prepareattributedString1.append(preparenormalString)
        preparenormalString.append(prepareattributedString1)
        
        if self.lblPrepare != nil {
            self.lblPrepare.attributedText = preparenormalString
        }
        
        
        //2
        let dialboldText = "Clean your screen"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString1 = NSMutableAttributedString(string: dialboldText, attributes: attrs)
        let normalText = " to ensure clear image capture."
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString1.append(normalString)
        
        if self.lblClean != nil {
            self.lblClean.attributedText = attributedString1
        }
        
        //3
        let settingboldText = "Remove the back cover,"
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let settingattributedString2 = NSMutableAttributedString(string: settingboldText, attributes: attrs2)
        let normalText2 = " case, or accessories that may obstruct the device's back and edges."
        let normalString2 = NSMutableAttributedString(string: normalText2)
        settingattributedString2.append(normalString2)
        
        if self.lblRemove != nil {
            self.lblRemove.attributedText = settingattributedString2
        }
        
        
        //4
        let boxBoldText = "Do not close"
        let attrsBox = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let boxAttributedString = NSMutableAttributedString(string: boxBoldText, attributes: attrsBox)
        let boxNormalText = " or minimize the app while the process is ongoing."
        let boxNormalString = NSMutableAttributedString(string: boxNormalText)
        boxAttributedString.append(boxNormalString)
        
        if self.lblDonotClose != nil {
            self.lblDonotClose.attributedText = boxAttributedString
        }
        
        
        //5
        let AvoidBoldText = "Avoid any direct reflections "
        let AvoidAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let AvoidAttributedString = NSMutableAttributedString(string: AvoidBoldText, attributes: AvoidAttrs)
        
        let AvoidNormalText = " on the device while capturing the image."
        let AvoidNormalString = NSMutableAttributedString(string: AvoidNormalText)
        AvoidAttributedString.append(AvoidNormalString)
        
        if self.lblAvoid != nil {
            self.lblAvoid.attributedText = AvoidAttributedString
        }
        
        
        //6
        let helperBoldText = "(2nd Device for Scanning)"
        let helperAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let helperAttributedString = NSMutableAttributedString(string: helperBoldText, attributes: helperAttrs)
        
        let helperNormalText = "Helper Device "
        let helperNormalString = NSMutableAttributedString(string: helperNormalText)
        helperNormalString.append(helperAttributedString)
        
        if self.lblHelper != nil {
            self.lblHelper.attributedText = helperNormalString
        }
        
        
        //7
        let ensureBoldText = "Camera lens is clean"
        let ensureArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let ensureAttributedString = NSMutableAttributedString(string: ensureBoldText, attributes: ensureArattrs)
        
        let ensureNormalText1 = "Ensure the "
        let ensureNormalText2 = " for accurate scanning."
        let ensureNormalString1 = NSMutableAttributedString(string: ensureNormalText1)
        let ensureNormalString2 = NSMutableAttributedString(string: ensureNormalText2)
        
        ensureNormalString1.append(ensureAttributedString)
        ensureNormalString1.append(ensureNormalString2)
        
        if self.lblEnsure != nil {
            self.lblEnsure.attributedText = ensureNormalString1
        }
        
        
        //8
        let maintainBoldText = "stable hand"
        let maintainArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let maintainAttributedString = NSMutableAttributedString(string: maintainBoldText, attributes: maintainArattrs)
        
        let maintainNormalText1 = "Maintain a "
        let maintainNormalText2 = " while scanning to avoid blurry captures."
        let maintainNormalString1 = NSMutableAttributedString(string: maintainNormalText1)
        let maintainNormalString2 = NSMutableAttributedString(string: maintainNormalText2)
        
        maintainNormalString1.append(maintainAttributedString)
        maintainNormalString1.append(maintainNormalString2)
        
        if self.lblMaintain != nil {
            self.lblMaintain.attributedText = maintainNormalString1
        }
        
        
        //9
        let keepBoldText = "vertical position"
        let keepArattrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let keepAttributedString = NSMutableAttributedString(string: keepBoldText, attributes: keepArattrs)
        
        let keepNormalText1 = "Keep the device in a "
        let keepNormalText2 = " for the best scanning accuracy."
        let keepNormalString1 = NSMutableAttributedString(string: keepNormalText1)
        let keepNormalString2 = NSMutableAttributedString(string: keepNormalText2)
        
        keepNormalString1.append(keepAttributedString)
        keepNormalString1.append(keepNormalString2)
        
        if self.lblKeep != nil {
            self.lblKeep.attributedText = keepNormalString1
        }
        
    }
    
}
