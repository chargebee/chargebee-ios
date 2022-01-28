//
// Created by Mac Book on 7/7/20.
//

import Foundation

final class CBPaymentConfigResource: CBAPIResource {
    typealias ModelType = CBMerchantPaymentConfig
    typealias ErrorType = CBInternalErrorWrapper

    var baseUrl: String
    var authHeader: String? {
        get {
            "Basic \(CBEnvironment.apiKey)"
        }
    }
    var methodPath: String = "/internal/component/retrieve_config"
    var header: [String: String]? = ["X-Requested-With":"XMLHttpRequest"]

    init() {
        self.baseUrl = CBEnvironment.baseUrl
    }

}

struct CBGatewayDetail {
    let clientId: String
    let gatewayId: String
}

final class CBMerchantPaymentConfig: Decodable {
    let apmConfig: [String: PaymentConfigs]
    let currencies: [String]
    let defaultCurrency: String

    enum CodingKeys: String, CodingKey {
        case apmConfig = "apm_config"
        case currencies = "currency_list"
        case defaultCurrency = "default_currency"
    }

    func getPaymentProviderConfig(_ currencyCode: String,_ paymentType: CBPaymentType) -> CBGatewayDetail? {
        let paymentMethod: PaymentMethod? = self.apmConfig[currencyCode]?
                .paymentMethods.first(where: { $0.type == paymentType.rawValue && $0.gatewayName == "STRIPE" })
        if let clientId = paymentMethod?.tokenizationConfig?.STRIPE?.clientId, let gatewayId = paymentMethod?.id {
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

struct PaymentMethod {
    let type: String
    let id: String
    let gatewayName: String
    let gatewayCurrency: String
    let tokenizationConfig: TokenizationConfig?
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
    let STRIPE: PaymentProviderConfig?

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
