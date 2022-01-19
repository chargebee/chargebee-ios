//
//  StripeTokenizer.swift
//  Chargebee
//
//  Created by Mac Book on 9/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class StripeTokenizer {
    let resource: StripeTokenResource

    init(card: CBCard, paymentProviderKey: String) {
        let card = StripeCard(number: card.cardNumber, expiryMonth: card.expiryMonth, expiryYear: card.expiryYear, cvc: card.cvc)
        self.resource = StripeTokenResource(apiKey: paymentProviderKey, card: card)
    }

    func tokenize(completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler) {
        let request = CBAPIRequest(resource: self.resource)
        request.create(withCompletion: { (stripeToken) in
            handler(stripeToken.id)
        }, onError: onError)
    }
}
