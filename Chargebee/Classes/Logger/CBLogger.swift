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
        let request = APIRequest(resource: LoggerResource(
            action: action,
            type: LogType.Error,
            error_message: message,
            error_code: code))
        request.create()
    }
}
