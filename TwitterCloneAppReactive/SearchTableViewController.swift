//
//  SearchTableViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

public final class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!

    fileprivate let searchViewModel: SearchViewModeling = SearchViewModel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        tableView.allowsSelection = false
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchViewModel.startUpdateCurrentUser()
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cellModels.value.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        cell.buttonTap = {
            self.searchViewModel.updateUsersList(label: self.searchTextField).startWithCompleted {
                self.tableView.reloadData()
            }
        }
        cell.viewModel = searchViewModel.cellModels.value[indexPath.row]
        
        return cell
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func searchBarButtonAction(_ sender: UIBarButtonItem) {
        guard let count = searchTextField.text?.characters.count else { return }
        if count > 2 && count < 15 {
            self.searchViewModel.updateUsersList(label: searchTextField).startWithCompleted {
                self.tableView.reloadData()
            }
        }
    }
}
