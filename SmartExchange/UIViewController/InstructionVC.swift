//
//  InstructionVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 07/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftGifOrigin
import AlamofireImage
import SwiftyJSON

class InstructionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /*
    @IBOutlet weak var wifiView: UIView!
    @IBOutlet weak var bluetoothView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var fingerprintView: UIView!
    @IBOutlet weak var rotationView: UIView!
    
    @IBOutlet weak var wifiImgView: UIImageView!
    @IBOutlet weak var bluetoothImgView: UIImageView!
    @IBOutlet weak var locationImgView: UIImageView!
    @IBOutlet weak var fingerprintImgView: UIImageView!
    @IBOutlet weak var rotationImgView: UIImageView!
    */
    
    @IBOutlet weak var gradientBGView: UIView!
    @IBOutlet weak var shadowBtmView: UIView!
    
    @IBOutlet weak var deviceImgView: UIImageView!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceImei: UILabel!
    
    @IBOutlet weak var logoCollectionView: UICollectionView!
    
    //var arrIconImage = [#imageLiteral(resourceName: "wifi"),#imageLiteral(resourceName: "sim"),#imageLiteral(resourceName: "finger"),#imageLiteral(resourceName: "nfc"),#imageLiteral(resourceName: "rotation"),#imageLiteral(resourceName: "bluetooth")]
    
    var arrIconImage = ["wifi","sim","finger","nfc","rotation","bluetooth"]
    var arrIconName = ["Connect to Wifi/Internet","Active Sim Card","Set up Fingerprint (if applicable)","Enable NFC (if applicable)","Enable Auto-Rotate Screen","Enable bluetooth"]
    
    var strIMEI = ""
    var strDeviceName = ""
    var strDeviceImg = ""
    
    var resultJSON = JSON()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetUp()

        self.loadGifFiles()
        
        self.setStatusBarColor()
        
        performDiagnostics = nil
        //self.performTestsInSDK()
        
        
        //MARK: Assign List of Tests to be performed in App
        //arrTestsInSDK = CustomUserDefault.getArrDiagnosisTest()
        
        if arrTestsInSDK.count == 0 {
            arrTestsInSDK = ["wifi", "bluetooth", "earphone jack", "battery", "storage", "gps", "nfc", "gsm network", "vibrator", "auto rotation", "proximity", "fingerprint scanner", "dead pixels", "screen", "microusb slot", "autofocus", "camera", "torch", "device buttons", "speaker", "microphone"]
        }
        
        /*
        // 1. WiFi
        if arrTestsInSDK.contains("wifi") {
            self.wifiView.isHidden = false
        }else {
            self.wifiView.isHidden = true
        }
        
        // 2. Bluetooth
        if arrTestsInSDK.contains("bluetooth") {
            self.bluetoothView.isHidden = false
        }else {
            self.bluetoothView.isHidden = true
        }
        
        // 3. Location
        if arrTestsInSDK.contains("gps") {
            self.locationView.isHidden = false
        }else {
            self.locationView.isHidden = true
        }
        
        // 4. Fingerprint
        if arrTestsInSDK.contains("fingerprint scanner") {
            self.fingerprintView.isHidden = false
        }else {
            self.fingerprintView.isHidden = true
        }
        
        // 5. Rotation
        if arrTestsInSDK.contains("auto rotation") {
            self.rotationView.isHidden = false
        }else {
            self.rotationView.isHidden = true
        }
        */
        
    }
    
    func UISetUp() {
        
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async(execute: {
        
            self.gradientBGView.cornerRadius(usingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 50.0, height: 50.0))
            UIView.addShadowOn4side(baseView: self.shadowBtmView)
            
        })
        
        self.lblDeviceName.text = self.strDeviceName
        self.lblDeviceImei.text = self.strIMEI
        
        let imgurl = URL(string: self.strDeviceImg)
        self.deviceImgView.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "smartphone")) //set image automatically when download compelete.

        
    }
    
    func loadGifFiles() {
        /*
        self.wifiImgView.loadGif(name: "wifi_gif")
        self.bluetoothImgView.loadGif(name: "bluetooth_gif")
        self.locationImgView.loadGif(name: "location_gif")
        self.fingerprintImgView.loadGif(name: "fingerprint_gif")
        self.rotationImgView.loadGif(name: "rotation_gif")
        */
    }
    
    func changeLanguageOfUI() {
        
    }
    
    //MARK: IBActions
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        
        self.touchScreenTest(self.resultJSON)
        
        //self.TestResultScreen(self.resultJSON)
        
    }
    
    //MARK: UICollectionView DataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrIconImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let logoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "logoCell", for: indexPath)
        let img : UIImageView = logoCell.viewWithTag(10) as! UIImageView
        let lbl : UILabel = logoCell.viewWithTag(20) as! UILabel
        
        img.image = UIImage(named: self.arrIconImage[indexPath.item])
        lbl.text = self.getLocalizatioStringValue(key: self.arrIconName[indexPath.item])
        
        return logoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.model.hasPrefix("iPad") {
            
            let size = CGSize.init(width: self.logoCollectionView.bounds.width/3 - 20, height: self.logoCollectionView.bounds.width/3 - 30)
            return size
        }else {
            
            let size = CGSize.init(width: self.logoCollectionView.bounds.width/2 - 20, height: self.logoCollectionView.bounds.width/2 - 30)
            return size
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}


extension InstructionVC {
    
    func touchScreenTest(_ testResultJSON : JSON) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScreenViewController") as! ScreenViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .flipHorizontal
        vc.resultJSON = testResultJSON
        
        vc.screenTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.DeadPixelTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func DeadPixelTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeadPixelVC") as! DeadPixelVC
        vc.modalPresentationStyle = .overFullScreen
        //vc.modalTransitionStyle = .flipHorizontal
        vc.resultJSON = testResultJSON
        
        vc.deadPixelTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.AutoRotationTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    /*
    func MicrophoneTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MicrophoneVC") as! MicrophoneVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.micTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.SpeakerTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func SpeakerTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.speakerTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.VibratorTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func VibratorTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.vibratorTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.FlashlightTest(rsltJson)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func FlashlightTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TorchVC") as! TorchVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.flashLightTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.AutoRotationTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    */
    
    func AutoRotationTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.rotationTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.ProximityTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func ProximityTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.proximityTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.VolumeButtonTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func VolumeButtonTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VolumeRockerVC") as! VolumeRockerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.volumeTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.ChargerTest(rsltJson)
                
            }
            
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func EarphoneTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarphoneJackVC") as! EarphoneJackVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.earphoneTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.ChargerTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func ChargerTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceChargerVC") as! DeviceChargerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.chargerTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.CameraTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func CameraTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.cameraTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.BiometricTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func BiometricTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FingerprintViewController") as! FingerprintViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.biometricTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.WiFiTest(rsltJson)
                
            }
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func WiFiTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WiFiTestVC") as! WiFiTestVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.wifiTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.BackgroundTest(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func BackgroundTest(_ testResultJSON : JSON) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InternalTestsVC") as! InternalTestsVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.backgroundTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                self.TestResultScreen(rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func TestResultScreen(_ testResultJSON : JSON) {
        
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryVC
        vc.modalPresentationStyle = .overFullScreen
        vc.resultJSON = testResultJSON
        
        vc.testResultTestDiagnosis = { rsltJson in
            DispatchQueue.main.async() {
                
                print("rsltJson",rsltJson)
                
            }
        }
        self.present(vc, animated: true, completion: nil)
                
    }
    
    
}
