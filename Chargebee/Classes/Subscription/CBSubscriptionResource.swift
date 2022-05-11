//
//  Supscribtion.swift
//  Chargebee
//
//  Created by Imayaselvan on 24/05/21.
//

import Foundation

final class CBSubscriptionResource: CBAPIResource {
    typealias ModelType = CBSubscriptionStatus
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        return    "Basic \(CBEnvironment.encodedApiKey)"
    }

    var baseUrl: String

    var methodPath: String = "/v2/in_app_subscriptions"

    init(_ subscriptionId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(subscriptionId)"
    }

    var url: URLRequest {
        var components = URLComponents(string: baseUrl)
        components!.path += methodPath
        var urlRequest = URLRequest(url: components!.url!)
        urlRequest.httpMethod = "get"
        urlRequest.addValue(authHeader!, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        urlRequest.addValue(sdkVersion, forHTTPHeaderField: "version")
        urlRequest.addValue(platform, forHTTPHeaderField: "platform")
        return urlRequest
    }

}

final class SubscriptionResource: CBAPIResource {

    typealias ModelType = CBSubscriptionWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        return   "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var methodPath: String = "/v2/in_app_subscriptions"
    var queryParams: [String: String]?

    init(queryParams: [String: String]? = nil) {
        self.baseUrl = CBEnvironment.baseUrl
        if let queryParams = queryParams {
            self.queryParams = queryParams
        }
    }

}
