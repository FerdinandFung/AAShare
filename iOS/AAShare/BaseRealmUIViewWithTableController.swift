//
//  BaseRealmUIViewWithTableController.swift
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

class BaseRealmUIViewWithTableController: BaseUIViewWithTableController {

    var tableViewAction: updateUiAction!
    var realm: Realm!
    
    var payinoutStrings: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        tableViewAction = { [unowned self] (deletions, insertions, modifications) in
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                       with: .automatic)
            self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                       with: .automatic)
            self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                       with: .automatic)
            self.tableView.endUpdates()
        }
        
        //支付类型，比如 支出、缴费
        payinoutStrings = [PayInOut.OutComing.rawValue, PayInOut.InComing.rawValue, PayInOut.Refund.rawValue]
    }
}
