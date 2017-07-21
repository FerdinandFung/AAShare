//
//  ProjectListViewController.swift
//  AAShare
//
//  Created by Chen Tom on 21/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import Realm
import RealmSwift
import RxSwift
import RxCocoa
import SnapKit

class ProjectListViewController: BaseRealmUIViewWithTableController {
    
    @IBOutlet private weak var noProjectsView: UIView!
    @IBOutlet private weak var addProjectButton: UIButton!
    
    private var inputVc: CommonInputViewController?
    
    var projectList: Results<PayProject>!
    var personNumberInProject = Array<Int>()

// MARK: - func
    func injected() {
        print("I've been injected: \(self)")
    }
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: ProjectListViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = "我的账本"
        
        tableView.register(UINib.init(nibName: String(describing: ProjectListCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ProjectListCell.self))
        
        projectList = realm.objects(PayProject.self)
        personNumberInProject.removeAll()
        for (_, project) in (projectList?.enumerated())! {
            let count = PayPerson.getPayPersonNumber(projectId: project.id, inRealm: self.realm)
            personNumberInProject.append(count)
        }
        
        projectList.asObservable(updateAction: tableViewAction)
            .subscribe({ [unowned self] event in
                if((event.element?.count)! > 0) {
                    self.noProjectsView.isHidden = true
                    self.rightButton?.isHidden = false
                    
                    self.personNumberInProject.removeAll()
                    for (_, project) in (event.element?.enumerated())! {
                        let count = PayPerson.getPayPersonNumber(projectId: project.id, inRealm: self.realm)
                        self.personNumberInProject.append(count)
                    }
                }else {
                    self.noProjectsView.isHidden = false
                    self.rightButton?.isHidden = true
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.noProjectsView.isHidden = (projectList.count > 0)
        self.rightButton?.isHidden = !(projectList.count > 0)
    }
    
    @IBAction func addNewProject(sender: UIButton) {
        showAddProjectViewAnimation(isShow: true)
    }
    
    @IBAction override func navRightButtonPressed(sender: UIButton) {
        addNewProject(sender: sender)
    }
    
    func showAddProjectViewAnimation(isShow: Bool) {
        if isShow {
            if (inputVc == nil) {
                inputVc = CommonInputViewController.initWithStoryBoard() as? CommonInputViewController
                inputVc?.okBlock = { [unowned self] str in
                    try! self.realm.write {
                        let project = PayProject()
                        project.name = str
                        self.realm.add(project)
                    }
                }
            }
            addChildViewController(inputVc!)
            view.addSubview(inputVc!.view)
            inputVc?.view.snp.makeConstraints({ (make) in
                //make.edges.equalToSuperview()
                make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, 48, 0))
            })
            inputVc?.setTitle("请输入账本名称", inputHoldSting: "名称长度大于2个字符")
        }else {
            inputVc?.removeFromParentViewController()
            inputVc?.view.removeFromSuperview()
        }
    }
}

extension ProjectListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ProjectListCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProjectListCell.self), for: indexPath) as! ProjectListCell
        cell.updateUi(project: projectList[indexPath.row], personNumber: personNumberInProject[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        
        let vc = ProjectPayItemListViewController.initWithStoryBoard() as! ProjectPayItemListViewController
        vc.projectName = projectList[indexPath.row].name
        vc.projectId = projectList[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}
