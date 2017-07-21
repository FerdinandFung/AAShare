//
//  UILabel+Rx.swift
//  AAShare
//
//  Created by Chen Tom on 23/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base : UILabel {
    /**
     Reactive wrapper for `text` property.
     */
    public var textObservable: ControlProperty<String> {
        /// 序列
        let source: Observable<String> = self.observe(String.self, "text").map { $0 ?? "" }
        /// 观察者
        let setter: (UILabel, String) -> Void = { $0.text = $1 }
        let bindingObserver = UIBindingObserver(UIElement: self.base, binding: setter)
        return ControlProperty<String>(values: source, valueSink: bindingObserver)
    }
}

extension UILabel {
    /**
     Reactive wrapper for `text` property.
     */
    public var rx_text_observable: ControlProperty<String> {
        /// 序列
        let source: Observable<String> = self.rx.observe(String.self, "text").map { $0 ?? "" }
        /// 观察者
        let setter: (UILabel, String) -> Void = { $0.text = $1 }
        let bindingObserver = UIBindingObserver(UIElement: self, binding: setter)
        return ControlProperty<String>(values: source, valueSink: bindingObserver)
    }
}
