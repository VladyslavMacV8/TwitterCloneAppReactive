//
//  HomeTableViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveSwift

public final class HomeTableViewController: UITableViewController, TwitterTableViewDelegate {
    
    fileprivate let homeViewModel: HomeTableViewModeling = HomeTableViewModel()
    fileprivate let realmManager: RealmProtocol = RealmManager()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        reloadData()
        setupRefreshControl()
        setupLogo(imageNamed: "Icon-Twitter")
    }
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = view.bounds.width
    }
    
    fileprivate func setupLogo(imageNamed: String) {
        let imageView = UIImageView(image: UIImage(named: imageNamed))
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)
    }
    
    @objc fileprivate func reloadData() {
        homeViewModel.startUpdate().observe(on: UIScheduler()).start()
        homeViewModel.cellModels.producer.on { _ in self.tableView.reloadData() }.start()
        refreshControl?.endRefreshing()
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.cellModels.value.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! TweetCell
        cell.delegate = self
        cell.viewModel = homeViewModel.cellModels.value[indexPath.row]
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenName = homeViewModel.cellModels.value[indexPath.row].authorScreenName.chopPrefix()
        if screenName != realmManager.getCurrentUser().screenName {
            openProfile(screenName)
        }
    }
    
    func reloadTableCellAtIndex(_ cell: UITableViewCell) {
        guard let newIndex = tableView.indexPath(for: cell) else { return }
        DispatchQueue.main.async { self.tableView.reloadRows(at: [newIndex], with: .none) }
    }
    
    func openProfile(_ userScreenName: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? UINavigationController,
            let pVC = vc.viewControllers.first as? ProfileViewController {
            pVC.userScreenName = userScreenName
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func openCompose(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

