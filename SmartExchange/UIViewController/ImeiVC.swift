//
//  ViewController.swift
//  Insta Exchange
//
//  Created by Sameer Khan on 04/01/25.
//

import UIKit
import Vision
import Photos
import JGProgressHUD

var detectScreenshot : (() -> Void)?
var currentIMEI = String()

class ImeiVC: UIViewController {
    
    @IBOutlet weak var gradientBGView: UIView?
    @IBOutlet weak var shadowBtmView: UIView?
    @IBOutlet weak var txtFieldIMEI: UITextField?
    @IBOutlet weak var autoDetectBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var lblDial: UILabel!
    @IBOutlet weak var lblDeviceSetting: UILabel!
    @IBOutlet weak var lblDeviceBox: UILabel!
    
    var strIMEI = ""
    //var currentIMEI = String()
    var images:[UIImage] = []
    let hud = JGProgressHUD()
    var isComeFrom = ""
    let reachability: Reachability? = Reachability()
    
    var baseDict = NPCountryModel(countryDict: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.UISetUp()
            self.getCountriesDataFromFirebase()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isComeFrom == "ImeiVC" {
            let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePopGesture(_:)))
            edgePanGestureRecognizer.edges = .left
            view.addGestureRecognizer(edgePanGestureRecognizer)
        }
        
        
        detectScreenshot = {
            // Start observing for changes
            PhotoLibraryObserver.shared.startObserving()
            ImeiVC().fetchPhotos()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func handlePopGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Custom Method
    func UISetUp() {
        
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        self.gradientBGView?.cornerRadius(usingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 50.0, height: 50.0))
        
        UIView.addShadowOn4side(baseView: self.shadowBtmView ?? UIView())
        
        self.setBoldTextInString()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    func getCountriesDataFromFirebase() {
        
        //MARK: Get country from Firebase
        if reachability?.connection.description != "No Connection" {
            
            self.hud.textLabel.text = ""
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            NPCountryModel.fetchCredentialsFromFireBase(isInterNet: true, getController: self) { (npCountry) in
                
                DispatchQueue.main.async() {
                    self.hud.dismiss()
                }
                
                self.baseDict = npCountry
                print("self.baseDict.debugUrl", self.baseDict.debugUrl)
                print("self.baseDict.releaseUrl", self.baseDict.releaseUrl)
                
                //MARK: Save Live Credentials in UserDefaults
                let userDefaults = UserDefaults.standard
                
                /*
                if let mode = userDefaults.value(forKey: "appTestMode") as? String {
                    if mode == "Release" {
                        
                        let dict = self.baseDict.releaseUrl
                        userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                        userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                        userDefaults.setValue(dict["url"], forKey: "App_BaseURL")
                        userDefaults.setValue(dict["tnc"], forKey: "App_TncUrl")
                        
                        print("Firebase DB dict is :",dict)
                        
                    }
                }else {
                    */
                    
                    #if DEBUG
                    
                        let dict = self.baseDict.debugUrl
                        userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                        userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                        userDefaults.setValue(dict["url"], forKey: "App_BaseURL")
                        userDefaults.setValue(dict["tnc"], forKey: "App_TncUrl")
                        
                        print("Firebase DB dict is :",dict)
                    
                    #else
                    
                        let dict = self.baseDict.releaseUrl
                        userDefaults.setValue(dict["apiKey"], forKey: "App_ApiKey")
                        userDefaults.setValue(dict["userName"], forKey: "App_UserName")
                        userDefaults.setValue(dict["url"], forKey: "App_BaseURL")
                        userDefaults.setValue(dict["tnc"], forKey: "App_TncUrl")
                        
                        print("Firebase DB dict is :",dict)
                    
                    #endif
                    
                //}
                                                
                
            }
        }else {
            
            DispatchQueue.main.async() {
                self.view.makeToast(self.getLocalizatioStringValue(key: "No connection found"), duration: 2.0, position: .bottom)
            }
            
        }

    }
    
    func setBoldTextInString() {
        
        //1
        let dialboldText1 = "Dial:"
        let dialboldText2 = "*#06#."
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString1 = NSMutableAttributedString(string: dialboldText1, attributes: attrs)
        let attributedString2 = NSMutableAttributedString(string: dialboldText2, attributes: attrs)
        let normalText = " Open the dialer and type "
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString1.append(normalString)
        attributedString1.append(attributedString2)
        
        if self.lblDial != nil {
            self.lblDial.attributedText = attributedString1
        }
        
        //2
        let settingboldText = "Settings:"
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let settingattributedString2 = NSMutableAttributedString(string: settingboldText, attributes: attrs2)
        let normalText2 = " Go to Settings > About Phone > IMEI."
        let normalString2 = NSMutableAttributedString(string: normalText2)
        settingattributedString2.append(normalString2)
        
        if self.lblDeviceSetting != nil {
            self.lblDeviceSetting.attributedText = settingattributedString2
        }
        
        //3
        let boxBoldText = "Device Box:"
        let attrsBox = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let boxAttributedString = NSMutableAttributedString(string: boxBoldText, attributes: attrsBox)
        let boxNormalText = " Device Box: Check the original packaging box of your device for the IMEl number."
        let boxNormalString = NSMutableAttributedString(string: boxNormalText)
        boxAttributedString.append(boxNormalString)
        
        if self.lblDeviceBox != nil {
            self.lblDeviceBox.attributedText = boxAttributedString
        }
        
    }
    
    func isIMEIValid(imeiNumber: String) -> Bool {
        var sum = 0;
        for i in (0..<15) {
            var number = Int(imeiNumber.substring(fromIndex: i, toIndex: i))
            if ((i+1)%2 == 0){
                number = (number ?? 0)*2;
                number = (number ?? 0)/10 + (number ?? 0)%10;
            }
            sum = sum+(number ?? 0)
        }
        
        if (sum%10 == 0) {
            return true
        }else{
            return false
        }
    }
    
    //MARK: IBActions
    @IBAction func autoDetectBtnPressed(_ sender: UIButton) {
        
        ShowGlobalPopUp()
        
        /*
        DispatchQueue.main.async {
            self.hud.textLabel.text = "fetching screenshot..."
            self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
            self.hud.show(in: self.view)
            
            self.fetchPhotos()
        }
        */
        
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        
        if (txtFieldIMEI?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please enter IMEI/Serial no."), duration: 2.0, position: .top)
            }
            
        }
        else if (txtFieldIMEI?.text?.count ?? 0 < 15) {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please enter valid IMEI/Serial no."), duration: 2.0, position: .top)
            }
            
        }
        else if (txtFieldIMEI?.text?.count == 15) {
            
            if self.isIMEIValid(imeiNumber: self.txtFieldIMEI?.text ?? "") {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.IMEINumber = self.txtFieldIMEI?.text ?? ""
                UserDefaults.standard.set("\(self.txtFieldIMEI?.text ?? "")", forKey: "imei_number")
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                DispatchQueue.main.async {
                    self.view.makeToast(self.getLocalizatioStringValue(key: "Invalid IMEI Number Entered."), duration: 2.0, position: .top)
                }
                
            }
            
        }
        else {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please enter valid IMEI/Serial no."), duration: 2.0, position: .top)
            }
            
        }
        
    }
    
    func fetchPhotos () {
        // Sort the images by descending creation date and fetch the first 3
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Filter for screenshots
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 1 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
        else {
            
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
        }
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                // Else you have completed creating your array
                print("Completed array: \(self.images)")
                
                self.fetchedImage(img: self.images[0])
            }
        })
    }
    
    func fetchedImage(img : UIImage) {
        
        let imeiImg = img
        
        // converting image into CGImage
        guard let cgImage = imeiImg.cgImage else {return}
        
        // creating request with cgImage
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Vision provides its text-recognition capabilities through VNRecognizeTextRequest, an image-based request type that finds and extracts text in images.
        if #available(iOS 13.0, *) {
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = (request.results ?? []) as? [VNRecognizedTextObservation],
                      error == nil else {return}
                let text = observations.compactMap({
                    $0.topCandidates(1).first?.string
                }).joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
                
                print("text we get from image" , text) // text we get from image
                
                let keyword1 = "IMEI"
                let keyword2 = "IMEI2"
                
                if let result2 = self.getNextWord(after: keyword2, in: text) {
                    //print("Next word after '\(keyword2)': \(result2)")
                    
                    currentIMEI = result2
                    
                    self.txtFieldIMEI?.text = result2.replacingOccurrences(of: ",", with: "")
                    
                    if self.txtFieldIMEI != nil {
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "IMEI has been fetched"), duration: 2.0, position: .bottom)
                        }
                    }
                    
                } else {
                    //print("'\(keyword2)' not found in the text.")
                    
                    if currentIMEI != "" {
                        self.txtFieldIMEI?.text = currentIMEI.replacingOccurrences(of: ",", with: "")
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "IMEI has been fetched"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                                        
                    
                }
                
                if let result1 = self.getNextWord(after: keyword1, in: text) {
                    //print("Next word after '\(keyword1)': \(result1)")
                    
                    currentIMEI = result1
                    //print("currentIMEI 1",currentIMEI)
                    
                    self.txtFieldIMEI?.text = result1.replacingOccurrences(of: ",", with: "")
                    
                    // Stop observing for changes
                    PhotoLibraryObserver.shared.stopObserving()
                    
                    if self.txtFieldIMEI != nil {
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "IMEI has been fetched"), duration: 2.0, position: .bottom)
                        }
                    }
                    
                } else {
                    //print("'\(keyword1)' not found in the text.")
                    //print("currentIMEI 1",currentIMEI)
                    
                    if currentIMEI != "" {
                        self.txtFieldIMEI?.text = currentIMEI.replacingOccurrences(of: ",", with: "")
                        
                        DispatchQueue.main.async {
                            self.view.makeToast(self.getLocalizatioStringValue(key: "IMEI has been fetched"), duration: 2.0, position: .bottom)
                        }
                        
                    }
                                        
                    
                }
                
            }
            
            //Just add .fast at the end
            //request.recognitionLevel = VNRequestTextRecognitionLevel.fast
            
            //Just add .fast at the end
            request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            
            do {
                try handler.perform([request])
            }
            catch (let err) {
                print("err :", err)
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                }
            }
            
        } else {
            // Fallback on earlier versions
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            
        }
        
    }
    
    func getNextWord(after text: String, in string: String) -> String? {
        if let range = string.range(of: text) {
            let substring = string[range.upperBound...] // Get the substring starting after `text`
            let words = substring.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            return words.first.map(String.init) // Get the first word as a String
        }
        return nil
    }
    
    func ShowGlobalPopUp() {
        
        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalSkipPopUpVC") as! GlobalSkipPopUpVC
        
        //popUpVC.strTitle = "To auto-detect your IMEI, please follow these steps:"
        
        popUpVC.strTitle = "Allow Insta-Exchange to Detect IMEI"
        popUpVC.strMessage = "1. Open the phone dialer and type *#06#." + "\n\n" + "2. Take a screenshot of the IMEI displayed on the screen." + "\n\n" + "3. The app will automatically detect and read the IMEI from your latest screenshot." + "\n\n\n" + "Your privacy is our priority. Screenshots are processed locally and are not shared or uploaded."
        popUpVC.strBtnYesTitle = "Cancel"
        popUpVC.strBtnNoTitle = "Ok"
        popUpVC.strBtnRetryTitle = ""
        popUpVC.isShowThirdBtn = false
        
        popUpVC.isComeFrom = "ImeiVC"
        
        popUpVC.userConsent = { btnTag in
            switch btnTag {
            case 1:
                
                print("cancel clicked")
                
            case 2:
                
                print("ok clicked")
                
                DispatchQueue.main.async {
                    self.hud.textLabel.text = "fetching screenshot..."
                    self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                    self.hud.show(in: self.view)
                    
                    self.fetchPhotos()
                }
                
            default:
                
                break
            }
        }
        
        popUpVC.modalPresentationStyle = .overFullScreen
        self.present(popUpVC, animated: false) { }
        
    }
    
}

// Register for photo library changes
class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    
    static let shared = PhotoLibraryObserver()
    
    func startObserving() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func stopObserving() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Fetch the most recent screenshot after a change
        DispatchQueue.main.async {
            //fetchMostRecentScreenshot()
            
            ImeiVC().fetchPhotos()
        }
    }
    
}
