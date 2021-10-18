//
//  CBValidateReceiptResource.swift
//  FakeGame
//
//  Created by cb-christopher on 19/04/21.
//  Copyright © 2021 Chargebee. All rights reserved.
//

import Foundation
@available(macCatalyst 13.0, *)
class CBValidateReceiptResource: CBAPIResource {
    typealias ModelType = CBValidateReceiptWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        get {
            return "Basic \(CBEnvironment.encodedApiKey)"
        }
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    var methodPath: String {
        get {
            return "/v2/in_app_subscriptions/\(CBEnvironment.sdkKey)/process_purchase_command"
        }
    }

    private func buildBaseRequest() -> URLRequest {
        var components = URLComponents(string: baseUrl)
        components!.path += methodPath
        var urlRequest = URLRequest(url: components!.url!)
        if let authHeader = authHeader {
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        header?.forEach({ (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })
        return urlRequest
    }
    
    func create() -> URLRequest {
        return createRequest()

    }

    func createRequest() -> URLRequest {
        var urlRequest = buildBaseRequest()
        urlRequest.httpMethod = "post"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = requestBody?.toFormBody().map({ (key, value) -> URLQueryItem in
          URLQueryItem(name: key,
                 value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!.replacingOccurrences(of: "+", with: "%2B"))
        })
        
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        return urlRequest
      }
    
    init(receipt: String, productId: String,
         price: String, currencyCode : String,
         customerId : String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.requestBody = PayloadBody(receipt: receipt, productId: productId,
                                       price: price, currencyCode : currencyCode,
                                       customerId : customerId)
    }

}

struct PayloadBody: URLEncodedRequestBody {
    let receipt: String
    let productId: String
    let price: String
    let currencyCode : String
    let customerId : String
    let channel : String = "app_store"

    func toFormBody() -> [String: String] {
        [
            "receipt" : receipt,
            "product[id]" : productId,
            "product[price]" :price,
            "product[currency_code]" :currencyCode,
            "customer[id]" :customerId,
            "channel": channel
        ]
    }
}

