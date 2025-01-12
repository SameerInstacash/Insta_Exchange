//
//  DataStore.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 10/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import Foundation
import UIKit

final class DataStore {
    
    static let sharedInstance = DataStore()
    fileprivate init(){}
    
    var answers: [Question] = []
    var answerImages: [UIImage] = []
    
    
    func getAnswers (completion: @escaping() -> Void) {
        
    }
    
    
    func getImages (completion: @escaping() -> Void) {
        
    }
    
    
    
}
