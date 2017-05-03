//
//  ProfileViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/28/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result

public protocol ProfileViewModeling {
    var id: Property<Int> { get }
    var name: Property<String> { get }
    var screenName: Property<String> { get }
    var profileUrl: Property<String> { get }
    var backgroundImageURL: Property<String?> { get }
    var usingBannerImage: Property<Bool> { get }
    var followersCount: Property<String> { get }
    var followingCount: Property<String> { get }
    var isFollow: MutableProperty<Bool?> { get set }
    
    var cellModels: MutableProperty<[TweetCellViewModeling]> { get set }
    
    func userTimeline(id: Int)
    func userByScreenName(screenName: String) -> ProfileViewModeling
}

public final class ProfileViewModel: ProfileViewModeling {
    
    fileprivate let _id = MutableProperty<Int>(0)
    fileprivate let _name = MutableProperty<String>("")
    fileprivate let _screenName = MutableProperty<String>("")
    fileprivate let _profileUrl = MutableProperty<String>("")
    fileprivate let _backgroundImageURL = MutableProperty<String?>(nil)
    fileprivate let _usingBannerImage = MutableProperty<Bool>(false)
    fileprivate let _followersCount = MutableProperty<String>("")
    fileprivate let _followingCount = MutableProperty<String>("")
    fileprivate var _isFollow = MutableProperty<Bool?>(nil)
    
    fileprivate var _cellModels = MutableProperty<[TweetCellViewModeling]>([])
    
    public var id: Property<Int> { return Property(_id) }
    public var name: Property<String> { return Property(_name) }
    public var screenName: Property<String> { return Property(_screenName) }
    public var profileUrl: Property<String> { return Property(_profileUrl) }
    public var backgroundImageURL: Property<String?> { return Property(_backgroundImageURL) }
    public var usingBannerImage: Property<Bool> { return Property(_usingBannerImage) }
    public var followersCount: Property<String> { return Property(_followersCount) }
    public var followingCount: Property<String> { return Property(_followingCount) }
    public var isFollow: MutableProperty<Bool?> {
        get { return _isFollow }
        set { _isFollow = newValue }
    }
    
    public var cellModels: MutableProperty<[TweetCellViewModeling]> {
        get { return _cellModels }
        set { _cellModels = newValue }
    }
    
    fileprivate let twitter: TwitterProtocol = TwitterAPIManager()
    
    public init(user: UserModel) {
        _id.value = user.id
        _name.value = user.name
        _screenName.value = "@" + user.screenName
        _profileUrl.value = user.profileUrl
        _backgroundImageURL.value = user.backgroundImageURL
        _usingBannerImage.value = user.usingBannerImage
        _followersCount.value = user.followersCount.description
        _followingCount.value = user.followingCount.description
        _isFollow.value = user.isFollow
    }
    
    public init() {}
    
    public func userTimeline(id: Int) {
        twitter.userTimeline(id: id).observe(on: UIScheduler()).on { (tweetsModel) in
            for tweet in tweetsModel {
                let tweetModel = TweetCellViewModel(tweet: tweet)
                self._cellModels.value.append(tweetModel)
            }
        }.start()
    }
    
    public func userByScreenName(screenName: String) -> ProfileViewModeling {
        var userModel: ProfileViewModeling = ProfileViewModel()
        twitter.userByScreenName(screenName: screenName).observe(on: UIScheduler()).startWithValues { (user) in
            userModel = ProfileViewModel(user: user)
        }
        return userModel
    }
}
