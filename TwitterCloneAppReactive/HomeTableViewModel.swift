//
//  HomeTableViewModel.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/26/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result

public protocol HomeTableViewModeling {
    var cellModels: MutableProperty<[TweetCellViewModeling]> { get set }
    
    func startUpdate()
}

public final class HomeTableViewModel: HomeTableViewModeling {
    fileprivate var _cellModels = MutableProperty<[TweetCellViewModeling]>([])
    fileprivate let twitter: TwitterProtocol = TwitterAPIManager()
    
    public var cellModels: MutableProperty<[TweetCellViewModeling]> {
        get { return _cellModels }
        set { _cellModels = newValue }
    }
    
    public init() {}
    
    public func startUpdate() {
        twitter.homeTimeline().observe(on: UIScheduler()).on { (tweetsModel) in
            for tweet in tweetsModel {
                let modeling = TweetCellViewModel(tweet: tweet)
                self._cellModels.value.append(modeling)
            }
        }.start()
    }
}
