//
//  CBCache.swift
//  Chargebee
//
//Created by ramesh_g on 28/07/23.
//

import Foundation


struct ConfigCacheModel: Codable {
    var config: CBAuthentication
    var date: Date
    init(config: CBAuthentication, date: Date) {
        self.config = config
        self.date = date
    }
}

protocol CacheProtocal {
    func writeConfigDetails(key:String,object:CBAuthentication)
    func readConfigDetails(key:String,logger: CBLogger, handler: @escaping CBAuthenticationHandler)
    func saveAuthenticationDetails(key:String,data: CBAuthenticationStatus)
    func isCacheDataAvailable(key:String)-> Bool
}

struct CBCache: CacheProtocal {
    
    static let shared = CBCache()
    var todaysDate = NSDate()
    
    internal func writeConfigDetails(key:String, object configObject:CBAuthentication) {
        debugPrint("Time created for 1 mint: \(createTime())")
        let configObj: ConfigCacheModel = ConfigCacheModel(config: configObject, date: createTime())
        if let encoded = try? JSONEncoder().encode(configObj) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func createTime() -> Date {
        let currentDate = Date()
        let newDate = NSDate(timeInterval: 86400, since: currentDate)
        return newDate as Date
    }
    
    func readConfigDetails(key: String,logger: CBLogger, handler: @escaping CBAuthenticationHandler){
        let (onSuccess, _) = CBResult.buildResultHandlers(handler, logger)
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
           let config = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            let cacheObj = ConfigCacheModel(config: config.config, date: config.date)
            let auth = CBAuthenticationStatus.init(details: cacheObj.config)
            onSuccess(auth)
        }
    }
    
    func saveAuthenticationDetails(key: String,data: CBAuthenticationStatus) {
        if let appId = data.details.appId,let status = data.details.status , let version = data.details.version{
            let configDetails = CBAuthentication.init(appId: appId, status: status, version: version)
            self.writeConfigDetails(key:key,object: configDetails)
        }
    }
    
    func isCacheDataAvailable(key:String)-> Bool {
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
           let config = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            if let appID = config.config.appId ,let status = config.config.status {
                if !appID.isEmpty && !status.isEmpty {
                    let waitingDate:NSDate = config.date as NSDate
                    if (self.todaysDate.compare(waitingDate as Date) == ComparisonResult.orderedDescending) {
                        self.clearCacheFromMemory(key: key)
                        return false
                    }
                }
                return true
            }
        }
        return false
    }
    
    func clearCacheFromMemory(key:String){
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
           let config = try? JSONDecoder().decode(ConfigCacheModel.self, from: data) {
            if (config.config.appId != nil) || (config.config.status != nil) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
