//
//  CBTokenizer.swift
//  Chargebee
//
//  Created by Haripriyan on 7/7/20.
//

import Foundation


public struct CBCard {
    
    public init(cardNumber: String, expiryMonth: String, expiryYear: String, cvc: String) {
        self.cardNumber = cardNumber
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvc = cvc
    }
    
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String
    

}

public struct CBPaymentDetail {
    public init(type: String, currencyCode: String, card: CBCard) {
        self.type = type
        self.currencyCode = currencyCode
        self.card = card
    }
    
    let type: String
    let currencyCode: String
    let card: CBCard
}

class CBTokenizer {
    init() {
        
    }
    
    func tokenize(options: CBPaymentDetail, completion handler: @escaping (String?) -> Void) {
//        1. Retreive CB Config
//                - FIlter
        retrieveCBPaymentConfig(options) { gatewayDetail in
            self.createPaymentGatewayToken(options, gatewayDetail: gatewayDetail) { (cbToken) in
                print("cbToken   \(cbToken)")
                handler(cbToken)
            }
        }
//        2. Create Payment GW Token
//        3. Create CB Temp token from GW Token
    }
    
    func retrieveCBPaymentConfig(_ paymentDetail: CBPaymentDetail, handler: @escaping (CBGatewayDetail) -> Void) {
        let paymentConfigResource = CBPaymentConfigResource(key: merchantKey)
        let request = APIRequest(resource: paymentConfigResource)
        request.load() { paymentConfig in
            guard (paymentConfig != nil) else {
                return
            }
            let paymentProviderKey: CBGatewayDetail? = paymentConfig!.getPaymentProviderConfig(paymentDetail.currencyCode, paymentDetail.type)
            guard paymentProviderKey != nil else {
                return
            }
            handler(paymentProviderKey!)
            return
        }
    }
    
    func createPaymentGatewayToken(_ paymentDetail: CBPaymentDetail, gatewayDetail: CBGatewayDetail, handler: @escaping (String?) -> Void) {
        StripeTokenizer(card: paymentDetail.card, paymentProviderKey: gatewayDetail.clientId).tokenize() { stripeToken in
            print("stripe======\(stripeToken)")
            if stripeToken != nil {
                CBTemporaryToken().createToken(gatewayToken: stripeToken!, paymentMethodType: paymentDetail.type, gatewayId: gatewayDetail.gatewayId) { cbToken in
                    handler(cbToken)
                }
            }
        }
    }
    
//    func createCBToken(stripeToken: String, gateWayInfo: CBWrapper) -> {
//
//    }
}
