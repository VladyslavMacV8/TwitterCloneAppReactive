//
//  TweetModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/25/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Himotoki
import ReactiveCocoa
import ReactiveSwift
import Result

public class TweetModel {
    
    public var tweetID: Int = 0
    public var authorName: String = ""
    public var authorScreenName: String = ""
    public var tweetContents: String = ""
    public var tweetAge: String = ""
    public var retweetCount: Int = 0
    public var favoriteCount: Int = 0
    public var urls: [[String: AnyObject]] = [[:]]
    public var media: [[String: AnyObject]] = [[:]]
    public var favorited: Bool = false
    public var retweeted: Bool = false
    public var authorProfilePic: String = ""
    public var mediaProfilePic: String?
    
    init(_ dictionary: [String: AnyObject]) {
        retrieveDataFrom(dictionary)
    }
    
    private func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        tweetID = dictionary["id"] as? Int ?? 0
        tweetContents = dictionary["text"] as? String ?? ""
        retweetCount = dictionary["retweet_count"] as? Int ?? 0
        favoriteCount = dictionary["favorite_count"] as? Int ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        tweetAge = dictionary["created_at"] as? String ?? ""
        if let dictionary = dictionary["user"] as? [String: AnyObject] {
            authorScreenName = dictionary["screen_name"] as? String ?? ""
            authorName = dictionary["name"] as? String ?? ""
            authorProfilePic = dictionary["profile_image_url_https"] as? String ?? ""
        }
        if let dictionary = dictionary["entities"] as? [String: AnyObject] {
            urls = dictionary["urls"] as? [[String: AnyObject]] ?? []
            media = dictionary["media"] as? [[String: AnyObject]] ?? []
            for medium in media {
                if (medium["type"] as? String) == "photo" {
                    if let mediaurl = medium["media_url"] as? String {
                        mediaProfilePic = mediaurl
                    }
                }
            }
        }
    }
    
    class func tweetsWithArray(_ dictionaries: [[String: AnyObject]]) -> [TweetModel] {
        var tweets = [TweetModel]()
        
        for dictionary in dictionaries {
            let tweet = TweetModel(dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}

