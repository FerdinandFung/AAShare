//
//  TczUIViewExtension.swift
//  AAShare
//
//  Created by Chen Tom on 15/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    
    //:
    //:  UIView Animation Syntax Sugar
    //:
    //:  Created by Andyy Hope on 18/08/2016.
    //:  Twitter: @andyyhope
    //:  Medium: Andyy Hope, https://medium.com/@AndyyHope
    class Animator {
        
        typealias Completion = (Bool) -> Void
        typealias Animations = () -> Void
        
        private var animations: Animations
        private var completion: Completion?
        private let duration: TimeInterval
        private let delay: TimeInterval
        private let options: UIViewAnimationOptions
        
        init(duration: TimeInterval, delay: TimeInterval = 0, options: UIViewAnimationOptions = []) {
            self.animations = {}
            self.completion = nil
            self.duration = duration
            self.delay = delay
            self.options = options
        }
        
        func animations(_ animations: @escaping Animations) -> Self {
            self.animations = animations
            return self
        }
        
        func completion(_ completion: @escaping Completion) -> Self {
            self.completion = completion
            return self
        }
        
        func animate() {
            UIView.animate(withDuration: duration, animations: animations, completion: completion)
        }
    }
    
    final class SpringAnimator: Animator {
        
        private let damping: CGFloat
        private let velocity: CGFloat
        
        init(duration: TimeInterval, delay: TimeInterval = 0, damping: CGFloat, velocity: CGFloat, options: UIViewAnimationOptions = []) {
            
            self.damping = damping
            self.velocity = velocity
            
            super.init(duration: duration, delay: delay, options: options)
        }
    }
    
    // 
    // https://kemchenj.github.io/2016/12/08/2016-12-08/?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io
    //
    //other implemention
    class Animator2 {
        typealias Animations = () -> Void
        typealias Completion = (Bool) -> Void
        private let duration: TimeInterval
        private var animations: Animations! {
            didSet {
                UIView.animate(withDuration: duration, animations: animations) { success in
                    self.completion?(success)
                    self.success = success
                }
            }
        }
        private var completion: Completion? {
            didSet {
                guard let success = success else { return }
                completion?(success)
            }
        }
        private var success: Bool?
        init(duration: TimeInterval) {
            self.duration = duration
        }
        func animations(animations: @escaping Animations) -> Self {
            self.animations = animations
            return self
        }
        func completion(completion: @escaping Completion) -> Self {
            self.completion = completion
            return self
        }
    }
}


class TestUAClass {
    
    func viewExTest() {
        // MARK: - Example API
        let view = UIView(frame: .zero)
        
        
        // Regular Animations
        UIView.Animator(duration: 0.3)
            .animations {
                view.frame.size.height = 100
                view.frame.size.width = 100
            }
            .completion { finished in
                view.backgroundColor = .black
            }
            .animate()
        
        
        // Regular Animations with options
        UIView.Animator(duration: 0.4, delay: 0.2)
            .animations { }
            .completion { _ in }
            .animate()
        
        UIView.Animator(duration: 0.4, options: [.autoreverse, .curveEaseIn])
            .animations { }
            .completion { _ in }
            .animate()
        
        UIView.Animator(duration: 0.4, delay: 0.2, options: [.autoreverse, .curveEaseIn])
            .animations { }
            .completion { _ in }
            .animate()
        
        // Spring Animator
        UIView.SpringAnimator(duration: 0.3, delay: 0.2, damping: 0.2, velocity: 0.2, options: [.autoreverse, .curveEaseIn])
            .animations { }
            .completion { _ in }
            .animate()

    }
    
}







