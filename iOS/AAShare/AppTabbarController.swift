//
//  AppTabbarController.swift
//  AAShare
//
//  Created by Chen Tom on 09/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

class AppTabbarController: BaseTabbarController {
    
    // MARK: - func
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: AppTabbarController.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.tintColor = UIColor.tczColorMain()
        for tabBarItem in tabBar.items! {
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
            tabBarItem.setTitleTextAttributes([NSFontAttributeName : UIFont.tczMainFont(fontSize: 10.0)!], for: .normal)
        }
        
        dirPath()
        initDB()
    }
    
    private func initDB() {
        let _ = DBManager.shareInstance.initDB()
    }
    
    func dirPath() {
        let homeDirectory = NSHomeDirectory()
        print(homeDirectory)
        
        //方法1
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0]
        print(documnetPath)
        
        //方法2
        let ducumentPath2 = NSHomeDirectory() + "/Documents"
        print(ducumentPath2)
        
        //Library目录－方法1
        let libraryPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory,
                                                               FileManager.SearchPathDomainMask.userDomainMask, true)
        let libraryPath = libraryPaths[0]
        print(libraryPath)
        
        //Library目录－方法2
        let libraryPath2 = NSHomeDirectory() + "/Library"
        print(libraryPath2)
        
        //Cache目录－方法1
        let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                             FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = cachePaths[0]
        print(cachePath)
        
        //Cache目录－方法2
        let cachePath2 = NSHomeDirectory() + "/Library/Caches"
        print(cachePath2)
    }
}
