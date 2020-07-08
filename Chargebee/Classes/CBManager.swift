//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

let merchantKey = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah"

public typealias PlanHandler = (Plan?) -> Void
public typealias AddonHandler = (Addon?) -> Void
public typealias TokenHandler = (String?) -> Void
public typealias ErrorHandler = (Error) -> Void

public func defaultErrorHandler(_ error: Error) -> Void {}

@available(macCatalyst 13.0, *)
public class CBManager {
    public init() {
        
    }

    public func getPlan(_ planId: String, completion handler: @escaping PlanHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        let planResource = PlanResource(key: merchantKey, planId)
        let request = APIRequest(resource: planResource)
        request.load(withCompletion: { planWrapper in
            handler(planWrapper?.plan)
        }, onError: onError)
    }

    public func getAddon(_ addonId: String, completion handler: @escaping AddonHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        let addonResource = AddonResource(key: merchantKey)
        addonResource.setAddon(addonId)
        let request = APIRequest(resource: addonResource)
        request.load(withCompletion: { planWrapper in
            handler(planWrapper?.addon)
        }, onError: onError)
    }

    public func getTemporaryToken(paymentDetail: CBPaymentDetail, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        CBTokenizer().tokenize(options: paymentDetail, completion: handler, onError: onError)
    }

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
    
    func tokenize(completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        let request = APIRequest(resource: StripeTokenResource(paymentProviderKey))
        request.create(body: self.card, withCompletion: { (stripeToken) in
            handler(stripeToken?.id)
        }, onError: onError)
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
    func createToken(gatewayToken: String, paymentMethodType: String, gatewayId: String, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        let resource = CBTokenResource()
        let request = APIRequest(resource: resource)
        let body = TempTokenBody(paymentMethodType: paymentMethodType, token: gatewayToken, gatewayId: gatewayId)
        request.create(body: body, withCompletion: { (res: TokenWrapper?) in
            if res != nil {
                handler(res?.token.id)
            }
        }, onError: onError)
    }
}

struct TempTokenBody: URLEncodedRequestBody {
    let paymentMethodType: String
    let token: String
    let gatewayId: String
    
    func toFormBody() -> [String : String] {
        return [
            "payment_method_type": paymentMethodType,
            "id_at_vault": token,
            "gateway_account_id": gatewayId,
        ]
    }
}
