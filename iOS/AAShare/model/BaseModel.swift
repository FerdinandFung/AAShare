//
//  BaseModel.swift
//  AAShare
//
//  Created by Chen Tom on 7/14/16.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import RealmSwift

import Argo
import Curry
import Runes

let MACRO_BANK_CARD_SEPARATOR = "^"

// 基类
public class BaseModel: Object {
    dynamic var createDate: Date? = Date() // optionals supported
    dynamic var modifyDate: Date? = Date()
    dynamic var id: String = UUID().uuidString
    
    dynamic var version: Float = 1.0
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

// 活动
public class PayProject: BaseModel {
      // 活动名称
    dynamic var name: String = "" {
        didSet {
            self.modifyDate = Date()
        }
    }
}

protocol DBBaseTypeProtocol {}

public class DBBaseType: Object, DBBaseTypeProtocol {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    
    dynamic var priority: Int = 0 // 权重（使用频率）
    
    dynamic var version: Float = 1.0
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        return self.id == (object as! DBBaseType).id && self.name == (object as! DBBaseType).name
    }
}

extension DBBaseType: Decodable {
    public typealias DecodedType = DBBaseType
    
    public static func decode(_ json: JSON) -> Decoded<DBBaseType> {
        let type = DBBaseType()
        type.id = (json <| "id").value!
        type.name = (json <| "name").value!
        
        return .success(type)
    }
}

// 消费类型 - 大类
public class PayType: DBBaseType {
}

//extension PayType: Decodable {
//    public typealias DecodedType = PayType
//    
//    public static func decode(_ json: JSON) -> Decoded<PayType> {
//        let type = PayType()
//        type.id = (json <| "id").value!
//        type.name = (json <| "name").value!
//        
//        return .success(type)
//    }
//}

// 消费类型 - 小类
public class PaySubType: PayType {
	dynamic var superId: Int = 0 // 所属大类Id
}

//支出 or 缴费
public class PayInOutInfo: DBBaseType {
    //dynamic var name: String = "" //支付名称 "缴费" or "支出" or "退款"
}
enum PayInOut: String {
	case InComing = "缴费"
	case OutComing = "支出"
    case Refund = "退款"
    
    func description() -> String {
        switch self {
        default:
            return self.rawValue
        }
    }
}

//银行信息
public class BankInfo: DBBaseType {
    //dynamic var name: String = "" //银行名称
}

//银行卡信息
public class BankCardInfo: BankInfo {
    dynamic var type: String = "" //银行卡类型，"储蓄卡" or "信用卡"
    dynamic var number: String = "" //银行卡后四位
}

//银行卡信息
public class BankCardType: BankInfo {
    //dynamic var name: String = "" //银行卡类型，"储蓄卡" or "信用卡"
}

public enum BankCard {
    public enum BankName: String {
        case BankOfChina = "中国银行"
    }
    public enum BankCardType: String {
        case DepositCard = "储蓄卡"
        case CreditCard = "信用卡"
    }
    case Cash // "现金"
    case WeixinPay // "微信"
    case AliPay // "支付宝"
    case Bank(name: BankName, type: BankCardType, number: String) //银行卡支付
    case Other // "其他"
    
    func description() -> String {
        switch self {
        case .Bank(let name, let type, let number):
            return name.rawValue + MACRO_BANK_CARD_SEPARATOR + type.rawValue + MACRO_BANK_CARD_SEPARATOR + number
        case .Cash:
            return "现金"
        case .WeixinPay:
            return "微信"
        case .AliPay:
            return "支付宝"
        case .Other:
            return "其他"
        }
    }
}

// 付款项
public class PayItem: BaseModel {
    public dynamic var projectId: String = "" // 所属活动的id PayProject.id

    public dynamic var payInOut: PayInOutInfo? = nil //支出 or 缴费
    public dynamic var bankCard: BankCardInfo? = nil //支付方式
    public dynamic var money: Float = 0.0 // 缴费总金额
	public dynamic var name: String = "" // 付款项名称
	public dynamic var payItemType: PayType? = nil // 消费类型
	public dynamic var payItemSubType: PaySubType? = nil

	public let persons = List<PayPerson>() //所有参与此次付款的人
    
    public class func getPayItems(projectId: String, inRealm realm: Realm) -> Results<PayItem> {
        let predicate = NSPredicate(format: "projectId = %@", projectId)
        return realm.objects(PayItem.self).filter(predicate)
    }
    
//    public class func getPayItems(projectId: String, name: String, inRealm realm: Realm) -> Results<PayItem> {
//        let predicate = NSPredicate(format: "projectId = %@ AND name = %@", projectId, name)
//        return getPayItems(projectId: projectId, inRealm: realm).filter({
//            $0.persons.filter({
//                $0.name == name
//            }) != []
//        })
//    }
    
    public class func getPayItems(personName: String, projectId: String, inRealm realm: Realm) -> Results<PayItem> {
        let predicate = NSPredicate(format: "projectId = %@ AND ANY persons.name = %@", projectId, personName)
        let realmObjects = realm.objects(PayItem.self).filter(predicate)
        return realmObjects
    }
}

// 付款人
public class PayPerson: Person {
	public dynamic var payMoney: Float = 0.0 //此人此次付款的单人金额
	public dynamic var number: Int = 1 //此人此次付款 人数。常见于以家庭为单位的付款，一个人付多人的份额
    
    //是否是特殊金额，为true时不用 number*payMoney 计算
    //常用于小孩这类需要打折的情况， number小于1
    public dynamic var specificMoney: Bool = false
    
    // 付款人id
    public dynamic var personId: String = ""
    
    // 付款人id
    public dynamic var payInOutName: String = ""
    
    // 所属付款项
    var payItem: PayItem { return payItems.first! }
    let payItems = LinkingObjects(fromType: PayItem.self, property: "persons")
    
    convenience init(person: Person) {
        self.init()
        self.personId = person.id
        self.name = person.name
        self.gender = person.gender
        self.serverId = person.serverId
    }
    
    public class func getPayPersonNames(projectId: String, inRealm realm: Realm) -> [String] {
        let predicate = NSPredicate(format: "ANY payItems.projectId = %@", projectId)
        let realmObjects = realm.objects(PayPerson.self).filter(predicate)
        var names = Set<String>()
        for person in realmObjects {
            names.insert(person.name)
        }
        return Array(names)
    }
    
    public class func getPayPerson(projectId: String, name: String, inRealm realm: Realm) -> Results<PayPerson> {
        let predicate = NSPredicate(format: "name = %@ AND ANY payItems.projectId = %@", name, projectId)
        let realmObjects = realm.objects(PayPerson.self).filter(predicate)
        return realmObjects
    }
    
    public class func getPayPersons(projectId: String, inRealm realm: Realm) -> Results<PayPerson> {
        let predicate = NSPredicate(format: "ANY payItems.projectId = %@", projectId)
        let realmObjects = realm.objects(PayPerson.self).filter(predicate)
        return realmObjects
    }
    
    // 查询某个Project下，所有付款人的数量
    public class func getPayPersonNumber(projectId: String, inRealm realm: Realm) -> Int {
        let predicate = NSPredicate(format: "ANY payItems.projectId = %@", projectId)
        let realmObjects = realm.objects(PayPerson.self).filter(predicate)
        var persons = Set<String>()
        for p in realmObjects {
            persons.insert(p.personId)
        }
        return persons.count
    }
}
func ==(lhs: PayPerson, rhs:PayPerson) -> Bool {
    return lhs.id == rhs.id
}

// 性别
public enum Gender: String {
    case Male = "男"
    case Female = "女"
    case Other = "其他"
    
    func description() -> String {
        switch self {
        default:
            return self.rawValue
        }
    }
}

// 活动参与者
public class Person: BaseModel {
    public dynamic var money: Float = 0.0 // 余额
	public dynamic var name: String = "" //活动参与者 姓名
    
    public dynamic var gender = Gender.Male.rawValue //活动参与者 性别
    public var genderEnum: Gender {
        get {
            return Gender(rawValue: gender)!
        }
        set {
            gender = newValue.rawValue
        }
    }

    //从服务器取得的唯一id，用来同步本地创建用户和网站注册用户
    //使用场景：用户添加好友后，使用这个id来对应本地创建的用户
    public dynamic var serverId: String = ""
    
    
    //适用于UI需求
    public dynamic var selected: Bool = false
}


/////// test //////
public class Dog: Object {
    public dynamic var name = ""
    public dynamic var age = 0
    let owners = LinkingObjects(fromType: DogPerson.self, property: "dogs")
}
public class DogPerson: Object {
    public dynamic var name = ""
    public dynamic var picture: NSData? = nil // optionals supported
    let dogs = List<Dog>()
}
