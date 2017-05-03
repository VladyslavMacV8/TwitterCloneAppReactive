//
//  LoginViewController.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/25/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import SwiftSpinner

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    fileprivate let twitterManager: TwitterProtocol = TwitterAPIManager()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    fileprivate func config() {
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        twitterManager.authenticateAction.events.observe(on: UIScheduler()).observeValues { (event) in
            SwiftSpinner.hide()
            switch event {
            case .completed:
                goToNextController("TabViewController")
            case .failed(let error):
                alertControllerWith(error.localizedDescription)
            case .interrupted:
                alertControllerWith("Other Error")
            default: break
            }
        }
        
        loginButton.reactive.controlEvents(.touchUpInside).observe { _ in
            SwiftSpinner.show("Authentication...")
        }
        
        loginButton.reactive.pressed = twitterManager.authenticateCocoaAction
    }
}