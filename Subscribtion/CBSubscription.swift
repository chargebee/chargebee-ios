//
//  CBSubscription.swift
//  Chargebee
//
//  Created by Imayaselvan on 24/05/21.
//

import Foundation

public struct CBSubscriptionStatus: Codable {
    public let subscription: CBSubscription
    public let customer: CBCustomer
}

public struct CBSubscription: Codable {
    public let activatedAt: Double?
    public let status: String?
    public let planAmount: Double?
    
   
    enum CodingKeys: String, CodingKey  {
        case activatedAt = "activated_at"
        case status
        case planAmount = "plan_amount"
    }
}

public struct CBCustomer: Codable {
    public let allowDirectDebit: Bool
    public let autoCollection: String
    public let billingAddress: CBAddress?
    public let cardStatus: String?
    public let createdAt: Double?
    public let deleted: Bool?
    
    enum CodingKeys: String, CodingKey  {
        case allowDirectDebit = "allow_direct_debit"
        case autoCollection = "auto_collection"
        case billingAddress = "billing_address"
        case cardStatus = "card_status"
        case createdAt = "created_at"
        case deleted
    }
}

public struct CBAddress: Codable {
    public let city: String?
    public let country: String?
    public let firstName: String?
    public let lastName: String?
    public let line1: String?
    public let object: String?
    public let state: String?
    public let stateCode: String?
    public let validationStatus: String?
    public let zip: String?
    
    enum CodingKeys: String, CodingKey  {
        case city, country, line1, object, state, zip
        case firstName = "first_name"
        case lastName = "last_name"
        case stateCode = "state_code"
        case validationStatus = "validation_status"
    }
}

public typealias CBSubscriptionHandler = (CBResult<CBSubscriptionStatus>) -> Void

public class CBSubscriptionManager {}

public extension CBSubscriptionManager {
    static func fetchSubscriptionStatus(forID id: String, handler: @escaping CBSubscriptionHandler) {
        let logger = CBLogger(name: "Subscription", action: "Fetch Subscription")
        logger.info()
        
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        
        guard id.isNotEmpty else {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "Subscription id is empty"))
        }
        let request = CBAPIRequest(resource: CBSubscriptionResource(id))
        request.load(withCompletion: { subscriptionStatus in
            onSuccess(subscriptionStatus)
        }, onError: onError)
    }
    
}


extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}




