//
//  ErrorResource.swift
//  Chargebee
//
//  Created by Haripriyan on 7/20/20.
//
import Foundation

class CBLoggerResource: CBAPIResource {
    
    typealias ModelType = String?
    typealias ErrorType = String?
    
    var baseUrl: String
    var methodPath: String = "/internal/track_info_error"
    private var logDetail: LogDetail
    
    func create() -> URLRequest {
        return self.url
    }
    
    var url: URLRequest {
        get {
            var components = URLComponents(string: baseUrl)
            components!.path += methodPath
            var urlRequest = URLRequest(url: components!.url!)
            urlRequest.httpMethod = "post"
            urlRequest.httpBody = try? JSONEncoder().encode(self.logDetail)
            urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
            return urlRequest
        }
    }
    
    init(action: String, type: LogType, errorMessage: String? = nil, errorCode: Int? = nil) {
        var data =  ["key": "cb.logging",
                     "ref_module": "cb_ios_sdk",
                     "site": CBEnvironment.site,
                     "action": action,
                     "log_data_type": type.rawValue]
        if let errorMessage = errorMessage {
            data["error_message"] = errorMessage
        }
        if let errorCode = errorCode {
            data["error_code"] = "\(errorCode)"
        }
        self.baseUrl = CBEnvironment.baseUrl
        self.logDetail = LogDetail(data: data)
    }
}

struct LogDetail: Codable {
    
    let data: [String: String]
    let type = "kvl"
    
}

enum LogType: String {
    case Error = "error"
    case Info = "info"
}
