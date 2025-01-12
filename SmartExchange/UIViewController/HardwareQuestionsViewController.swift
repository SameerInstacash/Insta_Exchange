//
//  HardwareQuestionsViewController.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 13/04/18.
//  Copyright © 2018 ZeroWaste. All rights reserved.
//

import UIKit
import EZSwipeController
import Toast_Swift
import SwiftyJSON
import MaterialCard
import Alamofire
import AlamofireImage


class HardwareQuestionsViewController: EZSwipeController {
    
    var questionsString = Data()
    var selections: [String] = []
    var currentSelection: Int = 0
    var viewControllers: [UIViewController] = []
    var allQuestionCards: [QuestionCards] = []
    var btnText: String = ""
    
    struct QuestionCards {
        var appcodeString: String
        var selectedIndices: [Int] = []
        var cards: [MaterialCard] = []
    }

    
    
    override func setupView() {
        DispatchQueue.main.async() {
            self.datasource = self
            self.navigationBarShouldNotExist = false
            self.navigationBarShouldBeOnBottom = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarColor(themeColor: GlobalUtility().AppThemeColor)
        
        view.backgroundColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped: \(btnText)")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        testTouches(touches: touches)
        print("Touch Begun")
        
        //        if let layer = self.view.layer.hitTest(point!) as? CAShapeLayer { // If you hit a layer and if its a Shapelayer
        //            if CGPathContainsPoint(layer.path, nil, point, false) { // Optional, if you are inside its content path
        //                println("Hit shapeLayer") // Do something
        //            }
        //        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!) {
        testTouches(touches: touches)
    }
    
    
    
    func testTouches(touches: Set<UITouch>) {
        // Get the first touch and its location in this view controller's view coordinate system
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self.view)
        let thisQuestion = allQuestionCards[self.currentVCIndex ]
        print("\(touchLocation)")
        for (_,card) in thisQuestion.cards.enumerated() {
            // Convert the location of the obstacle view to this view controller's view coordinate system
            let cardFrame = self.view.convert(card.frame, from: card.superview)
            
            // Check if the touch is inside the obstacle view
            if cardFrame.contains(touchLocation) {
               print("touch recorded")
                card.backgroundColor = UIColor.green
                
            }
            
        }
        
    }
    
    
}
extension HardwareQuestionsViewController: EZSwipeControllerDataSource {
    
    func disableSwipingForLeftButtonAtPageIndex(index: Int) -> Bool {
        return true
    }

    
    func disableSwipingForRightButtonAtPageIndex(index: Int) -> Bool {
       return true
    }

    func viewControllerData() -> [UIViewController] {
        var questionsJSONArray: [JSON] = []
        var questionsArray: [Question] = []
        do{
            let json = try JSON(data: questionsString)
            questionsJSONArray = json["msg"]["questions"].array!
        }catch{
            DispatchQueue.main.async() {
                self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
            }
        }
       
        
        for question in questionsJSONArray {
            let thisQuestion = Question.init(dictionary: question)
            questionsArray.append(thisQuestion!)
        }
        
        for quest in questionsArray {
            if quest.questionIsInput == "1"{
                var materialCards: [MaterialCard] = []
                var appCodeString = ""
                var select: [Int] = []
                var questCard = QuestionCards(appcodeString: appCodeString,selectedIndices: select,cards: materialCards)
                
                let vc = UIViewController()
                vc.view.backgroundColor = UIColor.black
                var startX = 10
                var startY = Int(UIApplication.shared.statusBarFrame.size.height + 10)
                for (index,ans) in quest.answers.enumerated() {
                   
                
    //                if ans.answerImage != nil{
    //                    var data: Data? = nil
    //                     let card = MaterialCard(frame: CGRect(x: startX, y: startY, width: Int((UIApplication.shared.statusBarFrame.size.width/2) - 15), height: 100))
    //                    do {
    //                         data = try Data(contentsOf: URL(string: ans.answerImage)!)
    //
    //                    } catch {
    //                        DispatchQueue.main.async() {
    //                            self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
    //                        }
    //                    }
                    
    //                    var imageView: UIImageView
    //                    if data != nil{
    //                        let image = UIImage(data: data!, scale: UIScreen.main.scale)!
    //
    //                        image.af_inflate()
    //
    //                       imageView = UIImageView(frame: CGRect(x:10, y:10, width:Int((UIApplication.shared.statusBarFrame.size.width/2) - 40), height:55))
    //                        imageView.image = image
    //                        card.addSubview(imageView)
    //                    }
    //                    let label = UILabel(frame: CGRect(x: 70, y: 10, width: card.frame.size.width, height: 20))
    //                    label.textAlignment = NSTextAlignment.center
    //                    label.textColor = UIColor.white
    //                    label.adjustsFontSizeToFitWidth = true
    //                    label.numberOfLines = 2
    //                    label.text = ans.answerText
    //                    card.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.8)
    //                    card.addSubview(label)
    //                    vc.view.addSubview(card)
    //
    //                }else{
                    
                       
//                        let card = MaterialCard(frame: CGRect(x: startX, y: startY, width: Int((UIApplication.shared.statusBarFrame.size.width/2) - 15), height: 50))
//                        let label = UILabel(frame: CGRect(x: 0, y: 10, width: card.frame.size.width, height: 30))
//                        label.textAlignment = NSTextAlignment.center
//                        label.textColor = UIColor.darkGray
//                        label.adjustsFontSizeToFitWidth = true
//                        label.numberOfLines = 3
//                        label.text = ans.answerText
//                        card.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.8)
//                        card.addSubview(label)
//                        questCard.cards.append(card)
                    let button = UIButton()
                    button.frame = CGRect(x: startX, y: startY, width: Int((UIApplication.shared.statusBarFrame.size.width/2) - 15), height: 50)
                    button.backgroundColor = UIColor.red
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                    button.setTitleColor(UIColor.green, for: .normal)
                    button.setTitle("\(ans.answerText)", for: .normal)
                    btnText = button.titleLabel!.text!
                    
                    
                    
                   
                        vc.view.addSubview(button)
                    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    button.sendActions(for: .touchUpInside)
        //                }
                        if startX == 10 {
                            startX = Int((UIApplication.shared.statusBarFrame.size.width/2)+5)
                        }else{
                            startX = 10
                            startY = startY + 60
                        }
                    
                }
                allQuestionCards.append(questCard)
                viewControllers.append(vc)
            }
        }
        
        return viewControllers
    }
    
    

  
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        var questionsJSONArray: [JSON] = []
        var questionsArray: [Question] = []
        do{
            let json = try JSON(data: questionsString)
            questionsJSONArray = json["msg"]["questions"].array!
        }catch{
            DispatchQueue.main.async() {
                self.view.makeToast("JSON Exception", duration: 2.0, position: .bottom)
            }
        }
        
        for question in questionsJSONArray {
            if question["isInput"].string! == "1"{
                let thisQuestion = Question.init(dictionary: question)
                questionsArray.append(thisQuestion!)
            }
        }
        let title = questionsArray[index].questionTitle
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.default
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            navigationItem.leftBarButtonItem = nil
        }else{
            let leftButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: "a")
            
            navigationItem.leftBarButtonItem = leftButtonItem
        }
        if index == questionsArray.count-1 {
            if questionsArray[index].questionViewType == "checkbox"{
                let rightButtonItem = UIBarButtonItem(title: "Get Price", style: UIBarButtonItemStyle.plain, target: self, action: "a")
                navigationItem.rightBarButtonItem = rightButtonItem
            }else{
                navigationItem.rightBarButtonItem = nil
            }
        } else{
            
            if questionsArray[index].questionViewType == "checkbox" {
                let rightButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: "a")
                navigationItem.rightBarButtonItem = rightButtonItem
            }else{
                navigationItem.rightBarButtonItem = nil
            }
        }
        
        
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }
}
