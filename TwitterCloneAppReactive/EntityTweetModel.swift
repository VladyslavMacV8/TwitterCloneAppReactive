//
//  EntityTweetModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 5/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ObjectMapper

public class EntityTweetModel: Mappable {
    
    public var urls: [[String: AnyObject]] = [[:]]
    public var media: [[String: AnyObject]] = [[:]]
    
    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        urls <- map["urls"]
        media <- map["media"]
    }
}
