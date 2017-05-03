//
//  TwitterAPIManager.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import OAuthSwift
import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import Result

public protocol TwitterProtocol {
    var authenticateCocoaAction: CocoaAction<UIButton>! { get }
    var authenticateAction: Action<(), (), NoError>! { get }
    
    func currentAccount() -> SignalProducer<UserModel, NoError>
    func homeTimeline() -> SignalProducer<[TweetModel], NoError>
    func userTimeline(id: Int) -> SignalProducer<[TweetModel], NoError>
    func userByScreenName(screenName: String) -> SignalProducer<UserModel, NoError>
    func retweet(params: [String: AnyObject]?, retweet: Bool) -> SignalProducer<TweetModel, NoError>
    func favorite(params: [String: AnyObject], favorite: Bool) -> SignalProducer<TweetModel, NoError>
    func publishTweet(params: [String: AnyObject]) -> SignalProducer<TweetModel, NoError>
    func replyToTweet(text: String, replyToTweetID: Int?) -> SignalProducer<TweetModel, NoError>
    func deleteTweet(tweetId: String) -> SignalProducer<TweetModel, NoError>
    func searchNewUser(query: String) -> SignalProducer<[UserModel], NoError>
    func followNewUser(screenName: String) -> SignalProducer<UserModel, NoError>
    func logout()
}

public class TwitterAPIManager: TwitterProtocol {
    
    static let key = "cNaxiVQIlmj6Fheu3PQu8j7n2"
    static let secret = "QlJ0kaeCYDzy2HQRRbI2FqAbqTwUMCXIKozWfFA8MGW0UYJ32B"
    
    static let consumerData: [String: String] = ["consumerKey": TwitterAPIManager.key, "consumerSecret": TwitterAPIManager.secret]
    static var tokens: (String, String)!
    
    
    let oauth1swift = OAuth1Swift(consumerKey:     key,
                                  consumerSecret:  secret,
                                  requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                                  authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                                  accessTokenUrl:  "https://api.twitter.com/oauth/access_token")
    
    fileprivate let realmManager: RealmProtocol = RealmManager()
    fileprivate let defaults = UserDefaults.standard
    
    public var authenticateCocoaAction: CocoaAction<UIButton>!
    public var authenticateAction: Action<(), (), NoError>!
    
    init() {
        authenticateAction = Action<(), (), NoError> { (_) -> SignalProducer<(), NoError> in
            return self.doOAuthTwitter()
        }
        authenticateCocoaAction = CocoaAction(authenticateAction)
    }
    
    fileprivate func doOAuthTwitter() -> SignalProducer<(), NoError> {
        return SignalProducer { (observer, disposable) in
            self.oauth1swift.authorizeURLHandler = self.getURLHandler()
            self.oauth1swift.authorize(withCallbackURL: URL(string: "oauth-twitter://oauth-callback")!, success: { credential, response, parameters in
                TwitterAPIManager.tokens = (credential.oauthToken, credential.oauthTokenSecret)
                self.currentAccount().startWithValues({ (user) in
                    self.defaults.set(user.id, forKey: "id")
                    self.defaults.synchronize()
                    self.realmManager.setCurrentUser(user)
                })
                observer.sendCompleted()
            }, failure: { error in
                print(error.description)
                observer.sendInterrupted()
            })
        }
    }
    
    fileprivate func getURLHandler() -> OAuthSwiftURLHandlerType {
        return OAuthSwiftOpenURLExternally.sharedInstance
    }
    
    fileprivate func getTokens() {
        guard let token = TwitterAPIManager.tokens?.0, let secretToken = TwitterAPIManager.tokens?.1 else { return }
        self.oauth1swift.client.credential.oauthToken = token
        self.oauth1swift.client.credential.oauthTokenSecret = secretToken
    }
    
    public func currentAccount() -> SignalProducer<UserModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get("https://api.twitter.com/1.1/account/verify_credentials.json", parameters: [:], success: { response in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let user = UserModel(jsonDictinary)
                    observer.send(value: user)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                print(error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func homeTimeline() -> SignalProducer<[TweetModel], NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get("https://api.twitter.com/1.1/statuses/home_timeline.json",
                                                parameters: ["count": 30], success: { response in
                do {
                    guard let dictionaries = try response.jsonObject() as? [[String: AnyObject]] else { return }
                    let tweets = TweetModel.tweetsWithArray(dictionaries)
                    observer.send(value: tweets)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                observer.sendInterrupted()
                print("HT " + error.localizedDescription)
            })
        }
    }
    
    public func userTimeline(id: Int) -> SignalProducer<[TweetModel], NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get("https://api.twitter.com/1.1/statuses/user_timeline.json",
                                                parameters: ["count": 30, "user_id": id], success: { response in
                do {
                    guard let dictionaries = try response.jsonObject() as? [[String: AnyObject]] else { return }
                    let tweets = TweetModel.tweetsWithArray(dictionaries)
                    observer.send(value: tweets)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                observer.sendInterrupted()
                print("UT " + error.localizedDescription)
            })
        }
    }
    
    public func userByScreenName(screenName: String) -> SignalProducer<UserModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get("https://api.twitter.com/1.1/users/lookup.json",
                                                parameters: ["screen_name": screenName], success: { response in
                do {
                    guard let dictionaries = try response.jsonObject() as? [[String: AnyObject]] else { return }
                    let user = UserModel(dictionaries[0])
                    observer.send(value: user)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                observer.sendInterrupted()
                print("UbS " + error.localizedDescription)
            })
        }
    }
    
    public func retweet(params: [String : AnyObject]?, retweet: Bool) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let tweetID = params!["id"] as! String
            let endpoint = retweet ? "retweet" : "unretweet"
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/statuses/\(endpoint)/\(tweetID).json",
                                                 parameters: ["id": tweetID], headers: nil, body: nil, success: { (response) in
                do {
                    guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let tweet = TweetModel(dictionary)
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("R " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func favorite(params: [String : AnyObject], favorite: Bool) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let endpoint = favorite ? "create" : "destroy"
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/favorites/\(endpoint).json",
                                                 parameters: params, headers: nil, body: nil, success: { (response) in
                do {
                    guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let tweet = TweetModel(dictionary)
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("F " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func publishTweet(params: [String : AnyObject]) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/statuses/update.json",
                                                 parameters: params, headers: nil, body: nil, success: { (response) in
                do {
                    guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let tweet = TweetModel(dictionary)
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("PT " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func replyToTweet(text: String, replyToTweetID: Int?) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            if text == "" {
                observer.sendInterrupted()
                return
            }
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/statuses/update.json",
                                                 parameters: ["status": text, "in_reply_to_status_id":
                                                    replyToTweetID!], headers: nil, body: nil, success: { (response) in
                do {
                    guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let tweet = TweetModel(dictionary)
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("RT " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func deleteTweet(tweetId: String) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/statuses/destroy/\(tweetId).json",
                                                 parameters: [:], headers: nil, body: nil, success: { (response) in
                do {
                    guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                    let tweet = TweetModel(dictionary)
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("DT " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func searchNewUser(query: String) -> SignalProducer<[UserModel], NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get("https://api.twitter.com/1.1/users/search.json",
                                                parameters: ["q": query], success: { response in
                do {
                    guard let dictionaries = try response.jsonObject() as? [[String: AnyObject]] else { return }
                    let user = UserModel.usersWithArray(dictionaries)
                    observer.send(value: user)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                observer.sendInterrupted()
                print("SNU " + error.localizedDescription)
            })
        }
    }
    
    public func followNewUser(screenName: String) -> SignalProducer<UserModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.post("https://api.twitter.com/1.1/friendships/create.json",
                parameters: ["screen_name": screenName, "follow": true], headers: nil, body: nil, success: { (response) in
                    do {
                        guard let dictionary = try response.jsonObject() as? [String: AnyObject] else { return }
                        let tweet = UserModel(dictionary)
                        observer.send(value: tweet)
                        observer.sendCompleted()
                    } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("FNU " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }

    public func logout() {
        let storage = HTTPCookieStorage.shared
        guard let cookies = storage.cookies else { return }
        for cookie in cookies {
            storage.deleteCookie(cookie)
        }
        realmManager.deleteCurrentUser()
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
