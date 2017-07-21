//
//  TczUtility.swift
//  AAShare
//
//  Created by Chen Tom on 7/14/16.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation

/**
 * base on: Swift 3
 *
 * 延迟x秒后，执行block
 * tczDelay(5) { print("5 秒后在主线程执行xxx") }
 *
 * let task = tczDelay(5) { print("call 911") }
 * tczDelayCancel(task)
 *
 * from: http://swifter.tips/gcd-delay-call/
 */

typealias tczTask = (_ cancel: Bool) -> Void
typealias tczBlock = () -> ()

func tczDelay(time: TimeInterval, task: @escaping tczBlock) ->  tczTask? {
    
    func dispatch_later(block: @escaping tczBlock) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
    }
    
    var closure: tczBlock? = task
    var result: tczTask?
    
    let delayedClosure: tczTask = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure);
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    
    return result;
}

func tczDelayCancel(task: tczTask?) {
    task?(true)
}

func tczPrintPointer<T>(ptr: UnsafePointer<T>) {
    print(ptr)
}

/**
 *
 */


