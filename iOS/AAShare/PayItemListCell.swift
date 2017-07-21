//
//  PayItemListCell.swift
//  AAShare
//
//  Created by Chen Tom on 13/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

class PayItemListCell: BaseTableViewCell {
    
    @IBOutlet private weak var detailView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var amountTitleLabel: UILabel?
    @IBOutlet private weak var amountLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var personsNameLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailView?.layer.borderWidth = 0.5
        detailView?.layer.borderColor = UIColor.tczColorMain().cgColor
        detailView?.layer.cornerRadius = 4.0
        detailView?.clipsToBounds = true
    }
    
    func updateUi(item: PayItem) {
        titleLabel?.text = item.name
        
        var payinout = "总支出："
        if (item.payInOut?.name.characters.count)! > 0 {
            payinout = "总\(item.payInOut!.name)："
        }
        amountTitleLabel?.text = payinout
        amountLabel?.text = "\(item.money)"
        
        dateLabel?.text = getFormatDate(indate: item.modifyDate)
        
        var nameArray = [String]()
        for p in item.persons {
            if p.number > 1 {
                nameArray.append(p.name + " x \(p.number)")
            }else {
                nameArray.append(p.name)
            }
            
        }
        personsNameLabel?.text = nameArray.joined(separator: "、")
    }
}
