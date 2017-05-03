//
//  TweetCellViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/26/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result

public protocol TweetCellViewModeling {
    var tweetID: Int { get }
    var authorName: String { get }
    var authorScreenName: String { get }
    var tweetContents: String { get }
    var tweetAge: String { get }
    var retweetCount: Int { get set }
    var favoriteCount: Int { get set }
    var urls: [[String: AnyObject]] { get }
    var media: [[String: AnyObject]] { get }
    var favorited: Bool { get }
    var retweeted: Bool { get }
    var mediaProfilePic: String? { get }
    
    func getProfilePictureImageView() -> SignalProducer<UIImage?, NoError>
    func getMediaImageView() -> SignalProducer<UIImage?, NoError>
    func getHyperlink(_ label: UILabel)
    func getDate() -> String
}

public final class TweetCellViewModel: NSObject, TweetCellViewModeling {
    
    fileprivate var authorImage: UIImage?
    fileprivate var mediaImage: UIImage?
    fileprivate var authorProfilePic: String
    fileprivate var rCount: Int = 0
    fileprivate var fCount: Int = 0
    
    public let tweetID: Int
    public let authorName: String
    public let authorScreenName: String
    public let tweetContents: String
    public let tweetAge: String
    public var retweetCount: Int {
        get { return rCount }
        set { rCount = newValue } }
    public var favoriteCount: Int {
        get { return fCount }
        set { fCount = newValue } }
    public let urls: [[String: AnyObject]]
    public let media: [[String: AnyObject]]
    public let favorited: Bool
    public let retweeted: Bool
    public var mediaProfilePic: String?
    
    internal init(tweet: TweetModel) {
        
        tweetID = tweet.tweetID
        authorName = tweet.authorName
        authorScreenName = "@" + tweet.authorScreenName
        tweetContents = tweet.tweetContents
        tweetAge = tweet.tweetAge
        rCount = tweet.retweetCount
        fCount = tweet.favoriteCount
        urls = tweet.urls
        media = tweet.media
        favorited = tweet.favorited
        retweeted = tweet.retweeted
        
        authorProfilePic = tweet.authorProfilePic
        mediaProfilePic = tweet.mediaProfilePic
        
        super.init()
    }
    
    public func getDate() -> String {
        var date = tweetAge
        let firstBound = date.index(date.startIndex, offsetBy: 4)
        let endBound = date.index(date.endIndex, offsetBy: -18)
        date = date.substring(from: firstBound)
        date = date.substring(to: endBound)
        return date
    }
    
    public func getHyperlink(_ label: UILabel) {
        var displayUrls = [String]()
        
        for url in urls {
            if let urltext = url["url"] as? String {
                label.text = label.text?.replacingOccurrences(of: urltext, with: "")
            }
            guard var displayurl = url["display_url"] as? String else { return }
            if let expandedURL = url["expanded_url"] {
                displayurl = expandedURL as! String
            }
            displayUrls.append(displayurl)
        }
        
        if(displayUrls.count > 0){
            let content = label.text ?? ""
            
            let urlText = " " + displayUrls.joined(separator: " ")
            
            let text = NSMutableAttributedString(string: content)
            text.addAttribute(NSFontAttributeName,
                              value: UIFont(name: "AppleSDGothicNeo-Thin", size: 17)!,
                              range: NSRange(location: 0, length: content.characters.count))
            
            let links = NSMutableAttributedString(string: urlText)
            links.addAttribute(NSFontAttributeName,
                               value: UIFont(name: "AppleSDGothicNeo-Light", size: 17)!,
                               range: NSRange(location: 0, length: urlText.characters.count))
            links.addAttribute(NSForegroundColorAttributeName,
                               value: #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1),
                               range: NSRange(location: 0, length: urlText.characters.count))
            
            text.append(links)
            label.attributedText = text
        }
    }
    
    public func getProfilePictureImageView() -> SignalProducer<UIImage?, NoError> {
        return SignalProducer { (observer, disposable) in
            if let image = self.authorImage {
                observer.send(value: image)
                observer.sendCompleted()
            } else {
                requestImage(self.authorProfilePic).observe(on: UIScheduler())
                    .take(until: self.reactive.lifetime.ended)
                    .map { $0 as UIImage? }.startWithValues {
                        self.authorImage = $0
                        observer.send(value: $0)
                        observer.sendCompleted()
                }
            }
        }
    }
    
    public func getMediaImageView() -> SignalProducer<UIImage?, NoError> {
        return SignalProducer { (observer, disposable) in
            if let image = self.mediaImage {
                observer.send(value: image)
                observer.sendCompleted()
            } else {
                guard let image = self.mediaProfilePic else { return }
                requestImage(image)
                    .take(until: self.reactive.lifetime.ended)
                    .startWithValues {
                        self.mediaImage = $0
                        observer.send(value: $0)
                        observer.sendCompleted()
                }
            }
        }
    }
}
