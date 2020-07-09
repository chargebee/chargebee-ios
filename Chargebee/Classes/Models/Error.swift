//
//  Error.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation


public enum CBError: Error {
    case operationFailed(errorResponse: CBErrorDetail)
    case invalidRequest(errorResponse: CBErrorDetail)
    case paymentFailed(errorResponse: CBErrorDetail)
    
    static func defaultSytemError(statusCode: Int, message: String = "") -> CBError {
        let errorDetail = CBErrorDetail(message: message, type: "", apiErrorCode: "", param: "", httpStatusCode: statusCode)
        return CBError.operationFailed(errorResponse: errorDetail)
    }
}

extension CBError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .operationFailed(let errorResponse):
            return errorResponse.message
        case .invalidRequest(let errorResponse):
            return errorResponse.message
        case .paymentFailed(let errorResponse):
            return errorResponse.message
        }
    }
}

protocol ErrorDetail {
    func toCBError(_ statusCode: Int) -> CBError
}

public struct CBErrorDetail: Decodable, ErrorDetail {

    let message: String
    let type: String?
    let apiErrorCode: String?
    let param: String?
    let httpStatusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case type = "type"
        case apiErrorCode = "api_error_code"
        case param = "param"
        case httpStatusCode = "http_status_code"
    }
    
    func toCBError(_ statusCode: Int) -> CBError {
        switch statusCode {
        case (400...499):
            return CBError.invalidRequest(errorResponse: self)
        default:
            return CBError.operationFailed(errorResponse: self)
        }
    }
    
}

struct StripeError: Decodable {
    let code: String?
    let message: String
    let param: String?
    let type: String
}

public struct StripeErrorWrapper: Decodable, ErrorDetail {

    let error: StripeError
    
    func toCBError(_ statusCode: Int) -> CBError {
        return CBError.paymentFailed(errorResponse: CBErrorDetail(message: error.message, type: error.type, apiErrorCode: error.code, param: error.param, httpStatusCode: statusCode))
    }
}

struct CBInternalErrorDetail: Decodable {
    let message: String
}

struct CBInternalErrorWrapper: Decodable, ErrorDetail {
    
    let errors: [CBInternalErrorDetail]?
    
    func toCBError(_ statusCode: Int) -> CBError {
        let message = errors?.first?.message ?? ""
        return CBError.defaultSytemError(statusCode: statusCode, message: message)
    }
    
}

