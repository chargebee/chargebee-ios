//
//  CBTokenizer.swift
//  Chargebee
//
//  Created by Haripriyan on 7/7/20.
//

import Foundation


class CBTokenizer {
    init() {
        
    }
    
    func tokenize(options: CBPaymentDetail, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        retrieveCBPaymentConfig(options, handler: { gatewayDetail in
            self.createPaymentGatewayToken(options, gatewayDetail: gatewayDetail, handler: { (stripeToken) in
                if let stripeToken = stripeToken {
                    CBTemporaryToken().createToken(gatewayToken: stripeToken, paymentMethodType: options.type, gatewayId: gatewayDetail.gatewayId, completion: { cbToken in
                        handler(cbToken)
                    }, onError: onError)
                }
            }, onError: onError)
        },
        onError: onError)
    }
    
    func retrieveCBPaymentConfig(_ paymentDetail: CBPaymentDetail, handler: @escaping (CBGatewayDetail) -> Void, onError: @escaping ErrorHandler) {
        let paymentConfigResource = CBPaymentConfigResource()
        let request = APIRequest(resource: paymentConfigResource)
        request.load(withCompletion: { paymentConfig in
            guard (paymentConfig != nil) else {
                return
            }
            let paymentProviderKey: CBGatewayDetail? = paymentConfig!.getPaymentProviderConfig(paymentDetail.currencyCode, paymentDetail.type)
            guard paymentProviderKey != nil else {
                return
            }
            handler(paymentProviderKey!)
            return
        },
                     onError: onError)
    }
    
    func createPaymentGatewayToken(_ paymentDetail: CBPaymentDetail, gatewayDetail: CBGatewayDetail, handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        StripeTokenizer(card: paymentDetail.card, paymentProviderKey: gatewayDetail.clientId).tokenize(completion: {stripeToken in
            handler(stripeToken)
        }, onError: onError)
    }
    
}
