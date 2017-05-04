//
//  UserModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import RealmSwift
import ObjectMapper

public class UserModel: Object, Mappable {
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var screenName: String = ""
    dynamic var profileUrl: String = ""
    dynamic var backgroundImageURL: String = ""
    dynamic var followersCount: Int = 0
    dynamic var followingCount: Int = 0
    
    var isFollow: Bool?
  
    convenience public required init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        screenName <- map["screen_name"]
        backgroundImageURL <- map["profile_background_image_url_https"]
        profileUrl <- map["profile_image_url_https"]
        followersCount <- map["followers_count"]
        followingCount <- map["friends_count"]
        isFollow <- map["following"]
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["isFollow"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

