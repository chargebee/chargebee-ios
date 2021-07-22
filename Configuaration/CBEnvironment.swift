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
    //static var customerID: String = ""
    
    
    static func configure(site: String, publishableApiKey: String, allowErrorLogging: Bool, sdkKey: String? = nil) {
        CBEnvironment.site = site
        CBEnvironment.publishableApiKey = publishableApiKey
        CBEnvironment.allowErrorLogging = allowErrorLogging
        CBEnvironment.encodedApiKey = CBEnvironment.publishableApiKey.data(using: .utf8)?.base64EncodedString() ?? ""
        //        CBEnvironment.baseUrl = "https://\(CBEnvironment.site).chargebee.com/api"
        //Fix Me : For internal testing
        CBEnvironment.baseUrl = "https://\(CBEnvironment.site)/api"
        
        //Verify SDK key
        if let _sdkKey = sdkKey {
            CBEnvironment.sdkKey = _sdkKey
            CBAuthenticationManager.authenticate(forSDKKey: sdkKey!) { result in
                switch result {
                case .success(let status):
                    debugPrint(status)
                case .error(let error):
                    debugPrint(error)
                }
                
            }
        }
    }
    
}
