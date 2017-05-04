//
//  UserTweetModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 5/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ObjectMapper

public class UserTweetModel: Mappable {
    
    public var authorScreenName: String = ""
    public var authorName: String = ""
    public var authorProfilePic: String = ""
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        authorScreenName <- map["screen_name"]
        authorName <- map["name"]
        authorProfilePic <- map["profile_image_url_https"]
    }
    
}
