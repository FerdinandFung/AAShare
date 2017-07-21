//
//  PersonCell.swift
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

class PersonCell: BaseTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var selectImageView: UIImageView!
    
    var person: Person!
    var realm: Realm!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        selectImageView.isUserInteractionEnabled = true
        selectImageView.addGestureRecognizer(tap)
    }
    
    @objc private func imageTapped() {
        try! realm.write {
            self.person.selected = !self.person.selected
        }
        updateImageView(select: self.person.selected)
    }
    
    private func updateImageView(select: Bool) {
        let name = select ? "radio_select" : "radio_unselect"
        selectImageView.image = UIImage(named: name)
    }
    
    func updateUi( person: Person, canSelect: Bool) {
        self.person = person
        nameLabel.text = self.person.name
        selectImageView.isHidden = !canSelect
        updateImageView(select: self.person.selected)
    }
    
    func updateUi( inRealm: Realm, person: Person, canSelect: Bool) {
        self.person = person
        self.realm = inRealm
        nameLabel.text = self.person.name
        selectImageView.isHidden = !canSelect
        updateImageView(select: self.person.selected)
    }
}
