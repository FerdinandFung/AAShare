//
//  UIResponder+Rx.swift
//  AAShare
//
//  Created by Chen Tom on 26/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

extension UIResponder {
    public var rx_firstResponder: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) {control, shouldRespond in
            let _ = shouldRespond ? control.becomeFirstResponder() : control.resignFirstResponder()
            }.asObserver()
    }
}
