//
//  UIView+SnapExtension.swift
//  AAShare
//
//  Created by Chen Tom on 16/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import UIKit
import Foundation
import SnapKit

extension UIView {
    
    func addSubViewEqualWidth(subViews: [UIView]) {
        var lastObj: UIView?
        
        for view in subViews {
            self.addSubview(view)
            view.snp.makeConstraints({ (make) in
                if let _ = lastObj {
                    make.left.equalTo(lastObj!.snp.right)
                    make.centerY.equalTo(lastObj!.snp.centerY)
                    make.width.equalTo(lastObj!.snp.width)
                    make.height.equalTo(lastObj!.snp.height)
                }else {
                    make.top.equalTo(self.snp.top)
                    make.left.equalTo(self.snp.left)
                    make.bottom.equalTo(self.snp.bottom)
                }
            })
            
            lastObj = view
        }
        lastObj?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right)
        })
    }
    
    func addSubViewEqualHeight(subViews: [UIView]) {
        var lastObj: UIView?
        
        for view in subViews {
            self.addSubview(view)
            view.snp.makeConstraints({ (make) in
                if let _ = lastObj {
                    make.top.equalTo(lastObj!.snp.bottom)
                    make.centerX.equalTo(lastObj!.snp.centerX)
                    make.width.equalTo(lastObj!.snp.width)
                    make.height.equalTo(lastObj!.snp.height)
                }else {
                    make.top.equalTo(self.snp.top)
                    make.left.equalTo(self.snp.left)
                    make.right.equalTo(self.snp.right)
                }
            })
            
            lastObj = view
        }
        lastObj?.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
        })
    }
    
    func addSubView(views: [UIView], countWithH: Int) {
        var lastObj: UIView?
        var firstObj: UIView?
        
        var subViews: [UIView] = Array(views)
        if (views.count % countWithH) > 0 {
            let diff = countWithH - (views.count % countWithH)
            for _ in 0..<diff {
                let v = UIView()
                v.backgroundColor = UIColor.clear
                subViews.append(v)
            }
        }
        
        for (i, view) in subViews.enumerated() {
            self.addSubview(view)
            view.snp.makeConstraints({ (make) in
                if (i % countWithH) == 0 {
                    if let _ = firstObj {
                        make.top.equalTo(firstObj!.snp.bottom)
                        make.left.equalTo(self.snp.left)
                        make.width.equalTo(firstObj!.snp.width)
                        make.height.equalTo(firstObj!.snp.height)
                    }else {
                        if let _ = lastObj {
                            make.top.equalTo(lastObj!.snp.top)
                            make.left.equalTo(lastObj!.snp.right)
                            make.width.equalTo(lastObj!.snp.width)
                            make.height.equalTo(lastObj!.snp.height)
                        }else {
                            make.top.equalTo(self.snp.top)
                            make.left.equalTo(self.snp.left)
                        }
                        
                    }
                    firstObj = view;
                    
                }else if ((i % countWithH) == (countWithH - 1)) {
                    if let _ = lastObj {
                        make.top.equalTo(lastObj!.snp.top)
                        make.left.equalTo(lastObj!.snp.right)
                        make.width.equalTo(lastObj!.snp.width)
                        make.height.equalTo(lastObj!.snp.height)
                        make.right.equalTo(self.snp.right)
                    }
                }else {
                    if let _ = lastObj {
                        make.top.equalTo(lastObj!.snp.top)
                        make.left.equalTo(lastObj!.snp.right)
                        make.width.equalTo(lastObj!.snp.width)
                        make.height.equalTo(lastObj!.snp.height)
                    }
                }
            })
            
            lastObj = view
        }
        lastObj?.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
        })
    }
}
