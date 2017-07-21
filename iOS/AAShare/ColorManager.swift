//
//  ColorManager.swift
//  AAShare
//
//  Created by Chen Tom on 30/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import UIKit

extension UIColor {
    
    class func tczColorMain() -> UIColor {
        return tczColorHex(hexString: "0AC775") //   #colorLiteral(red: 0.03921568627, green: 0.7803921569, blue: 0.4588235294, alpha: 1)
    }
    
    class func tczColorButtonDisable() -> UIColor {
        return tczColorHex(hexString: "ededed") //   #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
    }
    
    class func tczColorBorder() -> UIColor {
        return tczColorHex(hexString: "ededed") //   #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
    }
    
    class func tczColorPlaceHolder() -> UIColor {
        return tczColorHex(hexString: "ededed") //   #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)
    }
    
    class func tczColorHex(hexString: String, alpha: Float) -> UIColor {
        var colorString = hexString.replacingOccurrences(of: " ", with: "").uppercased()
        if hexString.hasPrefix("#") {
            colorString = colorString.substring(from: hexString.index(hexString.startIndex, offsetBy: 1))
        }
        if hexString.hasPrefix("0X") {
            colorString = colorString.substring(from: hexString.index(hexString.startIndex, offsetBy: 2))
        }
        if hexString.characters.count != 6 {
            return UIColor.clear
        }
        
        // Separate into r, g, b substrings
        //r
        let rString: String = "0x" + hexString.substring(with: hexString.startIndex ..< hexString.index(hexString.startIndex, offsetBy: 2));
        //g
        let gString: String = "0x" + hexString.substring(with: hexString.index(hexString.startIndex, offsetBy: 2) ..< hexString.index(hexString.startIndex, offsetBy: 4));
        //b
        let bString: String = "0x" + hexString.substring(with: hexString.index(hexString.startIndex, offsetBy: 4) ..< hexString.endIndex);
        
        // Scan values
        var r: Float = 0.0
        var g: Float = 0.0
        var b: Float = 0.0
        Scanner(string: rString).scanHexFloat(&r)
        Scanner(string: gString).scanHexFloat(&g)
        Scanner(string: bString).scanHexFloat(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alpha))
    }
    
    class func tczColorHex(hexString: String) -> UIColor {
        return tczColorHex(hexString: hexString, alpha: 1.0)
    }
    
    class func tczColorRandom() -> UIColor {
        return tczColorRandom(alpha: 1.0)
    }
    
    class func tczColorRandom(alpha: Float) -> UIColor {
        let r = Double(arc4random_uniform(256))
        let g = Double(arc4random_uniform(256))
        let b = Double(arc4random_uniform(256))
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alpha))
    }
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
            
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
