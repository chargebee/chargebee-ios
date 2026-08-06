//
// Created by Mac Book on 9/7/20.
//

import Foundation

/// Closure supplied by the App, which is responsible for returning a fresh mobile token from the server.
/// The SDK invokes it during configure and whenever a request fails with a 401. The Server must mint a token via
/// `create_mobile_token` and return the raw token to the App.
public typealias CBMobileTokenProvider = (@escaping (String?) -> Void) -> Void

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
    // When a mobile token is present, the SDK sends it for the `Authorization` similar to the publishable key.
    // If empty, we fall back to the publishable key flow.
    static var mobileToken: String = ""
    static var tokenProvider: CBMobileTokenProvider?
    static var encodedMobileToken: String {
        return mobileToken.data(using: .utf8)?.base64EncodedString() ?? ""
    }

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

    // Mobile token flow: the SDK is configured without a publishable key. We fetch a token from
    // the App's token provider and then verify the app details using it. If successful, the SDK is ready to use.
    func configure(site: String, sdkKey: String? = nil, allowErrorLogging: Bool, tokenProvider: @escaping CBMobileTokenProvider, handler: @escaping CBAuthenticationHandler) {
        CBEnvironment.site = site
        CBEnvironment.apiKey = ""
        CBEnvironment.encodedApiKey = ""
        CBEnvironment.allowErrorLogging = allowErrorLogging
        CBEnvironment.baseUrl = "https://\(site).chargebee.com/api"
        CBEnvironment.version = .unknown
        CBEnvironment.tokenProvider = tokenProvider
        if let sdkKey = sdkKey {
            CBEnvironment.sdkKey = sdkKey
        }

        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
        CBEnvironment.refreshMobileToken { success in
            guard success else {
                return onError(CBError.defaultSytemError(statusCode: 401, message: "Unable to fetch a mobile token from the token provider"))
            }
            guard CBEnvironment.sdkKey.isNotEmpty else {
                // Nothing to verify without an SDK key; environment is ready.
                return onSuccess(CBAuthenticationStatus(details: CBAuthentication(appId: nil, status: "ok", version: .unknown)))
            }
            CBAuthenticationManager().authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
                switch result {
                case .success(let status):
                    CBEnvironment.version = status.details.version ?? .unknown
                    onSuccess(status)
                case .error(let error):
                    CBEnvironment.version = .unknown
                    onError(error)
                }
            }
        }
    }

    // Fetches a fresh token from the App's token provider and stores it.
    static func refreshMobileToken(completion: @escaping (Bool) -> Void) {
        guard let provider = tokenProvider else {
            return completion(false)
        }
        provider { token in
            if let token = token, token.isNotEmpty {
                CBEnvironment.mobileToken = token
                completion(true)
            } else {
                completion(false)
            }
        }
    }

}
