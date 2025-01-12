//
//  ResultView.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 05/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import PureLayout

class ResultView: UIView {
    var shouldSetupConstraints = true
    
    var testResultTypeImage: UIImageView!
    var testNameView: UILabel!
    
    let screenSize = UIScreen.main.bounds
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        testResultTypeImage = UIImageView(frame: CGRect.zero)
        testResultTypeImage.autoSetDimension(.height, toSize: 30.0)
        testResultTypeImage.autoSetDimension(.width, toSize: 30.0)
        self.addSubview(testResultTypeImage)
        testNameView = UITextView(frame: CGRect.zero)
        testNameView.text = 
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
