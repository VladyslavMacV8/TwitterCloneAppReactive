//
//  HomeTableViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/26/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ReactiveSwift
import Result

public protocol HomeTableViewModeling {
    var cellModels: Property<[TweetCellViewModeling]> { get }
    
    func startUpdate() -> SignalProducer<(), NoError>
}

public final class HomeTableViewModel: HomeTableViewModeling {
    fileprivate let _cellModels = MutableProperty<[TweetCellViewModeling]>([])
    fileprivate let twitter: TwitterProtocol = TwitterAPIManager()
    
    public var cellModels: Property<[TweetCellViewModeling]> { return Property(_cellModels) }
    
    public init() {}
    
    public func startUpdate() -> SignalProducer<(), NoError> {
        return SignalProducer { (observer, disposable) in
            self.twitter.homeTimeline().observe(on: UIScheduler()).on { (tweets) in
                var tweetsModel = [TweetCellViewModeling]([])
                for tweet in tweets {
                    tweetsModel.append(TweetCellViewModel(tweet: tweet))
                }
                self._cellModels.value = tweetsModel
            }.start()
            observer.sendCompleted()
        }
    }
}
