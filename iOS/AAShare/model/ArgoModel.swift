//
//  ArgoModel.swift
//  AAShare
//
//  Created by Chen Tom on 08/11/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct Item {
    let errcode: Int
    let errdesc: String
}

extension Item: Decodable {
    public static func decode(_ json: Argo.JSON) -> Argo.Decoded<Item> {
        return curry(Item.init)
            <^> json <| "errcode"
            <*> json <| "errdesc"
    }
}
