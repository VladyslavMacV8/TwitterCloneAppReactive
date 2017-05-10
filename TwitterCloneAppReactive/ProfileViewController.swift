//
//  ProfileViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/31/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveSwift
import SwiftSpinner

public final class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TwitterTableViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    fileprivate let realmManager: RealmProtocol = RealmManager()
    fileprivate let homeViewModel: HomeTableViewModeling = HomeTableViewModel()
    fileprivate let userViewModel: ProfileViewModeling = ProfileViewModel()
    
    fileprivate var userModeling: ProfileViewModeling?
    fileprivate var refreshControl = UIRefreshControl()
    
    public var userScreenName: String!
    
    override public var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        setupView()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.userScreenName == nil {
            userModeling = ProfileViewModel(user: realmManager.getCurrentUser())
            setupConfig()
        } else {
            SwiftSpinner.show("Initialization...")
            twitterManager.userByScreenName(screenName: userScreenName).observe(on: UIScheduler()).on(value: { (user) in
                self.userModeling = ProfileViewModel(user: user)
            }).startWithCompleted {
                SwiftSpinner.hide({ 
                    self.setupConfig()
                })
            }
        }
    }
    
    fileprivate func setupConfig() {
        guard let user = userModeling else { return }
        
        if let backgorundImageUrl = URL(string: user.backgroundImageURL.value) {
            backgroundImageView.kf.setImage(with: backgorundImageUrl, placeholder: UIImage(named: "bg"), options: [.backgroundDecode])
        }
        
        if let profileUrl = URL(string: user.profileUrl.value) {
            profileImageView.kf.setImage(with: profileUrl, options: [.backgroundDecode])
        }
        
        nameLabel.reactive.text <~ user.name
        screenNameLabel.reactive.text <~ user.screenName
        followersCountLabel.reactive.text <~ user.followersCount
        followingCountLabel.reactive.text <~ user.followingCount

        if user.screenName.value != "@" + realmManager.getCurrentUser().screenName {
            logOutButton.isHidden = true
            closeButton.isHidden = false
        } else {
            logOutButton.isHidden = false
            closeButton.isHidden = true
        }
        
        reloadData()
    }
    
    fileprivate func setupView() {
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        closeButton.layer.cornerRadius = closeButton.frame.height / 4
        closeButton.clipsToBounds = true
        
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.rowHeight = UITableViewAutomaticDimension
        userTableView.estimatedRowHeight = view.bounds.width
        userTableView.allowsSelection = false
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        userTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc fileprivate func reloadData() {
        guard let user = userModeling else { return }
        userViewModel.userTimeline(id: user.id.value)
        userViewModel.cellModels.producer.on { _ in self.userTableView.reloadData() }.start()
        refreshControl.endRefreshing()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModel.cellModels.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! TweetCell
        cell.delegate = self
        cell.viewModel = userViewModel.cellModels.value[indexPath.row]
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if userScreenName == nil {
            return true
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tweet = userViewModel.cellModels.value[indexPath.row]
            twitterManager.deleteTweet(tweetId: tweet.tweetID.description).observe(on: UIScheduler()).startWithCompleted {
                self.reloadData()
            }
        }
    }
    
    func reloadTableCellAtIndex(_ cell: UITableViewCell) {
        guard let newIndex = userTableView.indexPath(for: cell) else { return }
        DispatchQueue.main.async { self.userTableView.reloadRows(at: [newIndex], with: .none) }
    }
    
    func openCompose(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    @IBAction func logOutButtonAction(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelActionButton)
        let logOutActionButton = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            self.twitterManager.logout().observe(on: UIScheduler()).startWithCompleted {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LoginViewController {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        actionSheetController.addAction(logOutActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
