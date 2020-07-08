//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class AddonResource: APIResource {
    typealias ModelType = AddonWrapper
    typealias ErrorType = CBErrorDetail
    
    var authHeader: String
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2"
    var methodPath: String = "/addons"

    init(key: String) {
        let encodedKey = key.data(using: .utf8)?.base64EncodedString() ?? ""
        self.authHeader = "Basic \(encodedKey)"
    }

    func setAddon(_ addonId: String) {
        self.methodPath = self.methodPath + "/\(addonId)"
    }

}
