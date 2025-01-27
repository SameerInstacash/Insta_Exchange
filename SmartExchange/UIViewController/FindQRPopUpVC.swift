//
//  FindQRPopUpVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 16/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit

class FindQRPopUpVC: UIViewController {
    
    @IBOutlet weak var lblSubHeading: UILabel!
    
    @IBOutlet weak var lblVisit: UILabel!
    @IBOutlet weak var lblDeviceSetting: UILabel!
    @IBOutlet weak var lblDeviceBox: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.setBoldTextInString()
        
        self.lblSubHeading.font = UIFont.italicSystemFont(ofSize: 18)
                
    }
    
    func setBoldTextInString() {
        
        //"Visit your nearest Boost Mobile store with an active trade-in program."
        //"Look for the Token or QR code shared in previous communications including email, WhatsApp, or other messages."
        //"Once you have the QR code, tap Scan QR to begin your trade-in session."
        
        
        //1
        let dialboldText = "Visit a Nearby Store"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let attributedString1 = NSMutableAttributedString(string: dialboldText, attributes: attrs)
        let normalText = ": Go to your nearest store."
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString1.append(normalString)
        
        if self.lblVisit != nil {
            self.lblVisit.attributedText = attributedString1
        }
        
        //2
        let settingboldText = "Locate the QR Code"
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let settingattributedString2 = NSMutableAttributedString(string: settingboldText, attributes: attrs2)
        let normalText2 = ": Look for the QR code displayed at the store counter."
        let normalString2 = NSMutableAttributedString(string: normalText2)
        settingattributedString2.append(normalString2)
        
        if self.lblDeviceSetting != nil {
            self.lblDeviceSetting.attributedText = settingattributedString2
        }
        
        //3
        let boxBoldText = "Scan the QR Code"
        let attrsBox = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let boxAttributedString = NSMutableAttributedString(string: boxBoldText, attributes: attrsBox)
        let boxNormalText = ": Tap the Scan QR button on this screen to scan the code and start the process."
        let boxNormalString = NSMutableAttributedString(string: boxNormalText)
        boxAttributedString.append(boxNormalString)
        
        if self.lblDeviceBox != nil {
            self.lblDeviceBox.attributedText = boxAttributedString
        }
        
    }
    
    func setBoldTextInString_OLD() {
        
        //1
        let dialboldText = "Visit a Nearby Store"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let attributedString1 = NSMutableAttributedString(string: dialboldText, attributes: attrs)
        let normalText = ": Go to your nearest store."
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString1.append(normalString)
        
        if self.lblVisit != nil {
            self.lblVisit.attributedText = attributedString1
        }
        
        //2
        let settingboldText = "Locate the QR Code"
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let settingattributedString2 = NSMutableAttributedString(string: settingboldText, attributes: attrs2)
        let normalText2 = ": Look for the QR code displayed at the store counter."
        let normalString2 = NSMutableAttributedString(string: normalText2)
        settingattributedString2.append(normalString2)
        
        if self.lblDeviceSetting != nil {
            self.lblDeviceSetting.attributedText = settingattributedString2
        }
        
        //3
        let boxBoldText = "Scan the QR Code"
        let attrsBox = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let boxAttributedString = NSMutableAttributedString(string: boxBoldText, attributes: attrsBox)
        let boxNormalText = ": Tap the Scan QR button on this screen to scan the code and start the process."
        let boxNormalString = NSMutableAttributedString(string: boxNormalText)
        boxAttributedString.append(boxNormalString)
        
        if self.lblDeviceBox != nil {
            self.lblDeviceBox.attributedText = boxAttributedString
        }
        
    }
    
    //MARK: IBActions
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
