//
//  CBEntitlementResource.swift
//  Chargebee
//
//  Created by Imay on 26/08/22.
//

import Foundation

final class CBEntitlementResource: CBAPIResource {
    typealias ModelType = CBEntitlementWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        return    "Basic \(CBEnvironment.encodedApiKey)"
    }

    var baseUrl: String

    var methodPath: String = "/v2/subscriptions"

    init(_ subscriptionId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(subscriptionId)/subscription_entitlements"
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

