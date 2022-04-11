//
//  CBTokenizer.swift
//  Chargebee
//
//  Created by Haripriyan on 7/7/20.
//

import Foundation

 class CBToken {

    func tokenize(options: CBPaymentDetail, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        retrieveCBPaymentConfig(options, handler: { gatewayDetail in
            self.createPaymentGatewayToken(options, gatewayDetail: gatewayDetail, handler: { (stripeToken) in
                CBTemporaryToken().createToken(gatewayToken: stripeToken, paymentMethodType: options.type, gatewayId: gatewayDetail.gatewayId, completion: { cbToken in
                    handler(cbToken)
                }, onError: onError)
            }, onError: onError)
        },
                                onError: onError)
    }

    func retrieveCBPaymentConfig(_ paymentDetail: CBPaymentDetail, handler: @escaping (CBGatewayDetail) -> Void, onError: @escaping ErrorHandler) {
        let paymentConfigResource = CBPaymentConfigResource()
        let request = CBAPIRequest(resource: paymentConfigResource)
        request.load(withCompletion: { (paymentConfig: CBMerchantPaymentConfig) in
            guard let paymentProviderKey = paymentConfig.getPaymentProviderConfig(paymentDetail.currencyCode, paymentDetail.type)
                else {
                    return onError(CBError.defaultSytemError(statusCode: 400, message: "Currency/gateway not yet supported in the SDK"))
            }
            return handler(paymentProviderKey)
        },
                     onError: onError)
    }

    func createPaymentGatewayToken(_ paymentDetail: CBPaymentDetail, gatewayDetail: CBGatewayDetail, handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        StripeTokenizer(card: paymentDetail.card, paymentProviderKey: gatewayDetail.clientId).tokenize(completion: { stripeToken in
            handler(stripeToken)
        }, onError: onError)
    }
}
