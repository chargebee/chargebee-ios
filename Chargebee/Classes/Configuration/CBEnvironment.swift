//
// Created by Mac Book on 9/7/20.
//

import Foundation

class CBEnvironment {
    static var site: String = ""
    static var apiKey: String = ""
    static var encodedApiKey: String = ""
    static var baseUrl: String = ""
    static var allowErrorLogging: Bool = true
    static var sdkKey: String = ""
    static var version: CatalogVersion = .unknown
    static var session = URLSession.shared

    func configure(site: String, apiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil) {
        CBEnvironment.site = site
        CBEnvironment.apiKey = apiKey
        CBEnvironment.allowErrorLogging = allowErrorLogging
        CBEnvironment.encodedApiKey = CBEnvironment.apiKey.data(using: .utf8)?.base64EncodedString() ?? ""
        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"
        CBEnvironment.version = .unknown

        if let sdkKey = sdkKey {
            CBEnvironment.sdkKey = sdkKey
            // Verify SDK Key and Setup the Environment
            CBAuthenticationManager().authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
                switch result {
                case .success(let status):
                    print("Environment Setup - Completed")
                    print("Note: pre-requisites configuration is mandatory for SDK to work. Learn more(https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html)")
                    CBEnvironment.version = status.details.version ?? .unknown
                case .error(let error):
                    print(error)
                    print("Note: pre-requisites configuration is mandatory for SDK to work. Learn more(https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html)")
                    CBEnvironment.version = .unknown
                }
            }
        }

    }

}
