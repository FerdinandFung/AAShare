//
// Results+Rx.swift
//
// Make Realm auto-updating Results observable. Works with Realm 0.98 and later, RxSwift 2.1.0 and later.
//
// Created by Florent Pillet on 12/02/16.
// Copyright (c) 2016 Florent Pillet. All rights reserved.
//
// https://gist.github.com/fpillet/4ceb477eeb2705fb5159
//
// Modified by Tom Chen on 22/12/16. for Realm 2.1.x and Swift3.0
//
import Foundation
import UIKit
import RealmSwift
import RxSwift


typealias initUiAction = () -> ()
typealias updateUiAction = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> ()

extension Results {
    
    func asObservable() -> Observable<Results<Element>> {
        let initAction: initUiAction = { () -> () in }
        let updateAction: updateUiAction = { (deletions, insertions, modifications) -> () in }
        return self.asObservable(initAction: initAction, updateAction: updateAction)
    }
    
    func asObservable(updateAction: @escaping updateUiAction) -> Observable<Results<Element>> {
        let initAction: initUiAction = { () -> () in }
        return self.asObservable(initAction: initAction, updateAction: updateAction)
    }
    
    /// turn a Realm Results into an Observable sequence that sends the Results object itself once at query, then
    /// again every time a change occurs in the Results. Caller just subscribes to the observable to get
    /// updates. Note that Realm may send updates even when there is no actual change to the data
    /// (Realm docs mention they will fine tune this later)
    ///
    /// phamquochoan commented on Feb 27
    ///     do we need to add [unowned self] or [weak self] into these functions ?
    /// fpillet commented on Apr 18
    ///     @phamquochoan: I don't think so. In the second API you're right that we're using self in the closure so essentially keeping it alive -- but this is what we want! As long as we keep observing the Results, they will stay alive. It's when we dispose our subscription that we don't need Results anymore.
    func asObservable(initAction: @escaping initUiAction, updateAction: @escaping updateUiAction) -> Observable<Results<Element>> {
        return Observable.create { observer in
            var token: NotificationToken? = nil
            token = self.addNotificationBlock { changes in
                switch changes {
                case .initial(let results):
                    //
                    // Tom: .initial will be called when Realm do transaction each time. like add(),
                    //      delete(), modify()
                    //
                    //      'results' is the original value of Results<Element>.
                    //
                    //      So, NO need pass this to the next phase.
                    //
                    
                    print("Realm notification initial : \(results)")
                    //observer.onNext(results)
                    
                    // RealmSwift:
                    // Results are now populated and can be accessed without blocking the UI
                    // self.tableView.reloadData()
                    
                    //
                    // Tom: most time, you do NOT need update your UI when the initial is triggering
                    //      every time
                    //
                    initAction()

                case .update(let results, let deletions, let insertions, let modifications):
                    //
                    // Tom: like 'deletions', It's the index of the Realm update operation.
                    //      the 'results' is the objects after you are operated.
                    //
                    print("Realm notification update")
                    print("    results       : \(results)")
                    print("    deletions     : \(deletions)")
                    print("    insertions    : \(insertions)")
                    print("    modifications : \(modifications)")
                    observer.onNext(results)
                    
                    //
                    // Tom: most time, you should update your UI when the update is triggering
                    //
                    // RealmSwift:
                    // self.tableView?.beginUpdates()
                    // self.tableView?.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                    //                            with: .automatic)
                    // self.tableView?.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                    //                           with: .automatic)
                    // self.tableView?.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                    //                           with: .automatic)
                    // self.tableView?.endUpdates()
                    //
                    updateAction(deletions, insertions, modifications)

                case .error(let err):
                    print("Realm notification error")
                    observer.onError(err)

                }
            }
            return Disposables.create() {
                token?.stop()
            }
        }
    }
    
    func asObservableArray() -> Observable<[Element]> {
        let initAction: initUiAction = { () -> () in }
        let updateAction: updateUiAction = { (deletions, insertions, modifications) -> () in }
        return self.asObservableArray(initAction: initAction, updateAction: updateAction)
    }
    
    func asObservableArray(updateAction: @escaping updateUiAction) -> Observable<[Element]> {
        let initAction: initUiAction = { () -> () in }
        return self.asObservableArray(initAction: initAction, updateAction: updateAction)
    }
    
    func asObservableArray(initAction: @escaping initUiAction, updateAction: @escaping updateUiAction) -> Observable<[Element]> {
        return Observable.create { observer in
            var token: NotificationToken? = nil
            token = self.addNotificationBlock { changes in
                switch changes {
                case .initial:
                    initAction()

                case .update(let results, let deletions, let insertions, let modifications):
                    print("Realm notification update")
                    print("    results       : \(results)")
                    print("    deletions     : \(deletions)")
                    print("    insertions    : \(insertions)")
                    print("    modifications : \(modifications)")
                    observer.onNext(Array(results))
                    
                    updateAction(deletions, insertions, modifications)

                case .error(let err):
                    observer.onError(err)

                }
            }
            return Disposables.create() {
                token?.stop()
            }
        }
    }
    
}
