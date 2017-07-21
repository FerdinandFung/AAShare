//
//  SingleSelectView.swift
//  AAShare
//
//  Created by Chen Tom on 13/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

typealias singleSelectTapBlock = ( _ index: Int ) -> ()

class SingleSelectSubView: UIView {
    var subView: UIView!
    var titilLabel: UILabel!
    var imageView: UIImageView!
    
    var selectedImageName: String!
    var unselectedImageName: String!
    
    var selectedColor: UIColor = UIColor.tczColorMain()
    var unselectedColor: UIColor = UIColor.tczColorHex(hexString: "666666")
    
    var block: singleSelectTapBlock?
    var index: Int?
    
    init(title: String, selectedImageName: String, unselectedImageName: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        subView = UIView()
        addSubview(subView)
        subView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
        
        self.selectedImageName = selectedImageName
        self.unselectedImageName = unselectedImageName
        
        imageView = UIImageView()
        if let image = UIImage(named: unselectedImageName) {
            imageView.image = image
        }
        subView.addSubview(imageView)
        
        titilLabel = UILabel()
        titilLabel.textAlignment = .center
        titilLabel.text = title
        titilLabel.font = UIFont.tczMainFontMedium(fontSize: 12)
        subView.addSubview(titilLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(subView.snp.left)
            make.right.equalTo(titilLabel.snp.left).offset(6)
            make.centerY.equalTo(subView.snp.centerY).offset(4)
//            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
        titilLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subView.snp.top)
            make.bottom.equalTo(subView.snp.bottom)
            make.right.equalTo(subView.snp.right)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchTap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImageViewSize(width: CGFloat, height: CGFloat) {
        imageView.snp.updateConstraints { (make) in
            make.size.equalTo(CGSize(width: width, height: height))
        }
    }
    
    func setViewSelected(selected: Bool) {
        
        let imageName = selected ? selectedImageName : unselectedImageName
        
        if let image = UIImage(named: imageName!) {
            imageView.image = image
        }
        
        titilLabel.textColor = selected ? selectedColor : unselectedColor
    }

    func touchTap() {
        if let _ = index {
            block?(index!)
        }
    }
}

class SingleSelectView: UIView {
    
    var singleViews: Array<SingleSelectSubView>!
    var selectIndex: Int!
    var block: singleSelectTapBlock?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(titles: [String], selectedImageName: String, unselectedImageName: String, touchBlock: @escaping singleSelectTapBlock) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        block = touchBlock
        selectIndex = 0
        singleViews = Array<SingleSelectSubView>()
        for (i, title) in titles.enumerated() {
            let view = SingleSelectSubView(title: title, selectedImageName: selectedImageName, unselectedImageName: unselectedImageName)
            singleViews.append(view)
            view.index = i
            view.block = { [unowned self] index in
                for view in self.singleViews {
                    view.setViewSelected(selected: (index == view.index))
                }
                self.selectIndex = index
                
                if let _ = self.block {
                    self.block!(index)
                }
            }
            view.setViewSelected(selected: (selectIndex == view.index))
        }
        
        addSubViewEqualWidth(subViews: singleViews)
    }
    
    init(viewWidth: CGFloat, numberOfLine: Int, numberOfPerLine: Int, titles: [String], selectedImageName: String, unselectedImageName: String, touchBlock: @escaping singleSelectTapBlock) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        var lastObj: UIView?
        
        block = touchBlock
        selectIndex = 0
        singleViews = Array<SingleSelectSubView>()
        var subViews = Array<SingleSelectSubView>()
        for (i, title) in titles.enumerated() {
            let view = SingleSelectSubView(title: title, selectedImageName: selectedImageName, unselectedImageName: unselectedImageName)
            singleViews.append(view)
            subViews.append(view)
            view.index = i
            view.block = { [unowned self] index in
                for view in self.singleViews {
                    view.setViewSelected(selected: (index == view.index))
                }
                self.selectIndex = index
                
                if let _ = self.block {
                    self.block!(index)
                }
            }
            view.setViewSelected(selected: (selectIndex == view.index))
            
            if subViews.count == (numberOfPerLine * numberOfLine) {
                let currentView = UIView()
                addSubview(currentView)
                currentView.addSubView(views: subViews, countWithH: numberOfPerLine)
                currentView.snp.makeConstraints({ (make) in
                    if let _ = lastObj {
                        make.left.equalTo(lastObj!.snp.right)
                    }else {
                        make.left.equalTo(self.snp.left)
                    }
                    make.top.equalTo(self.snp.top)
                    make.bottom.equalTo(self.snp.bottom)
                    make.width.equalTo(viewWidth)
                })
                
                lastObj = currentView
                subViews = Array<SingleSelectSubView>()
            }
        }
        
        if subViews.count > 0 {
            let currentView = UIView()
            addSubview(currentView)
            var subSubViews: [UIView] = Array(subViews)
            let total = numberOfPerLine * numberOfLine
            if (subViews.count % total) > 0 {
                let diff = total - (subViews.count % total)
                for _ in 0..<diff {
                    let v = UIView()
                    v.backgroundColor = UIColor.clear
                    subSubViews.append(v)
                }
            }
            currentView.addSubView(views: subSubViews, countWithH: numberOfPerLine)
            currentView.snp.makeConstraints({ (make) in
                if let _ = lastObj {
                    make.left.equalTo(lastObj!.snp.right)
                }else {
                    make.left.equalTo(self.snp.left)
                }
                make.top.equalTo(self.snp.top)
                make.bottom.equalTo(self.snp.bottom)
                make.width.equalTo(viewWidth)
                make.right.equalTo(self.snp.right)
            })
        }
    }
    
    func presetSelectView(index: Int) {
        selectIndex = index
        for view in singleViews {
            view.setViewSelected(selected: view.index == index)
        }
    }
}
