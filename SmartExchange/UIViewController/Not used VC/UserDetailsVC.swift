//
//  UserDetailsVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 30/05/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import BEMCheckBox
//import iOSDropDown
import JGProgressHUD

import Luminous
import DropDown
import Alamofire
import AlamofireImage

class UserDetailsVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var userDetailTableView: UITableView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var lblTnc: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblUserDetail: UILabel!
    
    var arrQuestionAnswerData = [[String:Any]]()
    var questionAppCodeStr = ""
    var appCodeStr = ""
    var resultJOSN = JSON()
    let hud = JGProgressHUD()
    
    var endPoint = AppBaseUrl

    //var drop = UIDropDown()
    //var arrDrop = [String]()
    
    var responseDictIN = [String : Any]()
    var responseDict = [String : Any]()
    //var arrDictKeys = [Any]()
    var arrDictKeys = [String]()
    var arrDictKeys1 = [String]()
    var arrDictValues = [[Any]]()
    
    var isHtml = true
    var setInfo = [String:String]()
    
    var bankDetails = [String:Any]()
    var bankDict = [String:Any]()
    var arrBankKeysMendatory = [String]()
    //var arrBankKeysOptional = [String]()
    var placeHold : String = ""

    var customerId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.hideKeyboardWhenTappedAround()
        
        //self.userDetailTableView.register(HtmlCell.self, forCellReuseIdentifier: "HtmlCell")
        //self.userDetailTableView.register(MobileNumberCell.self, forCellReuseIdentifier: "MobileNumberCell")
        //self.userDetailTableView.register(SelectTextCell.self, forCellReuseIdentifier: "SelectTextCell")
        //self.userDetailTableView.register(TextBoxCell.self, forCellReuseIdentifier: "TextBoxCell")
        
        
        if let cId = UserDefaults.standard.string(forKey: "customer_id") {
            self.customerId = cId
        }
    
        
        self.getXtraCoverForm()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.handleTap))
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserDetailsVC.handleTap))
        self.lblTnc.isUserInteractionEnabled = true
        self.lblTnc.addGestureRecognizer(tap)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
                
        self.lblTitle.text = self.getLocalizatioStringValue(key: "IC Exchange")
        
        self.setTextOfUserLabel()
        
        self.lblTnc.text = self.getLocalizatioStringValue(key: "I accept the Terms and Conditions")

        self.btnContinue.setTitle(self.getLocalizatioStringValue(key: "Continue"), for: UIControlState.normal)
         
    }
    
    func setTextOfUserLabel() {
        
        //let clientText = "1. Please enter customer's name, email and mobile number" + "\n" +
        //"2. Check I accept the Terms and Conditions" + "\n" + "3. Click Continue"
        
        
        let clientText1 = self.getLocalizatioStringValue(key: "1. Please enter customer's name, email and mobile number") + "\n"
        let clientText2 = self.getLocalizatioStringValue(key: "2. Check I accept the Terms and Conditions") + "\n"
        let clientText3 = self.getLocalizatioStringValue(key: "3. Click Continue")
        
        self.lblUserDetail.text = clientText1 + clientText2 + clientText3
        
    }
    
    // MARK: IBAction
    @IBAction func continueBtnClicked(_ sender: UIButton) {
        
        if isHtml {
            
//            let vc = OrderFinalVC()
//            vc.orderID = self.placedOrderId
//            vc.finalPrice = self.finalPriced
//            vc.selectPaymentType = self.selectedPaymentType
//            vc.selectCurrency = self.selectedCurrency
//            self.navigationController?.pushViewController(vc, animated: true)
            
        }else {
            
            /*
            for key in self.arrBankKeysMendatory {
                if self.bankDict[key] as? String == "" {
                    if key == "tnc" {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please agree Terms & Conditions", duration: 2.0, position: .bottom)
                        }
                        return
                    }else if key == "Bank Name" {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please select \(key)", duration: 2.0, position: .bottom)
                        }
                        return
                    }else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Enter \(key)", duration: 2.0, position: .bottom)
                        }
                        return
                    }
                }
            }*/
            
            
            /*
            for key in self.arrBankKeysMendatory {
                if self.bankDict[key] as? String == "" {
                    if key == "tnc" {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please agree Terms & Conditions", duration: 2.0, position: .bottom)
                        }
                        return
                    }else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Please Enter \(key)", duration: 2.0, position: .bottom)
                        }
                        return
                    }
                }
            }
            */
            
            for key in self.arrBankKeysMendatory {
                
                //MARK: Mobile Validation
                if key.contains("mobile") || key.contains("Mobile*") {
                    let mobNumber = self.bankDict[key] as? String ?? ""
                    
                    if mobNumber.count < 10 {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter valid \(key)"), duration: 2.0, position: .bottom)
                            
                            return
                        }
                                                
                    }
                }
                
                //MARK: Email Validation
                else if key.contains("email") {
                    let emailValidation = self.isValidEmail(self.bankDict[key] as? String ?? "")
                    
                    if !emailValidation {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter valid \(key)"), duration: 2.0, position: .bottom)
                            
                            return
                        }
                                                
                    }
                }
                
                else {
                    
                    let bankVal = self.bankDict[key] as? String ?? ""
                    
                    if bankVal == "" {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter \(key)"), duration: 2.0, position: .bottom)
                        
                            return
                        }
                                                
                    }
                    
                }
                
            }
            
            
            
            if !checkBox.on {
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please agree Terms & Conditions"), duration: 2.0, position: .bottom)
                }
                
                return
            }
           
            self.bankDict["customerId"] = self.customerId
            self.bankDetails = self.bankDict
            
            self.setXtraCoverFormToServer()
        }
        
    }
    
    //MARK: UITextField Delegates methods
   /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtFieldIfsc {
            textField.resignFirstResponder()
            return true
        }
        
        return false
    }*/
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // YOU SHOULD FIRST CHECK FOR THE BACKSPACE. IF BACKSPACE IS PRESSED ALLOW IT
        
        if string == "" {
            return true
        }
        
        if (textField.placeholder?.contains("mobile") ?? false || textField.placeholder?.contains("Mobile*") ?? false)  {
           
            if let characterCount = textField.text?.count {
                
                // CHECK FOR CHARACTER COUNT IN TEXT FIELD
                if characterCount == 10 {
                    // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                    return textField.resignFirstResponder()
                }
            }
            
        }
        
        return true
    }

    
    //MARK: UITextField Delegates methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.placeHold = textField.placeholder ?? ""
        
        //cellTextBox.txtField.placeholder = (self.arrDictKeys[indexPath.row])
        
        self.placeHold = self.arrDictKeys[textField.tag]
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let ndx = IndexPath(row: textField.tag, section: 0)
        if let cell = self.userDetailTableView.cellForRow(at: ndx) as? TextBoxCell {
            
            if cell.txtField.text?.isEmpty ?? false {
                //self.bankDict[cell.txtField.placeholder ?? ""] = ""
                
                self.bankDict[self.placeHold] = ""
                
            }else {
                self.bankDict[self.placeHold] = cell.txtField.text ?? ""
            }
            
            /*
            if cell.txtField.placeholder == "IFSC" {
                
                let ndx = IndexPath(row:textField.tag, section: 0)
                let cell = self.userDetailTableView.cellForRow(at: ndx) as! TextBoxCell
                
                if cell.txtField.text?.isEmpty ?? false {
                    self.bankDict[cell.txtField.placeholder ?? ""] = ""

                    DispatchQueue.main.async {
                        self.view.makeToast("Enter valid IFSC Code", duration: 2.0, position: .bottom)
                    }
                    
                    return
                }else {
                    self.bankDict[self.placeHold] = cell.txtField.text ?? ""
                    self.razorpayApiCheckFromServer(txtFValue: cell.txtField.text ?? "")
                }
                
            }else if cell.txtField.text?.isEmpty ?? false {
                self.bankDict[cell.txtField.placeholder ?? ""] = ""
            }else {
                self.bankDict[self.placeHold] = cell.txtField.text ?? ""
            }*/
            
        }
        
        if let cell = self.userDetailTableView.cellForRow(at: ndx) as? SelectTextCell {
            if cell.selectTextField.text?.isEmpty ?? false {
                //self.bankDict[cell.selectTextField.placeholder ?? ""] = ""
                
                self.bankDict[self.placeHold] = ""
            }else {
                self.bankDict[self.placeHold] = cell.selectTextField.text ?? ""
            }
        }
        
        if let cell = self.userDetailTableView.cellForRow(at: ndx) as? MobileNumberCell {
            if cell.mobileNumberTxtField.text?.isEmpty ?? false {
                //self.bankDict[cell.mobileNumberTxtField.placeholder ?? ""] = ""
                
                self.bankDict[self.placeHold] = ""
            }else {
                self.bankDict[self.placeHold] = cell.mobileNumberTxtField.text ?? ""
            }
        }
        
    }
    
    // MARK: WebService Method
    func getXtraCoverForm() {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        var request = URLRequest(url: URL(string: "\(self.endPoint)/getForm")!)
        //print("endpoint= \(endPoint)")
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&customerId=\(self.customerId)"
        //print("postString= \(postString)")
        
        print("url is :",request,"\nParam is :",postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                
                /*
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    //check for fundamental networking error
                    
                    print("error=\(error.debugDescription)")
                    self.view.makeToast("Please Check Internet conection.", duration: 2.0, position: .bottom)
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: dataThis)
                if json["status"] == "Success" {
                    
                    DispatchQueue.main.async() {
                        
                        do {
                            let resp = try (JSONSerialization.jsonObject(with: dataThis, options: []) as? [String:Any] ?? [:])
                            
                            print(" Form Response is:", resp)
                            
                            self.responseDict = resp["msg"] as? [String:Any] ?? [:]
                           
                            //print(" First name is: \(self.responseDict)")
                            
                            for (ind,item) in self.responseDict.enumerated() {
                                print(ind)
                                //print(item)
                                
                                self.arrDictKeys1.append(item.key)
                                //self.arrDictKeys.append(item.key)
                                //self.arrDictValues.append([item.value])
                                
                                if item.key == "Bank Name" {
                                   
                                    /*
                                    if let arr = (item.value as! NSArray)[3] as? [String] {
                                        self.arrDrop = arr
                                    }
                                    */
                                    
                                    /*
                                    if let arr = item.value as? [Any] {
                                        if arr.count > 3 {
                                            if let bankNameArr = arr[3] as? NSArray {
                                                self.arrDrop = bankNameArr as! [String]
                                            }
                                        }
                                    }*/
                                    
                                }
                                
                            }
                            
                            
                            self.arrDictKeys = self.arrDictKeys1.sorted()
                        
                    
                            if self.arrDictKeys.contains("name") {
                                if let nameIndex = self.arrDictKeys.index(of: "name") {
                                    let element = self.arrDictKeys.remove(at: nameIndex)
                                    self.arrDictKeys.insert(element, at: 0)
                                }
                            }
                            
                            if self.arrDictKeys.contains("mobile") {
                                if let mobileIndex = self.arrDictKeys.index(of: "mobile") {
                                    let element = self.arrDictKeys.remove(at: mobileIndex)
                                    self.arrDictKeys.insert(element, at: 1)
                                }
                            }
                            
                            
                            if self.arrDictKeys.contains("email") {
                                if let emailIndex = self.arrDictKeys.index(of: "email") {
                                    let element = self.arrDictKeys.remove(at: emailIndex)
                                    self.arrDictKeys.insert(element, at: 2)
                                }
                            }
                            
                            if self.arrDictKeys.contains("Bank Holders Name") {
                                if let BankHoldersNameIndex = self.arrDictKeys.index(of: "Bank Holders Name") {
                                    if self.arrDictKeys.count > 3 {
                                        let element = self.arrDictKeys.remove(at: BankHoldersNameIndex)
                                        self.arrDictKeys.insert(element, at: 3)
                                    }
                                }
                            }
                           
                            if self.arrDictKeys.contains("Bank Account Number") {
                                if let BankAccountNumberIndex = self.arrDictKeys.index(of: "Bank Account Number") {
                                    if self.arrDictKeys.count > 4 {
                                        let element = self.arrDictKeys.remove(at: BankAccountNumberIndex)
                                        self.arrDictKeys.insert(element, at: 4)
                                    }
                                }
                            }
                            
                            if self.arrDictKeys.contains("IFSC") {
                                if let IFSCIndex = self.arrDictKeys.index(of: "IFSC") {
                                    if self.arrDictKeys.count > 5 {
                                        let element = self.arrDictKeys.remove(at: IFSCIndex)
                                        self.arrDictKeys.insert(element, at: 5)
                                    }
                                }
                            }
                            
                            if self.arrDictKeys.contains("Bank Name") {
                                if let BankNameIndex = self.arrDictKeys.index(of: "Bank Name") {
                                    if self.arrDictKeys.count > 6 {
                                        let element = self.arrDictKeys.remove(at: BankNameIndex)
                                        self.arrDictKeys.insert(element, at: 6)
                                    }
                                }
                            }
                            
                            
                            print("self.arrDictKeys are",self.arrDictKeys)
                            
                            
                            /*
                            "name"
                            "mobile"
                            "email"
                            "Bank Holders Name"
                            "Bank Account Number"
                            "IFSC"
                            "Bank Name"
                            */
                            
                            for item in self.arrDictKeys {
                                //let val = self.responseDict[item as? String ?? ""]
                                let val = self.responseDict[item]
                                self.arrDictValues.append([val ?? []])
                            }
                            
                            // sameer 2/6/21
                            //for (index,keyFld) in (self.arrDictKeys as! [String]).enumerated() {
                            for (index,keyFld) in (self.arrDictKeys).enumerated() {
                                
                                let data = self.arrDictValues[index]
                                let arrData = data[0] as! Array<Any>
                                
                                if !((arrData[0] as? String) == "html") {
                                
                                    if arrData[1] as? Int == 1 {
                                        self.bankDict[keyFld] = ""
                                        self.arrBankKeysMendatory.append(keyFld)
                                    }else {
                                        self.bankDict[keyFld] = ""
                                        //self.arrBankKeysOptional.append(keyFld)
                                    }
                                    
                                }
                            }
                            
                            print(self.bankDict)
                            print(self.arrBankKeysMendatory)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                
                                self.userDetailTableView.dataSource = self
                                self.userDetailTableView.delegate = self
                                
                                self.userDetailTableView.reloadData()
                                //self.formTableView.tableFooterView = UIView()
                            }
                            
                            
                        } catch let error as NSError {
                            print(error)
                            DispatchQueue.main.async() {
                                self.view.makeToast(self.getLocalizatioStringValue(key: "JSON Exception"), duration: 2.0, position: .bottom)
                            }
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
            
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response.debugDescription)")
                }
                
                
            } else {
                
                //print("response = \(response)")
                //SwiftSpinner.hide()
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                do {
                    let resp = try (JSONSerialization.jsonObject(with: dataThis, options: []) as? [String:Any] ?? [:])
                    
                    print(" Form Response is:", resp)
                    
                    self.responseDict = resp["msg"] as? [String:Any] ?? [:]
                   
                    //print(" First name is: \(self.responseDict)")
                    
                    for (ind,item) in self.responseDict.enumerated() {
                        print(ind)
                        //print(item)
                        
                        self.arrDictKeys1.append(item.key)
                        //self.arrDictKeys.append(item.key)
                        //self.arrDictValues.append([item.value])
                        
                        if item.key == "Bank Name" {
                           
                            /*
                            if let arr = (item.value as! NSArray)[3] as? [String] {
                                self.arrDrop = arr
                            }
                            */
                            
                            if let arr = item.value as? [Any] {
                                if arr.count > 3 {
                                    if let bankNameArr = arr[3] as? NSArray {
                                        self.arrDrop = bankNameArr as! [String]
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    
                    self.arrDictKeys = self.arrDictKeys1.sorted()
                
            
                    if self.arrDictKeys.contains("name") {
                        if let nameIndex = self.arrDictKeys.index(of: "name") {
                            let element = self.arrDictKeys.remove(at: nameIndex)
                            self.arrDictKeys.insert(element, at: 0)
                        }
                    }
                    
                    if self.arrDictKeys.contains("mobile") {
                        if let mobileIndex = self.arrDictKeys.index(of: "mobile") {
                            let element = self.arrDictKeys.remove(at: mobileIndex)
                            self.arrDictKeys.insert(element, at: 1)
                        }
                    }
                    
                    if self.arrDictKeys.contains("email") {
                        if let emailIndex = self.arrDictKeys.index(of: "email") {
                            let element = self.arrDictKeys.remove(at: emailIndex)
                            self.arrDictKeys.insert(element, at: 2)
                        }
                    }
                    
                    if self.arrDictKeys.contains("Bank Holders Name") {
                        if let BankHoldersNameIndex = self.arrDictKeys.index(of: "Bank Holders Name") {
                            if self.arrDictKeys.count > 3 {
                                let element = self.arrDictKeys.remove(at: BankHoldersNameIndex)
                                self.arrDictKeys.insert(element, at: 3)
                            }
                        }
                    }
                   
                    if self.arrDictKeys.contains("Bank Account Number") {
                        if let BankAccountNumberIndex = self.arrDictKeys.index(of: "Bank Account Number") {
                            if self.arrDictKeys.count > 4 {
                                let element = self.arrDictKeys.remove(at: BankAccountNumberIndex)
                                self.arrDictKeys.insert(element, at: 4)
                            }
                        }
                    }
                    
                    if self.arrDictKeys.contains("IFSC") {
                        if let IFSCIndex = self.arrDictKeys.index(of: "IFSC") {
                            if self.arrDictKeys.count > 5 {
                                let element = self.arrDictKeys.remove(at: IFSCIndex)
                                self.arrDictKeys.insert(element, at: 5)
                            }
                        }
                    }
                    
                    if self.arrDictKeys.contains("Bank Name") {
                        if let BankNameIndex = self.arrDictKeys.index(of: "Bank Name") {
                            if self.arrDictKeys.count > 6 {
                                let element = self.arrDictKeys.remove(at: BankNameIndex)
                                self.arrDictKeys.insert(element, at: 6)
                            }
                        }
                    }
                    
                    
                    print("self.arrDictKeys are",self.arrDictKeys)
                    
                    
                    /*
                    "name"
                    "mobile"
                    "email"
                    "Bank Holders Name"
                    "Bank Account Number"
                    "IFSC"
                    "Bank Name"
                    */
                    
                    for item in self.arrDictKeys {
                        //let val = self.responseDict[item as? String ?? ""]
                        let val = self.responseDict[item]
                        self.arrDictValues.append([val ?? []])
                    }
                    
                    // sameer 2/6/21
                    //for (index,keyFld) in (self.arrDictKeys as! [String]).enumerated() {
                    for (index,keyFld) in (self.arrDictKeys).enumerated() {
                        
                        let data = self.arrDictValues[index]
                        let arrData = data[0] as! Array<Any>
                        
                        if !((arrData[0] as? String) == "html") {
                        
                            if arrData[1] as? Int == 1 {
                                self.bankDict[keyFld] = ""
                                self.arrBankKeysMendatory.append(keyFld)
                            }else {
                                self.bankDict[keyFld] = ""
                                //self.arrBankKeysOptional.append(keyFld)
                            }
                            
                        }
                    }
                    
                    print(self.bankDict)
                    print(self.arrBankKeysMendatory)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.userDetailTableView.dataSource = self
                        self.userDetailTableView.delegate = self
                        
                        self.userDetailTableView.reloadData()
                        //self.formTableView.tableFooterView = UIView()
                    }
                    
                    
                } catch let error as NSError {
                    print(error)
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                    }
                }
                
            }*/
            
        }
        task.resume()
    }
    
    func setXtraCoverFormToServer() {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        self.endPoint = UserDefaults.standard.string(forKey: "endpoint")!
        var request = URLRequest(url: URL(string: "\(self.endPoint)/setForm")!)
        //print("endpoint= \(endPoint)")
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        
        let jsonData = try! JSONSerialization.data(withJSONObject: self.bankDetails, options:[])
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        let postString = "userName=\(AppUserName)&apiKey=\(AppApiKey)&formData=\(jsonString)"
        //print("postString= \(postString)")
        print("url is :",request,"\nParam is :",postString)
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
            guard let dataThis = data, error == nil else {
                //SwiftSpinner.hide()
                
                /*
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    //check for fundamental networking error
                    print("error=\(error.debugDescription)")
                    
                    self.view.makeToast("Please Check Internet conection.", duration: 2.0, position: .bottom)
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            
            do {
                let json = try JSON(data: dataThis)
                print(json)
                
                if json["status"].string == "Success" {
                    
                    DispatchQueue.main.async {
                        
                        /*
                         if let success = self.formSubmit {
                         success(self.bankDetails)
                         self.dismiss(animated: false, completion: nil)
                         }*/
                        
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
                            vc.arrQuestionAnswerFinalData = self.arrQuestionAnswerData
                            
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
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
            
            
            
            
            
            /* SAMEER-14/6/22
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                //SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
                
            } else {
                
                //print("response = \(response)")
                //SwiftSpinner.hide()
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                do {
                    let json = try JSON(data: dataThis)
                    print(json)
                    
                    if json["status"].string == "Success" {
                        
                        DispatchQueue.main.async {
                            
                            /*
                            if let success = self.formSubmit {
                                success(self.bankDetails)
                                self.dismiss(animated: false, completion: nil)
                            }*/
                            
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
                                
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                         
                        }
                      
                    }else {
                        
                        DispatchQueue.main.async {
                            self.view.makeToast("Something went wrong!!", duration: 2.0, position: .bottom)
                        }
                        
                    }
                    
                }catch {
                    
                    DispatchQueue.main.async() {
                        self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
                    }
                    
                }
                
            }*/
            
        }
        task.resume()
    }
    
    //MARK: WebService Razorpay Api
    
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
                
                //self.txtFieldBranch.text = responseObject?["BRANCH"] as? String
                
                for (index,keyFld) in (self.arrDictKeys).enumerated() {
                    
                    let data = self.arrDictValues[index]
                    let arrData = data[0] as! Array<Any>
                    
                    if (arrData[0] as? String) == "text" && keyFld == "Bank Name" {
                        
                        let ndx = IndexPath(row:index, section: 0)
                        let cell = self.userDetailTableView.cellForRow(at: ndx) as! TextBoxCell
                        cell.txtField.text = responseObject?["BRANCH"] as? String
                        
                        self.bankDict["Bank Name"] = responseObject?["BRANCH"] as? String
                        
                    }
                    
                }
                
            }
            else{
                debugPrint(error as Any)
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "oops,something went wrong"), duration: 2.0, position: .bottom)
                }
                
            }
        })
        
        
    }
    
    //MARK: UITableview DataSource & Delegates methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDictValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let data = self.arrDictValues[indexPath.row]
        let arrData = data[0] as? Array<Any>
        
        if (arrData?[0] as? String) == "text" {
            
            isHtml = false
            
            let cellTextBox = tableView.dequeueReusableCell(withIdentifier: "TextBoxCell", for: indexPath) as! TextBoxCell
            
            //cellTextBox.txtField.placeholder = (self.arrDictKeys[indexPath.row])
            if (arrData?.count ?? 0) > 2 {
                cellTextBox.txtField.placeholder = self.getLocalizatioStringValue(key: arrData?[2] as? String ?? "")
            }
            
            
            cellTextBox.txtField.tag = indexPath.row
            cellTextBox.txtField.delegate = self
            cellTextBox.txtField.autocorrectionType = .no
            
            if cellTextBox.txtField.placeholder == "mobile" || cellTextBox.txtField.placeholder == "Mobile*" {
                
                cellTextBox.txtField.keyboardType = .numberPad
                
            }else if cellTextBox.txtField.placeholder == "email"  || cellTextBox.txtField.placeholder == "Email*" {
                
                cellTextBox.txtField.keyboardType = .emailAddress
                
            }else if cellTextBox.txtField.placeholder == "Bank Name" || cellTextBox.txtField.placeholder == "mobile" {
                
                cellTextBox.txtField.keyboardType = .default
                //cellTextBox.txtField.isUserInteractionEnabled = false
                
            }else {
                
                cellTextBox.txtField.keyboardType = .default
            }
                        
                    
            
            cellTextBox.txtField.layer.cornerRadius = 5.0
            cellTextBox.txtField.layer.borderWidth = 1.0
            cellTextBox.txtField.layer.borderColor = #colorLiteral(red: 0.4156862745, green: 0.1058823529, blue: 0.6039215686, alpha: 1)
            cellTextBox.seperatorLbl.backgroundColor = .clear
            
            return cellTextBox
            
        }else if (arrData?[0] as? String) == "html" {
            
            self.userDetailTableView.isScrollEnabled = true
                        
            let cellTextHtml = tableView.dequeueReusableCell(withIdentifier: "HtmlCell", for: indexPath) as! HtmlCell
            cellTextHtml.htmlTextView.attributedText =  (arrData?[3] as? String)?.htmlToAttributedString
            
            return cellTextHtml
            
        }else if (arrData?[0] as? String) == "select" {
            
            isHtml = false
            
            let cellTextSelect = tableView.dequeueReusableCell(withIdentifier: "SelectTextCell", for: indexPath) as! SelectTextCell
            
            //cellTextSelect.selectTextField.placeholder = (self.arrDictKeys[indexPath.row])
            if (arrData?.count ?? 0) > 2 {
                cellTextSelect.selectTextField.placeholder = self.getLocalizatioStringValue(key: arrData?[2] as? String ?? "")
            }
            
            cellTextSelect.selectTextField.tag = indexPath.row
            cellTextSelect.selectTextField.delegate = self
            cellTextSelect.selectTextField.addTarget(self, action: #selector(selectBankNameButtonClicked(_:)), for: .editingDidBegin)
            
            cellTextSelect.selectTextField.layer.cornerRadius = 5.0
            cellTextSelect.selectTextField.layer.borderWidth = 1.0
            cellTextSelect.selectTextField.layer.borderColor = #colorLiteral(red: 0.4156862745, green: 0.1058823529, blue: 0.6039215686, alpha: 1)
            cellTextSelect.seperatorLbl.backgroundColor = .clear
            
            return cellTextSelect
            
        }else if (arrData?[0] as? String) == "mobile" || (arrData?[0] as? String) == "number" {
            
            isHtml = false
            
            let cellMobNum = tableView.dequeueReusableCell(withIdentifier: "MobileNumberCell", for: indexPath) as! MobileNumberCell
            
            //if let imgURL = URL.init(string: self.responseDictIN["paymentImage"] as? String ?? "") {
                //cellMobNum.paymentImgView.af_setImage(withURL: imgURL)
            //}
            
            //cellMobNum.mobileNumberTxtField.placeholder = (self.arrDictKeys[indexPath.row])
            if (arrData?.count ?? 0) > 2 {
                cellMobNum.mobileNumberTxtField.placeholder = self.getLocalizatioStringValue(key: arrData?[2] as? String ?? "")
            }
            
            
            cellMobNum.mobileNumberTxtField.layer.cornerRadius = 5.0
            cellMobNum.mobileNumberTxtField.layer.borderWidth = 1.0
            cellMobNum.mobileNumberTxtField.layer.borderColor = #colorLiteral(red: 0.4156862745, green: 0.1058823529, blue: 0.6039215686, alpha: 1)
            cellMobNum.seperatorLbl.backgroundColor = .clear
            
            cellMobNum.mobileNumberTxtField.tag = indexPath.row
            cellMobNum.mobileNumberTxtField.delegate = self
            
            return cellMobNum
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: Custom Methods
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        
        let tncendpoint = UserDefaults.standard.string(forKey: "App_TncUrl") ?? AppBaseTnc // XtraCover Live
        
        guard let url = URL(string: tncendpoint) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func selectBankNameButtonClicked(_ sender: UITextField) {
        
        let existingFileDropDown = DropDown()
        existingFileDropDown.anchorView = sender
        existingFileDropDown.cellHeight = 44
        existingFileDropDown.bottomOffset = CGPoint(x: 0, y: 0)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        //let typeOfFileArray = self.arrDrop
        
        let data = self.arrDictValues[sender.tag]
        let arrData = data[0] as? Array<Any>
        
        //let drop = UIDropDown()
        var arrDrop = [String]()
        let arr = (arrData)?[3] as? [String]
        arrDrop = arr ?? []
        //drop.options = arrDrop
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        //let typeOfFileArray = self.arrDrop
        let typeOfFileArray = arrDrop
        existingFileDropDown.dataSource = typeOfFileArray
        
        // Action triggered on selection
        existingFileDropDown.selectionAction = { [unowned self] (index, item) in
            //sender.setTitle(item, for: .normal)
            sender.text = self.getLocalizatioStringValue(key: item)
        }
        existingFileDropDown.show()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
