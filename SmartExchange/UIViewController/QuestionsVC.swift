//
//  QuestionsVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 23/05/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class QuestionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrQuestionAnswer : Questions?
    var TestDiagnosisForward: (() -> Void)?
    var selectedAppCode = ""
    var selectedCellIndex = -1
    var arrSelectedCellIndex = [Int]()
    
    var selectedDict = [String:Any]()
    var selectedAnswers = ""
    
    @IBOutlet weak var lblQuestionName: UILabel!
    @IBOutlet weak var cosmeticTableView: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    
    //@IBOutlet weak var optionView: UIView!
    //@IBOutlet weak var lblClickInfoOption: UILabel!
    var isInfoViewShow = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppQuestionIndex == 0 {
            self.btnPrevious.isHidden = true
        }else {
            self.btnPrevious.isHidden = false
        }
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            //self.lblQuestionName.text = arrQuestionAnswer?.specificationName
            self.lblQuestionName.text = self.getLocalizatioStringValue(key: arrQuestionAnswer?.specificationName ?? "")
            
        }else {
            //self.lblQuestionName.text = arrQuestionAnswer?.conditionSubHead
            self.lblQuestionName.text = self.getLocalizatioStringValue(key: arrQuestionAnswer?.conditionSubHead ?? "")
        }
      
        
        //self.changeLanguageOfUI()
        
    }
    
    func changeLanguageOfUI() {
                
        self.btnNext.setTitle(self.getLocalizatioStringValue(key: "NEXT"), for: UIControlState.normal)
        self.btnPrevious.setTitle(self.getLocalizatioStringValue(key: "BACK"), for: UIControlState.normal)
         
    }
    
    //MARK: IBActions
    @IBAction func previousBtnPressed(_ sender: UIButton) {
        
        arrAppQuestionsAppCodes?.remove(at: AppQuestionIndex-1)
        print("arrQuestionsAppCodes are :", arrAppQuestionsAppCodes ?? [])
        
        arrAppQuestAnswr?.remove(at: AppQuestionIndex-1)
        print("arrAppQuestAnswr are :", arrAppQuestAnswr ?? [])
        
        hardwareQuestionsCount += 2
        AppQuestionIndex -= 2
        
        
        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
        didFinishRetryDiagnosis()
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.selectedAppCode == "" {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are :", arrAppQuestionsAppCodes ?? [])
                
                //MARK: Physical Question's Data
                
                if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                    
                    self.selectedDict = [arrQuestionAnswer?.specificationName ?? "" : self.selectedAnswers]
                    
                }else {
                    
                    self.selectedDict = [arrQuestionAnswer?.conditionSubHead ?? "" : self.selectedAnswers]

                }
               
                arrAppQuestAnswr?.append(self.selectedDict)
                print("arrAppQuestAnswr are :", arrAppQuestAnswr ?? [])
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }else {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are :", arrAppQuestionsAppCodes ?? [])
                
                //MARK: Physical Question's Data
                
                if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                    
                    self.selectedDict = [arrQuestionAnswer?.specificationName ?? "" : self.selectedAnswers]
                    
                }else {
                    
                    self.selectedDict = [arrQuestionAnswer?.conditionSubHead ?? "" : self.selectedAnswers]

                }
                
                arrAppQuestAnswr?.append(self.selectedDict)
                print("arrAppQuestAnswr are :", arrAppQuestAnswr ?? [])
                
                // 14/3/22
                //AppResultString = AppResultString + self.selectedAppCode + ";"
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
            }
            
        }else {
            // "radio"
            // "select"
            
            if self.selectedAppCode == "" {
                
                DispatchQueue.main.async() {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Please select one option"), duration: 2.0, position: .bottom)
                }
                
            }else {
                
                arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                print("arrQuestionsAppCodes are :", arrAppQuestionsAppCodes ?? [])
                
                //MARK: Physical Question's Data
                
                if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                    
                    self.selectedDict = [arrQuestionAnswer?.specificationName ?? "" : self.selectedAnswers]
                    
                }else {
                    
                    self.selectedDict = [arrQuestionAnswer?.conditionSubHead ?? "" : self.selectedAnswers]

                }
                
                arrAppQuestAnswr?.append(self.selectedDict)
                print("arrAppQuestAnswr are :", arrAppQuestAnswr ?? [])
                
                // 14/3/22
                //AppResultString = AppResultString + self.selectedAppCode + ";"
                
                guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
            }
            
        }
                        
    }
    
    @IBAction func imageInfoBtnPressed(_ sender: UIButton) {
        
        var infoImage = ""
        var infoAnswer = ""
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            
            //print(self.arrQuestionAnswer?.specificationValue?[sender.tag].image ?? "No image")
            //print(self.arrQuestionAnswer?.specificationValue?[sender.tag].value ?? "No value")
            
            
            infoImage = self.arrQuestionAnswer?.specificationValue?[sender.tag].image ?? ""
            
            let str = self.arrQuestionAnswer?.specificationValue?[sender.tag].value?.removingPercentEncoding ?? ""
            infoAnswer = (str.replacingOccurrences(of: "+", with: " "))
            
        }else {
        
            //print(self.arrQuestionAnswer?.conditionValue?[sender.tag].image ?? "No image")
            //print(self.arrQuestionAnswer?.conditionValue?[sender.tag].value ?? "No value")
            
            infoImage = self.arrQuestionAnswer?.conditionValue?[sender.tag].image ?? ""
            
            let str = self.arrQuestionAnswer?.conditionValue?[sender.tag].value?.removingPercentEncoding ?? ""
            infoAnswer = (str.replacingOccurrences(of: "+", with: " "))
            
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageInfoPopUpVC") as! ImageInfoPopUpVC
                    
        vc.strInfoImage = infoImage
        vc.strAnswerInfo = infoAnswer
    
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
        
    }
    
    // MARK: - UITableView DataSource & Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            
            //return self.arrQuestionAnswer?.specificationValue?.count ?? 0
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                return (self.arrQuestionAnswer?.specificationValue?.count ?? 0) + 1
            }else {
                return self.arrQuestionAnswer?.specificationValue?.count ?? 0
            }
            
        }else {
            
            //return self.arrQuestionAnswer?.conditionValue?.count ?? 0
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                return (self.arrQuestionAnswer?.conditionValue?.count ?? 0) + 1
            }else {
                return self.arrQuestionAnswer?.conditionValue?.count ?? 0
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CosmeticQuestionTblCell = tableView.dequeueReusableCell(withIdentifier: "CosmeticQuestionTblCell", for: indexPath) as! CosmeticQuestionTblCell
        
        CosmeticQuestionTblCell.layer.cornerRadius = 5.0
        CosmeticQuestionTblCell.baseContentView.layer.cornerRadius = 5.0
        
        //let iconImgView : UIImageView = CosmeticQuestionTblCell.viewWithTag(10) as! UIImageView
        //let lblIconName : UILabel = CosmeticQuestionTblCell.viewWithTag(20) as! UILabel
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                
                if indexPath.row == self.arrQuestionAnswer?.specificationValue?.count {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.text = self.getLocalizatioStringValue(key: "None of the Above")
                }
                
            }
            
            if indexPath.row < (self.arrQuestionAnswer?.specificationValue?.count ?? 0) {
                
                let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.row]
                
                CosmeticQuestionTblCell.imageInfoBtn.tag = indexPath.row
                
                let str = answer?.value?.removingPercentEncoding ?? ""
                CosmeticQuestionTblCell.lblIconName.text = self.getLocalizatioStringValue(key: (str.replacingOccurrences(of: "+", with: " ")))
                
                
                if let qImage = self.arrQuestionAnswer?.specificationValue?[indexPath.row].image, qImage != "" {
                    
                    if let imgUrl = URL(string: qImage) {
                        
                        CosmeticQuestionTblCell.iconImgView.image = nil
                        CosmeticQuestionTblCell.iconImgView.af_setImage(withURL: imgUrl)
                        
                        //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = false
                        CosmeticQuestionTblCell.iconImgView.isHidden = false
                        ////CosmeticQuestionTblCell.imageInfoBtn.isHidden = false
                        CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                        
                        self.isInfoViewShow = false
                        
                    }else {
                        //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = true
                        CosmeticQuestionTblCell.iconImgView.isHidden = true
                        CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                        CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                    }
                    
                }else {
                    //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = true
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                }
                
            }
            
        }else {
            
            //MARK: To handle the case of NONE OF THE ABOVE
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                
                if indexPath.row == self.arrQuestionAnswer?.conditionValue?.count {
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.text = self.getLocalizatioStringValue(key: "None of the Above")
                }
                
            }
            
            if indexPath.row < (self.arrQuestionAnswer?.conditionValue?.count ?? 0) {
                
                let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.row]
                
                CosmeticQuestionTblCell.imageInfoBtn.tag = indexPath.row
                
                let str = answer?.value?.removingPercentEncoding ?? ""
                CosmeticQuestionTblCell.lblIconName.text = self.getLocalizatioStringValue(key: (str.replacingOccurrences(of: "+", with: " ")))
                
                
                if let qImage = self.arrQuestionAnswer?.conditionValue?[indexPath.row].image, qImage != "" {
                    
                    if let imgUrl = URL(string: qImage) {
                        
                        CosmeticQuestionTblCell.iconImgView.image = nil
                        CosmeticQuestionTblCell.iconImgView.af_setImage(withURL: imgUrl)
                        
                        //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = false
                        CosmeticQuestionTblCell.iconImgView.isHidden = false
                        ////CosmeticQuestionTblCell.imageInfoBtn.isHidden = false
                        CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                        
                        self.isInfoViewShow = false
                        
                    }else {
                        //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = true
                        CosmeticQuestionTblCell.iconImgView.isHidden = true
                        CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                        CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                    }
                    
                }else {
                    //CosmeticQuestionTblCell.img_icon_ContentainerView.isHidden = true
                    CosmeticQuestionTblCell.iconImgView.isHidden = true
                    CosmeticQuestionTblCell.imageInfoBtn.isHidden = true
                    CosmeticQuestionTblCell.lblIconName.textAlignment = .center
                }
                
            }
            
        }
        
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.arrSelectedCellIndex.contains(indexPath.row) {
                
                //CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#FC5400")
                //CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#52A68E")
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#28B03D")
                
                
                CosmeticQuestionTblCell.lblIconName.textColor = .white
                
            }else {
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.white
                CosmeticQuestionTblCell.lblIconName.textColor = .black
            }
            
        }else {
            
            if self.selectedCellIndex == indexPath.row {
                
                //CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#FC5400")
                //CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#52A68E")
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.init(hexString: "#28B03D")
                
                
                CosmeticQuestionTblCell.lblIconName.textColor = .white
                
            }else {
                
                CosmeticQuestionTblCell.baseContentView.backgroundColor = UIColor.white
                CosmeticQuestionTblCell.lblIconName.textColor = .black
            }
            
        }
        
        //MARK: To Show/Hide info icon option view
        //self.optionView.isHidden = self.isInfoViewShow
        //self.lblClickInfoOption.text = self.getLocalizatioStringValue(key: "Click “i” to see photos of all options")
        
        return CosmeticQuestionTblCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.cosmeticTableView {
            
            if self.arrQuestionAnswer?.viewType == "checkbox" {
                
                if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                    
                    //MARK: To handle the case of NONE OF THE ABOVE
                    if indexPath.row == self.arrQuestionAnswer?.specificationValue?.count {
                        
                        self.selectedAppCode = ""
                        
                        arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                        print("arrQuestionsAppCodes are when NONE OF THE ABOVE:", arrAppQuestionsAppCodes ?? [])
                        
                        
                        //MARK: 5/12/23
                        self.selectedDict = ["" : ""]
                        arrAppQuestAnswr?.append(self.selectedDict)
                        
                        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                        didFinishRetryDiagnosis()
                        self.dismiss(animated: false, completion: nil)
                        
                        return
                    }
                    
                    if self.selectedAppCode == "" {
                        
                        self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.row].appCode ?? ""
                        
                        //MARK: Physical Question's Data
                        let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.row]
                        let str = answer?.value?.removingPercentEncoding ?? ""
                        
                        self.selectedAnswers = (str.replacingOccurrences(of: "+", with: " "))
                        
                    }else {
                        
                        if !self.selectedAppCode.contains(self.arrQuestionAnswer?.specificationValue?[indexPath.row].appCode ?? "") {
                            
                            self.selectedAppCode += ";" + (self.arrQuestionAnswer?.specificationValue?[indexPath.row].appCode ?? "")
                            
                            //MARK: Physical Question's Data
                            let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.row]
                            let str = answer?.value?.removingPercentEncoding ?? ""
                            
                            self.selectedAnswers += "," + (str.replacingOccurrences(of: "+", with: " "))
                            
                        }
                        
                    }
                    
                }else {
                    
                    //MARK: To handle the case of NONE OF THE ABOVE
                    if indexPath.row == self.arrQuestionAnswer?.conditionValue?.count {
                        
                        self.selectedAppCode = ""
                        
                        arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                        print("arrQuestionsAppCodes are when NONE OF THE ABOVE:", arrAppQuestionsAppCodes ?? [])
                        
                        
                        //MARK: 5/12/23
                        self.selectedDict = ["" : ""]
                        arrAppQuestAnswr?.append(self.selectedDict)
                    
                        
                        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                        didFinishRetryDiagnosis()
                        self.dismiss(animated: false, completion: nil)
                        
                        return
                    }
                    
                    if self.selectedAppCode == "" {
                        
                        self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.row].appCode ?? ""
                        
                        //MARK: Physical Question's Data
                        let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.row]
                        
                        let str = answer?.value?.removingPercentEncoding ?? ""
                        self.selectedAnswers = (str.replacingOccurrences(of: "+", with: " "))
                        
                    }else {
                        if !self.selectedAppCode.contains(self.arrQuestionAnswer?.conditionValue?[indexPath.row].appCode ?? "") {
                            
                            self.selectedAppCode += ";" + (self.arrQuestionAnswer?.conditionValue?[indexPath.row].appCode ?? "")
                            
                            //MARK: Physical Question's Data
                            let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.row]
                            
                            let str = answer?.value?.removingPercentEncoding ?? ""
                            self.selectedAnswers += "," + (str.replacingOccurrences(of: "+", with: " "))
                            
                        }
                    }
                    
                }
                
                print("self.selectedAppCode is:-", self.selectedAppCode)
                print("self.selectedAnswers is:-", self.selectedAnswers)
                
                self.arrSelectedCellIndex.append(indexPath.row)
                //self.selectedCellIndex = indexPath.item
                self.cosmeticTableView.reloadData()
                
            }else {
                // "radio"
                // "select"
                
                if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                    
                    self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.row].appCode ?? ""
                    
                    //MARK: Physical Question's Data
                    let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.row]
                    let str = answer?.value?.removingPercentEncoding ?? ""
                    
                    self.selectedAnswers = (str.replacingOccurrences(of: "+", with: " "))
                    
                }else {
                    
                    self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.row].appCode ?? ""
                    
                    //MARK: Physical Question's Data
                    let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.row]
                    
                    let str = answer?.value?.removingPercentEncoding ?? ""
                    self.selectedAnswers = (str.replacingOccurrences(of: "+", with: " "))
                    
                }
                
                print("self.selectedAppCode is:-", self.selectedAppCode)
                print("self.selectedAnswers is:-", self.selectedAnswers)
                
                self.selectedCellIndex = indexPath.row
                self.cosmeticTableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    
                    arrAppQuestionsAppCodes?.append(self.selectedAppCode)
                    print("arrQuestionsAppCodes are when forward:", arrAppQuestionsAppCodes ?? [])
                    
                    //MARK: Physical Question's Data
                    if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                        
                        self.selectedDict = [self.arrQuestionAnswer?.specificationName ?? "" : self.selectedAnswers]
                        
                    }else {
                        
                        self.selectedDict = [self.arrQuestionAnswer?.conditionSubHead ?? "" : self.selectedAnswers]

                    }
                    
                    arrAppQuestAnswr?.append(self.selectedDict)
                    print("arrAppQuestAnswr are when forward:", arrAppQuestAnswr ?? [])
                    
                                        
                    guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                }
                
            }
            
            
            /* 14/3/22
             AppResultString = AppResultString + self.selectedAppCode + ";"
             
             guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
             didFinishRetryDiagnosis()
             self.dismiss(animated: false, completion: nil)
             */
            
        }else {
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    /*
    // MARK: - UICollectionView DataSource & Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            return self.arrQuestionAnswer?.specificationValue?.count ?? 0
        }else {
            return self.arrQuestionAnswer?.conditionValue?.count ?? 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cosmeticCell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "cosmeticCell1", for: indexPath)
        cosmeticCell1.layer.cornerRadius = 5.0
        
        //let iconImgView : UIImageView = cosmeticCell1.viewWithTag(10) as! UIImageView
        let lblIconName : UILabel = cosmeticCell1.viewWithTag(20) as! UILabel
        
        if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
            let answer = self.arrQuestionAnswer?.specificationValue?[indexPath.item]
            
            //let str = answer?.value?.removingPercentEncoding
            let str = answer?.value?.removingPercentEncoding ?? ""
            lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
            
            /*
            if let qImage = self.arrQuestionAnswer?.specificationValue?[indexPath.item].image {
                if let imgUrl = URL(string: qImage) {
                    iconImgView.af.setImage(withURL: imgUrl)
                }
            }*/
            
        }else {
            let answer = self.arrQuestionAnswer?.conditionValue?[indexPath.item]
            
            //let str = answer?.value?.removingPercentEncoding
            let str = answer?.value?.removingPercentEncoding ?? ""
            lblIconName.text = str.replacingOccurrences(of: "+", with: " ")
            
            /*
            if let qImage = self.arrQuestionAnswer?.conditionValue?[indexPath.item].image {
                if let imgUrl = URL(string: qImage) {
                    iconImgView.af.setImage(withURL: imgUrl)
                }
            }*/
         
        }
        
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if self.arrSelectedCellIndex.contains(indexPath.item) {
                cosmeticCell1.layer.borderWidth = 1.0
                cosmeticCell1.layer.borderColor = UIColor.init(hexString: "#20409A").cgColor
            }else {
                cosmeticCell1.layer.borderWidth = 0.0
                cosmeticCell1.layer.borderColor = UIColor.clear.cgColor
            }
        
        }else {
            
            if self.selectedCellIndex == indexPath.item {
                cosmeticCell1.layer.borderWidth = 1.0
                cosmeticCell1.layer.borderColor = UIColor.init(hexString: "#20409A").cgColor
            }else {
                cosmeticCell1.layer.borderWidth = 0.0
                cosmeticCell1.layer.borderColor = UIColor.clear.cgColor
            }
            
        }
                
        return cosmeticCell1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.arrQuestionAnswer?.viewType == "checkbox" {
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? "")
                    }
                    
                }
                
            }else {
                
                if self.selectedAppCode == "" {
                    self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
                }else {
                    if !self.selectedAppCode.contains(self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "") {
                        self.selectedAppCode += ";" + (self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? "")
                    }
                }
                
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.arrSelectedCellIndex.append(indexPath.item)
            //self.selectedCellIndex = indexPath.item
            self.cosmeticCollectionView.reloadData()
            
        }else {
            // "radio"
            // "select"
            
            if (self.arrQuestionAnswer?.specificationValue?.count ?? 0) > 0 {
                self.selectedAppCode = self.arrQuestionAnswer?.specificationValue?[indexPath.item].appCode ?? ""
            }else {
                self.selectedAppCode = self.arrQuestionAnswer?.conditionValue?[indexPath.item].appCode ?? ""
            }
            
            print("self.selectedAppCode is:-", self.selectedAppCode)
            
            self.selectedCellIndex = indexPath.item
            self.cosmeticCollectionView.reloadData()
            
        }
        
        
        /* 14/3/22
        AppResultString = AppResultString + self.selectedAppCode + ";"
        
        guard let didFinishRetryDiagnosis = self.TestDiagnosisForward else { return }
        didFinishRetryDiagnosis()
        self.dismiss(animated: false, completion: nil)
        */
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: self.cosmeticCollectionView.bounds.width, height: 60.0)
    }
    
    */
    

}
