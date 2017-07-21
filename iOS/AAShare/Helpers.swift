//
//  Helpers.swift
//  AAShare
//
//  Created by Chen Tom on 30/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift

final class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

func cleanRealmAndCaches() {
    
    // clean Realm
    
    guard let realm = try? Realm() else {
        return
    }
    
    let _ = try? realm.write {
        realm.deleteAll()
    }
    
    realm.refresh()
    
    print("cleaned realm!")
    
    // cleam all memory caches
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
}


func cleanDiskCacheFolder() {
    
    let folderPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    let fileMgr = FileManager.default
    
    guard let fileArray = try? fileMgr.contentsOfDirectory(atPath: folderPath) else {
        return
    }
    
    for filename in fileArray  {
        do {
            try fileMgr.removeItem(atPath: folderPath.stringByAppendingPathComponent(path: filename))
        } catch {
            print(" clean error ")
        }
        
    }
}
