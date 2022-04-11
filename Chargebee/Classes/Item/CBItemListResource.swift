//
//  CBItemManager.swift
//  Chargebee
//
//  Created by Harish Bharadwaj on 22/07/21.
//

import Foundation

final class CBItemListResource: CBAPIResource {

    typealias ModelType = CBItemListWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var methodPath: String = "/v2/items"
    var queryParams: [String: String]?

    init(queryParams: [String: String]? = nil) {
        self.baseUrl = CBEnvironment.baseUrl
        if let queryParams = queryParams {
            self.queryParams = queryParams
        }
    }

}
