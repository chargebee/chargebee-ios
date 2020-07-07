//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class PlanResource: APIResource {
    typealias ModelType = PlanWrapper
    var authHeader: String
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2"
    let methodPath: String
    
    init(key: String, _ planId: String) {
        let encodedKey = key.data(using: .utf8)?.base64EncodedString() ?? ""
        self.authHeader = "Basic \(encodedKey)"
        self.methodPath = "/plans/\(planId)"
    }
}
