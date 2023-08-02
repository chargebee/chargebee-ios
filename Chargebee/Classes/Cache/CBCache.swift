//
//  CBCache.swift
//  Chargebee
//
//Created by ramesh_g on 28/07/23.
//

import Foundation


private struct ConfigCacheModel: Codable {
    var config: CBAuthentication
    var validTill: Date
    init(config: CBAuthentication, validTill: Date) {
        self.config = config
        self.validTill = validTill
    }
}

private protocol CacheProtocol {
    func writeConfigDetails(object:CBAuthentication)
    func readConfigDetails(logger: CBLogger, withCompletion completion: @escaping (CBResult<CBAuthenticationStatus>) -> Void, onError: ErrorHandler?)
    func saveAuthenticationDetails(data: CBAuthenticationStatus)
    func isCacheDataAvailable()-> Bool
}

internal struct CBCache: CacheProtocol {
    private let uniqueIdKey = "chargebee_config"
    static let shared = CBCache()
    
    func readConfigDetails(logger: CBLogger, withCompletion completion: @escaping (CBResult<CBAuthenticationStatus>) -> Void, onError: ErrorHandler?) {
        let (onSuccess, _) = CBResult.buildResultHandlers(completion, logger)
        if let data = UserDefaults.standard.object(forKey: getFormattedkey()) as? Data,
           let cacheModel = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            let cacheObj = ConfigCacheModel(config: cacheModel.config, validTill: cacheModel.validTill)
            let auth = CBAuthenticationStatus.init(details: cacheObj.config)
            if ((auth.details.appId?.isEmpty) != nil) || ((auth.details.status?.isEmpty) != nil){
                onSuccess(auth)
            }else{
                onError?(CBError.defaultSytemError(statusCode: 400, message:"Empty data found"))
            }
        }else{
            onError?(CBError.defaultSytemError(statusCode: 400, message:"Failed to read config details from Cache"))
        }
    }
    
    internal func writeConfigDetails(object configObject:CBAuthentication) {
        if let data = UserDefaults.standard.object(forKey: getFormattedkey()) as? Data,
           let cacheModel = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            if ((cacheModel.config.appId?.isEmpty) != nil) {
                UserDefaults.standard.removeObject(forKey: getFormattedkey())
            }
        }
        let configObj: ConfigCacheModel = ConfigCacheModel(config: configObject, validTill: createTime())
        if let encoded = try? JSONEncoder().encode(configObj) {
            UserDefaults.standard.set(encoded, forKey: getFormattedkey())
        }
    }
    
    private func createTime() -> Date {
        let currentDate = Date()
        let newDate = NSDate(timeInterval: 86400, since: currentDate)
        return newDate as Date
    }
    
    internal func saveAuthenticationDetails(data: CBAuthenticationStatus) {
        if let appId = data.details.appId,let status = data.details.status , let version = data.details.version{
            let configDetails = CBAuthentication.init(appId: appId, status: status, version: version)
            self.writeConfigDetails(object: configDetails)
        }
    }
    
    internal func isCacheDataAvailable()-> Bool {
        if let data = UserDefaults.standard.object(forKey: getFormattedkey()) as? Data,
           let cacheModel = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            if let appID = cacheModel.config.appId ,let status = cacheModel.config.status {
                if !appID.isEmpty && !status.isEmpty {
                    let waitingDate:NSDate = cacheModel.validTill as NSDate
                    if (Date().compare(waitingDate as Date) == ComparisonResult.orderedDescending) {
                        UserDefaults.standard.removeObject(forKey: getFormattedkey())
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
    
    private func getBundleID() ->String{
        var bundleID = ""
        if let id = Bundle.main.bundleIdentifier {
            bundleID = id
        }
        return bundleID
    }
    
    private func getFormattedkey() -> String {
        return getBundleID().appending("_").appending(uniqueIdKey)
    }
}


