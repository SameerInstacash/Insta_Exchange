//
//  AllGifsBlynkVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 08/02/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftGifOrigin
import AlamofireImage
import SwiftyJSON

class AllGifsBlynkVC: UIViewController {
    
    @IBOutlet weak var wifiImgView: UIImageView!
    @IBOutlet weak var bluetoothImgView: UIImageView!
    @IBOutlet weak var locationImgView: UIImageView!
    @IBOutlet weak var fingerprintImgView: UIImageView!
    @IBOutlet weak var rotationImgView: UIImageView!
    
    var resultJSON = JSON()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        loadGifFiles()
    }
    
    func loadGifFiles() {
        
        self.wifiImgView.loadGif(name: "wifi_gif")
        self.bluetoothImgView.loadGif(name: "bluetooth_gif")
        self.locationImgView.loadGif(name: "location_gif")
        self.fingerprintImgView.loadGif(name: "fingerprint_gif")
        self.rotationImgView.loadGif(name: "rotation_gif")
        
    }

    //MARK: IBActions
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton) {
        
        self.touchScreenTest(self.resultJSON)
        
        //self.TestResultScreen(self.resultJSON)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension AllGifsBlynkVC {
    
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
