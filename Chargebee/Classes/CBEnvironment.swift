//
// Created by Mac Book on 9/7/20.
//

import Foundation

class CBEnvironment {
    static var site: String = ""
    static var publishableApiKey: String = ""
    static var encodedApiKey: String = ""
    static var baseUrl: String = ""

    static func configure(site: String, publishableApiKey: String) {
        CBEnvironment.site = site
        CBEnvironment.publishableApiKey = publishableApiKey
        CBEnvironment.encodedApiKey = CBEnvironment.publishableApiKey.data(using: .utf8)?.base64EncodedString() ?? ""
        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"
    }
}
