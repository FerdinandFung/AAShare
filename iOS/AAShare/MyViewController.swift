//
//  MyViewController.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import Realm
import RealmSwift
import RxSwift
import RxCocoa

class MyViewController: BaseUIViewController {
    
    @IBOutlet private weak var versionLabel: UILabel!
    
    @IBOutlet private weak var payWaterButton: UIButton!
    @IBOutlet private weak var payBeerButton: UIButton!
    
    @IBOutlet private weak var helpView: UIView!
    @IBOutlet private weak var feedbackView: UIView!
    
    // MARK: - func
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: MyViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.isHidden = true
        
        let currentVersionStr = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        versionLabel.text = "版本：" + currentVersionStr
        
        payWaterButton.layer.borderColor = UIColor.tczColorMain().cgColor
        payWaterButton.layer.borderWidth = 0.4
        payWaterButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.payWithStore(money: 8.0)
            })
            .addDisposableTo(disposeBag)
        
        payBeerButton.layer.borderColor = UIColor.tczColorMain().cgColor
        payBeerButton.layer.borderWidth = 0.4
        payBeerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.payWithStore(money: 28.0)
                })
            .addDisposableTo(disposeBag)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(showHelpView))
        helpView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(showFeedbackView))
        feedbackView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func payWithStore(money: Float) {
        
    }
    
    func showHelpView() {
        let vc = HelpViewController.initWithStoryBoard()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showFeedbackView() {
        let vc = FeedbackViewController.initWithStoryBoard()
        navigationController?.pushViewController(vc, animated: true)
    }
}
