//
// Created by Mac Book on 7/7/20.
//

import Foundation

protocol URLEncodedRequestBody {
    func toFormBody() -> [String: String]
}

struct StripeCard: URLEncodedRequestBody {
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String

    func toFormBody() -> [String: String] {
        return ["card[number]": number,
         "card[exp_month]": expiryMonth,
         "card[exp_year]": expiryYear,
         "card[cvc]": cvc]
    }
}

class StripeTokenResource: APIResource {
    typealias ModelType = StripeToken

    private(set) var methodPath: String = "/tokens"
    var baseUrl: String = "https://api.stripe.com/v1"
    var authHeader: String = ""

    init(_ apiKey: String) {
        self.authHeader = "Bearer \(apiKey)"
    }
}
