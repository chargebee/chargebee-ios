//
// Created by Mac Book on 7/7/20.
//

import Foundation

class StripeTokenResource: CBAPIResource {
    typealias ModelType = StripeToken
    typealias ErrorType = StripeErrorWrapper

    private(set) var methodPath: String = "/tokens"
    private let apiKey: String
    var baseUrl: String = "https://api.stripe.com/v1"
    var authHeader: String? {
        get {
            "Bearer \(apiKey)"
        }
    }
    var requestBody: URLEncodedRequestBody?

    init(apiKey: String, card: StripeCard) {
        self.apiKey = apiKey
        self.requestBody = card
    }
}

struct StripeToken: Decodable {
    let id: String
    let type: String
}

struct StripeCard: URLEncodedRequestBody {
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String

    func toFormBody() -> [String: String] {
        ["card[number]": number,
         "card[exp_month]": expiryMonth,
         "card[exp_year]": expiryYear,
         "card[cvc]": cvc]
    }
}

struct StripeError: Decodable {
    let code: String?
    let message: String
    let param: String?
    let type: String?
}

public struct StripeErrorWrapper: Decodable, ErrorDetail {

    let error: StripeError
    
    func toCBError(_ statusCode: Int) -> CBError {
        return CBError.paymentFailed(errorResponse: CBErrorDetail(message: error.message, type: error.type, apiErrorCode: error.code, param: error.param, httpStatusCode: statusCode))
    }
}
