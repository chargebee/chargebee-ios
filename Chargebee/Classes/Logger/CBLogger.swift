//
//  ErrorLogger.swift
//  Chargebee
//
//  Created by Haripriyan on 7/20/20.
//

import Foundation

class CBLogger {
    
    private let name: String
    private let action: String
    
    init(name: String, action: String) {
        self.name = name
        self.action = action
    }
    
    func error(message: String, code: Int? = nil) {
        postLog(LogType.Error, message, code)
    }
    
    func info() {
        postLog(LogType.Info)
    }
    
    private func postLog(_ type: LogType, _ message: String? = nil, _ code: Int? = nil) {
        if CBEnvironment.allowErrorLogging {
            let request = CBAPIRequest(resource: CBLoggerResource(
                action: action,
                type: type,
                errorMessage: message,
                errorCode: code))
            request.create()
        }
    }
    
}
