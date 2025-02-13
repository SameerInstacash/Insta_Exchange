//
//  PreviousQuotationsViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 02/08/19.
//  Copyright © 2019 ZeroWaste. All rights reserved.
//

import UIKit
//import SwiftSpinner
import SwiftyJSON
import JGProgressHUD

class PreviousQuotationsViewController: UIViewController {

    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var secondStack: UIStackView!
    
    @IBOutlet weak var lblReferenceNumber: UILabel!
    @IBOutlet weak var lblPreferredTime: UILabel!
    
    @IBOutlet weak var referenceNumText: UITextField!
    
    @IBOutlet weak var submitBtnPrev: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    
    @IBOutlet weak var refId: UILabel!
    @IBOutlet weak var prefTime: UILabel!
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var mobText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var tableView: UILabel!
   
    var ref = ""
    var endPoint = ""
    let hud = JGProgressHUD()
    
    
    var sessionDict = [String:Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
                
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.changeLanguageOfUI()
    }
    
    func changeLanguageOfUI() {
                
        self.lblReferenceNumber.text = self.getLocalizatioStringValue(key: "Reference No")
        self.lblPreferredTime.text = self.getLocalizatioStringValue(key: "Preferred Time")
        self.referenceNumText.placeholder = self.getLocalizatioStringValue(key: "Reference Number")
        
        self.submitBtnPrev.setTitle(self.getLocalizatioStringValue(key: "Submit"), for: UIControl.State.normal)
        self.homeBtn.setTitle(self.getLocalizatioStringValue(key: "Home"), for: UIControl.State.normal)
         
    }
    
    @IBAction func homeBtnClicked(_ sender: Any) {
        
        /*
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! ViewController
        let imei = UserDefaults.standard.string(forKey: "imei_number")
        vc.IMEINumber = imei ?? ""
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        */
        
        self.dismiss(animated: false)
        
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        self.ref = referenceNumText.text ?? "0"
        
        if (self.ref.length > 1)  {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            self.modAPI()
        }else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Reference Number"), duration: 2.0, position: .bottom)
            }
            
        }
    }
    
    func modAPI()
    {
        //self.endPoint = "https://exchange.buyblynk.com/api/v1/public/" // Blynk
        
        self.endPoint = AppBaseUrl
        
        var request = URLRequest(url: URL(string: "\(endPoint)/getSessionIdbyIMEI")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        //let preferences = UserDefaults.standard
        //let postString = "productId=\(productId!)&customerId=\(customerId!)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        
        var postString = ""
        let imei = UserDefaults.standard.string(forKey: "imei_number") ?? ""
        
        postString = "IMEINumber=\(imei)&quotationId=\(ref)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        request.httpBody = postString.data(using: .utf8)
        
        print("url is :",request,"\nParam is :",postString)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async() {
                self.hud.dismiss()
            }
            
            guard let data = data, error == nil else {
                /*
                // check for fundamental networking error
                print("error=\(error.debugDescription)")
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                DispatchQueue.main.async {
                    self.view.makeToast("internet_prompt".localized, duration: 2.0, position: .bottom)
                }*/
                
                DispatchQueue.main.async() {
                    self.view.makeToast(error?.localizedDescription, duration: 3.0, position: .bottom)
                }
                
                return
            }
            
            
            //* SAMEER-14/6/22
            do {
                let json = try JSON(data: data)
                if json["status"] == "Success" {
                    
                    print(json)
                    DispatchQueue.main.async() {
                        let msg = json["msg"]
                        let id = msg["id"].string ?? ""
                        let name = msg["name"].string ?? ""
                        let mobileNumber = msg["mobileNumber"].string ?? ""
                        let email = msg["email"].string ?? ""
                        let productSummary = msg["productSummary"]
                        self.mobText.text = mobileNumber
                        self.nameText.text = name
                        self.emailText.text = email
                        self.refId.text = id
                        self.prefTime.text = "Not Set"
                        self.topStack.isHidden = false
                        self.secondStack.isHidden = false
                        self.submitBtnPrev.isHidden = true
                        self.referenceNumText.isHidden = true
                        self.tableView.isHidden = false
                        let htmlString = productSummary.string ?? ""
                        // works even without <html><body> </body></html> tags, BTW
                        let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
                        let attrStr = try? NSAttributedString( // do catch
                            data: data,
                            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                            documentAttributes: nil)
                        // suppose we have an UILabel, but any element with NSAttributedString will do
                        self.tableView.attributedText = attrStr
                        
                        
                        //let simpleStr = productSummary.string?.htmlToString ?? ""
                        //print(simpleStr)
                        
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
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            } else{
                
                DispatchQueue.main.async() {
                    //self.smartExLoadingImage.layer.removeAllAnimations()
                    //self.smartExLoadingImage.isHidden = true
                    
                    self.hud.dismiss()
                }
                
                do {
                    let json = try JSON(data: data)
                    if json["status"] == "Success" {
                        print(json)
                        DispatchQueue.main.async() {
                            let msg = json["msg"]
                            let id = msg["id"].string ?? ""
                            let name = msg["name"].string ?? ""
                            let mobileNumber = msg["mobileNumber"].string ?? ""
                            let email = msg["email"].string ?? ""
                            let productSummary = msg["productSummary"] ?? ""
                            self.mobText.text = mobileNumber
                            self.nameText.text = name
                            self.emailText.text = email
                            self.refId.text = id
                            self.prefTime.text = "Not Set"
                            self.topStack.isHidden = false
                            self.secondStack.isHidden = false
                            self.submitBtnPrev.isHidden = true
                            self.referenceNumText.isHidden = true
                            self.tableView.isHidden = false
                            let htmlString = productSummary.string ?? ""
                            // works even without <html><body> </body></html> tags, BTW
                            let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
                            let attrStr = try? NSAttributedString( // do catch
                                data: data,
                                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                documentAttributes: nil)
                            // suppose we have an UILabel, but any element with NSAttributedString will do
                            self.tableView.attributedText = attrStr
                            
                        }
                    }
                }catch{
                    
                }
                
            }*/
            
        }
        task.resume()
    }
    
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


