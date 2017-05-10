//
//  TweetCellViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/26/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

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
    
    func getProfilePictureImageView() -> SignalProducer<URL, NoError>
    func getHyperlink(_ label: UILabel)
    func getDate(_ label: UILabel)
}

public final class TweetCellViewModel: TweetCellViewModeling {
    
    fileprivate var authorProfilePic: String
    fileprivate var rCount: Int = 0
    fileprivate var fCount: Int = 0
    
    public let tweetID: Int
    public let authorName: String
    public let authorScreenName: String
    public let tweetContents: String
    public let tweetAge: String
    public let urls: [[String: AnyObject]]
    public let media: [[String: AnyObject]]
    public let favorited: Bool
    public let retweeted: Bool
    
    public var retweetCount: Int {
        get { return rCount }
        set { rCount = newValue }
    }
    
    public var favoriteCount: Int {
        get { return fCount }
        set { fCount = newValue }
    }
    
    internal init(tweet: TweetModel) {
        tweetID = tweet.tweetID
        authorName = tweet.userTweet.authorName
        authorScreenName = "@" + tweet.userTweet.authorScreenName
        tweetContents = tweet.tweetContents
        tweetAge = tweet.tweetAge
        rCount = tweet.retweetCount
        fCount = tweet.favoriteCount
        urls = tweet.entityTweet.urls
        media = tweet.entityTweet.media
        favorited = tweet.favorited
        retweeted = tweet.retweeted
        authorProfilePic = tweet.userTweet.authorProfilePic
    }
    
    public func getDate(_ label: UILabel) {
        DispatchQueue.global(qos: .background).async {
            var date = self.tweetAge
            let firstBound = date.index(date.startIndex, offsetBy: 4)
            let endBound = date.index(date.endIndex, offsetBy: -18)
            date = date.substring(from: firstBound)
            date = date.substring(to: endBound)
            DispatchQueue.main.async {
                label.text = date
            }
        }
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
        
        if displayUrls.count > 0 {
            let content = label.text ?? ""
            
            let urlText = " " + displayUrls.joined(separator: " ")
            
            guard let font = UIFont(name: "AppleSDGothicNeo-Light", size: 17) else { return }
            
            let text = NSMutableAttributedString(string: content)
            text.addAttribute(NSFontAttributeName, value: font,
                              range: NSRange(location: 0, length: content.characters.count))
            
            let links = NSMutableAttributedString(string: urlText)
            links.addAttribute(NSFontAttributeName, value: font,
                               range: NSRange(location: 0, length: urlText.characters.count))
            links.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1),
                               range: NSRange(location: 0, length: urlText.characters.count))
            
            text.append(links)
            label.attributedText = text
        }
    }
    
    public func getProfilePictureImageView() -> SignalProducer<URL, NoError> {
        return SignalProducer { (observer, disposable) in
            guard let pictureURL = URL(string: self.authorProfilePic) else {
                observer.sendInterrupted()
                return
            }
            observer.send(value: pictureURL)
            observer.sendCompleted()
        }
    }
}
