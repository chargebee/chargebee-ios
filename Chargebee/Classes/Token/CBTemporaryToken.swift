//  CBTemporaryToken.swift
//  Chargebee
//
//  Created by Mac Book on 9/7/20.
//

import Foundation

typealias TokenHandler = (String) -> Void

struct TokenWrapper: Decodable {
    let token: TemporaryToken
}

struct TemporaryToken: Decodable {
    let id: String
}

final class CBTemporaryToken {
    func createToken(gatewayToken: String, paymentMethodType: CBPaymentType, gatewayId: String, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        let request = CBAPIRequest(resource: CBTokenResource(paymentMethodType: paymentMethodType, token: gatewayToken, gatewayId: gatewayId))
        request.create(withCompletion: { (res: TokenWrapper?) in
            if res != nil {
                handler(res!.token.id)
            }
        }, onError: onError)
    }
}
