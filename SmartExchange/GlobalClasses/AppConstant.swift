//
//  AppConstant.swift
//  InstaCashApp
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON

//let themeColor = #colorLiteral(red: 0.1176470588, green: 0.5411764706, blue: 0.1843137255, alpha: 1)
let themeColor = #colorLiteral(red: 1, green: 0.9564185739, blue: 0.9339895844, alpha: 1)
//let themeColor = #colorLiteral(red: 1, green: 0.768627451, blue: 0.6549019608, alpha: 1)

var performDiagnostics: (() -> Void)?
var arrTestsInSDK = [String]()
var arrHoldTestsInSDK = [String]()
var currentTestIndex = 0

let appDelegate_Obj = UIApplication.shared.delegate as! AppDelegate

//MARK: AppApiKey
//var AppApiKey = UserDefaults.standard.string(forKey: "App_ApiKey") ?? "fd9a42ed13c8b8a27b5ead10d054caaf"
var AppApiKey = UserDefaults.standard.string(forKey: "App_ApiKey") ?? "5329551116e8e9ce5b21cb6a8b6860e4"

//MARK: AppUserName
//var AppUserName = UserDefaults.standard.string(forKey: "App_UserName") ?? "planetm"
var AppUserName = UserDefaults.standard.string(forKey: "App_UserName") ?? "IOSUSER1"

//MARK: AppBaseUrl
//var AppBaseUrl = UserDefaults.standard.string(forKey: "App_BaseURL") ?? "https://nayapurano.getinstacash.in/npexchange/api/v1/public/"
var AppBaseUrl = UserDefaults.standard.string(forKey: "App_BaseURL") ?? "https://exchange.getinstacash.com.my/us/api/v1/public/"

//MARK: AppBaseTnc
//var AppBaseTnc = UserDefaults.standard.string(forKey: "App_TncUrl") ?? "https://nayapurano.getinstacash.in/npexchange/tnc.php"
var AppBaseTnc = UserDefaults.standard.string(forKey: "App_TncUrl") ?? "https://exchange.getinstacash.com.my/usexchange/tnc.php"


//var AppUserName = "planetm"
//var AppApiKey = "fd9a42ed13c8b8a27b5ead10d054caaf"

//var AppBaseUrl = "https://xcover-uat.getinstacash.in/xtracoverexchange/api/v1/public/" // Staging-XtraCover
//var AppBaseUrl = "https://sellncash.xtracover.com/xtracoverexchange/api/v1/public/" // Live

//var AppBaseTnc = "https://xcover-uat.getinstacash.in/xtracoverexchange/tnc.php"  // Staging-XtraCover\
//var AppBaseTnc = "https://sellncash.xtracover.com/xtracoverexchange/tnc.php"  // Live


// Api Name
let kStartSessionURL = "startSession"
let kGetProductDetailURL = "getProductDetail"
let kUpdateCustomerURL = "updateCustomer"
let kGetSessionIdbyIMEIURL = "getSessionIdbyIMEI"
let kPriceCalcNewURL = "priceCalcNew"
let kSavingResultURL = "savingResult"
let kIdProofURL = "idProof"
let kgetMaxisForm = "getMaxisForm"
let ksetMaxisForm = "setMaxisForm"
let kCheckTradeinVoucher = "checkTradeinVoucher"
let kRemoveTradeinVoucher = "removeTradeinVoucher"

var AppCurrentProductBrand = ""
var AppCurrentProductName = ""
var AppCurrentProductImage = ""

var hardwareQuestionsCount = 0
var AppQuestionIndex = -1

var AppHardwareQuestionsData : CosmeticQuestions?
var arrAppHardwareQuestions: [Questions]?
var arrAppQuestionsAppCodes : [String]?
var arrAppQuestAnswr : [[String:Any]]?

// ***** App Tests Performance ***** //
var holdAppTestsPerformArray = [String]()
var AppTestsPerformArray = [String]()
var AppTestIndex : Int = 0

let AppUserDefaults = UserDefaults.standard
var AppResultJSON = JSON()
var AppResultString = ""



