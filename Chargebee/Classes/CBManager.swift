//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

struct SubscriptionOptions {
    let currency: String
    let type: String
}

let merchantKey = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah"


@available(macCatalyst 13.0, *)
public class CBManager {
    public init() {
        
    }

    public func getPlan(_ planId: String, completion handler: @escaping (Plan?) -> Void) {
        let planResource = PlanResource(key: merchantKey, planId)
        let request = APIRequest(resource: planResource)
        request.load() { planWrapper in
            handler(planWrapper?.plan)
        }
    }

    public func getAddon(_ addonId: String, completion handler: @escaping (Addon?) -> Void) {
        let addonResource = AddonResource(key: merchantKey)
        addonResource.setAddon(addonId)
        let request = APIRequest(resource: addonResource)
        request.load() { planWrapper in
            handler(planWrapper?.addon)
        }
    }

    public func getTemporaryToken(paymentDetail: CBPaymentDetail, completion handler: @escaping (String?) -> Void) {
        CBTokenizer().tokenize(options: paymentDetail, completion: handler)
    }


}

struct StripeResponse: Decodable {
    let id: String
    let object: String
}

@available(macCatalyst 13.0, *)
class StripeTokenizer {
    let paymentConfigUrl = "https://api.stripe.com/v1/tokens"
    let card: StripeCard
    let paymentProviderKey: String
    
    init(card: CBCard, paymentProviderKey: String) {
        self.card = StripeCard(number: card.cardNumber, expiryMonth: card.expiryMonth, expiryYear: card.expiryYear, cvc: card.cvc)
        self.paymentProviderKey = paymentProviderKey
    }
    
    func tokenize(completion handler: @escaping ((String?) -> Void)) {
        let request = APIRequest(resource: StripeTokenResource(paymentProviderKey))
        request.create(body: self.card) { (stripeToken) in
            handler(stripeToken?.id)
        }
    }
}

struct TokenWrapper: Decodable {
    let token: TemporaryToken
}

struct TemporaryToken: Decodable {
    let id: String
}

@available(macCatalyst 13.0, *)
class CBTemporaryToken {
    func createToken(gatewayToken: String, paymentMethodType: String, gatewayId: String, completion handler: @escaping (String?) -> Void) {
        let resource = CBTokenResource()
        let request = APIRequest(resource: resource)
        let body = TempTokenBody(paymentMethodType: paymentMethodType, token: gatewayToken, gatewayId: gatewayId)
        request.create(body: body) { (res: TokenWrapper?) in
            if res != nil {
                handler(res?.token.id)
            }
        }
    }
}

