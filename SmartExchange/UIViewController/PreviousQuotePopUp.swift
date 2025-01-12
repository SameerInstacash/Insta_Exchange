//
//  PreviousQuotePopUp.swift
//  SmartExchange
//
//  Created by Sameer Khan on 10/01/25.
//  Copyright © 2025 ZeroWaste. All rights reserved.
//

import UIKit

class PreviousQuotePopUp: UIViewController {
    
    @IBOutlet weak var txtFieldRefNum: UITextField!
    @IBOutlet weak var submitBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: IBActions
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        
        if (txtFieldRefNum.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ?? false {
            
            DispatchQueue.main.async {
                self.view.makeToast(self.getLocalizatioStringValue(key: "Please enter refrence number"), duration: 2.0, position: .top)
            }
            
        }
        else {
            
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
