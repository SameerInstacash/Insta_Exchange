//
//  NewInstructionVC.swift
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

class NewInstructionVC: UIViewController {
    
    @IBOutlet weak var gradientBGView: UIView!
    
    @IBOutlet weak var shadowBtmView1: UIView!
    @IBOutlet weak var boostVWHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boostView: UIView!
    @IBOutlet weak var chevronBtn: UIButton!
    
    @IBOutlet weak var mapIconBaseView: UIView!
    @IBOutlet weak var mapIconView: UIView!
    @IBOutlet weak var lblMapDetail: UILabel!
    
    @IBOutlet weak var callIconBaseView: UIView!
    @IBOutlet weak var callIconView: UIView!
    @IBOutlet weak var lblContactNum: UILabel!
    
    @IBOutlet weak var shadowBtmView2: UIView!
    @IBOutlet weak var shadowBtmView3: UIView!
    
    @IBOutlet weak var deviceImgView: UIImageView!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceImei: UILabel!
    
    var resultJSON = JSON()
    var strIMEI = ""
    var strDeviceName = ""
    var strDeviceImg = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.UISetUp()
        }
        
    }
    
    func UISetUp() {
        
        self.setStatusBarColor()
        self.navigationController?.navigationBar.isHidden = true
        
        
        self.lblMapDetail.text = appDelegate_Obj.appStoreAddress
        self.lblContactNum.text = appDelegate_Obj.appStoreContactNumber
        
        self.lblDeviceName.text = self.strDeviceName
        self.lblDeviceImei.text = self.strIMEI
        
        let imgurl = URL(string: self.strDeviceImg)
        self.deviceImgView.af_setImage(withURL: imgurl ?? URL(fileURLWithPath: ""), placeholderImage: UIImage(named: "smartphone"))
        
        self.chevronBtn.transform = self.chevronBtn.transform.rotated(by: .pi)
        
        
        DispatchQueue.main.async(execute: {
            self.boostView.cornerRadius(usingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.addShadowOn4side(baseView: self.shadowBtmView1)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIView.addShadowOn4side(baseView: self.shadowBtmView2)
            UIView.addShadowOn4side(baseView: self.shadowBtmView3)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.gradientBGView.cornerRadius(usingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 50.0, height: 50.0))
        })
        
    }
    
    //MARK: IBActions
    @IBAction func chevronBoostBtnPressed(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = !sender.isSelected
            
            UIView.animate(withDuration: 0.2) {
                self.boostVWHeightConstraint.constant = 0
                self.chevronBtn.transform = self.chevronBtn.transform.rotated(by: .pi)
            } completion: { _ in
                
                DispatchQueue.main.async {
                    self.shadowBtmView1.layer.shadowPath = UIBezierPath(rect: self.shadowBtmView1.bounds).cgPath
                }
                
            }
            
        }else {
            sender.isSelected = !sender.isSelected
            
            UIView.animate(withDuration: 0.2) {
                self.boostVWHeightConstraint.constant = 180
                self.chevronBtn.transform = self.chevronBtn.transform.rotated(by: 0)
            } completion: { _ in
                
                DispatchQueue.main.async {
                    self.setupShadow(view: self.mapIconView)
                    self.setupShadow(view: self.callIconView)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.shadowBtmView1.layer.shadowPath = UIBezierPath(rect: self.shadowBtmView1.bounds).cgPath
                })
                
            }
            
        }
        
    }
    
    func setupShadow(view: UIView) {
        // Set rounded corners
        view.layer.cornerRadius = 25 // Adjust for desired roundness
        view.layer.masksToBounds = false // Important for shadow visibility
        
        // Set shadow properties
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1, height: 2)
        view.layer.shadowRadius = 2
    }
    
    @IBAction func mapBtnPressed(_ sender: UIButton) {
        
        if appDelegate_Obj.appStoreLatitude == "" {
            return
        }
        else {
            
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(appDelegate_Obj.appStoreLatitude ?? ""),\(appDelegate_Obj.appStoreLongitude ?? "")&zoom=14&views=traffic&q=\(appDelegate_Obj.appStoreLatitude ?? ""),\(appDelegate_Obj.appStoreLongitude ?? "")")!, options: [:], completionHandler: nil)
                
            } else {
                
                UIApplication.shared.open(URL(string: "http://maps.google.com/maps?q=loc:\(appDelegate_Obj.appStoreLatitude ?? ""),\(appDelegate_Obj.appStoreLongitude ?? "")&zoom=14&views=traffic&q=\(appDelegate_Obj.appStoreLatitude ?? ""),\(appDelegate_Obj.appStoreLongitude ?? "")")!, options: [:], completionHandler: nil)
                
            }
            
        }
        
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        
        if let url = URL(string: "tel://\(appDelegate_Obj.appStoreContactNumber ?? "")"), UIApplication.shared.canOpenURL(url) {
            
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
    
    @IBAction func startDiagnosticsBtnPressed(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllGifsBlynkVC") as! AllGifsBlynkVC
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}
