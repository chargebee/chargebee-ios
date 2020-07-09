//
// Created by Mac Book on 7/7/20.
//

import Foundation

class CBPaymentConfigResource: APIResource {
    typealias ModelType = CBWrapper
    typealias ErrorType = CBInternalErrorWrapper

    var baseUrl: String
    var authHeader: String
    var methodPath: String = "/internal/component/retrieve_config"
    var header: [String: String]? = ["X-Requested-With":"XMLHttpRequest"]
    
    init() {
        self.authHeader = "Basic \(CBEnvironment.apiKey)"
        self.baseUrl = CBEnvironment.baseUrl
    }
}
