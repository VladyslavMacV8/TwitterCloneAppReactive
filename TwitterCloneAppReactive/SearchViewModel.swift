//
//  SearchViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 5/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ReactiveSwift
import Result

public protocol SearchViewModeling {
    var cellModels: Property<[ProfileViewModeling]> { get }
    
    func startUpdateCurrentUser()
    func updateUsersList(label: UITextField) -> SignalProducer<(), NoError>
}

public class SearchViewModel: SearchViewModeling {
    
    fileprivate let _cellModels = MutableProperty<[ProfileViewModeling]>([])
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    fileprivate let realmManager: RealmProtocol = RealmManager()
    
    public var cellModels: Property<[ProfileViewModeling]> { return Property(_cellModels) }
    
    public init() {}
    
    public func startUpdateCurrentUser() {
        twitterManager.currentAccount().startWithValues { (user) in
            self.realmManager.setCurrentUser(user)
        }
    }
    
    public func updateUsersList(label: UITextField) -> SignalProducer<(), NoError> {
        return SignalProducer { (observer, disposable) in
            self.twitterManager.searchNewUser(query: label.text!).startWithValues { (newUsers) in
                var users = [ProfileViewModeling]([])
                for user in newUsers {
                    users.append(ProfileViewModel(user: user))
                }
                self._cellModels.value = users
                observer.sendCompleted()
            }
        }
    }
}
