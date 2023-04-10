//
//  CBValidateNonSubscriptionResource.swift
//  Chargebee
//
//  Created by ramesh_g on 14/03/23.
//

import Foundation


@available(macCatalyst 13.0, *)
class CBValidateNonSubscriptionResource: CBAPIResource {
    typealias ModelType = CBValidateNonSubscriptionReceiptWrapper
    typealias ErrorType = CBErrorDetail
    
    var components: URLComponents!
    var urlRequest: URLRequest!
    
    var authHeader: String? {
        return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    var methodPath: String {
        return "/v2/non_subscriptions/\(CBEnvironment.sdkKey)/one_time_purchase"
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
    
    init(receipt: CBReceipt ) {
        self.baseUrl = CBEnvironment.baseUrl
        self.requestBody = Payload(receipt: receipt.token, productId: receipt.productID, name: receipt.name,
                                   price: receipt.price, currencyCode: receipt.currencyCode,
                                   customerId: receipt.customer?.customerID ?? "", period: "\(receipt.period)", periodUnit: "\(receipt.periodUnit)",firstName: receipt.customer?.firstName ?? "",lastName: receipt.customer?.lastName ?? "", email: receipt.customer?.email ?? "",type: receipt.productType?.rawValue ?? "")
    }
    
}

struct Payload: URLEncodedRequestBody {
    let receipt: String
    let productId: String
    let name: String
    let price: String
    let currencyCode: String
    let customerId: String
    let period: String
    let periodUnit: String
    let firstName: String
    let lastName: String
    let email: String
    let type: String
    func toFormBody() -> [String: String] {
        [
            "receipt": receipt,
            "product[id]": productId,
            "product[name]": name,
            "product[price_in_decimal]": price,
            "product[currency_code]": currencyCode,
            "product[period]": period,
            "product[period_unit]": periodUnit,
            "customer[id]": customerId,
            "customer[first_name]": firstName,
            "customer[last_name]": lastName,
            "customer[email]": email,
            "product[type]": type
            
        ]
    }
}

