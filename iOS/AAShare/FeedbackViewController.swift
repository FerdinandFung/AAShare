//
//  FeedbackViewController.swift
//  AAShare
//
//  Created by Chen Tom on 28/02/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa
import Alamofire

class FeedbackViewController: BaseUIViewController {
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var feedbackTextView: UITextView!
    @IBOutlet private weak var tipsLabel: UILabel!
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: FeedbackViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.isHidden = false
        titleLabel?.text = "意见反馈"
        
        let textValid = feedbackTextView.rx.text.orEmpty
            .map { $0.characters.count > 10 }
            .shareReplay(1)
        
        textValid
            .bindTo(sendButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        sendButton.backgroundColor = UIColor.tczColorMain()
        sendButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendFeedback()
                })
            .addDisposableTo(disposeBag)
        
        let tipsValid = feedbackTextView.rx.text.orEmpty
            .map { $0.characters.count > 0 }
            .shareReplay(1)
        tipsValid
            .bindTo(tipsLabel.rx.isHidden)
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func sendFeedback() {
        let dict = ["feedback": feedbackTextView.text] as [String : Any]
        let url = getServerUrl() + "/api/v1/feedback/update"
        
        Alamofire.request(url, method: .post, parameters: dict, encoding: JSONEncoding.default).responseJSON { [unowned self] response in
            guard let JSON = response.result.value as? [String: Any] else {
                self.showErrorDialog(title: "错误", message: "网络异常，请稍后重试！")
                return
            }
            print("JSON: \(JSON)")
            let code = JSON["code"] as? Int
            var title = "错误"
            if code == 0 {
                title = "成功"
            }
            self.showErrorDialog(title: title, message: JSON["msg"] as! String)
            if code == 0 {
                self.backToPreVc()
            }
        }
    }
    
    
}
