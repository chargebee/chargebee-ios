//
//  CBTokenReource.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class CBTokenResource: APIResource {
    typealias ModelType = TokenWrapper
    typealias ErrorType = CBErrorDetail

    var authHeader: String
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    let methodPath: String = "/v2/tokens/create_using_temp_token"

    init(paymentMethodType: CBPaymentType, token: String, gatewayId: String) {
        self.authHeader = "Basic \(CBEnvironment.encodedApiKey)"
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

