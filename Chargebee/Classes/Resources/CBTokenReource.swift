//
//  CBTokenReource.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class CBTokenResource: APIResource {
    typealias ModelType = TokenWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String
    var baseUrl: String
    let methodPath: String = "/v2/tokens/create_using_temp_token"

    init() {
        self.authHeader = "Basic \(CBEnvironment.encodedApiKey)"
        self.baseUrl = CBEnvironment.baseUrl
    }
    
}
