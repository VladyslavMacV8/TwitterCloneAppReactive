//
//  ComposeViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/3/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveSwift

public final class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var replayScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var countCharacterLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    fileprivate let realmManager: RealmProtocol = RealmManager()
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    
    fileprivate var user: ProfileViewModeling!
    
    public var replyToTweet: TweetCellViewModeling!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConfiguration()
    }
    
    fileprivate func setupView() {
        photoImageView.layer.cornerRadius = 5
        photoImageView.clipsToBounds = true
        
        tweetTextView.delegate = self
        tweetTextView.layer.cornerRadius = 5
        tweetTextView.clipsToBounds = true
        
        countCharacterLabel.text = "50"
        
        sendButton.layer.cornerRadius = 5
        closeButton.layer.cornerRadius = 5
    }
    
    fileprivate func setupConfiguration() {
        user = ProfileViewModel(user: realmManager.getCurrentUser())
        
        if let url = URL(string: user.profileUrl.value) {
            photoImageView.kf.setImage(with: url, options: [.backgroundDecode])
        }
        
        nameLabel.reactive.text <~ user.name
        screenNameLabel.reactive.text <~ user.screenName
        
        if replyToTweet == nil {
            replayScreenNameLabel.text = ""
        } else {
            replayScreenNameLabel.isHidden = false
            replayScreenNameLabel.text = replyToTweet.authorScreenName + ":"
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What happened?" {
            textView.text = ""
            textView.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
        textView.becomeFirstResponder()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What happened?"
            textView.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
        textView.resignFirstResponder()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        let total = 140 - count
        if total >= 0 {
           countCharacterLabel.text = total.description
        }
        
        if total < 0 || total == 50 {
            sendButton.isHidden = true
            countCharacterLabel.textColor = .red
        } else {
            sendButton.isHidden = false
            countCharacterLabel.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        guard var composedText = tweetTextView.text else { return }
        
        if replyToTweet == nil {
            var apiParams: [String: AnyObject] = [:]
            apiParams["status"] = composedText as AnyObject
            
            twitterManager.publishTweet(params: apiParams).observe(on: UIScheduler()).startWithCompleted {
                self.presentViewController()
            }
            
        } else {
            composedText = replyToTweet.authorScreenName + ":" + composedText
            
            twitterManager.replyToTweet(text: composedText, replyToTweetID: replyToTweet.tweetID).observe(on: UIScheduler()).startWithCompleted {
                self.presentViewController()
            }
        }
    }
    
    fileprivate func presentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController") as? UITabBarController {
            self.present(vc, animated: true, completion: nil)
        }
    }

}
