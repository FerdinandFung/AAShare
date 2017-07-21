//
//  FontManager.swift
//  AAShare
//
//  Created by Chen Tom on 30/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    class func tczPrintAllFontsName() {
        for family in UIFont.familyNames {
            print("Family name: %@", family);
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("    >Font name: %@", fontName);
            }
        }
    }
    
//    #define FONT_NAME @"Helvetica"
//    #define FONT_NAME_LIGHT @"Helvetica Light"
//    #define FONT_NAME_BOLD @"Helvetica Bold"
    
//    #define FONT_NAME @"HelveticaNeue"
//    #define FONT_NAME_LIGHT @"HelveticaNeue-Light"
//    #define FONT_NAME_BOLD @"HelveticaNeue-Medium"
    
    //// Valid after iOS9
//    #define NEW_FONT_NAME @"Avenir Oblique"
//    #define NEW_FONT_NAME_LIGHT @"Avenir Light"
//    #define NEW_FONT_NAME_BOLD @"Avenir medium"
    
    class func tczMainFont(fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "HelveticaNeue", size: fontSize)
    }
    
    class func tczMainFontMedium(fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "HelveticaNeue-Medium", size: fontSize)
    }
    
    class func tczMainFontLight(fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "HelveticaNeue-Light", size: fontSize)
    }
}
