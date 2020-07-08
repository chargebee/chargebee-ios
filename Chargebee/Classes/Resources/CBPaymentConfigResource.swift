//
// Created by Mac Book on 7/7/20.
//

import Foundation

class CBPaymentConfigResource: APIResource {
    typealias ModelType = CBWrapper
    typealias ErrorType = CBErrorDetail

    var methodPath: String = "/internal/component/retrieve_config"
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api"
    var authHeader: String
    var header: [String: String]? = ["X-Requested-With":"XMLHttpRequest"]
    
    init(key: String) {
        self.authHeader = "Basic \(key)"
    }
}
