//
//  UIView+Rx.swift
//  AAShare
//
//  Created by Chen Tom on 26/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

extension UIView {
    public var rx_visible: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { view, visible in
            view.isHidden = !visible
            }.asObserver()
    }
}
