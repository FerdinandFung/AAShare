//
//  PayItemPersonCell.swift
//  AAShare
//
//  Created by Chen Tom on 24/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class PayItemPersonCell: BaseTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var countView: UIView!
    @IBOutlet private weak var numLabel: UILabel!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var subtractButton: UIButton!
    
    @IBOutlet private weak var specificView: UIView!
    @IBOutlet private weak var specificTextField: UITextField!
    
    var realm: Realm!
    var payPerson: PayPerson!
    var disposeBag: DisposeBag!
    var numberVariable: Variable<String>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        plusButton.layer.borderWidth = 0.5
        plusButton.layer.borderColor = UIColor.tczColorMain().cgColor
        plusButton.clipsToBounds = true
        plusButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        
        subtractButton.layer.borderWidth = 0.5
        subtractButton.layer.borderColor = UIColor.tczColorMain().cgColor
        subtractButton.clipsToBounds = true
        subtractButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        
        numLabel.text = "0"
        
        disposeBag = DisposeBag()
        numberVariable = Variable(numLabel.text!)
        let valid = numberVariable.asObservable()
                                      .map { Int($0)! > 1 }
                                      .shareReplay(1)
        valid.bindTo(subtractButton.rx.isEnabled)
             .addDisposableTo(disposeBag)
        
        subtractButton.rx.tap
            .subscribe(onNext: { [weak self] in
                var count = Int((self?.numLabel.text!)!)!
                count = (count - 1) < 0 ? 0 : (count - 1)
                self?.numLabel.text = "\(count)"
                self?.numberVariable.value = "\(count)"
                try! self?.realm.write {
                    self?.payPerson.number = count
                }
                })
            .addDisposableTo(disposeBag)
        
        plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                var count = Int((self?.numLabel.text!)!)!
                count = count + 1
                self?.numLabel.text = "\(count)"
                self?.numberVariable.value = "\(count)"
                if let _ = self?.realm {
                    try! self?.realm.write {
                        self?.payPerson.number = count
                    }
                }
                })
            .addDisposableTo(disposeBag)
        
        let specificValid = specificTextField.rx.text.orEmpty
            .map { [weak self] (text) -> Bool in
                let valid = text.tcz_isValidMoney()
                let money = valid ? Float(text) : Float(0)
                if let _ = self?.realm {
                    try! self?.realm.write {
                        if valid {
                            self?.payPerson.payMoney = money!
                        }
                        self?.payPerson.specificMoney = valid
                    }
                }
                return !valid
            }
            .shareReplay(1)
        specificValid.bindTo(plusButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        specificValid.bindTo(subtractButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
    }
    
    func updateUi(person: PayPerson, inRealm: Realm) {
        payPerson = person
        realm = inRealm
        nameLabel.text = payPerson.name
        numLabel.text = "\(payPerson.number)"
        numberVariable.value = "\(payPerson.number)"
        if payPerson.specificMoney {
            specificTextField.text = "\(payPerson.payMoney)"
            plusButton.isEnabled = false
        }
    }
}
