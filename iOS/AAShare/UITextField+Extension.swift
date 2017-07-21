//
//  UITextField+Extension.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            let mas = NSMutableAttributedString()
            let str = self.placeholder != nil ? self.placeholder! : ""
            if let _ = self.attributedPlaceholder {
                mas.append(self.attributedPlaceholder!)
            }
            mas.addAttribute(NSForegroundColorAttributeName, value: newValue!, range: NSMakeRange(0, str.characters.count))
            self.attributedPlaceholder = mas
        }
    }
    
    @IBInspectable var placeHolderFont: UIFont? {
        get {
            return self.placeHolderFont
        }
        set {
            let mas = NSMutableAttributedString()
            let str = self.placeholder != nil ? self.placeholder! : ""
            if let _ = self.attributedPlaceholder {
                mas.append(self.attributedPlaceholder!)
            }
            mas.addAttribute(NSFontAttributeName, value: newValue!, range: NSMakeRange(0, str.characters.count))
            self.attributedPlaceholder = mas
        }
    }
}
