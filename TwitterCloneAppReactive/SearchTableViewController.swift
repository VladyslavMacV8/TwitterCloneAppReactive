//
//  SearchTableViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import RealmSwift

public final class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!

    fileprivate var newUsers: [ProfileViewModeling]?
    fileprivate let realmManager: RealmProtocol = RealmManager()
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        tableView.allowsSelection = false
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        twitterManager.currentAccount().startWithValues { (user) in
            self.realmManager.setCurrentUser(user)
        }
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newUsers == nil ? 0 : newUsers!.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        cell.buttonTap = { self.reloadData() }
        cell.viewModel = newUsers?[indexPath.row]
        
        return cell
    }
    
    fileprivate func reloadData() {
        twitterManager.searchNewUser(query: searchTextField.text!).startWithValues { (newUsers) in
            var users = [ProfileViewModeling]([])
            for user in newUsers {
                users.append(ProfileViewModel(user: user))
            }
            self.newUsers = users
            self.tableView.reloadData()
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func searchBarButtonAction(_ sender: UIBarButtonItem) {
        guard let count = searchTextField.text?.characters.count else { return }
        if count > 2 && count < 15 {
            reloadData()
        }
    }
}
