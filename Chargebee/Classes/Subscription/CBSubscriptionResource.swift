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
        get {
          "Basic \(CBEnvironment.encodedApiKey)"
        }
    }
    
    var baseUrl: String
    
    var methodPath: String = "/v2/in_app_subscriptions"
    
    init(_ subscriptionId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(subscriptionId)"
    }
   
    var url: URLRequest {
        get {
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


}
