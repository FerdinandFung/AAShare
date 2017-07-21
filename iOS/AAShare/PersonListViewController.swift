//
//  PersonListViewController.swift
//  AAShare
//
//  Created by Chen Tom on 28/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import Realm
import RealmSwift
import RxSwift
import RxCocoa

protocol PersonListDelegate: class {
    func addPersonsFromList(persons: [Person])
}

class PersonListViewController: BaseRealmUIViewWithTableController {
    
    weak var delegate: PersonListDelegate?
    
    var excludePayerIds: Array<String>!
    var persons: Results<Person>!
    var showBackButton = false
    
    @IBOutlet private weak var noPersonItemsView: UIView!
    @IBOutlet private weak var addPersonItemButton: UIButton!
    
    @IBOutlet private weak var addSelectPersonItemButton: UIButton!
    @IBOutlet private weak var selectPersonItemButtonViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchInput: UITextField!
    @IBOutlet private weak var searchClearButton: UIButton!
    
    private var inputVc: CommonInputViewController?

    // MARK: - func
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: PersonListViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = "朋友"
        
        tableView.register(UINib.init(nibName: String(describing: PersonCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: PersonCell.self))
        
        
        if let _ = excludePayerIds {
        }else {
            excludePayerIds = Array<String>()
        }
        persons = realm.objects(Person.self).filter("NOT (id IN %@)", excludePayerIds)
        
        persons.asObservable(updateAction: tableViewAction)
            .subscribe({ [unowned self] event in
                self.noPersonItemsView.isHidden = (event.element?.count)! > 0
                self.rightButton?.isHidden = (event.element?.count)! == 0
                self.addSelectPersonItemButton.isEnabled = (event.element?.filter({$0.selected}).count)! > 0
                })
            .addDisposableTo(disposeBag)
        
        addPersonItemButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddPersonViewAnimation(isShow: true)
                })
            .addDisposableTo(disposeBag)
        
        addSelectPersonItemButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        addSelectPersonItemButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.newPersonsAdded()
                })
            .addDisposableTo(disposeBag)
        
        searchClearButton.setTitleColor(UIColor.tczColorButtonDisable(), for: .disabled)
        let inputValid = searchInput.rx.text.orEmpty
            .map { [unowned self] (value) -> Bool in
                self.filterPerson(name: value)
                return value.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0
            }
            .shareReplay(1)
        inputValid
            .bindTo(searchClearButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        //TODO:当有过滤时，如果不禁用添加按钮，新加联系人到persons，会crash。
        //     这个和persons过滤被重新赋值有关系，数组越界
        let inputInValid = searchInput.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 }
            .shareReplay(1)
        inputInValid
            .bindTo(rightButton!.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        searchClearButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.searchClearButtonClicked(sender: self.searchClearButton)
                })
            .addDisposableTo(disposeBag)
        
        try! realm.write {
            for p in persons {
                p.selected = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //有返回按钮，从其他VC进入
        if showBackButton {
            leftButton?.isHidden = false
            
        }else {
            //无返回按钮，从TabbarVC进入
//            persons = realm.objects(Person.self)
        }
        
        self.noPersonItemsView.isHidden = (persons.count > 0)
        self.rightButton?.isHidden = !(persons.count > 0)
    }
    
    @IBAction func addNewPerson(sender: UIButton) {
        showAddPersonViewAnimation(isShow: true)
    }
    
    @IBAction override func navRightButtonPressed(sender: UIButton) {
        addNewPerson(sender: sender)
    }
    
    @IBAction func searchClearButtonClicked(sender: UIButton) {
        searchInput.text = ""
        searchInput.resignFirstResponder()
    }
    
    private func filterPerson(name: String) {
        if name.characters.count == 0 {
            persons = realm.objects(Person.self).filter("NOT (id IN %@)", excludePayerIds)
        }else {
            let predicate = NSPredicate(format: "name CONTAINS %@ AND NOT (id IN %@)", name, excludePayerIds)
            persons = realm.objects(Person.self).filter(predicate)
        }
        tableView.reloadData()
    }
    
    func showAddPersonViewAnimation(isShow: Bool) {
        if isShow {
            if (inputVc == nil) {
                inputVc = CommonInputViewController.initWithStoryBoard() as? CommonInputViewController
                inputVc?.okBlock = { [unowned self] str in
                    try! self.realm.write {
                        let p = Person()
                        p.name = str
                        self.realm.add(p)
                    }
                }
            }
            addChildViewController(inputVc!)
            view.addSubview(inputVc!.view)
            inputVc?.view.snp.makeConstraints({ (make) in
                //make.edges.equalToSuperview()
                make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, 48, 0))
            })
            inputVc?.setTitle("请输入朋友名称", inputHoldSting: "名称长度大于2个字符")
        }else {
            inputVc?.removeFromParentViewController()
            inputVc?.view.removeFromSuperview()
        }
    }
    
    func newPersonsAdded() {
        let newPersons = Array(persons.filter( {$0.selected} ))
        delegate?.addPersonsFromList(persons: newPersons)
    }
}

extension PersonListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let p = persons {
            count = p.count
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PersonCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonCell.self), for: indexPath) as! PersonCell
        cell.updateUi( inRealm: realm, person: persons[indexPath.row], canSelect: showBackButton)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
}
