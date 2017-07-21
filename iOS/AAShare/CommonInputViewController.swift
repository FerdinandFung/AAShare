//
//  CommonInputViewController.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

class CommonInputViewController: UIViewController {
    
    @IBOutlet private weak var dialogView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var okButton: UIButton!
    
    var disposeBag: DisposeBag!
    
    var cancelBlock: noParamBlock?
    var okBlock: oneParamBlock?
    
    // MARK: - func
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Common", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: CommonInputViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disposeBag = DisposeBag()
        
        dialogView.layer.borderWidth = 0.5
        dialogView.layer.borderColor = UIColor.tczColorBorder().cgColor
        dialogView.layer.cornerRadius = 4.0
        dialogView.clipsToBounds = true
        
        okButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        
        let inputValid = inputTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 1 }
            .shareReplay(1)
        inputValid
            .bindTo(okButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        okButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.okButtonClicked(sender: self.okButton)
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextField.becomeFirstResponder()
    }
    
    func setTitle(_ title: String, inputHoldSting: String) {
        titleLabel.text = title
        
        inputTextField.placeholder = inputHoldSting
        inputTextField.placeHolderColor = UIColor.tczColorPlaceHolder()
        inputTextField.placeHolderFont = UIFont.tczMainFontLight(fontSize: 12)

    }
    
    private func dismissSelf() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        if let cancel = cancelBlock {
            cancel()
        }
        dismissSelf()
    }
    
    @IBAction func okButtonClicked(sender: UIButton) {
        if let ok = okBlock {
            ok(inputTextField.text!)
        }
        dismissSelf()
    }
}
