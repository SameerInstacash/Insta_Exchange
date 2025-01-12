//
//  ImageInfoPopUpVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 18/11/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageInfoPopUpVC: UIViewController {
    
    @IBOutlet weak var lblSelectedAnswerInfo: UILabel!
    @IBOutlet weak var imgViewSelectedAnswerInfo: UIImageView!
    
    var strInfoImage : String?
    var strAnswerInfo : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imgStr = self.strInfoImage {
            if let imgUrl = URL(string: imgStr) {
                self.imgViewSelectedAnswerInfo.image = nil
                self.imgViewSelectedAnswerInfo.af_setImage(withURL: imgUrl, placeholderImage: UIImage(named: "info"))
            }
        }

        if let txtStr = self.strAnswerInfo {
            self.lblSelectedAnswerInfo.text = self.getLocalizatioStringValue(key: txtStr)
        }
        
    }
    
    //MARK: IBAction
    @IBAction func popUpCloseBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}


class ScaledHeightImageView: UIImageView {

   override var intrinsicContentSize: CGSize {

       if let myImage = self.image {
           let myImageWidth = myImage.size.width
           let myImageHeight = myImage.size.height
           let myViewWidth = self.frame.size.width

           let ratio = myViewWidth/myImageWidth
           let scaledHeight = myImageHeight * ratio

           return CGSize(width: myViewWidth, height: scaledHeight)
       }

       return CGSize(width: -1.0, height: -1.0)
   }

}
