//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class AddonResource: APIResource {
    typealias ModelType = AddonWrapper
    typealias ErrorType = CBErrorDetail
    
    var authHeader: String
    var baseUrl: String
    var methodPath: String = "/v2/addons"

    init() {
        self.authHeader = "Basic \(CBEnvironment.encodedApiKey)"
        self.baseUrl = CBEnvironment.baseUrl
    }

    func setAddon(_ addonId: String) {
        self.methodPath = self.methodPath + "/\(addonId)"
    }

}
