//
//  UserDetailsViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 28/07/19.
//  Copyright © 2019 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import BEMCheckBox
//import iOSDropDown
import JGProgressHUD

class UserDetailsViewController: UIViewController, UITextFieldDelegate {
    
    //@IBOutlet weak var userInfo: UILabel!
    
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldMobile: UITextField!
    //@IBOutlet weak var txtFieldBankAcNumber: UITextField!
    //@IBOutlet weak var txtFieldBankName: UITextField!
    //@IBOutlet weak var txtFieldBranch: UITextField!
    //@IBOutlet weak var txtFieldIfsc: UITextField!
    
    @IBOutlet weak var userDetailView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    //@IBOutlet weak var loaderImg: UIImageView!
    @IBOutlet weak var tnc: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var gradientBGView: UIView!
    
    //var email = ""
    //var mob = ""
    //var nam = ""
    
    var arrQuestionAnswerData = [[String:Any]]()
    
    var questionAppCodeStr = ""
    var appCodeStr = ""
    var resultJOSN = JSON()
    
    var strAppCodeInQrStatus = ""
    
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UISetUp()
        self.gradientBGView.cornerRadius(usingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 50.0, height: 50.0))
        
        //Bank Account Details
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.hideKeyboardWhenTappedAround()
        
        //print("Starting Update Users VC")
        //loaderImg.isHidden = true
        //let info = self.getLocalizatioStringValue(key: "Continue")
        //self.continueBtn.setTitle(info, for: .normal)
        //self.userInfo.text = "user_details_info".localized
        //self.userInfo.text = ""
        
        //self.txtFieldName.placeholder = self.getLocalizatioStringValue(key: "Name")
        //self.txtFieldEmail.placeholder = self.getLocalizatioStringValue(key: "Email Address")
        //self.txtFieldMobile.placeholder = self.getLocalizatioStringValue(key: "Mobile Number")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.handleTap))
        tnc.isUserInteractionEnabled = true
        tnc.addGestureRecognizer(tap)
        
        //self.txtFieldIfsc.delegate = self
        UIView.addShadow(baseView: self.userDetailView)
                
    }
    
    func UISetUp() {
                
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async(execute: {
            
            //UIView.addShadowOn4side(baseView: self.userDetailView)
            
        })
                
    }
    
    /*
    @IBAction func continueBtnClicked(_ sender: Any) {
        email = emailId.text ?? ""
        if (email.length > 0){
            mob = mobile.text ?? ""
            if (mob.length > 7){
                nam = name.text ?? ""
                if (nam.length > 2){
//                    loaderImg.isHidden = false
//                    loaderImg.rotate360Degrees()
                    if(checkBox.on){
                            call()
                    }else{
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Accept terms to continue", duration: 2.0, position: .bottom)
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.view.makeToast("Please Enter a valid name", duration: 2.0, position: .bottom)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.view.makeToast("Please Enter a valid mobile number ", duration: 2.0, position: .bottom)
                }
            }
        }else{
            DispatchQueue.main.async {
                self.view.makeToast("Please Enter a valid email Id ", duration: 2.0, position: .bottom)
            }
        }
        
    }*/
    
    
    @IBAction func continueBtnClicked(_ sender: UIButton) {
        if self.validation() {
            self.view.endEditing(true)
            self.call()
        }
    }
    
    func validation() -> Bool {
        
        if self.txtFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a valid name"), duration: 2.0, position: .bottom)
            }
            
            return false
        }else if self.txtFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a email Id"), duration: 2.0, position: .bottom)
            }
            
            return false
        }else if !self.isValidEmail(self.txtFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a valid email Id"), duration: 2.0, position: .bottom)
            }
            
            return false
        } else if self.txtFieldMobile.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a mobile number"), duration: 2.0, position: .bottom)
            }
            
            return false
        }else if (self.txtFieldMobile.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0) < 10 {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter a valid mobile number"), duration: 2.0, position: .bottom)
            }
            
            return false
        }
        
        /*
        else if self.txtFieldBankAcNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast("Please Enter bank account number", duration: 2.0, position: .bottom)
            }
            
            return false
        }
        else if self.txtFieldBankName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast("Please Enter bank name", duration: 2.0, position: .bottom)
            }
            
            return false
        }
        else if self.txtFieldBranch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast("Please Enter bank's branch name", duration: 2.0, position: .bottom)
            }
            
            return false
        }
        else if self.txtFieldIfsc.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast("Please Enter bank's IFSC number", duration: 2.0, position: .bottom)
            }
            
            return false
        }
        */
        
        else if !checkBox.on {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Accept terms to continue"), duration: 2.0, position: .bottom)
            }
            
            return false
        } else {
            return true
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func call(){
        
        /*
        var functional = "Functional Issue: "
        var start = 0;
        
        
        var l = UserDefaults.standard.string(forKey: "lcd") ?? ""
        if(appCodeStr.contains("SPTS01")) {
            l = "flawless".localized
        }
        if(appCodeStr.contains("SPTS02")) {
            l = "Minor_Scratches".localized
        }
        if(appCodeStr.contains("SPTS03")) {
            l = "Heavily_Scratched".localized
        }
        if(appCodeStr.contains("SPTS04")) {
            l = "cracked".localized
        }
        if(appCodeStr.contains("SBRK01")) {
            l = "Not_Working".localized
        }
        
        
        let lc = "lcd".localized
        let lcd = "\(lc): \(l)"
        let db = "device_body".localized
    
        var b = UserDefaults.standard.string(forKey: "back") ?? ""
        print("devie body: \(b)")
        
        if(appCodeStr.contains("CPBP01")){
            b = "flawless".localized
        }
        if(appCodeStr.contains("CPBP02")){
            b = "Minor_Scratches".localized
        }
        if(appCodeStr.contains("CPBP03")){
            b = "Heavily_Scratched".localized
        }
        if(appCodeStr.contains("CPBP05")){
            b = "cracked".localized
        }
        if(appCodeStr.contains("CPBP04")){
            b = "Dented".localized
        }
        
        
        
        let back = "\(db): \(b)"
        
        var myArray: Array = [lcd, back ]
        
        if(!UserDefaults.standard.bool(forKey: "rotation")){
            functional = "rotation_info".localized
            myArray.append(functional)
        }
        
        if((!UserDefaults.standard.bool(forKey: "proximity"))){
            functional = "Proximity_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "volume")){
            functional = "hardware_info".localized
            myArray.append(functional)
        }
        
        /*
        if(!UserDefaults.standard.bool(forKey: "connection")){
            functional = "Wifi_info".localized
            myArray.append(functional)
        }
        */
 
        if(!UserDefaults.standard.bool(forKey: "earphone")){
            functional = "earphone_info".localized
            myArray.append(functional)
        }

        if(!UserDefaults.standard.bool(forKey: "charger")){
            functional = "charger_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "camera")){
            functional = "camera_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "fingerprint")){
            functional = "fingerprint_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "WIFI")){
            functional = "wifi_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "GSM")) {
            functional = "gsm_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            functional = "bluetooth_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "GPS")) {
            functional = "gps_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "mic")){
            functional = "mic_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Speakers")) {
            functional = "speakers_info".localized
            myArray.append(functional)
        }
        
        if(!UserDefaults.standard.bool(forKey: "Vibrator")) {
            functional = "vibrator_info".localized
            myArray.append(functional)
        }
        
        /*
        if(!UserDefaults.standard.bool(forKey: "NFC")) {
            functional = "nfc_info".localized
            myArray.append(functional)
        }
        */
        
        */
   
        
        //let endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        //var request = URLRequest(url: URL(string: "https://exchange.buyblynk.com/api/v1/public/updateCustomer")!) // Blynk
        
        var request = URLRequest(url: URL(string: (AppBaseUrl) + "updateCustomer")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let customerId = UserDefaults.standard.string(forKey: "customer_id")
        let cust = customerId ?? ""
        let postString = "customerId=\(cust)&name=\(self.txtFieldName.text ?? "")&mobile=\(self.txtFieldMobile.text ?? "")&userName=\(AppUserName)&apiKey=\(AppApiKey)&email=\(self.txtFieldEmail.text ?? "")"
        
        request.httpBody = postString.data(using: .utf8)
        
        print("url is :",request,"\nParam is :",postString)
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
               
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PriceViewController") as! PriceViewController
                        
                        if self.questionAppCodeStr != "" {
                            
                            vc.appPhysicalQuestionCodeStr = self.questionAppCodeStr + ";" + self.strAppCodeInQrStatus
                            print("self.questionAppCodeStr", self.questionAppCodeStr)
                            
                        }else {
                            
                            vc.appCodeStr = self.appCodeStr + ";" + self.strAppCodeInQrStatus
                            print("self.appCodeStr", self.appCodeStr)
                            
                        }
                        
                        print("Result JSON 4: \(self.resultJOSN)")
                        vc.resultJOSN = self.resultJOSN
                        vc.arrQuestionAnswerFinalData = self.arrQuestionAnswerData
                        
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
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
                //self.retryBtn.isHidden = false
            } else{
                print(response ?? "")
                DispatchQueue.main.async() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PriceViewController") as! PriceViewController
                    
                    if self.questionAppCodeStr != "" {
                        vc.appPhysicalQuestionCodeStr = self.questionAppCodeStr
                        print("self.questionAppCodeStr", self.questionAppCodeStr)
                    }else {
                        vc.appCodeStr = self.appCodeStr
                        print("self.appCodeStr", self.appCodeStr)
                    }
                    
                    print("Result JSON 4: \(self.resultJOSN)")
                    vc.resultJOSN = self.resultJOSN
                    //vc.myArray = myArray
                    //print(myArray)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }*/
            
        }
        task.resume()
    }
    
    
    /*
     func handleTap(gestureRecognizer: UIGestureRecognizer) {
        guard let url = URL(string: "https://exchange.buyblynk.com/tnc.php") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    */
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
    
        let tncendpoint = (UserDefaults.standard.string(forKey: "App_TncUrl") ?? AppBaseTnc) 

        
        guard let url = URL(string: tncendpoint) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: webservice Razorpay Api
    
    func razorPayApiGet(strURL : String , parameters:NSDictionary, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        
        let web = WebServies()
        web.getRequest(urlString: strURL, paramDict: (parameters as! Dictionary<String, AnyObject>), completionHandler: completionHandler)
    }
    
    func razorpayApiCheckFromServer(txtFValue:String) {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
                
        let strUrl = "https://ifsc.razorpay.com/\(txtFValue)"
        print(strUrl)
        
        self.razorPayApiGet(strURL: strUrl, parameters: [:], completionHandler: {responseObject , error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            print("\(String(describing: responseObject) ) , \(String(describing: error))")
            
            if error == nil && responseObject != nil {
                
                ////self.txtFieldBranch.text = responseObject?["BRANCH"] as? String
                
            }
            else{
                debugPrint(error as Any)
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "oops,something went wrong"), duration: 2.0, position: .bottom)
                }
            }
        })
        
        
    }
    
    
    //MARK: UITextField Delegates methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*
        if textField == self.txtFieldIfsc {
            textField.resignFirstResponder()
            return true
        }
        */
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        /*
        if textField == self.txtFieldIfsc {
            
            if textField.text?.isEmpty ?? false {
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Enter valid IFSC Code"), duration: 2.0, position: .bottom)
                }
                
                return
            }else {
                self.razorpayApiCheckFromServer(txtFValue: textField.text ?? "")
            }
            
        }
        */
        
    }

}
