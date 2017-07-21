//
//  FirstViewController.swift
//  AAShare
//
//  Created by Chen Tom on 7/12/16.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import UIKit
import SnapKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

