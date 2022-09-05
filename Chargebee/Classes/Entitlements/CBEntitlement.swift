//
//  CBEntitlement.swift
//  Chargebee
//
//  Created by Imay on 26/08/22.
//

import Foundation

public typealias EntitlementHandler = (CBResult<CBEntitlementWrapper>) -> Void


// MARK: - SubscriptionEntitlement
public struct Entitlement: Codable {
    let subscriptionID, featureID, featureName, featureDescription: String
    let featureType, value, name: String
    let isOverridden, isEnabled: Bool
    let object: String

    enum CodingKeys: String, CodingKey {
        case subscriptionID = "subscription_id"
        case featureID = "feature_id"
        case featureName = "feature_name"
        case featureDescription = "feature_description"
        case featureType = "feature_type"
        case value, name
        case isOverridden = "is_overridden"
        case isEnabled = "is_enabled"
        case object
    }
}

public struct EntitlementList: Codable {
    let entitlement: Entitlement
    enum CodingKeys: String, CodingKey {
        case entitlement = "subscription_entitlement"
    }
}

public struct CBEntitlementWrapper: Codable {
    public let list: [EntitlementList]
}
