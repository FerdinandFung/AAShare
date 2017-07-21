//
//  AppRootController.swift
//  AAShare
//
//  Created by Chen Tom on 13/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

class AppRootController: BaseUIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = AppTabbarController.initWithStoryBoard()
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
