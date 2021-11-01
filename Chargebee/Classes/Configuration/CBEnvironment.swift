//
// Created by Mac Book on 9/7/20.
//

import Foundation

class CBEnvironment {
    static var site: String = ""
    static var publishableApiKey: String = ""
    static var encodedApiKey: String = ""
    static var baseUrl: String = ""
    static var allowErrorLogging: Bool = true
    static var sdkKey : String = ""
    static var version : CatalogVersion = .unknown

    static func configure(site: String, publishableApiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil, completion: (() -> Void)?) {
        CBEnvironment.site = site
        CBEnvironment.publishableApiKey = publishableApiKey
        CBEnvironment.allowErrorLogging = allowErrorLogging
        CBEnvironment.encodedApiKey = CBEnvironment.publishableApiKey.data(using: .utf8)?.base64EncodedString() ?? ""
//        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"
        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"

        if let sdkKey = sdkKey {
            CBEnvironment.sdkKey = sdkKey
            // Verify SDK Key
            CBAuthenticationManager.authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
                switch result {
                case .success(let status):
                    CBEnvironment.version = status.details.version ?? .unknown
                case .error(let error):
                    print(error)
                    CBEnvironment.version = .unknown
                }
                completion?()
            }
        } 
        
        
    }
    
}
