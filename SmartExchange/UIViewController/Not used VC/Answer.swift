//
//  Question.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 10/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Answer {
    var answerText: String
    var answerImage: String
    var appCode: String
    
    init(dictionary: JSON){
        self.answerText = dictionary["value"].string!
        self.answerImage = dictionary["image"].string!
        self.appCode = dictionary["appCode"].string!
    }
}
