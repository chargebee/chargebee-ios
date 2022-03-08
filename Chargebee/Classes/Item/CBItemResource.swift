//
//  CBItemManager.swift
//  Chargebee
//
//  Created by Harish Bharadwaj on 22/07/21.
//

import Foundation

final class CBItemResource: CBAPIResource {

    typealias ModelType = CBItemWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var methodPath: String = "/v2/items"

    init(_ itemId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(itemId)"
    }

}
