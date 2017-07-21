//
//  Realm+Extension.swift
//  AAShare
//
//  Created by Chen Tom on 28/12/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import RealmSwift

extension Object {
    //Convert to Dictionary from Realm object
    func realmToDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // convert Date to String, because JSON parse will crash if type is 'Date'
            if let nestedObject = self[prop.name] as? Date {
                mutabledic.setValue(nestedObject.description, forKey: prop.name)
            }
            // find lists
            else if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.realmToDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.realmToDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}

extension Results {
    func realmToDictionary() -> Array<NSDictionary> {
        var array = Array<NSDictionary>()
        for obj in self {
            array.append(obj.realmToDictionary())
        }
        return array
    }
}
