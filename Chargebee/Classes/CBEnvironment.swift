//
// Created by Mac Book on 9/7/20.
//

import Foundation

class CBEnvironment {
    static var site: String = ""
    static var apiKey: String = ""
    static var encodedApiKey: String = ""
    static var baseUrl: String = ""

    static func configure(site: String, apiKey: String) {
        CBEnvironment.site = site
        CBEnvironment.apiKey = apiKey
        CBEnvironment.encodedApiKey = CBEnvironment.apiKey.data(using: .utf8)?.base64EncodedString() ?? ""
        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"
    }
}
