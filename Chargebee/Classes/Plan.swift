//
// Created by Mac Book on 6/7/20.
//

import Foundation

public struct PlanWrapper: Decodable {
    let plan: Plan
}

public struct Plan: Decodable {
    let addonApplicability: String
    let chargeModel: String
    let currencyCode: String
    let enabledInHostedPages: Bool
    let enabledInPortal: Bool
    let freeQuantity: Int
    let giftable: Bool
    let id: String
    let invoiceName: String
    let isShippable: Bool
    let name: String
    let object: String
    let period: Int
    let periodUnit: String
    let price: Int
    let pricingModel: String
    let resourceVersion: UInt64
    let status: String
    let taxable: Bool
    let updatedAt: UInt64

    enum CodingKeys: String, CodingKey {
        case addonApplicability = "addon_applicability"
        case chargeModel = "charge_model"
        case currencyCode = "currency_code"
        case enabledInHostedPages = "enabled_in_hosted_pages"
        case enabledInPortal = "enabled_in_portal"
        case freeQuantity = "free_quantity"
        case giftable = "giftable"
        case id = "id"
        case invoiceName = "invoice_name"
        case isShippable = "is_shippable"
        case name = "name"
        case object = "object"
        case period = "period"
        case periodUnit = "period_unit"
        case price = "price"
        case pricingModel = "pricing_model"
        case resourceVersion = "resource_version"
        case status = "status"
        case taxable = "taxable"
        case updatedAt = "updated_at"
    }
}
