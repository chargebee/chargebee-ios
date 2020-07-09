//
// Created by Mac Book on 7/7/20.
//

import Foundation

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

class StripeTokenResource: APIResource {
    typealias ModelType = StripeToken
    typealias ErrorType = StripeErrorWrapper

    private(set) var methodPath: String = "/tokens"
    var baseUrl: String = "https://api.stripe.com/v1"
    var authHeader: String

    init(_ apiKey: String) {
        self.authHeader = "Bearer \(apiKey)"
    }
}
