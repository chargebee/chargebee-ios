
//
//  CBRestoreServiceManager.swift
//  Chargebee
//
//  Created by ramesh_g on 20/02/23.
//

import Foundation
import StoreKit

final class CBRestoreResource: CBAPIResource {
    typealias ModelType = CBRestorePurchase
    typealias ErrorType = CBErrorDetail
    
    var components: URLComponents!
    var urlRequest: URLRequest!
    
    var authHeader: String? {
        return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    var methodPath: String {
        return  "/v2/in_app_subscriptions/\(CBEnvironment.sdkKey)/retrieve"
    }
    
    private func buildBaseRequest() -> URLRequest {
        if let component = URLComponents(string: baseUrl) {
            components =  component
            components.path += methodPath
        }
        if let reqUrl = components?.url {
            urlRequest = URLRequest(url: (reqUrl))
        }
        if let authHeader = authHeader {
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        header?.forEach({ (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })
        urlRequest.addValue(sdkVersion, forHTTPHeaderField: "version")
        urlRequest.addValue(platform, forHTTPHeaderField: "platform")
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
        let bodyData = requestBody?.toFormBody().filter({!$0.value.isEmpty})
        if let data = bodyData {
            bodyComponents.queryItems = data.compactMap({ (key, value) -> URLQueryItem in
                URLQueryItem(name: key,
                             value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!.replacingOccurrences(of: "+", with: "%2B"))
            })
        }
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        return urlRequest
    }
    
    init(receipt: String ) {
        self.baseUrl = CBEnvironment.baseUrl
        self.requestBody = PayloadBodyData(receipt: receipt)
    }
}
struct PayloadBodyData: URLEncodedRequestBody {
    let receipt: String
    func toFormBody() -> [String: String] {
        [
            "receipt": receipt
        ]
    }
}
