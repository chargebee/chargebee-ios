//
//  CBTokenReource.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation

final class CBTokenResource: CBAPIResource {
    typealias ModelType = TokenWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        get {
            return "Basic \(CBEnvironment.encodedApiKey)"
        }
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    let methodPath: String = "/v2/tokens/create_using_temp_token"

    init(paymentMethodType: CBPaymentType, token: String, gatewayId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.requestBody = TempTokenBody(paymentMethodType: paymentMethodType, token: token, gatewayId: gatewayId)
    }

}

struct TempTokenBody: URLEncodedRequestBody {
    let paymentMethodType: CBPaymentType
    let token: String
    let gatewayId: String

    func toFormBody() -> [String: String] {
        [
            "payment_method_type": paymentMethodType.rawValue,
            "id_at_vault": token,
            "gateway_account_id": gatewayId,
        ]
    }
}

