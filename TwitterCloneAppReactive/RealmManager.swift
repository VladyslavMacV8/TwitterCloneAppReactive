//
//  RealmManager.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import RealmSwift

public protocol RealmProtocol {
    func setCurrentUser(_ user: UserModel)
    func getCurrentUser() -> UserModel
    func deleteCurrentUser()
}

public class RealmManager: RealmProtocol {
    
    let userDefaults = UserDefaults.standard
    
    public func setCurrentUser(_ user: UserModel) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user, update: true)
            }
        } catch { print("not user") }
    }
    
    public func getCurrentUser() -> UserModel {
        let id = userDefaults.integer(forKey: "id")
        var user: UserModel!
        
        do {
            let realm = try Realm()
            user = realm.object(ofType: UserModel.self, forPrimaryKey: id)
        } catch { print("error current user") }
        
        userDefaults.synchronize()
        
        return user
    }
    
    public func deleteCurrentUser() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch { print("not user") }
    }
}
