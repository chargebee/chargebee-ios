//
//  ErrorResource.swift
//  Chargebee
//
//  Created by Haripriyan on 7/20/20.
//
import Foundation

@available(macCatalyst 13.0, *)
class LoggerResource: APIResource {
    
    typealias ModelType = String?
    typealias ErrorType = String?
    
    var baseUrl: String
    var methodPath: String = "/internal/track_info_error"
    private var logDetail: LogDetail
    
    var url: URLRequest {
        get {
            var components = URLComponents(string: baseUrl)
            components!.path += methodPath
            var urlRequest = URLRequest(url: components!.url!)
            urlRequest.httpBody = try? JSONEncoder().encode(self.logDetail)
            urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
            return urlRequest
        }
    }
    
    init(action: String, type: LogType, error_message: String, error_code: Int?) {
        self.logDetail = LogDetail(data: [
            "key": "cb.logging",
            "ref_module": "cb_ios_sdk",
            "site": CBEnvironment.site,
            "action": action,
            "log_data_type": type.rawValue,
            "error_message": error_message,
            "error_code": "\(error_code ?? 0)"
        ])
        self.baseUrl = CBEnvironment.baseUrl
    }
}

struct LogDetail: Codable {
    
    let data: [String: String]
    let type = "kvl"
    
}

enum LogType: String {
    case Error = "ERROR"
}
