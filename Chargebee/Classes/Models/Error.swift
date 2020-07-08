//
//  Error.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation

public enum CBError: Error {
    case unknown(String? = nil)
    case authenticationError
    case resourceNotFound
}

protocol ErrorDetail {
    func toCBError() -> CBError
}

struct CBErrorDetail: Decodable, ErrorDetail {

    let message: String?
    let type: String?
    let apiErrorCode: String?
    let param: String?
    let errorCode: String?
    let errorMsg: String?
    let errorParam: String?
    let httpStatusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case type = "type"
        case apiErrorCode = "api_error_code"
        case param = "param"
        case errorCode = "error_code"
        case errorMsg = "error_msg"
        case errorParam = "error_param"
        case httpStatusCode = "http_status_code"
    }
    
    func toCBError() -> CBError {
        
        switch httpStatusCode {
        case .none:
            return CBError.unknown()
        case .some(let status):
            switch status {
            case 401:
                return CBError.authenticationError
            case 404:
                return CBError.resourceNotFound
            default:
                return CBError.unknown()
            }
        }
    }
}
