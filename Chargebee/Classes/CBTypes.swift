//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

struct CBGatewayDetail {
    let clientId: String
    let gatewayId: String
}

class CBWrapper: Decodable {
    let apmConfig: [String: PaymentConfigs]
    let currencies: [String]
    let defaultCurrency: String

    enum CodingKeys: String, CodingKey {
        case apmConfig = "apm_config"
        case currencies = "currency_list"
        case defaultCurrency = "default_currency"
    }
    
    func getPaymentProviderConfig(_ currencyCode: String,_ paymentType: String) -> CBGatewayDetail? {
        let paymentMethod: PaymentMethod? = self.apmConfig[currencyCode]?
                .paymentMethods.first(where: { $0.type == paymentType && $0.gatewayName == "STRIPE" })
        if let clientId = paymentMethod?.tokenizationConfig.STRIPE.clientId, let gatewayId = paymentMethod?.id {
            return CBGatewayDetail(clientId: clientId, gatewayId: gatewayId)
        }
        return nil
    }
}

struct PaymentConfigs {
    let paymentMethods: [PaymentMethod]
}

extension PaymentConfigs: Decodable {
    enum CodingKeys: String, CodingKey {
        case paymentMethods = "pm_list"
    }
}

enum CardTypes: String, Decodable {
    case STRIPE = "STRIPE"
}

struct PaymentMethod {
    let type: String
    let id: String
    let gatewayName: String
    let gatewayCurrency: String
    let tokenizationConfig: TokenizationConfig
}

extension PaymentMethod: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case gatewayName = "gateway_name"
        case gatewayCurrency = "gateway_currency"
        case tokenizationConfig = "tokenization_config"
    }
}

struct TokenizationConfig: Decodable {
    let STRIPE: PaymentProviderConfig

    enum CodingKeys: String, CodingKey {
        case STRIPE
    }
}

struct PaymentProviderConfig: Decodable {
    let clientId: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
    }
}
