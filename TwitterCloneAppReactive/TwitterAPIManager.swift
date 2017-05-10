//
//  TwitterAPIManager.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import OAuthSwift
import ReactiveCocoa
import ReactiveSwift
import Result
import ObjectMapper

public protocol TwitterProtocol {
    var authenticateCocoaAction: CocoaAction<UIButton>! { get }
    var authenticateAction: Action<(), (), NoError>! { get }
    
    func currentAccount() -> SignalProducer<UserModel, NoError>
    func homeTimeline() -> SignalProducer<[TweetModel], NoError>
    func userTimeline(id: Int) -> SignalProducer<[TweetModel], NoError>
    func userByScreenName(screenName: String) -> SignalProducer<UserModel, NoError>
    func retweet(params: [String: AnyObject], retweet: Bool) -> SignalProducer<TweetModel, NoError>
    func favorite(params: [String: AnyObject], favorite: Bool) -> SignalProducer<TweetModel, NoError>
    func publishTweet(params: [String: AnyObject]) -> SignalProducer<TweetModel, NoError>
    func replyToTweet(text: String, replyToTweetID: Int?) -> SignalProducer<TweetModel, NoError>
    func deleteTweet(tweetId: String) -> SignalProducer<TweetModel, NoError>
    func searchNewUser(query: String) -> SignalProducer<[UserModel], NoError>
    func followNewUser(screenName: String) -> SignalProducer<UserModel, NoError>
    func logout()
}

public class TwitterAPIManager: TwitterProtocol {
    
    fileprivate static var tokens: (String, String)!
    
    fileprivate let oauth1swift = OAuth1Swift(consumerKey:     ConstantBaseString.key,
                                              consumerSecret:  ConstantBaseString.secret,
                                              requestTokenUrl: ConstantStrings.requestTokenUrl,
                                              authorizeUrl:    ConstantStrings.authorizeUrl,
                                              accessTokenUrl:  ConstantStrings.accessTokenUrl)
    
    fileprivate let realmManager: RealmProtocol = RealmManager()
    fileprivate let defaults = UserDefaults.standard
    
    public var authenticateCocoaAction: CocoaAction<UIButton>!
    public var authenticateAction: Action<(), (), NoError>!
    
    init() {
        authenticateAction = Action<(), (), NoError> { (_) -> SignalProducer<(), NoError> in return self.doOAuthTwitter() }
        authenticateCocoaAction = CocoaAction(authenticateAction)
    }
    
    fileprivate func doOAuthTwitter() -> SignalProducer<(), NoError> {
        return SignalProducer { (observer, disposable) in
            self.oauth1swift.authorizeURLHandler = self.getURLHandler()
            self.oauth1swift.authorize(withCallbackURL: URL(string: "oauth-twitter://oauth-callback")!, success: { credential, response, parameters in
                TwitterAPIManager.tokens = (credential.oauthToken, credential.oauthTokenSecret)
                self.currentAccount().startWithValues { (user) in
                    self.defaults.set(user.id, forKey: "id")
                    self.defaults.synchronize()
                    self.realmManager.setCurrentUser(user)
                }
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
        oauth1swift.client.credential.oauthToken = TwitterAPIManager.tokens.0
        oauth1swift.client.credential.oauthTokenSecret = TwitterAPIManager.tokens.1
    }
    
    public func currentAccount() -> SignalProducer<UserModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get(ConstantStrings.currentAccount,
                                                parameters: [:], success: { response in
                do {
                    let jsonDictinary = try response.jsonObject() as Any?
                    guard let user = Mapper<UserModel>().map(JSONObject: jsonDictinary) else { return }
                    observer.send(value: user)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                print("CA " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func homeTimeline() -> SignalProducer<[TweetModel], NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let _ = self.oauth1swift.client.get(ConstantStrings.homeTimeline,
                                                parameters: ["count": 30], success: { response in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [[String: Any]] else { return }
                    guard let tweets = Mapper<TweetModel>().mapArray(JSONArray: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.get(ConstantStrings.userTimeline,
                                                parameters: ["count": 30, "user_id": id], success: { response in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [[String: Any]] else { return }
                    guard let tweets = Mapper<TweetModel>().mapArray(JSONArray: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.get(ConstantStrings.userByScreenName,
                                                parameters: ["screen_name": screenName], success: { response in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [[String: Any]] else { return }
                    guard let users = Mapper<UserModel>().mapArray(JSONArray: jsonDictinary) else { return }
                    observer.send(value: users[0])
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { error in
                observer.sendInterrupted()
                print("UbS " + error.localizedDescription)
            })
        }
    }
    
    public func retweet(params: [String :AnyObject], retweet: Bool) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let tweetID = params["id"] as! String
            print(ConstantStrings.retweet + retweet.description + "/" + tweetID + ".json")
            let endpoint = retweet ? "retweet" : "unretweet"
            let _ = self.oauth1swift.client.post(ConstantStrings.retweet + endpoint + "/" + tweetID + ".json",
                                                 parameters: ["id": tweetID], success: { (response) in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: Any] else { return }
                    guard let tweet = Mapper<TweetModel>().map(JSON: jsonDictinary) else { return }
                    observer.send(value: tweet)
                    observer.sendCompleted()
                } catch { observer.sendInterrupted() }
            }, failure: { (error) in
                print("R " + error.localizedDescription)
                observer.sendInterrupted()
            })
        }
    }
    
    public func favorite(params: [String :AnyObject], favorite: Bool) -> SignalProducer<TweetModel, NoError> {
        getTokens()
        return SignalProducer { (observer, disposable) in
            let endpoint = favorite ? "create" : "destroy"
            let _ = self.oauth1swift.client.post(ConstantStrings.favorite + endpoint + ".json",
                                                 parameters: params, success: { (response) in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: Any] else { return }
                    guard let tweet = Mapper<TweetModel>().map(JSON: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.post(ConstantStrings.publishTweet,
                                                 parameters: params, success: { (response) in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: Any] else { return }
                    guard let tweet = Mapper<TweetModel>().map(JSON: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.post(ConstantStrings.publishTweet,
                                                 parameters: ["status": text, "in_reply_to_status_id": replyToTweetID!], success: { (response) in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: Any] else { return }
                    guard let tweet = Mapper<TweetModel>().map(JSON: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.post(ConstantStrings.deleteTweet + tweetId + ".json",
                                                 parameters: [:], success: { (response) in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [String: Any] else { return }
                    guard let tweet = Mapper<TweetModel>().map(JSON: jsonDictinary) else { return }
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
            let _ = self.oauth1swift.client.get(ConstantStrings.searchNewUser,
                                                parameters: ["q": query], success: { response in
                do {
                    guard let jsonDictinary = try response.jsonObject() as? [[String: Any]] else { return }
                    guard let users = Mapper<UserModel>().mapArray(JSONArray: jsonDictinary) else { return }
                    observer.send(value: users)
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
            let _ = self.oauth1swift.client.post(ConstantStrings.followNewUser,
                                                 parameters: ["screen_name": screenName, "follow": true], success: { (response) in
                    do {
                        let jsonDictinary = try response.jsonObject() as Any?
                        guard let user = Mapper<UserModel>().map(JSONObject: jsonDictinary) else { return }
                        observer.send(value: user)
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
