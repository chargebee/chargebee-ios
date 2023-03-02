//
//  CBValidateReceiptResource.swift
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
        return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    var methodPath: String {
        return "/v2/in_app_subscriptions/\(CBEnvironment.sdkKey)/process_purchase_command"
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
        self.requestBody = PayloadBody(receipt: receipt.token, productId: receipt.productID, name: receipt.name,
                                       price: receipt.price, currencyCode: receipt.currencyCode,
                                       customerId: receipt.customer?.customerID ?? "", period: "\(receipt.period)", periodUnit: "\(receipt.periodUnit)",firstName: receipt.customer?.firstName ?? "",lastName: receipt.customer?.lastName ?? "", email: receipt.customer?.email ?? "")
    }

}

struct PayloadBody: URLEncodedRequestBody {
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
            "customer[email]": email
        ]
    }
}
