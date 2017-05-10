//
//  SearchTableViewCell.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveSwift

internal final class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    
    internal var buttonTap:(()->())?
    
    internal var viewModel: ProfileViewModeling? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            if let url = URL(string: viewModel.backgroundImageURL.value) {
                photoImageView.kf.setImage(with: url, options: [.backgroundDecode])
            }
            
            nameLabel.reactive.text <~ viewModel.name
            screenNameLabel.reactive.text <~ viewModel.screenName
            
            if let follow = viewModel.isFollow.value, !follow {
                followButton.isHidden = false
            } else {
                followButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 5
        photoImageView.clipsToBounds = true
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
    }
    
    @IBAction func followButtonAction(_ sender: UIButton) {
        guard let viewModel = viewModel else { return }
        twitterManager.followNewUser(screenName: viewModel.screenName.value).startWithCompleted {
            self.buttonTap?()
            self.followButton.isHidden = true
        }
    }
}
