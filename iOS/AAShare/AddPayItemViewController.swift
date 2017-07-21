//
//  AddPayItemViewController.swift
//  AAShare
//
//  Created by Chen Tom on 26/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import Realm
import RealmSwift
import RxSwift
import RxCocoa

class AddPayItemViewController: BaseRealmUIViewWithTableController, PersonListDelegate {
    
    @IBOutlet private weak var payItemNameInput: UITextField!
    @IBOutlet private weak var paymentAmountInput: UITextField!
    @IBOutlet private weak var addPaymentButton: UIButton!
    @IBOutlet private weak var addPersonButton: UIButton!
    
    @IBOutlet private weak var payInOutTypeView: UIView!
    @IBOutlet private weak var payTypeView: UIView!
    
    var isModifyModel: Bool = false //是否是修改模式
    var payitemId: String = "" //修改模式下，payitemid
    var oldPayPersonCount = -1  //修改模式下，以前参与者数量
    
    var itemProjectId: String = "" //活动id
    private var payInOut: PayInOut = PayInOut.OutComing
    private var paymentAmount: Float = 0.0
    fileprivate var payers: Array<PayPerson>!
    private var variablePayers: Variable<Array<PayPerson>>!
    private var payTypes: Results<PayType>!
    
    private var payTypesStr: [String]!

    private var payinoutView: SingleSelectView!
    private var payinouttypeView: SingleSelectView!
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: AddPayItemViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOtherUi()
        
        leftButton?.isHidden = false
        
        tableView.register(UINib.init(nibName: String(describing: PayItemPersonCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: PayItemPersonCell.self))
        
        let moneyValid = paymentAmountInput.rx.text.orEmpty
            .map { $0.tcz_isValidMoney() }
            .shareReplay(1)
        
        let payNameValid = payItemNameInput.rx.text.orEmpty
            .map { $0.characters.count > 0 }
            .shareReplay(1)
        
        payers = Array<PayPerson>()
        variablePayers = Variable(payers)
        let payersValid = variablePayers.asObservable()
            .map { $0.count > 0 }
            .shareReplay(1)
        
        let everythingValid = Observable.combineLatest(moneyValid, payNameValid, payersValid) { $0 && $1 && $2 }
        everythingValid
            .bindTo(addPaymentButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        moneyValid.subscribe{ print("moneyValid : \($0)") }.addDisposableTo(disposeBag)
        payNameValid.subscribe{ print("payNameValid : \($0)") }.addDisposableTo(disposeBag)
        payersValid.subscribe{ print("payersValid : \($0)") }.addDisposableTo(disposeBag)
        everythingValid.subscribe{ print("everythingValid : \($0)") }.addDisposableTo(disposeBag)
        
        addPaymentButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        addPaymentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.savePayItem()
            })
            .addDisposableTo(disposeBag)
        
        addPersonButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddNewPersonsUi()
                })
            .addDisposableTo(disposeBag)
        
        payItemNameInput.placeHolderColor = UIColor.tczColorPlaceHolder()
        
        presetPayItemData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        let persons = realm.objects(Person.self)
        try! realm.write {
            for p in persons {
                p.selected = false
            }
        }
    }
    
    private func initOtherUi() {
        
        payinoutView = SingleSelectView(titles: payinoutStrings, selectedImageName: "radio_select", unselectedImageName: "radio_unselect"){ [unowned self] (index) in
            if self.payinoutStrings[index] == PayInOut.InComing.rawValue {
                
                let idx = self.payTypesStr.count - 2;
                self.payinouttypeView.presetSelectView(index: idx)
                self.payinouttypeView.isUserInteractionEnabled = false
                
            }else if self.payinoutStrings[index] == PayInOut.Refund.rawValue {
                let idx = self.payTypesStr.count - 3;
                self.payinouttypeView.presetSelectView(index: idx)
                self.payinouttypeView.isUserInteractionEnabled = false
                
            }else {
                self.payinouttypeView.presetSelectView(index: 0)
                self.payinouttypeView.isUserInteractionEnabled = true
            }
        }
        payInOutTypeView.addSubview(payinoutView)
        payinoutView.snp.makeConstraints { (make) in
            make.edges.equalTo(payInOutTypeView)
        }
        
        //支出类型，比如 交通、餐饮
        let scrollView = UIScrollView()
        payTypeView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(payTypeView)
        }
        
        payTypes = realm.objects(PayType.self)
        payTypesStr = Array<String>()
        for type in payTypes {
            payTypesStr.append(type.name)
        }

        let width = UIScreen.main.bounds.size.width
        payinouttypeView = SingleSelectView(viewWidth: width, numberOfLine: 2, numberOfPerLine: 4, titles: payTypesStr, selectedImageName: "radio_select", unselectedImageName: "radio_unselect"){ (index) in
        }
        scrollView.addSubview(payinouttypeView)
        payinouttypeView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
    }
    
    private func presetPayItemData() {
        payinoutView.isUserInteractionEnabled = !isModifyModel
        payinouttypeView.isUserInteractionEnabled = !isModifyModel
        
        if isModifyModel {
            let predicate = NSPredicate(format: "id = %@", payitemId)
            let payitem = realm.objects(PayItem.self).filter(predicate).first
            if let item = payitem {
                
                payItemNameInput.text = item.name
                //直接赋值，不能得到rx.text改变通知
                //https://github.com/ReactiveX/RxSwift/issues/551
                payItemNameInput.sendActions(for: .valueChanged)
                paymentAmountInput.text = "\(item.money)"
                paymentAmountInput.sendActions(for: .valueChanged)
                
                if let name = item.payInOut?.name {
                    if let idx = payinoutStrings.index(of: name) {
                        payinoutView.presetSelectView(index: idx)
                    }
                }
                
                if let name = item.payItemType?.name {
                    for (index, element) in payTypes.enumerated() {
                        if name == element.name {
                            payinouttypeView.presetSelectView(index: index)
                            break
                        }
                    }
                }
                
                payers = Array(item.persons)
                oldPayPersonCount = payers.count
                tableView.reloadData()
                variablePayers.value = payers
            }
        }
    }
    
    private func savePayItem() {
        if isModifyModel {
            saveModifyPayItem()
        }else {
            addPayItem()
        }
    }
    
    private func saveModifyPayItem() {
        let predicate = NSPredicate(format: "id = %@", payitemId)
        let item = realm.objects(PayItem.self).filter(predicate).first
        paymentAmount = Float(paymentAmountInput.text!)!
        if let payItem = item {
            try! realm.write {
                payItem.name = payItemNameInput.text!
                payItem.money = paymentAmount
                
                var personCount: Int = payers.reduce(0){ $0 + $1.number }
                //如果有特殊金额，总金额需要减去特殊金额后，再由其他人平分
                var specificMoney: Float = 0.0
                for p in payers {
                    if p.specificMoney {
                        personCount = personCount - p.number
                        specificMoney = specificMoney + p.payMoney
                    }
                    p.payInOutName = (payItem.payInOut?.name)!;
                }
                let moneyPerPerson: Float = (paymentAmount - specificMoney) / Float(personCount)
                for newPayer in payers {
                    let pd = NSPredicate(format: "id = %@", newPayer.id)
                    if let payer = payItem.persons.filter(pd).first {
                        if !payer.specificMoney {
                            payer.payMoney = moneyPerPerson
                        }
                    }else {
                        if !newPayer.specificMoney {
                            newPayer.payMoney = moneyPerPerson
                        }
                        payItem.persons.append(newPayer)
                    }
                }
            }
        }
        backToPreVc()
    }
    
    private func addPayItem() {
        let predicate = NSPredicate(format: "id = %@", itemProjectId)
        let project = realm.objects(PayProject.self).filter(predicate).first
        
        paymentAmount = Float(paymentAmountInput.text!)!
        try! realm.write {
            let payItem = PayItem()
            payItem.projectId = itemProjectId
            payItem.name = payItemNameInput.text!
            payItem.money = paymentAmount
            payItem.payInOut = getPayInOutInfo(index: payinoutView.selectIndex)
            payItem.payItemType = payTypes[payinouttypeView.selectIndex]
            
            var personCount: Int = payers.reduce(0){ $0 + $1.number }
            
            //如果有特殊金额，总金额需要减去特殊金额后，再由其他人平分
            var specificMoney: Float = 0.0
            for p in payers {
                if p.specificMoney {
                    personCount = personCount - p.number
                    specificMoney = specificMoney + p.payMoney
                }
                p.payInOutName = (payItem.payInOut?.name)!;
            }
            let money: Float = (paymentAmount - specificMoney) / Float(personCount)
            let moneyPerPerson = money.roundTo(places: 2)
            
            let _ = payers.map{ (p: PayPerson) in
                if !p.specificMoney {
                    p.payMoney = moneyPerPerson
                }
                payItem.persons.append(p)
            }
            
            realm.add(payers)
            realm.add(payItem)
            
            project?.modifyDate = Date()
        }
        
        backToPreVc()
    }
    
    private func getPayInOutInfo(index: Int) -> PayInOutInfo {
        let infos = realm.objects(PayInOutInfo.self)
        for info in infos {
            if info.name == payinoutStrings[index] {
                return info
            }
        }
        return PayInOutInfo()
    }
    
    func showAddNewPersonsUi() {
        var payerIds = Array<String>()
        let _ = payers.map{ payerIds.append($0.personId) }
        
        let vc = PersonListViewController.initWithStoryBoard() as! PersonListViewController
        vc.excludePayerIds = payerIds
        vc.showBackButton = true
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
// MARK: - PersonListDelegate
    func addPersonsFromList(persons: [Person]) {
        print("addPersonsFromList: \(persons)")
        for p in persons {
            let payperson = PayPerson(person: p)
            payers.append(payperson)
        }
        
        let _ = navigationController?.popViewController(animated: true)
        
        tableView.reloadData()
        variablePayers.value = payers
    }
}

extension AddPayItemViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PayItemPersonCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PayItemPersonCell.self), for: indexPath) as! PayItemPersonCell
        cell.updateUi(person: payers[indexPath.row], inRealm: realm)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    // Edit
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row >= oldPayPersonCount //只有后面添加的才能删除
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let dele = UITableViewRowAction(style: .normal, title: "删除") { [unowned self] (action, indexPath) in
            self.payers.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        dele.backgroundColor = UIColor.red

        return [dele]
    }
    
}
