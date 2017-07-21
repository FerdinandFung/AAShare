//
//  BaseTableViewCell.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var calender: Calendar!
    
    override func awakeFromNib() {
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
        
        calender = Calendar.current
    }
    
    func getFormatDate(indate: Date?) -> String {
        if let date = indate {
            let year = calender.component(.year, from: date)
            let month = calender.component(.month, from: date)
            let day = calender.component(.day, from: date)
            
            return "\(month)月\(day)日\(year)年"
            
        }
        return ""
    }
}
