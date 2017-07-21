//
//  SecondViewController.swift
//  AAShare
//
//  Created by Chen Tom on 7/12/16.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import UIKit
import Moya
import SwiftyBeaver
import Realm
import RealmSwift
import RxSwift

class SecondViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let logger = SwiftyBeaver.self

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        print("start a delay task...")
//        let task = tczDelay(time: 5) {
//            print("call 911 after 5 seconds")
//        }
//        tczDelayCancel(task: task)
        
//        RruuApi.apiGetTargetSelect(cityId: "1") { (_: Item) in
//            self.logger.debug("successful!")
//        }
        
        dirPath()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func addSomeDataIntoRealm() {
        
        guard let realm = try? Realm() else {
            print("")
            return
        }
        
        for i in 1...3 {
            let payPerson = PayPerson()
            payPerson.name = "Tom \(i)"
            
            realm.add(payPerson)
        }
        
        let _ = try? realm.write {
            for i in 4...6 {
                let payPerson = PayPerson()
                payPerson.name = "Tom \(i)"
                
                realm.add(payPerson)
            }
        }
        
        //realm.beginWrite()
        for i in 7...9 {
            let payPerson = PayPerson()
            payPerson.name = "Tom \(i)"
            
            realm.add(payPerson)
        }
        //let _ = try? realm.commitWrite()
        
        
        
        let payPerson10 = PayPerson()
        payPerson10.name = "Tom 10"
        let payPerson11 = PayPerson()
        payPerson11.name = "Tom 11"
        
        let payItem1 = PayItem()
        payItem1.projectId = "projectId 1"
        payItem1.name = "payItem 1"
        payItem1.money = 9.99
        payItem1.persons.append(payPerson10)
        payItem1.persons.append(payPerson11)
        
        let _ = try! realm.write {
            realm.add(payPerson10)
            realm.add(payPerson11)
            realm.add(payItem1)
        }
    }
    
    func getPayItems(payPersonName: String) {
        guard let realm = try? Realm() else {
            print("")
            return
        }
        
        let payItems = PayItem.getPayItems(personName: payPersonName, projectId: "projectId 1", inRealm: realm)
        print(payItems)
        print(payItems.first?.persons)
    }
    
    func getPayPerson(payPersonName: String) {
        guard let realm = try? Realm() else {
            print("")
            return
        }
        
        let payPersons = PayPerson.getPayPerson(projectId: "projectId 1", name: payPersonName, inRealm: realm)
        print(payPersons)
        print(payPersons.first?.payItems)
    }
    
    func addPayItem() {
        guard let realm = try? Realm() else {
            print("")
            return
        }
        
        let payPersons = PayPerson.getPayPerson(projectId: "projectId 1", name: "Tom 10", inRealm: realm)
        if let tom10 = payPersons.first {
            let payItem1 = PayItem()
            payItem1.projectId = "projectId 1"
            payItem1.name = "payItem 2"
            payItem1.money = 9.99
            payItem1.persons.append(tom10)
            
            let _ = try! realm.write {
                realm.add(payItem1)
            }
        }
    }
    
    func testRealm() {
        
//        if let realm = try? Realm() {
//            
//        }
        
//        guard let realm = try! Realm() else {
//            print("get realm instance had error")
//            return
//        }
        
        let realm = try! Realm()
        
        let myDog = Dog()
        myDog.name = "Rex"
        myDog.age = 1
        
        let tom = DogPerson()
        tom.name = "Tom Chen"
        tom.dogs.append(myDog)
    
        
        let _ = try! realm.write {
            //realm.add(myDog)
            //realm.add(tom)
        }
        
        //if let dogs = realm.objects(Dog.self).first {
            //print(dogs.name)
            //print(dogs.owners)
        //}
        
        //let payers = realm.objects(Dog.self).first
        let persons = realm.objects(Dog.self).filter("NOT (age IN %@)", [1, 2])
        print(persons)
    }
    
    let disposeBag = DisposeBag()
    func testRealmRx() {
        let realm = try! Realm()
        let dogsList = realm.objects(Dog.self)
        
        //typealias updateUiAction = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> ()
        let action1: initUiAction = { print("action 1 ...") }
        let action2: updateUiAction = { (del, insert, modify) in
            print("action 2 ...")
        }
        dogsList.asObservable(initAction: action1, updateAction: action2)
            .subscribe({ event in
                print(event)
            })
            .addDisposableTo(disposeBag)
        
        if let person = realm.objects(DogPerson.self).first {
            print(person)
            try! realm.write {
                let dog = Dog()
                dog.name = "Rex4"
                //person.dogs.append(dog)
                
                let dog3 = Dog()
                dog3.name = "Rex5"
                
                realm.add(dog)
                realm.add(dog3)
            }
            if let dog = realm.objects(Dog.self).last {
                try! realm.write {
                    realm.delete(dog)
                }
            }
            
        }
    }
    
    func shareFinanceApp() {
        
    }
    
    var cellArray: [String] = ["init data", "getPayItems", "getPayPerson", "addPayItem", "test dog", "test RealmRx", "ShareFinanceApp"]
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = cellArray[indexPath.row]
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        
        if indexPath.row == 0 {
            addSomeDataIntoRealm()
            
        }else if indexPath.row == 1 {
            getPayItems(payPersonName: "Tom 10")
            
        }else if indexPath.row == 2 {
            getPayPerson(payPersonName: "Tom 10")
            
        }else if indexPath.row == 3 {
            addPayItem()
            
        }else if indexPath.row == 4 {
            testRealm()
            
        }else if indexPath.row == 5 {
            testRealmRx()
        }else if indexPath.row == 6 {
            shareFinanceApp()
        }
    }
    
    // Edit
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Unblock", comment: "")
    }
}

