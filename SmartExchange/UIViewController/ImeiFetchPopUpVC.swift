//
//  ImeiFetchPopUpVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 01/02/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit

class ImeiFetchPopUpVC: UIViewController {
    
    @IBOutlet weak var bottomVWHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowImgVW: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: IBActions
    @IBAction func doItManualBtnPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1) {
            if sender.isSelected {
                sender.isSelected = !sender.isSelected
                
                self.bottomVWHeightConstraint.constant = 0
                
                self.arrowImgVW.transform = self.arrowImgVW.transform.rotated(by: 0)
            }else {
                sender.isSelected = !sender.isSelected
                
                self.bottomVWHeightConstraint.constant = 125
                
                self.arrowImgVW.transform = self.arrowImgVW.transform.rotated(by: .pi)
            }
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: false) {
            
        }
    }
    
    @IBAction func okBtnPressed(_ sender: UIButton) {
        if let allow = fetchIMEI {
            allow()
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
