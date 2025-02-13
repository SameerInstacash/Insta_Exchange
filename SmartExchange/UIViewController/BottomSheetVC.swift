//
//  BottomSheetViewController.swift
//  SmartExchange
//
//  Created by Sameer Khan on 07/02/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit

class BottomSheetVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var isArrowBtnSlide : ((_ isRotate:Bool) -> Void)?
    
    @IBOutlet weak var baseScrollView: UIScrollView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblSlide: UILabel!
    @IBOutlet weak var btnSlide: UIButton!
    
    var arrQuestionAnswerFinalData = [[String:Any]]()
    var arrFinalData = [[String:Any]]()
    var isComeForVC = ""
    
    var sessionDict = [String:Any]()    
    var arrKey = [String]()
    var arrValue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            
            self.myTableView.layer.cornerRadius = 5
            //self.setStatusBarColor(themeColor: .clear)
            
            if self.isComeForVC == "UserDetailsViewController" {
                self.createPhysicalDataTableUsingFinalArray()
            }
            else {
                self.createPhysicalDataTableForPreviousSession()
            }
            
            
        }
        
        self.isArrowBtnSlide = { isArrowBtnSlide in
            
            if isArrowBtnSlide {
                self.lblSlide.text = "Slide down"
                self.btnSlide.transform = self.btnSlide.transform.rotated(by: .pi)
            }
            else {
                self.lblSlide.text = "Slide up"
                self.btnSlide.transform = self.btnSlide.transform.rotated(by: .pi)
            }
            
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myTableView.register(UINib(nibName: "QuestAnsrTblCell", bundle: nil), forCellReuseIdentifier: "QuestAnsrTblCell")
        
        self.myTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
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
    
    func createPhysicalDataTableForPreviousSession() {
        
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
    
    //MARK: UITableView DataSource & Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Num: \(indexPath.row)")
        //print("Value: \(self.myArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isComeForVC == "UserDetailsViewController" ? self.arrFinalData.count : self.arrKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let QuestAnsrTblCell = tableView.dequeueReusableCell(withIdentifier: "QuestAnsrTblCell", for: indexPath) as! QuestAnsrTblCell
        
        if self.isComeForVC == "UserDetailsViewController" {
            
            let finalDict = self.arrFinalData[indexPath.row]
            
            QuestAnsrTblCell.lblQuestion.text = self.getLocalizatioStringValue(key: finalDict.keys.first ?? "")
            QuestAnsrTblCell.lblAnswer.text = self.getLocalizatioStringValue(key: finalDict.values.first as? String ?? "")
            
            if (indexPath.row == self.arrFinalData.count - 1) {
                QuestAnsrTblCell.lblSeperator.isHidden = true
            }else {
                QuestAnsrTblCell.lblSeperator.isHidden = false
            }
            
        }
        else {
            
            QuestAnsrTblCell.lblQuestion.text = self.arrKey[indexPath.row]
            QuestAnsrTblCell.lblAnswer.text = self.arrValue[indexPath.row]
            
        }                
        
        return QuestAnsrTblCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}
