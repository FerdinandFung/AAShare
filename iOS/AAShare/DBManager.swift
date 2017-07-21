//
//  DBManager.swift
//  AAShare
//
//  Created by Chen Tom on 22/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Argo

class DBManager {
    
    enum DBError: String {
        case NoJsonFile = "数据库-没有找到Json文件"
        case NoUpdate = "数据库-没有更新"
        case Success = "数据库-成功"
        
        func description() -> String {
            switch self {
            default:
                return self.rawValue
            }
        }
    }

    lazy var payTypes: Results<PayType> = {
        let realm = try! Realm()
        return realm.objects(PayType.self)
    }()
    
    //-MARK: 单例
    static var shareInstance: DBManager{
        struct MyStatic{
            static var instance: DBManager = DBManager()
        }
        return MyStatic.instance;
    }
    
    public func initDB() -> Bool {
        let realm = try! Realm()
        var error: DBError = initDBType(inRealm: realm, dbType: PayType.self)
        print("PayType" + error.description())
        error = initDBType(inRealm: realm, dbType: PayInOutInfo.self)
        print("PayInOutInfo" + error.description())
        error = initDBType(inRealm: realm, dbType: BankInfo.self)
        print("BankInfo" + error.description())
        error = initDBType(inRealm: realm, dbType: BankCardType.self)
        print("BankCardType" + error.description())
        
        return true
    }
    
    private func getJsonFileName<T: DBBaseType>(dbType: T.Type) -> String {

        return dbType.className().lowercased()
    }
    
    private func initDBType<T: DBBaseType>(inRealm: Realm, dbType: T.Type) -> DBError {
        let allType: Results<T> = inRealm.objects(dbType)
        let firstType = allType.first
        
        if let path = Bundle.main.path(forResource: dbType.className().lowercased(), ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
            
            //如果没有数据库，则建立
            if firstType == nil, let dict = json, let values = dict["data"] {
                
                let types: Decoded<[DBBaseType]>? = decode(values)
                
                try! inRealm.write {
                    if let version = dict["version"] as? Float {
                        for type in (types?.value)! {
                            type.version = version
                            inRealm.create(dbType, value: type, update: false)
                        }
                    }
                }
                
            }else if let type = firstType, let dict = json, let version = (dict["version"] as? Float) {
                //如果有，并且版本号小于最新的版本，则更新
                if version > type.version, let values = dict["data"] {
                    let types: Decoded<[DBBaseType]>? = decode(values)
                    //TODO: 更新部分数据
                    try! inRealm.write {
                        
                        if let temp = types?.value {
                            let newSet: Set<DBBaseType> = Set<DBBaseType>(temp)
                            let oldSet: Set<T> = Set<T>(allType)
                            let subSet = newSet.subtracting(oldSet)
                            for type in subSet {
                                type.version = version
                                inRealm.create(dbType, value: type, update: true)
                            }
                        }
                        
                        for type in allType {
                            type.version = version
                        }
                    }
                }
                
            }else {
                return .NoUpdate
            }
            
            return .Success
        }
        
        return .NoJsonFile
    }
    
    /*
    private func initPayType(inRealm: Realm) -> DBError {
        let firstPayType = payTypes.first
        
        if let path = Bundle.main.path(forResource: "paytype", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
            
            //如果没有数据库，则建立
            if firstPayType == nil, let dict = json, let values = dict["paytype"] {
                
                let types: Decoded<[PayType]>? = decode(values)
                
                try! inRealm.write {
                    if let version = dict["version"] as? Float {
                        for type in (types?.value)! {
                            type.version = version
                            inRealm.create(PayType.self, value: type, update: false)
                        }
                    }
                }
                
            }else if let type = firstPayType, let dict = json, let version = (dict["version"] as? Float) {
                //如果有，并且版本号小于最新的版本，则更新
                if version > type.version, let values = dict["paytype"] {
                    let types: Decoded<[PayType]>? = decode(values)
                    //TODO: 更新部分数据
                    try! inRealm.write {
                        
                        if let temp = types?.value {
                            let newSet: Set<PayType> = Set<PayType>(temp)
                            let oldSet: Set<PayType> = Set<PayType>(payTypes)
                            let subSet = newSet.subtracting(oldSet)
                            for type in subSet {
                                type.version = version
                                inRealm.create(PayType.self, value: type, update: true)
                            }
                        }
                        
                        for type in payTypes {
                            type.version = version
                        }
                    }
                }
                
            }else {
                return .NoUpdate
            }
            
            return .Success
        }
        
        return .NoJsonFile
    }
    */
}
