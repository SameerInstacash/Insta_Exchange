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
    
    var resultJSON = JSON()    
    var appCodeStr = ""
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    var statusTimer: Timer?
    
    var strAppCodeInQrStatus = ""
    var arrAppCodeInQrStatus = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
              
        var request = URLRequest(url: URL(string: "https://exchange.getinstacash.com.my/us/api/v1/public/checkCrackQRStatus")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData

        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&customerId=\(customerId)"

        print("url in checkCrackQRStatus api :",request, "\nParam is :",postString)
        
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
        
        print("runStatusTimer called now !")
        
        DispatchQueue.main.async() {
            self.checkCrackCheckQRStatus()
        }
        
    }
    
    //MARK: IBAction
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
                    
                    for enableQuestion in AppHardwareQuestionsData?.msg?.questions ?? [] {
                        if enableQuestion.isInput == "1" {
                            
                            
                            if let val = enableQuestion.specificationValue {
                                for appCD in val {
                                    print("appCD.appCode in specificationValue" , appCD.appCode ?? "")
                                 
                                    if self.arrAppCodeInQrStatus.contains(appCD.appCode ?? "") {
                                        
                                    }
                                    else {
                                        
                                        if enableQuestion.isInput == "1" {
                                            arrAppHardwareQuestions?.append(enableQuestion)
                                            hardwareQuestionsCount += 1
                                            
                                            break
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            if let val = enableQuestion.conditionValue {
                                for appCD in val {
                                    print("appCD.appCode in conditionValue" , appCD.appCode ?? "")
                                    
                                    if self.arrAppCodeInQrStatus.contains(appCD.appCode ?? "") {
                                        
                                    }
                                    else {
                                        
                                        if enableQuestion.isInput == "1" {
                                            arrAppHardwareQuestions?.append(enableQuestion)
                                            hardwareQuestionsCount += 1
                                            
                                            break
                                        }
                                        
                                    }
                                    
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
                    self.CosmeticHardwareQuestions()
                }else {
                    
                    for appCode in arrAppQuestionsAppCodes ?? [] {
                        AppResultString = AppResultString + appCode + ";"
                        print("AppResultString is :", AppResultString)
                    }
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
                                        
                    if AppResultString.contains(";;;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;;", with: ";")
                    }else if AppResultString.contains(";;") {
                        AppResultString = AppResultString.replacingOccurrences(of: ";;", with: ";")
                    }else {
                        
                    }
                    
                    print("Result JSON: \(self.resultJSON)")
                    print("AppResultString is After: ", AppResultString)
                    
                    vc.resultJOSN = self.resultJSON
                    //vc.appCodeStr = AppResultString
                    vc.questionAppCodeStr = AppResultString
                    vc.questionAppCodeStr = self.strAppCodeInQrStatus
                    
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
        
    }
    
}
