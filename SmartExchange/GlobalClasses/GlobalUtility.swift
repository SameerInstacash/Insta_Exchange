//
//  GlobalUtility.swift
//  SmartExchange
//
//  Created by Sameer Khan on 13/05/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit

class GlobalUtility: NSObject {
    
    let AppFontRegular = "Poppins-Regular"
    let AppFontMedium = "Poppins-Medium"
    let AppFontBold = "Poppins-Bold"

    //var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#20409A", alpha: 1.0) //XtraCover
    //var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#6A1B9A", alpha: 1.0) //NayaPurana
    
    //var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#1E8A2F", alpha: 1.0)
    
    //var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#FFC4A7", alpha: 1.0)
    var AppThemeColor : UIColor = UIColor().HexToColor(hexString: "#FFF1EA", alpha: 1.0)
    
}

public extension UIDevice {
    
    var moName: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        //switch identifier {
        switch identifier.replacingOccurrences(of: " ", with: "") {
            
            //MARK: iPhone
        case "iPhone1,1":                               return "iPhone"
        case "iPhone1,2":                               return "iPhone 3G"
        case "iPhone2,1":                               return "iPhone 3GS"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
            
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
            
        case "iPhone8,4":                               return "iPhone SE"
            
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
            
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
            
        case "iPhone14,4":                              return "iPhone 13 Mini"
        case "iPhone14,5":                              return "iPhone 13"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
            
        case "iPhone14,6":                              return "iPhone SE 3rd Gen"
            
        case "iPhone14,7":                              return "iPhone 14"
        case "iPhone14,8":                              return "iPhone 14 Plus"
        case "iPhone15,2":                              return "iPhone 14 Pro"
        case "iPhone15,3":                              return "iPhone 14 Pro Max"
            
        case "iPhone15,4":                              return "iPhone 15"
        case "iPhone15,5":                              return "iPhone 15 Plus"
        case "iPhone16,1":                              return "iPhone 15 Pro"
        case "iPhone16,2":                              return "iPhone 15 Pro Max"
            
        case "iPhone17,1":                              return "iPhone 16 Pro"
        case "iPhone17,2":                              return "iPhone 16 Pro Max"
        case "iPhone17,3":                              return "iPhone 16"
        case "iPhone17,4":                              return "iPhone 16 Plus"
            
            //MARK: iPod
        case "iPod1,1" :                                return "1st Gen iPod"
        case "iPod2,1" :                                return "2nd Gen iPod"
        case "iPod3,1" :                                return "3rd Gen iPod"
        case "iPod4,1" :                                return "4th Gen iPod"
        case "iPod5,1" :                                return "5th Gen iPod"
        case "iPod7,1" :                                return "6th Gen iPod"
        case "iPod9,1" :                                return "7th Gen iPod"
            
            
            //MARK: iPad
        case "iPad1,1", "iPad1,2":                      return "iPad (1st generation)"
            
            //case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad (2nd generation)"
        case "iPad2,1" :                                return "2nd Gen iPad"
        case "iPad2,2" :                                return "2nd Gen iPad GSM"
        case "iPad2,3" :                                return "2nd Gen iPad CDMA"
        case "iPad2,4" :                                return "2nd Gen iPad New Revision"
            
            //case "iPad3,1", "iPad3,2", "iPad3,3":         return "iPad (3rd generation)"
        case "iPad3,1" :                                return "3rd Gen iPad"
        case "iPad3,2" :                                return "3rd Gen iPad CDMA"
        case "iPad3,3" :                                return "3rd Gen iPad GSM"
            
            //case "iPad3,4", "iPad3,5", "iPad3,6":         return "iPad (4th generation)"
        case "iPad3,4" :                                return "4th Gen iPad"
        case "iPad3,5" :                                return "4th Gen iPad GSM+LTE"
        case "iPad3,6" :                                return "4th Gen iPad CDMA+LTE"
            
            //case "iPad6,11", "iPad6,12":                  return "iPad (5th generation)"
        case "iPad6,11" :                               return "iPad (2017) (5th generation)"
        case "iPad6,12" :                               return "iPad (2017) (5th generation)"
            
            //case "iPad7,5", "iPad7,6":                    return "iPad (6th generation)"
        case "iPad7,5" :                                return "iPad 6th Gen (WiFi)"
        case "iPad7,6" :                                return "iPad 6th Gen (WiFi+Cellular)"
            
            //case "iPad7,11", "iPad7,12":                  return "iPad (7th generation)"
        case "iPad7,11" :                               return "iPad 7th Gen (10.2-inch) (WiFi)"
        case "iPad7,12" :                               return "iPad 7th Gen (10.2-inch) (WiFi+Cellular)"
            
            //case "iPad11,6", "iPad11,7":                  return "iPad (8th generation)"
        case "iPad11,6" :                               return "iPad 8th Gen (WiFi)"
        case "iPad11,7" :                               return "iPad 8th Gen (WiFi+Cellular)"
            
            //MARK: iPad Air
            //case "iPad4,1", "iPad4,2", "iPad4,3":         return "iPad Air (1st generation)"
        case "iPad4,1" :                                return "1st Gen iPad Air (WiFi)"
        case "iPad4,2" :                                return "1st Gen iPad Air (GSM+CDMA)"
        case "iPad4,3" :                                return "1st Gen iPad Air (China)"
            
            //case "iPad5,3", "iPad5,4":                    return "iPad Air (2nd generation)"
        case "iPad5,3" :                                return "iPad Air 2 (WiFi) (2nd generation)"
        case "iPad5,4" :                                return "iPad Air 2 (Cellular) (2nd generation)"
            
            //case "iPad11,3", "iPad11,4":                  return "iPad Air (3rd generation)"
        case "iPad11,3" :                               return "iPad Air 3rd Gen (WiFi)"
        case "iPad11,4" :                               return "iPad Air 3rd Gen"
            
            //MARK: iPad Mini
            //case "iPad2,5", "iPad2,6", "iPad2,7":         return "iPad mini (1st generation)"
        case "iPad2,5" :                                return  "iPad mini (1st generation)"
        case "iPad2,6" :                                return  "iPad mini GSM+LTE (1st generation)"
        case "iPad2,7" :                                return  "iPad mini CDMA+LTE (1st generation)"
            
            //case "iPad4,4", "iPad4,5", "iPad4,6":         return "iPad mini (2nd generation)"
        case "iPad4,4" :                                return "iPad mini Retina (WiFi) (2nd generation)"
        case "iPad4,5" :                                return "iPad mini Retina (GSM+CDMA) (2nd generation)"
        case "iPad4,6" :                                return "iPad mini Retina (China) (2nd generation)"
            
            //case "iPad4,7", "iPad4,8", "iPad4,9":         return "iPad mini (3rd generation)"
        case "iPad4,7" :                                return "iPad mini 3 (WiFi) (3rd generation)"
        case "iPad4,8" :                                return "iPad mini 3 (GSM+CDMA) (3rd generation)"
        case "iPad4,9" :                                return "iPad Mini 3 (China) (3rd generation)"
            
            //case "iPad5,1", "iPad5,2":                    return "iPad mini (4th generation)"
        case "iPad5,1" :                                return "iPad mini 4 (WiFi) (4th generation)"
        case "iPad5,2" :                                return "4th Gen iPad mini (WiFi+Cellular) (4th generation)"
            
            //case "iPad11,1", "iPad11,2":                  return "iPad mini (5th generation)"
        case "iPad11,1" :                               return "iPad mini 5th Gen (WiFi)"
        case "iPad11,2" :                               return "iPad mini 5th Gen"
            
            //MARK: iPad Pro
            //case "iPad6,3", "iPad6,4":                    return "iPad Pro (9.7-inch)"
        case "iPad6,3" :                                return "iPad Pro (9.7 inch, WiFi)"
        case "iPad6,4" :                                return "iPad Pro (9.7 inch, WiFi+LTE)"
            
            //case "iPad7,3", "iPad7,4":                    return "iPad Pro (10.5-inch)"
        case "iPad7,3" :                                return "iPad Pro (10.5-inch) 2nd Gen"
        case "iPad7,4" :                                return "iPad Pro (10.5-inch) 2nd Gen"
            
            //case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,1" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi)"
        case "iPad8,2" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi)"
        case "iPad8,3" :                                return "iPad Pro (11-inch) 3rd Gen (WiFi+Cellular)"
        case "iPad8,4" :                                return "iPad Pro (11-inch) 3rd Gen (1TB, WiFi+Cellular)"
            
            //case "iPad8,9", "iPad8,10":                   return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,9" :                                return "iPad Pro (11-inch) 4th Gen (WiFi)"
        case "iPad8,10" :                               return "iPad Pro (11-inch) 4th Gen (WiFi+Cellular)"
            
            //case "iPad6,7", "iPad6,8":                    return "iPad Pro (12.9-inch) (1st generation)"
        case "iPad6,7" :                                return "iPad Pro (12.9-inch), WiFi) (1st generation)"
        case "iPad6,8" :                                return "iPad Pro (12.9-inch), WiFi+LTE) (1st generation)"
            
            //case "iPad7,1", "iPad7,2":                    return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,1" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi)"
        case "iPad7,2" :                                return "iPad Pro (12.9-inch) 2nd Gen (WiFi+Cellular)"
            
            //case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,5" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi)"
        case "iPad8,6" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi)"
        case "iPad8,7" :                                return "iPad Pro (12.9-inch) 3rd Gen (WiFi+Cellular)"
        case "iPad8,8" :                                return "iPad Pro (12.9-inch) 3rd Gen (1TB, WiFi+Cellular)"
            
            //case "iPad8,11", "iPad8,12":                  return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad8,11" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi)"
        case "iPad8,12" :                               return "iPad Pro (12.9-inch) 4th Gen (WiFi+Cellular)"
            
            //MARK: New iPads add on 6/10/22
        case "iPad12,1":                                return "iPad 9th Gen (WiFi)"
        case "iPad12,2":                                return "iPad 9th Gen (WiFi+Cellular)"
            
        case "iPad14,1":                                return "iPad mini 6th Gen (WiFi)"
        case "iPad14,2":                                return "iPad mini 6th Gen (WiFi+Cellular)"
            
            //case "iPad13,1", "iPad13,2":                  return "iPad Air (4th generation)"
        case "iPad13,1":                                return "iPad Air 4th Gen (WiFi)"
        case "iPad13,2":                                return "iPad Air 4th Gen (WiFi+Cellular)"
            
        case "iPad13,4":                                return "iPad Pro (11-inch) 5th Gen"
        case "iPad13,5":                                return "iPad Pro (11-inch) 5th Gen"
            
        case "iPad13,6":                                return "iPad Pro (11-inch) 5th Gen"
        case "iPad13,7":                                return "iPad Pro (11-inch) 5th Gen"
            
        case "iPad13,8":                                return "iPad Pro (12.9-inch) 5th Gen"
        case "iPad13,9":                                return "iPad Pro (12.9-inch) 5th Gen"
            
        case "iPad13,10":                               return "iPad Pro (12.9-inch) 5th Gen"
        case "iPad13,11":                               return "iPad Pro (12.9-inch) 5th Gen"
            
        case "iPad13,16":                               return "iPad Air 5th Gen (WiFi)"
        case "iPad13,17":                               return "iPad Air 5th Gen (WiFi+Cellular)"
            
        case "iPad13,18" :                              return "iPad 10th Gen"
        case "iPad13,19" :                              return "iPad 10th Gen"
            
        case "iPad14,3" :                               return "iPad Pro (11-inch) 4th Gen"
        case "iPad14,4" :                               return "iPad Pro (11-inch) 4th Gen"
        case "iPad14,5" :                               return "iPad Pro (12.9-inch) 6th Gen"
        case "iPad14,6" :                               return "iPad Pro (12.9-inch) 6th Gen"
            
        case "i386", "x86_64", "arm64":                 return identifier
        default:                                        return identifier
            
        }
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

extension String {
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func substring(fromIndex: Int, toIndex:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: fromIndex)
        let endIndex = self.index(startIndex, offsetBy: toIndex-fromIndex)
        
        return String(self[startIndex...endIndex])
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}


extension UIViewController {
    
    func setStatusBarColor(themeColor : UIColor) {
        if #available(iOS 13.0, *) {
            
            //let app = UIApplication.shared
            //let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = themeColor
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = themeColor
            
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ******* Set Country Language ******* //
    func saveLocalizationString(_ langDict : NSDictionary) {
        self.removeCountryLanguage()
        UserDefaults.standard.set(langDict, forKey: "AppCurrentLanguage")
    }
    
    func getCountryLanguage() -> NSDictionary  {
        return UserDefaults.standard.object(forKey: "AppCurrentLanguage") as? NSDictionary ?? NSDictionary()
    }
    
    func removeCountryLanguage() {
        UserDefaults.standard.removeObject(forKey: "AppCurrentLanguage")
    }
    
    func getLocalizatioStringValue(key : String) -> String {
    
        if let dict = UserDefaults.standard.object(forKey: "AppCurrentLanguage") as? NSDictionary {
            if (dict.value(forKey: key) != nil) {
                return dict.value(forKey: key) as? String ?? ""
            }else {
                return key
            }
        }else {
            return key
        }
    }
    // *******  ******* //
    
    
}

//MARK: Sameer on 21/11/23
//extension String {
    //var localized: String {
        //return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    //}
//}

extension UIColor
{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor
    {
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt64
    {
        var hexInt: UInt64 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt64(&hexInt)
        return hexInt
    }
    
    func gradientGreenFirstColor() -> UIColor
    {
        //return UIColor().HexToColor(hexString:"34C850")
        return UIColor().HexToColor(hexString:"FFC4A7")
    }
    
    func gradientGreenSecondColor() -> UIColor
    {
        //return UIColor().HexToColor(hexString:"1E8A2F")
        return UIColor().HexToColor(hexString:"FFF1EA")
    }
    
    func gradientGreenThirdColor() -> UIColor
    {
        return UIColor().HexToColor(hexString:"179A2B")
    }
    
    func colorGreen() -> UIColor
    {
        return UIColor().HexToColor(hexString:"189B2C")
    }
    
}

@IBDesignable class CornerButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
}

@IBDesignable class cornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
}

extension String {

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
 
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func convertToDateFormate(current: String, convertTo: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = current
        guard let date = dateFormatter.date(from: self) else {
            return self
        }
        dateFormatter.dateFormat = convertTo
        return  dateFormatter.string(from: date)
    }
    
}

extension UIView
{
    func cornerRadius(usingCorners corners: UIRectCorner, cornerRadii: CGSize) {
        let path = UIBezierPath( roundedRect: self.bounds, byRoundingCorners: corners,
                                 cornerRadii: cornerRadii)
        
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = self.frame
        maskLayer.position = self.center
        maskLayer .path = path.cgPath
        self.layer.mask = maskLayer
    }
}

extension UIView {
    
    func removeShadow() {
        self.layer.shadowOffset = CGSize(width: 0 , height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0.0
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
    }
    
    //to add Shadow and Radius On desired UIView
    static func addShadow(baseView: UIView) {
        baseView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        baseView.layer.shadowOffset = CGSize.init(width: 0.0, height: 1.2)
        baseView.layer.shadowOpacity = 1.0
        baseView.layer.shadowRadius = 1.5
        baseView.layer.masksToBounds = false
    }
    
    //to add 4 side Shadow and Radius On desired UIView
    static func addShadowOn4side(baseView: UIView) {
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,y: -shadowSize / 2,width: baseView.frame.size.width + shadowSize,height: baseView.frame.size.height + shadowSize))
        baseView.layer.masksToBounds = false
        baseView.layer.shadowColor = UIColor.darkGray.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 0.5
        baseView.layer.shadowPath = shadowPath.cgPath
        
        baseView.layer.cornerRadius = 5
    }
    
    //to add 4 side Shadow and Radius On Users screen's Views
    static func addShadowOn4sideOnUserPage(baseView: UIView) {
        let shadowSize : CGFloat = 1.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,y: -shadowSize / 2,width: baseView.frame.size.width + shadowSize,height: baseView.frame.size.height + shadowSize))
        baseView.layer.masksToBounds = false
        baseView.layer.shadowColor = UIColor.gray.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 0.5
        baseView.layer.shadowPath = shadowPath.cgPath
        
        baseView.layer.cornerRadius = 1
    }
    
    static func addShadowOn4sideOnMyOrderPage(baseView: UIView) {
        let shadowSize : CGFloat = 1.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,y: -shadowSize / 2,width: baseView.frame.size.width + shadowSize,height: baseView.frame.size.height + shadowSize))
        baseView.layer.masksToBounds = false
        baseView.layer.shadowColor = UIColor.gray.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 0.5
        baseView.layer.shadowPath = shadowPath.cgPath
        
        baseView.layer.cornerRadius = 5
    }
    
    static func addShadowOnViewThemeColor(baseView: UIView) {
        baseView.layer.cornerRadius = 5.0
        baseView.layer.shadowColor = UIColor.gray.cgColor
        baseView.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 1.0
        baseView.layer.shadowRadius = 5.0
        baseView.layer.masksToBounds = false
    }
    
}

extension UIViewController {
    
    func showaAlert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertAction.Style], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    {
        let alert = UIAlertController(title: title,message: message,preferredStyle: UIAlertController.Style.alert)
        
        for title in alertButtonTitles {
            let actionObj = UIAlertAction(title: title,
                                          style: alertButtonStyles[alertButtonTitles.firstIndex(of: title)!], handler: { action in
                completion(alertButtonTitles.firstIndex(of: action.title!)!)
            })
            
            alert.addAction(actionObj)
        }
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        // alert.view.tintColor = Utility.themeColor
        //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
        vc.present(alert, animated: true, completion: nil)
    }
    
    func setStatusBarColor() {
        if #available(iOS 13.0, *) {
            
            //let app = UIApplication.shared
            //let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = themeColor
            view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = themeColor
        }
    }
    
}

@IBDesignable class GradientView: UIView {

    private var gradientLayer: CAGradientLayer!
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        self.gradientLayer = self.layer as? CAGradientLayer
        self.gradientLayer.colors = [UIColor().gradientGreenFirstColor().cgColor, UIColor().gradientGreenSecondColor().cgColor]
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            
            self.layer.cornerRadius = 5
            self.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
}
