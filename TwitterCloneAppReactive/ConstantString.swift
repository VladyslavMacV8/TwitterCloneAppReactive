//
//  Constants.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 5/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

struct ConstantBaseString {
    static let api = "https://api.twitter.com/"
    static let key = "cNaxiVQIlmj6Fheu3PQu8j7n2"
    static let secret = "QlJ0kaeCYDzy2HQRRbI2FqAbqTwUMCXIKozWfFA8MGW0UYJ32B"
}

struct ConstantStrings {
    static let requestTokenUrl =  ConstantBaseString.api + "oauth/request_token"
    static let authorizeUrl = ConstantBaseString.api + "oauth/authorize"
    static let accessTokenUrl = ConstantBaseString.api + "oauth/access_token"
    static let currentAccount = ConstantBaseString.api + "1.1/account/verify_credentials.json"
    static let homeTimeline = ConstantBaseString.api + "1.1/statuses/home_timeline.json"
    static let userTimeline = ConstantBaseString.api + "1.1/statuses/user_timeline.json"
    static let userByScreenName = ConstantBaseString.api + "1.1/users/lookup.json"
    static let retweet = ConstantBaseString.api + "1.1/statuses/"
    static let favorite = ConstantBaseString.api + "1.1/favorites/"
    static let publishTweet = ConstantBaseString.api + "1.1/statuses/update.json"
    static let deleteTweet = ConstantBaseString.api + "1.1/statuses/destroy/"
    static let searchNewUser = ConstantBaseString.api + "1.1/users/search.json"
    static let followNewUser = ConstantBaseString.api + "1.1/friendships/create.json"
}
