//
// Created by Mac Book on 6/7/20.
//

import Foundation

public typealias AddonHandler = (CBResult<CBAddon>) -> Void

struct AddonWrapper: Decodable {
    let addon: CBAddon
}

public class CBAddon: Decodable {
    public let id: String
    public let name: String
    public let invoiceName: String
    public let description: String
    public let pricingModel: String
    public let chargeType: String
    public let price: Int
    public let periodUnit: String
    public let status: String
    public let enabledInPortal: Bool
    public let isShippable: Bool
    public let updatedAt: UInt64
    public let resourceVersion: UInt64
    public let object: String
    public let currencyCode: String
    public let taxable: Bool
    public let type: String
    public let showDescriptionInInvoices: Bool
    public let showDescriptionInQuotes: Bool

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
