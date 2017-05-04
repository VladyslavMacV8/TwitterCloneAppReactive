//
//  Constants.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 5/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

struct ConstantString {
    static let key = "cNaxiVQIlmj6Fheu3PQu8j7n2"
    static let secret = "QlJ0kaeCYDzy2HQRRbI2FqAbqTwUMCXIKozWfFA8MGW0UYJ32B"
    static let requestTokenUrl = "https://api.twitter.com/oauth/request_token"
    static let authorizeUrl = "https://api.twitter.com/oauth/authorize"
    static let accessTokenUrl = "https://api.twitter.com/oauth/access_token"
    static let currentAccount = "https://api.twitter.com/1.1/account/verify_credentials.json"
    static let homeTimeline = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    static let userTimeline = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    static let userByScreenName = "https://api.twitter.com/1.1/users/lookup.json"
    static let retweet = "https://api.twitter.com/1.1/statuses/"
    static let favorite = "https://api.twitter.com/1.1/favorites/"
    static let publishTweet = "https://api.twitter.com/1.1/statuses/update.json"
    static let deleteTweet = "https://api.twitter.com/1.1/statuses/destroy/"
    static let searchNewUser = "https://api.twitter.com/1.1/users/search.json"
    static let followNewUser = "https://api.twitter.com/1.1/friendships/create.json"
}
