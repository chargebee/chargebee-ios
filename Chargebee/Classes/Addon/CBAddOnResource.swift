//
// Created by Mac Book on 6/7/20.
//

import Foundation

class CBAddOnResource: CBAPIResource {
    typealias ModelType = AddonWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
       return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var methodPath: String = "/v2/addons"

    init(_ addonId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(addonId)"
    }

}
