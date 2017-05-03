//
//  Support.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/26/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Alamofire

func alertControllerWith(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(alertAction)
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
}

func requestImage(_ url: String) -> SignalProducer<UIImage, NoError> {
    return SignalProducer { observer, disposable in
        Alamofire.request(url, method: .get).response(queue: DispatchQueue.main, responseSerializer: Alamofire.DataRequest.dataResponseSerializer()) { response in
            switch response.result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    observer.sendInterrupted()
                    return
                }
                observer.send(value: image)
                observer.sendCompleted()
            case .failure:
                observer.sendInterrupted()
            }
        }
    }
}

extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
}
