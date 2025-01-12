//
//  PreviousQuotePopUp.swift
//  SmartExchange
//
//  Created by Sameer Khan on 10/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class PreviousQuotePopUp: UIViewController {
    
    var popupDismiss : ((_ dict : [String:Any]) -> Void)?
    
    @IBOutlet weak var txtFieldRefNum: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cornerView: UIView!
    
    var ref = ""    
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.hideKeyboardWhenTappedAround()
        
        UIView.addShadow(baseView: self.cornerView)
    }
    
    //MARK: IBActions
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
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        
        if (txtFieldRefNum.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ?? false {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please Enter Reference Number"), duration: 2.0, position: .bottom)
            }
            
        }
        else {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            self.modAPI()
            
        }
        
    }
    
    func modAPI()
    {        
        var request = URLRequest(url: URL(string: "\(AppBaseUrl)/getSessionIdbyIMEI")!)
        
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        var postString = ""
        let imei = UserDefaults.standard.string(forKey: "imei_number") ?? ""
        
        postString = "IMEINumber=\(imei)&quotationId=\(self.txtFieldRefNum.text ?? "")&userName=\(AppUserName)&apiKey=\(AppApiKey)"
        request.httpBody = postString.data(using: .utf8)
        
        print("url is :",request,"\nParam is :",postString)
        
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
                    
                    print("json in response is :",json)
                    DispatchQueue.main.async() {
                        
                        let msg = json["msg"]
                        let productDescription = msg["productDescription"].string ?? ""
                        let productName = msg["productName"].string ?? ""
                        let productImage = msg["image"].string ?? ""
                        let productPrice = msg["itemPrice"].string ?? ""
                        let productRefNum = msg["id"].string ?? ""
                        
                        var dataDict = [String:Any]()
                        dataDict["productDescription"] = productDescription
                        dataDict["productName"] = productName
                        dataDict["productImage"] = productImage
                        dataDict["productPrice"] = productPrice
                        dataDict["productRefNum"] = productRefNum
                        
                        
                        //guard let isDismiss = self.popupDismiss else { return }
                        //isDismiss(dataDict)
                        //self.dismiss(animated: false, completion: nil)
                        
                        
                        self.dismiss(animated: false, completion: {
                            guard let isDismiss = self.popupDismiss else { return }
                            isDismiss(dataDict)
                        })
                                                
                        
                        /*
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
                        */
                        
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
