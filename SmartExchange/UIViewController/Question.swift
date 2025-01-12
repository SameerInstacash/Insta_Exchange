//
//  Question.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 18/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import SwiftyJSON

class Question {
    var answers: [Answer] = []
    var questionTitle: String
    var questionAppViewType: String
    var questionType: String
    var questionViewType: String
    var questionIsInput: String
    
    init?(dictionary: JSON){
        if dictionary.isEmpty  {
            return nil
        }
        self.questionType = dictionary["type"].string!
        self.questionViewType = dictionary["viewType"].string!
        self.questionAppViewType = dictionary["appViewType"].string!
        self.questionIsInput = dictionary["isInput"].string!
        if self.questionType == "specification" {
             self.questionTitle = dictionary["specificationName"].string!
            let ans = dictionary["specificationValue"].array!
            for a in ans{
                let thisAnswer = Answer(dictionary: a)
                self.answers.append(thisAnswer)
            }
        }else{
            self.questionTitle = dictionary["conditionSubHead"].string!
            let ans = dictionary["conditionValue"].array!
            for a in ans{
                let thisAnswer = Answer(dictionary: a)
                self.answers.append(thisAnswer)
            }
        }
    }
    
}
