//
//  BaseUIViewController.swift
//  AAShare
//
//  Created by Chen Tom on 19/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

typealias noParamBlock = () -> ()
typealias oneParamBlock = ( _ str: String ) -> ()

class BaseUIViewController: UIViewController {
    @IBOutlet weak var titleView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var leftButton: UIButton?
    @IBOutlet weak var rightButton: UIButton?
    
    @IBOutlet weak var contentView: UIView?
    
    var disposeBag: DisposeBag!
    
    static func initWithStoryBoard(storyBoardName: String, viewController: AnyClass) -> UIViewController {
        return UIStoryboard(name: storyBoardName, bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: viewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disposeBag = DisposeBag()
        
        titleView?.backgroundColor = UIColor.tczColorMain()
        titleLabel?.textColor = UIColor.white
        titleLabel?.font = UIFont.tczMainFont(fontSize: 17)
        
        leftButton?.setImage(UIImage(named: "nav_back"), for: UIControlState.normal)
        leftButton?.setImage(UIImage(named: "nav_bakc_pressed"), for: UIControlState.highlighted)
        leftButton?.isHidden = true
        
        rightButton?.setImage(UIImage(named: "nav_add"), for: UIControlState.normal)
        rightButton?.setImage(UIImage(named: "nav_add_pressed"), for: UIControlState.highlighted)
        rightButton?.isHidden = true
    }
    
    @IBAction func navLeftButtonPressed(sender: UIButton) {
        backToPreVc()
    }
    
    @IBAction func navRightButtonPressed(sender: UIButton) {
    }
    
    func backToPreVc() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func backToVc(viewController: UIViewController) {
        let _ = navigationController?.popToViewController(viewController, animated: true)
    }
    
    func backToRootVc() {
        let _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func showErrorDialog(title: String, message: String) {
        let errorDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        errorDialog.addAction(cancelAction)
        self.present(errorDialog, animated:true, completion: nil)
    }
    
    func getServerUrl() -> String {
        
        return "http://127.0.0.1:7042"
//        return "https://funpigapp.com"
    }
}
