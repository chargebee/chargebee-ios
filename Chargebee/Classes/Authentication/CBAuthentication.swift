//
//  CBAuthentication.swift
//  Chargebee
//
//  Created by Imayaselvan on 23/06/21.
//

import Foundation


public typealias CBAuthenticationHandler = (CBResult<CBAuthenticationStatus>) -> Void

public class CBAuthenticationManager {}

public extension CBAuthenticationManager {
    
    // MARK : - Public Helpers
    static func isSDKKeyPresent() -> Bool {
        return CBEnvironment.sdkKey.isNotEmpty
    }
   
    static func isCatalogV1() -> Bool {
        return CBEnvironment.sdkKey.isNotEmpty
    }

    static func isSDKKeyValid(_ completion: @escaping ((_ status: Bool) -> Void)) {
        authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
            switch result {
            case let .success(data):
                completion(data.details.appId?.isNotEmpty ?? false)
            case .error:
                completion(false)
            }
        }
    }
    
    static func authenticate(forSDKKey key: String, handler: @escaping CBAuthenticationHandler) {
        let logger = CBLogger(name: "Authentication", action: "Authenticate SDK Key")
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)

        guard let appName = Bundle.main.displayName ,let bundleId = Bundle.main.bundleIdentifier  else {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "AppName is empty"))
        }
        
        guard key.isNotEmpty else {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "SDK Key is empty"))
        }
        let request = CBAPIRequest(resource: CBAuthenticationResource(key: key, bundleId: bundleId, appName: appName))
        request.load(withCompletion: { status in
            onSuccess(status)
        }, onError: onError)
    }
    
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}



