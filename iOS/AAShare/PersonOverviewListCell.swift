//
//  PersonOverviewListCell.swift
//  AAShare
//
//  Created by Chen Tom on 06/02/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

class PersonOverviewListCell: BaseTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var inMoneyLabel: UILabel!
    @IBOutlet private weak var outMoneyLabel: UILabel!
    @IBOutlet private weak var refundMoneyLabel: UILabel!
    
    func updateUi(person: ProjectOverviewPerson) {
        nameLabel.text = person.name
        
        var money = person.inMoney.roundTo(places: 2)
        var str = "共缴费：\(money)元"
        var mas = NSMutableAttributedString(string: str)
        mas.addAttribute(NSForegroundColorAttributeName, value: UIColor.tczColorMain(), range: NSMakeRange(4, "\(money)".characters.count))
        inMoneyLabel?.attributedText = mas
        
        money = person.outMoney.roundTo(places: 2)
        str = "共支出：\(money)元"
        mas = NSMutableAttributedString(string: str)
        mas.addAttribute(NSForegroundColorAttributeName, value: UIColor.tczColorHex(hexString: "fc665e"), range: NSMakeRange(4, "\(money)".characters.count))
        outMoneyLabel?.attributedText = mas
        
        let offsetMoney = person.inMoney - person.outMoney
        var refundStr = "需退款："
        var color = UIColor.tczColorMain()
        if offsetMoney < 0 {
            refundStr = "需补款："
            color = UIColor.tczColorHex(hexString: "fc665e")
        }
        money = offsetMoney.roundTo(places: 2)
        str = "\(refundStr)\(abs(money))元"
        mas = NSMutableAttributedString(string: str)
        mas.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(4, "\(abs(money))".characters.count))
        refundMoneyLabel?.attributedText = mas
    }
}
