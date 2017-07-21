//
//  ProjectListCell.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

class ProjectListCell: BaseTableViewCell {
    
    @IBOutlet private weak var detailView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var numLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailView?.layer.borderWidth = 0.5
        detailView?.layer.borderColor = UIColor.tczColorMain().cgColor
        detailView?.layer.cornerRadius = 4.0
        detailView?.clipsToBounds = true
    }
    
    func updateUi(project: PayProject, personNumber: Int) {
        titleLabel?.text = project.name

        dateLabel?.text = getFormatDate(indate: project.modifyDate)
        
        let str = "\(personNumber)人参与"
        let mas = NSMutableAttributedString(string: str)
        mas.addAttribute(NSForegroundColorAttributeName, value: UIColor.tczColorMain(), range: NSMakeRange(0, "\(personNumber)".characters.count))
        numLabel?.attributedText = mas
    }
    
}
