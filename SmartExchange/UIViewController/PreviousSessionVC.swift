//
//  PreviousSessionVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 12/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import Luminous
import DKCamera
import DateTimePicker
import SwiftyJSON
//import SwiftSpinner
import JGProgressHUD

class PreviousSessionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var refValueLabel: UILabel!
    
    @IBOutlet weak var offeredPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    let hud = JGProgressHUD()
    var orderId = ""
    var arrFinalData = [[String:Any]]()
    var arrQuestionAnswerFinalData = [[String:Any]]()
    var myArray: Array<String> = []
    var sessionDict = [String:Any]()
    var arrKey = [String]() //s.
    var arrValue = [String]() //s.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        //self.productName.text = UserDefaults.standard.string(forKey: "productName")
        //self.deviceName = UserDefaults.standard.string(forKey: "productName") ?? ""
        
        let img = URL(string: UserDefaults.standard.string(forKey: "productImage") ?? "")
        self.downloadImage(url: img ?? URL(fileURLWithPath: ""))
        
        
        //New work
        self.productName.text = self.sessionDict["productName"] as? String ?? ""
        self.offeredPrice.text = "$ " + (self.sessionDict["productPrice"] as? String ?? "")
        
        let imgurl = URL(string: self.sessionDict["productImage"] as? String ?? "")
        self.productImage.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "smartphone"))
        
        self.refValueLabel.text = "Ref# " + (self.sessionDict["productRefNum"] as? String ?? "")
        
        self.orderId = self.sessionDict["productRefNum"] as? String ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myTableView.register(UINib(nibName: "QuestAnsrTblCell", bundle: nil), forCellReuseIdentifier: "QuestAnsrTblCell")
        
        self.myTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        
        let finalSummaryText = self.sessionDict["productDescription"] as? String ?? ""
        let arrSummaryString : [String?] = finalSummaryText.components(separatedBy: ";")
        var arrItem = [""]
        self.arrKey = []
        self.arrValue = []
        
        for item in arrSummaryString {
            arrItem = item?.components(separatedBy: "->") ?? []
            
            if arrItem.count > 1 {
                self.arrKey.append(arrItem[0])
                self.arrValue.append(arrItem[1])
            }else {
                let pre = self.arrValue.last
                let val = (pre ?? "") + " & " + arrItem[0]
                let key = self.arrKey.last
                
                self.arrKey.removeLast()
                self.arrValue.removeLast()
                
                self.arrKey.append(key ?? "")
                self.arrValue.append(val)
            }
        }
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.myTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "contentSize") {
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.myTableViewHeightConstraint.constant = newsize.height + 10.0
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            }
        }
        
    }
    
    //MARK: IBAction
    @IBAction func backBtnTapped(_ sender:UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func copyBtnTapped(_ sender:UIButton) {
        UIPasteboard.general.string = self.orderId
        
        DispatchQueue.main.async() {
            self.view.makeToast(self.getLocalizatioStringValue(key: "copied"), duration: 1.0, position: .bottom)
        }
        
    }
    
    @IBAction func uploadIdBtnClicked(_ sender: UIButton) {
        
        let camera = DKCamera()
        camera.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
            self.dismiss(animated: true, completion: nil)
            let newImage = self.resizeImage(image: image ?? UIImage(), newWidth: 800)
            
            
            let backgroundImage = newImage
            let watermarkImage = #imageLiteral(resourceName: "watermark")
            UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
            backgroundImage.draw(in: CGRect(x: 0.0, y: 0.0, width: backgroundImage.size.width, height: backgroundImage.size.height))
            watermarkImage.draw(in: CGRect(x: 0, y: 0, width: watermarkImage.size.width, height: backgroundImage.size.height))
            
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageData:NSData = UIImagePNGRepresentation(result ?? newImage) as! NSData
            
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            
            var request = URLRequest(url: URL(string: "\(AppBaseUrl)/idProof")!)
            
            request.httpMethod = "POST"
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            
            let customerId = UserDefaults.standard.string(forKey: "customer_id") ?? ""
            let postString = "customerId=\(customerId)&orderId=\(self.orderId)&photo=\(strBase64)&userName=\(AppUserName)&apiKey=\(AppApiKey)"
            
            //print("idProof url is :",request,"\nParam is :",postString)
            print("idProof url is :",request,"\nParam is :")
            
            //SwiftSpinner.show("")
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                //let respjson = try? JSON(data: data ?? Data())
                //print("respjson",respjson ?? "nothing")
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                guard let dataThis = data, error == nil else {
                    
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
                            self.view.makeToast(self.getLocalizatioStringValue(key: "Photo Id uploaded successfully!"), duration: 1.0, position: .bottom)
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
        self.present(camera, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTableViewHeightConstraint: NSLayoutConstraint!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Num: \(indexPath.row)")
        //print("Value: \(self.myArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.arrFinalData.count
        return arrKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let QuestAnsrTblCell = tableView.dequeueReusableCell(withIdentifier: "QuestAnsrTblCell", for: indexPath) as! QuestAnsrTblCell
        
        //let finalDict = self.arrFinalData[indexPath.row]
        
        QuestAnsrTblCell.lblQuestion.text = self.arrKey[indexPath.row]
        QuestAnsrTblCell.lblAnswer.text = self.arrValue[indexPath.row]
        
//        if (indexPath.row == self.arrFinalData.count - 1) {
//            QuestAnsrTblCell.lblSeperator.isHidden = true
//        }else {
//            QuestAnsrTblCell.lblSeperator.isHidden = false
//        }
        
        return QuestAnsrTblCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func removeDuplicate(list: [[String:Any]]) -> [[String:Any]] {
        var alreadyKnowKeys: [String] = []
        var newArray: [[String:Any]] = []
        
        list.forEach { (item) in
            if let key = item.keys.first {
                if !alreadyKnowKeys.contains(key) {
                    newArray.append(item)
                    alreadyKnowKeys.append(key)
                }
            }
            
        }
        
        return newArray
    }
    
    func createPhysicalDataTableUsingFinalArray() {
        
        print("self.arrQuestionAnswerFinalData is : ", self.arrQuestionAnswerFinalData)
        
        for dict in self.arrQuestionAnswerFinalData {
            let key = dict.keys.first
            let val = dict.values.first
            
            if (key != "" && (val as? String ?? "") != "") {
                self.arrFinalData.append(dict)
                print("self.arrFinalData", self.arrFinalData)
            }
        }
        
        
        
        let arrRemoveDuplicate = self.removeDuplicate(list: self.arrFinalData)
        self.arrFinalData = []
        self.arrFinalData = arrRemoveDuplicate
        
        
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.reloadData()
        
    }
    
    func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    func createTableUsingMyArray() {
        
        let appCodeS = UserDefaults.standard.string(forKey: "appCodes") ?? ""
        
        var functional = "Functional Issue: "
        //var start = 0;
        
        //MARK: Ist
        var l = UserDefaults.standard.string(forKey: "lcd") ?? ""
        
        if (appCodeS.contains("SPTS01")) {
            //l = "flawless".localized
            l = "Flawless"
        }
        if(appCodeS.contains("SPTS02")) {
            //l = "Minor_Scratches".localized
            l = "2-3 Minor Scratches"
        }
        if(appCodeS.contains("SPTS03")) {
            //l = "Heavily_Scratched".localized
            l = "Heavily Scratched"
        }
        if(appCodeS.contains("SPTS04")) {
            //l = "cracked".localized
            l = "Cracked"
        }
        if(appCodeS.contains("SBRK01")) {
            //l = "Not_Working".localized
            l = "Not Working"
        }
        
        //let lc = "lcd".localized
        let lc = "LCD/Screen Glass"
        let lcd = "\(lc) : \(l)"
        
        
        //MARK: 2nd
        //let db = "device_body".localized
        let db = "Device Body"
        
        var b = UserDefaults.standard.string(forKey: "back") ?? ""
        print("devie body: \(b)")
        
        if(appCodeS.contains("CPBP01")){
            //b = "flawless".localized
            b = "Flawless"
        }
        if(appCodeS.contains("CPBP02")){
            //b = "Minor_Scratches".localized
            b = "2-3 Minor Scratches"
        }
        if(appCodeS.contains("CPBP03")){
            //b = "Heavily_Scratched".localized
            b = "Heavily Scratched"
        }
        if(appCodeS.contains("CPBP05")){
            //b = "cracked".localized
            b = "Cracked"
        }
        if(appCodeS.contains("CPBP04")){
            //b = "Dented".localized
            b = "Dented"
        }
        
        let body = "\(db) : \(b)"
        
        
        var myarray: Array = [lcd, body]
        
        if (!UserDefaults.standard.bool(forKey: "rotation")){
            //functional = "rotation_info".localized
            
            functional = "Auto Roatation : Defective"
            myarray.append(functional)
        }
        
        if ((!UserDefaults.standard.bool(forKey: "proximity"))){
            //functional = "Proximity_info".localized
            
            functional = "Proximity Sensor : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "volume")){
            //functional = "hardware_info".localized
            
            functional = "Hardware Buttons : Defective"
            myarray.append(functional)
        }
        
        /*
         if (!UserDefaults.standard.bool(forKey: "connection")){
         //functional = "Wifi_info".localized
         
         functional = "WIFI: Defective"
         myarray.append(functional)
         }
         */
        
        /* MARK: Ajay told to Remove both test on 27/3/23
         if (!UserDefaults.standard.bool(forKey: "earphone")){
         //functional = "earphone_info".localized
         
         functional = "Earphone Jack : Defective"
         myarray.append(functional)
         }
         
         if (!UserDefaults.standard.bool(forKey: "charger")){
         //functional = "charger_info".localized
         
         functional = "Device Charger : Defective"
         myarray.append(functional)
         }
         */
        
        if (!UserDefaults.standard.bool(forKey: "camera")){
            //functional = "camera_info".localized
            
            functional = "Camera : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "fingerprint")){
            //functional = "fingerprint_info".localized
            
            functional = "Device Biometrics : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "WIFI")){
            //functional = "wifi_info".localized
            
            functional = "WIFI : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "GSM")) {
            //functional = "gsm_info".localized
            
            functional = "GSM : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Bluetooth")) {
            //functional = "bluetooth_info".localized
            
            functional = "Bluetooth : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "GPS")) {
            //functional = "gps_info".localized
            
            functional = "GPS : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "mic")){
            //functional = "mic_info".localized
            
            functional = "Microphone : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Speakers")) {
            //functional = "speakers_info".localized
            
            functional = "Speakers : Defective"
            myarray.append(functional)
        }
        
        if (!UserDefaults.standard.bool(forKey: "Vibrator")) {
            //functional = "vibrator_info".localized
            
            functional = "Vibrator : Defective"
            myarray.append(functional)
        }
        
        /*
         if(!UserDefaults.standard.bool(forKey: "NFC")) {
         //functional = "nfc_info".localized
         
         functional = "nfc_info".localized
         myarray.append(functional)
         }
         */
        
        self.myArray = myarray
        print("self.myArray is : ", self.myArray)
        
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        self.myTableView.reloadData()
        
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.productImage.image = UIImage(data: data)
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
}
