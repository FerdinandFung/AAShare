//
//  ProjectPayItemListViewController.swift
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
import Alamofire

class ProjectPayItemListViewController: BaseRealmUIViewWithTableController {
    
    @IBOutlet private weak var noPayItemsView: UIView!
    @IBOutlet private weak var addPayItemButton: UIButton!
    @IBOutlet private weak var payItemsOperatorView: UIView!
    @IBOutlet private weak var payItemsOverviewView: UIView!
    @IBOutlet private weak var payItemsShareView: UIView!
    
    var payItemList: Results<PayItem>!
    
    var projectName: String!
    var projectId: String!
    
// MARK: - func
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: ProjectPayItemListViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.isHidden = false
        titleLabel?.text = projectName
        
        tableView.register(UINib.init(nibName: String(describing: PayItemListCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: PayItemListCell.self))

        payItemList = PayItem.getPayItems(projectId: projectId, inRealm: realm)
        
        payItemList.asObservable(updateAction: tableViewAction)
            .subscribe({ [unowned self] event in
                self.noPayItemsView.isHidden = (event.element?.count)! > 0
                self.rightButton?.isHidden = (event.element?.count)! == 0
            })
            .addDisposableTo(disposeBag)
        
        addPayItemButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddPayItemView(isShow: true)
            })
            .addDisposableTo(disposeBag)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(showPayItemsOverview))
        payItemsOverviewView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(sharePayItems))
        payItemsShareView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noPayItemsView.isHidden = (payItemList.count > 0)
        rightButton?.isHidden = !(payItemList.count > 0)
        
        payItemsOperatorView.backgroundColor = UIColor.tczColorRandom()
        payItemsOperatorView.snp.updateConstraints { (make) in
            let h = (payItemList.count > 0) ? 0 : 60
            make.bottom.equalToSuperview().offset(h)
        }
    }
    
    func showPayItemsOverview() {
        let vc = ProjectOverviewViewController.initWithStoryBoard() as! ProjectOverviewViewController
        vc.projectId = projectId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func sharePayItems() {
        print("share payItems to other via WeiChat")
        //分享给其他朋友
        //1.上传此账本的当前所有信息到服务器。
        //2.将服务器返回的url分享到微信。朋友通过网页查看此账本当前所有信息
        //3.如果此账本在后面有更新，需要再次上传到服务器才能让其他朋友通过网页看到最新信息
        
        let payitems = PayItem.getPayItems(projectId: projectId, inRealm: realm)
        let paypersons = PayPerson.getPayPersons(projectId: projectId, inRealm: realm)
        let dict = ["projectId": projectId, "projectName": projectName, "payItems": payitems.realmToDictionary(), "payPersons": paypersons.realmToDictionary()] as [String : Any]
        print(dict)
        
        let url = getServerUrl() + "/api/v1/payproject/update"
        Alamofire.request(url, method: .post, parameters: dict, encoding: JSONEncoding.default).responseJSON { [unowned self] response in
            guard let JSON = response.result.value as? [String: Any] else {
                self.showErrorDialog(title: "错误", message: "网络异常，请稍后重试！")
                return
            }
            print("JSON: \(JSON)")
            let code = JSON["code"] as? Int
            if code == 0 {
                self.showShareDialog(message: JSON["msg"] as! String, url: JSON["data"] as! String)
            }else {
                self.showErrorDialog(title: "错误", message: JSON["msg"] as! String)
            }
        }
    }
    
    private func showShareDialog(message: String, url: String) {
        
        let shareDialog = UIAlertController(title: "成功", message: message + url, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        let copyAction = UIAlertAction(title: "复制链接", style: .default, handler:{
            (UIAlertAction) -> Void in
            let pboard = UIPasteboard.general
            pboard.string = url;
        })
        shareDialog.addAction(cancelAction)
        shareDialog.addAction(copyAction)
        self.present(shareDialog, animated:true, completion: nil)
    }
    
    private func showAddPayItemView(isShow: Bool) {
        let vc = AddPayItemViewController.initWithStoryBoard() as! AddPayItemViewController
        vc.itemProjectId = projectId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func addNewPayItem(sender: UIButton) {
        showAddPayItemView(isShow: true)
    }
    
    @IBAction override func navRightButtonPressed(sender: UIButton) {
        addNewPayItem(sender: sender)
    }
}

extension ProjectPayItemListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payItemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PayItemListCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PayItemListCell.self), for: indexPath) as! PayItemListCell
        cell.updateUi(item: payItemList[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        
        let vc = AddPayItemViewController.initWithStoryBoard() as! AddPayItemViewController
        vc.itemProjectId = projectId
        vc.isModifyModel = true
        vc.payitemId = payItemList[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}
