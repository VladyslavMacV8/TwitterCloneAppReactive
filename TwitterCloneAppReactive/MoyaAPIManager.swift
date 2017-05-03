//
//  MoyaAPIManager.swift
//  TwitterCloneAppReactive
//
//  Created by Vladyslav Kudelia on 4/24/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift

struct Constants {
    static let baseUrl = "https://api.twitter.com"
    static let currentAccountUrl = "1.1/account/verify_credentials.json"
}

public enum APIManager {
    case currentAccount
}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        return try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
    } catch { return data }
}

let plugins = [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]

let endpointClosure = { (target: APIManager) -> Endpoint<APIManager> in
    var httpFields = [String: String]()
//    if let token = TwitterAPIManager.token {
//        httpFields["Authorization"] = "Bearer \(token)"
//    }
    
    let endpoint = Endpoint<APIManager>(url: target.baseURL.appendingPathComponent(target.path).absoluteString,
                                        sampleResponseClosure: {.networkResponse(200, target.sampleData)},
                                        method: target.method,
                                        parameters: target.parameters,
                                        httpHeaderFields: [:])
    switch target.method {
    case .get:
        return endpoint.adding(newParameterEncoding: URLEncoding.default)
    default:
        return endpoint
    }
}

let requestClosure = { (endpoint: Endpoint<APIManager>, done: @escaping ReactiveSwiftMoyaProvider<APIManager>.RequestResultClosure) in
    guard var request = endpoint.urlRequest else { return }
    
//    if let token = TwitterAPIManager.token {
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    }
    
    done(.success(request))
}

let provider = ReactiveSwiftMoyaProvider<APIManager>(/*endpointClosure: endpointClosure,*/ requestClosure: requestClosure, plugins: plugins)

extension APIManager: TargetType {
    public var baseURL: URL { return URL(string: Constants.baseUrl)! }
    
    public var path: String {
        switch self {
        case .currentAccount:
            return Constants.currentAccountUrl
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .currentAccount:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        var value = [String: Any]()
        switch self {
        case .currentAccount:
            value = [:]
        }
        return value
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .currentAccount:
            return URLEncoding.default
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task { return .request }
    
    public var validate: Bool { return true }
}
