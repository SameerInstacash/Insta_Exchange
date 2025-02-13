//
//  FindStoreVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 26/07/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import JGProgressHUD
import MessageUI

class FindStoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var storeTableView: UITableView!
    
    @IBOutlet weak var locationBaseView: UIView!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var heightOfLocationTableView: NSLayoutConstraint!
    @IBOutlet weak var lblStoreLocationTitle: UILabel!
    
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var heightOfBtnStackView: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var backBtnPopUP: UIButton!
    @IBOutlet weak var okBtnPopUP: UIButton!
    
    let reachability: Reachability? = Reachability()
    let hud = JGProgressHUD()
    
    //var arrStoreData = [[String:Any]]()
    var arrStoreData : [[String:Any]]?
    var arrStoreDataSelected : [[String:Any]]?
    
    var arrStoreCountry : [String]?
    var arrStoreStore : [String]?
    var arrStoreCity : [String]?
    
    var selectedStoreCountryIndex = -1
    var selectedStoreStoreIndex = -1
    var selectedStoreCityIndex = -1
    
    var selectedStoreCountryName = ""
    var selectedStoreStoreName = ""
    var selectedStoreCityName = ""
    
    var currentIndexShow = 0
    var btnIndex = 0
    
    
    @IBOutlet weak var floatTableView: UITableView!
    @IBOutlet weak var floatTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnFloating: UIButton!
    @IBOutlet weak var FloatBGView: UIView!
    
    var touchGest = UITapGestureRecognizer()
    var floatingItemsArrayIN:[String] = ["Call","Mail","Chat"]
    var floatingImageArrayIN:[UIImage] = [#imageLiteral(resourceName: "callSupport"),#imageLiteral(resourceName: "mailSupport"),#imageLiteral(resourceName: "chatSupport")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        self.fireWebServiceForFetchStoreLocationDetails()
        
        floatTableView.register(UINib(nibName: "FloatingItemCell", bundle: nil), forCellReuseIdentifier: "FloatingItemCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.storeTableView.register(UINib(nibName: "StoreDetailsTblCell", bundle: nil), forCellReuseIdentifier: "StoreDetailsTblCell")
        
        
        self.locationTableView.register(UINib(nibName: "StoreLocationTblCell", bundle: nil), forCellReuseIdentifier: "StoreLocationTblCell")
        //self.locationTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        
        touchGest = UITapGestureRecognizer(target: self, action: #selector(HomeVC.myviewTapped(_:)))
        touchGest.numberOfTapsRequired = 1
        touchGest.numberOfTouchesRequired = 1
        FloatBGView.addGestureRecognizer(touchGest)
        FloatBGView.isUserInteractionEnabled = true
        
        
        //self.changeLanguageOfUI()
        
    }
    
    func changeLanguageOfUI() {
                
        self.lblTitle.text = self.getLocalizatioStringValue(key: "Find Store")
        
        self.backBtn.setTitle(self.getLocalizatioStringValue(key: "BACK"), for: UIControl.State.normal)
        self.okBtn.setTitle(self.getLocalizatioStringValue(key: "OK"), for: UIControl.State.normal)
        
        self.backBtnPopUP.setTitle(self.getLocalizatioStringValue(key: "BACK"), for: UIControl.State.normal)
        self.okBtnPopUP.setTitle(self.getLocalizatioStringValue(key: "OK"), for: UIControl.State.normal)
         
    }
    
    //MARK: button action methods
    
    @IBAction func onClickCustomSupport(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = !sender.isSelected
            
            self.floatTableView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.floatTableViewHeightConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                self.floatTableView.alpha = 0
                self.FloatBGView.isHidden = true
            })
        }else {
            sender.isSelected = !sender.isSelected
            
            self.floatTableView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                
                self.floatTableViewHeightConstraint.constant = 150.0
                
                self.view.layoutIfNeeded()
                self.floatTableView.alpha = 1
                self.FloatBGView.isHidden = false
            })
        }
        
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        
        btnFloating.isSelected = !btnFloating.isSelected
        
        self.floatTableView.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.floatTableViewHeightConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.floatTableView.alpha = 0
            self.FloatBGView.isHidden = true
        })
        
    }
    
    @IBAction func okBtnPressedForBack(_ sender: UIButton) {
        //_ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false)
    }
    
    @IBAction func backButtonPressedOnStoreList(_ sender: UIButton) {
        
        self.currentIndexShow -= 1
        
        print("self.currentIndexShow back click" , self.currentIndexShow)
        
        switch self.currentIndexShow {
        case -1:
            //_ = self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: false)
            
        case 0:
            selectedStoreCountryIndex = -1
            selectedStoreCountryName = ""
            self.lblTitle.text = self.getLocalizatioStringValue(key: "Find Store")
            
            self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your Country")
            self.locationTableView.reloadData()
            self.heightOfLocationTableView.constant = CGFloat((self.arrStoreCountry?.count ?? 0)) * 50.0
            
        case 1:
            selectedStoreStoreIndex = -1
            selectedStoreStoreName = ""
            self.lblTitle.text = self.getLocalizatioStringValue(key: "Find Store")
            
            self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your Store")
            self.locationTableView.reloadData()
            self.heightOfLocationTableView.constant = CGFloat((self.arrStoreStore?.count ?? 0)) * 50.0
            
        case 2:
            selectedStoreCityIndex = -1
            selectedStoreCityName = ""
            self.lblTitle.text = self.getLocalizatioStringValue(key: "Find Store")
            
            self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your City")
            self.locationTableView.reloadData()
            self.heightOfLocationTableView.constant = CGFloat((self.arrStoreCity?.count ?? 0)) * 50.0
            
            self.locationBaseView.isHidden = !self.locationBaseView.isHidden
            
            self.btnStackView.isHidden = !self.btnStackView.isHidden
            self.heightOfBtnStackView.constant = 0
            self.arrStoreDataSelected = []
            self.storeTableView.reloadData()
            
        default:
            
            self.storeTableView.reloadData()
            
        }
        
    }
    
    @IBAction func okButtonPressedOnStoreList(_ sender: UIButton) {
        
        self.currentIndexShow += 1
        print("self.currentIndexShow ok click" , self.currentIndexShow)
        
        switch self.currentIndexShow {
            
        case 0:
            selectedStoreCountryIndex = -1
            
            self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your Country")
            self.locationTableView.reloadData()
            self.heightOfLocationTableView.constant = CGFloat((self.arrStoreCountry?.count ?? 0)) * 50.0
            
        case 1:
            
            if self.selectedStoreCountryIndex == -1 {
                
                self.currentIndexShow -= 1
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please select country"), duration: 1.0, position: .bottom)
                
            } else {
                
                self.loadStoreDataAccordingToSelectedCountry()
                
                self.selectedStoreStoreIndex = -1
                
                self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your Store")
                self.locationTableView.reloadData()
                self.heightOfLocationTableView.constant = CGFloat((self.arrStoreStore?.count ?? 0)) * 50.0
                
            }
                        
        case 2:
            
            if self.selectedStoreStoreIndex == -1 {
                
                self.currentIndexShow -= 1
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please select store"), duration: 1.0, position: .bottom)
                
            } else {
                
                self.loadCityDataAccordingToSelectedStore()
                
                selectedStoreCityIndex = -1
                
                self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your City")
                self.locationTableView.reloadData()
                self.heightOfLocationTableView.constant = CGFloat((self.arrStoreCity?.count ?? 0)) * 50.0
                
            }
            
        default:
            
            //MARK: TO-DO:  Load StoreTabelView here
            
            if self.selectedStoreCityIndex == -1 {
                
                self.currentIndexShow -= 1
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please select city"), duration: 1.0, position: .bottom)
                
            } else {
                
                self.loadStoreDataAccordingToSelectedCity()
                
                self.lblTitle.text = self.selectedStoreCityName
                
                selectedStoreCountryIndex = -1
                selectedStoreStoreIndex = -1
                selectedStoreCityIndex = -1
                
                self.locationBaseView.isHidden = !self.locationBaseView.isHidden
                self.btnStackView.isHidden = !self.btnStackView.isHidden
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.heightOfBtnStackView.constant = 55
                } else {
                    self.heightOfBtnStackView.constant = 40
                }
                
                self.storeTableView.dataSource = self
                self.storeTableView.delegate = self
                self.storeTableView.reloadData()
                                
            }
                        
        }
        
    }
    
    //MARK: Custom Methods
    func loadStoreDataAccordingToSelectedCountry() {
        
        //MARK: 2. Store
        var storeName = ""
        self.arrStoreStore = []
        
        for i in 0..<(self.arrStoreData?.count ?? 0) {
            
            let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
            
            if (obj["country"] as? String ?? "") == self.selectedStoreCountryName {
                
                storeName = (obj["project"] as? String ?? "")
                
                if !(self.arrStoreStore?.contains(storeName) ?? false) {
                    self.arrStoreStore?.append(storeName)
                }
                
            }
                        
        }
        
    }
    
    func loadCityDataAccordingToSelectedStore() {
        
        //MARK: 3. City
        var cityName = ""
        self.arrStoreCity = []
        
        for i in 0..<(self.arrStoreData?.count ?? 0) {
            
            let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
            
            if (obj["country"] as? String ?? "") == self.selectedStoreCountryName {
                
                if (obj["project"] as? String ?? "") == self.selectedStoreStoreName {
                    
                    cityName = (obj["city"] as? String ?? "")
                    
                    if !(self.arrStoreCity?.contains(cityName) ?? false) {
                        self.arrStoreCity?.append(cityName)
                    }
                    
                }
            }
                        
        }
        
        //MARK: Sort city array alphabetically on 8/8/23
        var _: ()? = self.arrStoreCity?.sort { $0.localizedLowercase < $1.localizedLowercase }
        //print("sorteArray",sorteArray ?? [])
        
    }
    
    func loadStoreDataAccordingToSelectedCity() {
        
        self.arrStoreDataSelected = []
        
        for i in 0..<(self.arrStoreData?.count ?? 0) {
            
            let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
            
            if (obj["country"] as? String ?? "") == self.selectedStoreCountryName {
                
                if (obj["project"] as? String ?? "") == self.selectedStoreStoreName {
                    
                    if (obj["city"] as? String ?? "") == self.selectedStoreCityName {
                        
                        self.arrStoreDataSelected?.append(self.arrStoreData?[i] ?? [:])
                    }
                }
            }
            
        }
        
    }
    
    
    @objc func radioButtonClicked(_ sender:UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.locationTableView)
        let indexPath = self.locationTableView.indexPathForRow(at: buttonPosition)
        //let cell = self.locationTableView.cellForRow(at: indexPath ?? IndexPath()) as! StoreLocationTblCell
        //print(cell.itemLabel.text)//print or get item
        print(indexPath?.row ?? -1)

        
        switch currentIndexShow {
        case 0:
            
            print(self.arrStoreCountry?[indexPath?.row ?? 0] ?? "Country")
            
            self.selectedStoreCountryName = self.arrStoreCountry?[indexPath?.row ?? 0] ?? ""
            
            self.selectedStoreCountryIndex = indexPath?.row ?? 0
            self.selectedStoreStoreIndex = -1
            self.selectedStoreCityIndex = -1
            
            self.locationTableView.reloadData()
            
        case 1:
            
            print(self.arrStoreStore?[indexPath?.row ?? 0] ?? "Store")
            
            self.selectedStoreStoreName = self.arrStoreStore?[indexPath?.row ?? 0] ?? ""
            
            self.selectedStoreCountryIndex = -1
            self.selectedStoreStoreIndex = indexPath?.row ?? 0
            self.selectedStoreCityIndex = -1
            
            self.locationTableView.reloadData()
            
        case 2:
            
            print(self.arrStoreCity?[indexPath?.row ?? 0] ?? "City")
            
            self.selectedStoreCityName = self.arrStoreCity?[indexPath?.row ?? 0] ?? ""
            
            self.selectedStoreCountryIndex = -1
            self.selectedStoreStoreIndex = -1
            self.selectedStoreCityIndex = indexPath?.row ?? 0
            
            self.locationTableView.reloadData()
            
        default:
            
            print("BLANK")
            
        }
        
        
    }
    
    //MARK: UITableview DataSource & Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == floatTableView {
            
            return self.floatingItemsArrayIN.count
            
        } else if tableView == self.locationTableView {
            
            switch currentIndexShow {
            case 0:
                return self.arrStoreCountry?.count ?? 0
                
            case 1:
                return self.arrStoreStore?.count ?? 0
                
            case 2:
                return self.arrStoreCity?.count ?? 0
                
            default:
                
                return 0
            }
            
        } else {
            
            // MARK: StoreDetailsTblCell
            
            return self.arrStoreDataSelected?.count ?? 0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == floatTableView {
            
            let floatingItemCell = tableView.dequeueReusableCell(withIdentifier: "FloatingItemCell", for: indexPath) as! FloatingItemCell
            
            floatingItemCell.itemImgView.image = floatingImageArrayIN[indexPath.row]
            floatingItemCell.itemDescriptionLbl.text = "  " + self.getLocalizatioStringValue(key: floatingItemsArrayIN[indexPath.row]) + "  "
            
            return floatingItemCell
            
        } else if tableView == self.locationTableView {
            
            let StoreLocationTblCell = tableView.dequeueReusableCell(withIdentifier: "StoreLocationTblCell", for: indexPath) as! StoreLocationTblCell
            
            switch currentIndexShow {
            case 0:
                StoreLocationTblCell.lblStoreLocation.text = self.arrStoreCountry?[indexPath.row]
                StoreLocationTblCell.btnRadio.tag = indexPath.row
                
                if indexPath.row == self.selectedStoreCountryIndex {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "unchk-fill"), for: .normal)
                    
                } else {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "uncheck"), for: .normal)
                    
                }
                
                StoreLocationTblCell.btnRadio.addTarget(self, action: #selector(radioButtonClicked), for: .touchUpInside)
                
            case 1:
                StoreLocationTblCell.lblStoreLocation.text = self.arrStoreStore?[indexPath.row]
                StoreLocationTblCell.btnRadio.tag = indexPath.row
                
                if indexPath.row == self.selectedStoreStoreIndex {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "unchk-fill"), for: .normal)
                    
                } else {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "uncheck"), for: .normal)
                    
                }
                
                StoreLocationTblCell.btnRadio.addTarget(self, action: #selector(radioButtonClicked), for: .touchUpInside)
                
            case 2:
                StoreLocationTblCell.lblStoreLocation.text = self.arrStoreCity?[indexPath.row]
                StoreLocationTblCell.btnRadio.tag = indexPath.row
                
                if indexPath.row == self.selectedStoreCityIndex {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "unchk-fill"), for: .normal)
                    
                } else {
                    
                    StoreLocationTblCell.btnRadio.setImage(UIImage.init(named: "uncheck"), for: .normal)
                    
                }
                
                StoreLocationTblCell.btnRadio.addTarget(self, action: #selector(radioButtonClicked), for: .touchUpInside)
                
            default:
                return UITableViewCell()
                
            }
            
            return StoreLocationTblCell
            
        } else {
            // MARK: StoreDetailsTblCell
            
            let StoreDetailsTblCell = tableView.dequeueReusableCell(withIdentifier: "StoreDetailsTblCell", for: indexPath) as! StoreDetailsTblCell
            
            let obj = self.arrStoreDataSelected?[indexPath.row]
            
            if let imgURL = URL(string: obj?["storeImage"] as? String ?? "") {
                StoreDetailsTblCell.storeImageVW.af_setImage(withURL: imgURL)
            }
            
            StoreDetailsTblCell.lblStoreName.text = self.getLocalizatioStringValue(key: obj?["storeName"] as? String ?? "")
            StoreDetailsTblCell.lblStoreLocation.text = self.getLocalizatioStringValue(key: obj?["address"] as? String ?? "")
            StoreDetailsTblCell.lblStoreToken.text = self.getLocalizatioStringValue(key: "STORE TOKEN: ") + (obj?["storeToken"] as? String ?? "")
            
            //StoreDetailsTblCell.lblStoreLocation.text = obj?["storeLocation"] as? String ?? ""
            //StoreDetailsTblCell.lblStoreCode.text = obj?["storeCode"] as? String ?? ""
                                    
            
            return StoreDetailsTblCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == floatTableView {
            
            switch indexPath.row {
            case 0:
                self.onClickCallButton()
            case 1:
                self.onClickEmailButton()
            default:
                
                guard let url = URL(string: "https://wa.me/\(appDelegate_Obj.supportChatNumber ?? "")") else {
                    return //be safe
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
            }
            
            
            btnFloating.isSelected = !btnFloating.isSelected
            
            self.floatTableView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.floatTableViewHeightConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                self.floatTableView.alpha = 0
                self.FloatBGView.isHidden = true
            })
            
            
        } else if tableView == self.locationTableView {
            
            switch currentIndexShow {
            case 0:
                
                print(self.arrStoreCountry?[indexPath.row] ?? "Country")
                
                self.selectedStoreCountryName = self.arrStoreCountry?[indexPath.row] ?? ""
                
                self.selectedStoreCountryIndex = indexPath.row
                self.selectedStoreStoreIndex = -1
                self.selectedStoreCityIndex = -1
                
                self.locationTableView.reloadData()
                
            case 1:
                
                print(self.arrStoreStore?[indexPath.row] ?? "Store")
                
                self.selectedStoreStoreName = self.arrStoreStore?[indexPath.row] ?? ""
                
                self.selectedStoreCountryIndex = -1
                self.selectedStoreStoreIndex = indexPath.row
                self.selectedStoreCityIndex = -1
                
                self.locationTableView.reloadData()
                
            case 2:
                
                print(self.arrStoreCity?[indexPath.row] ?? "City")
                
                self.selectedStoreCityName = self.arrStoreCity?[indexPath.row] ?? ""
                
                self.selectedStoreCountryIndex = -1
                self.selectedStoreStoreIndex = -1
                self.selectedStoreCityIndex = indexPath.row
                
                self.locationTableView.reloadData()
                
            default:
                
                print("BLANK")
                
            }
            
        } else {
            // MARK: StoreDetailsTblCell
            
        }
        
    }
    
    //MARK: web service methods
    
    func storeLocationDetailsApiPost(strURL : String , parameters:NSDictionary, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let web = WebServies()
        web.postRequest(urlString: strURL, paramDict: (parameters as! Dictionary<String, AnyObject>), completionHandler: completionHandler)
    }
    
    func fireWebServiceForFetchStoreLocationDetails()
    {
        if reachability?.connection.description != "No Connection" {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            #if DEBUG
            
            //let strUrl = "https://nayapurana-uat.getinstacash.in/npexchange/api/v1/public/storeList"
            
            let strUrl = AppBaseUrl + "storeList"
            
            #else
            
            let strUrl = AppBaseUrl + "storeList"
            
            #endif
            
            var parameters = [String: Any]()
            
            parameters  = [
                "userName" : AppUserName,
                "apiKey" : AppApiKey,
            ]
            
            print("strUrl is:" , strUrl)
            print("parameters are:" , parameters)
            
            self.storeLocationDetailsApiPost(strURL: strUrl, parameters: parameters as? NSDictionary ?? [:], completionHandler: { responseObject , error in
                
                DispatchQueue.main.async() {
                    self.hud.dismiss()
                }
                
                print(responseObject ?? [:])
                
                if error == nil {
                    
                    if responseObject?["status"] as! String == "Success" {
                        
                        if let arrStoreList = (responseObject?["msg"]) as? NSArray {
                            
                            //print("arrStoreList" , arrStoreList.count, arrStoreList)
                            
                            self.arrStoreData = []
                            
                            for i in 0..<arrStoreList.count {
                                self.arrStoreData?.append(arrStoreList[i] as? [String:Any] ?? [:])
                            }
                            
                            
                            if (self.arrStoreData?.count ?? 0 > 0) {
                                
                                //MARK: 1. Country
                                var countryName = ""
                                self.arrStoreCountry = []
                                
                                for i in 0..<(self.arrStoreData?.count ?? 0) {
                                    
                                    let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
                                    countryName = (obj["country"] as? String ?? "")
                                    
                                    if !(self.arrStoreCountry?.contains(countryName) ?? false) {
                                        self.arrStoreCountry?.append(countryName)
                                    }
                                    
                                }
                                
                                /*
                                //MARK: 2. Store
                                var storeName = ""
                                self.arrStoreStore = []
                                
                                for i in 0..<(self.arrStoreData?.count ?? 0) {
                                    
                                    let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
                                    storeName = (obj["project"] as? String ?? "")
                                    
                                    if !(self.arrStoreStore?.contains(storeName) ?? false) {
                                        self.arrStoreStore?.append(storeName)
                                    }
                                    
                                }*/
                                
                                
                                /*
                                //MARK: 3. City
                                var cityName = ""
                                self.arrStoreCity = []
                                
                                for i in 0..<(self.arrStoreData?.count ?? 0) {
                                    
                                    let obj = self.arrStoreData?[i] as? [String:Any] ?? [:]
                                    cityName = (obj["city"] as? String ?? "")
                                    
                                    if !(self.arrStoreCity?.contains(cityName) ?? false) {
                                        self.arrStoreCity?.append(cityName)
                                    }
                                    
                                }*/
                                
                            }
                            
                            
                            //print("Main",self.arrStoreData?.count ?? 0)
                            print("Main 1",self.arrStoreCountry?.count ?? 0, self.arrStoreCountry ?? [])
                            print("Main 2",self.arrStoreStore?.count ?? 0, self.arrStoreStore ?? [])
                            print("Main 3",self.arrStoreCity?.count ?? 0, self.arrStoreCity ?? [])
                            
                            if (self.arrStoreData?.count ?? 0 > 0) {
                                
                                self.locationBaseView.isHidden = !self.locationBaseView.isHidden
                                
                                self.currentIndexShow = 0
                                self.lblStoreLocationTitle.text = self.getLocalizatioStringValue(key: "Please select your Country")
                                
                                self.locationTableView.dataSource = self
                                self.locationTableView.delegate = self
                                self.locationTableView.reloadData()
                                
                                //self.heightOfLocationTableView.constant = CGFloat((self.arrStoreData?.count ?? 0)) * 50.0
                                self.heightOfLocationTableView.constant = CGFloat((self.arrStoreCountry?.count ?? 0)) * 50.0
                                
                            }
                            
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async() {
                            self.view.makeToast(self.getLocalizatioStringValue(key: responseObject?["msg"] as? String ?? ""), duration: 2.0, position: .bottom)
                        }
                        
                    }
                    
                }
                else
                {
                    DispatchQueue.main.async() {
                        self.view.makeToast(self.getLocalizatioStringValue(key: "oops,something went wrong"), duration: 2.0, position: .bottom)
                    }
                }
                
            })
            
        }
        else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "No connection found"), duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}


extension FindStoreVC {
    
    func onClickEmailButton() {
        
        if !MFMailComposeViewController.canSendMail() {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Oops! Mail Service not available."), duration: 2.0, position: .bottom)
            }
            
        }
        else{
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            //composeVC.setToRecipients([emailAddress])
            composeVC.setToRecipients([appDelegate_Obj.supportEmailAddress ?? ""])
            composeVC.setSubject("Message Subject")
            composeVC.setMessageBody("Message content.", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func onClickCallButton() {
        
        if let url = URL(string: "tel://\(appDelegate_Obj.supportPhoneNumber ?? "")"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Your device doesn't support this feature."), duration: 2.0, position: .bottom)
            }
            
        }
        
    }
    
}
