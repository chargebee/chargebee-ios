//
//  CBAuthentication.swift
//  Chargebee
//
//  Created by Imayaselvan on 23/06/21.
//

import Foundation

public typealias CBAuthenticationHandler = (CBResult<CBAuthenticationStatus>) -> Void

class CBAuthenticationManager {}

extension CBAuthenticationManager {

    // MARK: - Public Helpers
    static func isSDKKeyPresent() -> Bool {
        return CBEnvironment.sdkKey.isNotEmpty
    }

    static func isCatalogV1() -> Bool {
        return CBEnvironment.sdkKey.isNotEmpty
    }

    func isSDKKeyValid(_ completion: @escaping ((_ status: Bool) -> Void)) {
        authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
            switch result {
            case let .success(data):
                completion(data.details.appId?.isNotEmpty ?? false)
            case .error:
                completion(false)
            }
        }
    }

    func authenticate(forSDKKey key: String, handler: @escaping CBAuthenticationHandler) {
        let logger = CBLogger(name: "Authentication", action: "Authenticate SDK Key")
        logger.info()
        let (_, onError) = CBResult.buildResultHandlers(handler, logger)

        guard let appName = Bundle.main.displayName, let bundleId = Bundle.main.bundleIdentifier  else {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "AppName is empty"))
        }

        guard key.isNotEmpty else {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "SDK Key is empty"))
        }
        
        if CBCache.shared.isCacheDataAvailable() {
            CBCache.shared.readConfigDetails(logger: logger) { status in
                handler(status)
            } onError: { error in
                let request = CBAPIRequest(resource: CBAuthenticationResource(key: key, bundleId: bundleId, appName: appName))
                self.authenticateRestClient(network: request, logger: logger, handler: handler)
            }
        }else{
            let request = CBAPIRequest(resource: CBAuthenticationResource(key: key, bundleId: bundleId, appName: appName))
            authenticateRestClient(network: request, logger: logger, handler: handler)
        }
    }
    
    func authenticateRestClient<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping CBAuthenticationHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { status in
            if let data = status as? CBAuthenticationStatus {
                CBCache.shared.saveAuthenticationDetails(data: data)
                onSuccess(data)
            }
        }, onError: onError)
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
