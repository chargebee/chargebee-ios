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
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2/tokens/create_using_temp_token"
    let methodPath: String = ""

    init() {
        let encodedKey = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah".data(using: .utf8)?.base64EncodedString() ?? ""
        self.authHeader = "Basic \(encodedKey)"
    }
    
}
