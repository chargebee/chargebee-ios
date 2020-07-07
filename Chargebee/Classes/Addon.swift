//
// Created by Mac Book on 6/7/20.
//

import Foundation

struct AddonWrapper: Decodable {
    let addon: Addon
}

public struct Addon: Decodable {
    let id: String
    let name: String
    let invoiceName: String
    let description: String
    let pricingModel: String
    let chargeType: String
    let price: Int
    let periodUnit: String
    let status: String
    let enabledInPortal: Bool
    let isShippable: Bool
    let updatedAt: UInt64
    let resourceVersion: UInt64
    let object: String
    let currencyCode: String
    let taxable: Bool
    let type: String
    let showDescriptionInInvoices: Bool
    let showDescriptionInQuotes: Bool

    enum CodingKeys: String, CodingKey {
        case id =  "id"
        case name =  "name"
        case invoiceName =  "invoice_name"
        case description =  "description"
        case pricingModel =  "pricing_model"
        case chargeType =  "charge_type"
        case price =  "price"
        case periodUnit =  "period_unit"
        case status =  "status"
        case enabledInPortal =  "enabled_in_portal"
        case isShippable =  "is_shippable"
        case updatedAt =  "updated_at"
        case resourceVersion =  "resource_version"
        case object =  "object"
        case currencyCode =  "currency_code"
        case taxable =  "taxable"
        case type =  "type"
        case showDescriptionInInvoices =  "show_description_in_invoices"
        case showDescriptionInQuotes =  "show_description_in_quotes"
    }
}
