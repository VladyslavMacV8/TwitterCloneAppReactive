//
//  UserModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import RealmSwift

public class UserModel: Object {
    
    var dictionary: [String: AnyObject] = [:]
    var isFollow: Bool?
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var screenName: String = ""
    dynamic var profileUrl: String = ""
    dynamic var backgroundImageURL: String?
    dynamic var usingBannerImage = true
    dynamic var followersCount: Int = 0
    dynamic var followingCount: Int = 0
    
    convenience init(_ dictionary: [String: AnyObject]) {
        self.init()
        self.dictionary = dictionary
        retrieveDataFrom(dictionary)
    }
    
    fileprivate func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        screenName = dictionary["screen_name"] as? String ?? ""
        
        backgroundImageURL = dictionary["profile_banner_url"] as? String
        if(backgroundImageURL != nil) {
            backgroundImageURL?.append("/600x200")
        } else {
            backgroundImageURL = dictionary["profile_background_image_url_https"] as? String ?? ""
            usingBannerImage = false
        }
        
        profileUrl = dictionary["profile_image_url_https"] as? String ?? ""
        
        followersCount = dictionary["followers_count"] as? Int ?? 0
        followingCount = dictionary["friends_count"] as? Int ?? 0
        isFollow = dictionary["following"] as? Bool ?? false
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["dictionary", "isFollow"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    class func usersWithArray(_ dictionaries: [[String: AnyObject]]) -> [UserModel] {
        var users = [UserModel]()
        
        for dictionary in dictionaries {
            let user = UserModel(dictionary)
            users.append(user)
        }
        
        return users
    }
}
