//
//  TweetCell.swift
//  TwitterTest
//
//  Created by Константин on 29.03.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

internal final class TweetCell: UITableViewCell {
    
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorScreennameLabel: UILabel!
    @IBOutlet weak var tweetContentsLabel: UILabel!
    @IBOutlet weak var tweetAgeLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var heightMediaImage: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingMediaImage: NSLayoutConstraint!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TwitterTableViewDelegate?
    
    public var indexPath: IndexPath!
    
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    fileprivate var retweet = false
    fileprivate var favorite = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureImageView.layer.cornerRadius = 5
        profilePictureImageView.clipsToBounds = true
        mediaImageView.layer.cornerRadius = 5
        mediaImageView.clipsToBounds = true
    }
    
    internal var viewModel: TweetCellViewModeling? {
        didSet {
            guard let viewModel = viewModel else { return }
                        
            authorNameLabel.text = viewModel.authorName
            authorScreennameLabel.text = viewModel.authorScreenName
            tweetContentsLabel.text = viewModel.tweetContents
            tweetAgeLabel.text = viewModel.getDate()
            retweetCountLabel.text = viewModel.retweetCount.description
            favoriteCountLabel.text = viewModel.favoriteCount.description
            
            viewModel.getHyperlink(tweetContentsLabel)
            
            profilePictureImageView.reactive.image <~ viewModel.getProfilePictureImageView()
            
            configMediaImage().observe(on: UIScheduler()).startWithValues({ (image) in
                self.mediaImageView.image = image
            })
            
            retweetButton.isSelected = viewModel.retweeted
            favoriteButton.isSelected = viewModel.favorited
        }
    }
    
    fileprivate func configMediaImage() -> SignalProducer<UIImage?, NoError> {
        return SignalProducer { (observer, disposable) in
            self.mediaImageView.image = nil
            guard let viewModel = self.viewModel else { return }
            if viewModel.mediaProfilePic != nil {
                for medium in viewModel.media {
                    guard let urltext = medium["url"] as? String else { return }
                    self.tweetContentsLabel.text = self.tweetContentsLabel.text?.replacingOccurrences(of: urltext, with: "")
                }
                
                self.mediaImageView.isHidden = false
                self.verticalSpacingMediaImage.constant = 8
                if self.heightMediaImage != nil {
                    self.heightMediaImage.isActive = false
                }
                
                viewModel.getMediaImageView().observe(on: UIScheduler()).startWithValues {
                    observer.send(value: $0)
                    observer.sendCompleted()
                    self.delegate?.reloadTableCellAtIndex(cell: self, indexPath: self.indexPath)
                }
            }
        }
    }
    
    @IBAction func reTweetAction(_ sender: UIButton) {
        if retweet {
            retweet = false
            twitterManager.retweet(params: ["id": viewModel?.tweetID.description as AnyObject], retweet: retweet).startWithCompleted {
                self.viewModel?.retweetCount -= 1
                self.retweetCountLabel.text = self.viewModel?.retweetCount.description
            }
        } else {
            retweet = true
            twitterManager.retweet(params: ["id": viewModel?.tweetID.description as AnyObject], retweet: retweet).startWithCompleted {
                self.viewModel?.retweetCount += 1
                self.retweetCountLabel.text = self.viewModel?.retweetCount.description
            }
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        if favorite {
            favorite = false
            twitterManager.favorite(params: ["id": viewModel?.tweetID.description as AnyObject], favorite: favorite).startWithCompleted {
                self.viewModel?.favoriteCount -= 1
                self.favoriteCountLabel.text = self.viewModel?.favoriteCount.description
            }
        } else {
            favorite = true
            twitterManager.favorite(params: ["id": viewModel?.tweetID.description as AnyObject], favorite: favorite).startWithCompleted {
                self.viewModel?.favoriteCount += 1
                self.favoriteCountLabel.text = self.viewModel?.favoriteCount.description
            }
        }
    }
    
    @IBAction func replyButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as? ComposeViewController else { return }
        vc.replyToTweet = viewModel
        delegate?.openCompose(vc)
    }
}
