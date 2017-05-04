//
//  TweetModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/25/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ObjectMapper

public class TweetModel: Mappable {
    
    public var tweetID: Int = 0
    public var tweetContents: String = ""
    public var tweetAge: String = ""
    public var retweetCount: Int = 0
    public var favoriteCount: Int = 0
    public var userTweet: UserTweetModel!
    public var entityTweet: EntityTweetModel!
    public var favorited: Bool = false
    public var retweeted: Bool = false

    public required init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        tweetID <- map["id"]
        tweetContents <- map["text"]
        retweetCount <- map["retweet_count"]
        favoriteCount <- map["favorite_count"]
        retweeted <- map["retweeted"]
        favorited <- map["favorited"]
        tweetAge <- map["created_at"]
        userTweet <- map["user"]
        entityTweet <- map["entities"]
    }
}

