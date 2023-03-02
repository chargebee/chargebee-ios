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
    static var environment: String = "cb_ios_sdk"
    

    func configure(site: String, apiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil) {
        let resultHandler: CBAuthenticationHandler = { result in
                switch result {
                case .success(let status):
                    debugPrint("Environment Setup - Completed")
                    CBEnvironment.version = status.details.version ?? .unknown
                case .error(let error):
                    debugPrint(error)
                    CBEnvironment.version = .unknown
                }
            }
        authenticate(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey, resultHandler: resultHandler)
    }
    
    func configure(site: String, apiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil, handler: @escaping CBAuthenticationHandler) {
            let resultHandler: CBAuthenticationHandler = { result1 in
                let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
                switch result1 {
                case .success(let status):
                    debugPrint("Environment Setup - Completed")
                    CBEnvironment.version = status.details.version ?? .unknown
                    onSuccess(status)
                case .error(let error):
                    debugPrint(error)
                    CBEnvironment.version = .unknown
                    onError(error)
                }
            }
            
        authenticate(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey, resultHandler: resultHandler)
        }
        
        private func authenticate(site: String, apiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil, resultHandler: CBAuthenticationHandler? = nil) {
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
                    resultHandler?(result)
                    }
                }
            }

}
