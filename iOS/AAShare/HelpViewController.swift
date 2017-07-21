//
//  HelpViewController.swift
//  AAShare
//
//  Created by Chen Tom on 28/02/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

class HelpViewController: BaseUIViewController {
    
    @IBOutlet private weak var myWebView: UIWebView!
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: HelpViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.isHidden = false
        titleLabel?.text = "帮助"
        
        let path = Bundle.main.path(forResource: "help", ofType: "html")
        let webContent = try! String(contentsOfFile: path!)
        myWebView.loadHTMLString(webContent, baseURL: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
