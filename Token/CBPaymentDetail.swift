//
//  CBPaymentDetail.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
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

public enum CBPaymentType: String {
    case Card = "card"
}

public struct CBPaymentDetail {
    public init(type: CBPaymentType, currencyCode: String, card: CBCard) {
        self.type = type
        self.currencyCode = currencyCode
        self.card = card
    }
    
    let type: CBPaymentType
    let currencyCode: String
    let card: CBCard
}
