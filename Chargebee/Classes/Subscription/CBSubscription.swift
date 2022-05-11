//
//  CBSubscription.swift
//  Chargebee
//
//  Created by Imayaselvan on 24/05/21.
//

import Foundation



// MARK: - Subscription List
public struct SubscriptionList: Codable {
    public let subscription: Subscription
    enum CodingKeys: String, CodingKey {
        case subscription = "cb_subscription"
    }
}

public struct CBSubscriptionWrapper: Codable {
    public let list: [SubscriptionList]
    public  let nextOffset: [String]?
    enum CodingKeys: String, CodingKey {
        case nextOffset = "next_offset"
        case list
    }
}


struct CBSubscriptionStatus: Codable {
    public let subscription: Subscription
    enum CodingKeys: String, CodingKey {
        case subscription = "cb_subscription"
    }
}

public struct Subscription: Codable {
    public let activatedAt: Double?
    public let status: String?
    public let planAmount: Double?
    public let id: String?
    public let customerId: String?
    public let currentTermEnd: Double?
    public let currentTermStart: Double?

    enum CodingKeys: String, CodingKey {
        case activatedAt = "activated_at"
        case status
        case id = "subscription_id"
        case customerId = "customer_id"
        case planAmount = "plan_amount"
        case currentTermEnd = "current_term_end"
        case currentTermStart = "current_term_start"
    }
}

public typealias CBSubscriptionHandler = (CBResult<Subscription>) -> Void
public typealias SubscriptionHandler   = (CBResult<[SubscriptionList]>) -> Void

class CBSubscriptionManager {
    func retrieveSubscription<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping CBSubscriptionHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { status in
            if let data = status as? CBSubscriptionStatus {
                onSuccess(data.subscription)
            }
        }, onError: onError)
    }
   
    func retrieveSubscriptions<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping SubscriptionHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { status in
            if let data = status as? CBSubscriptionWrapper {
                if data.list.isEmpty {
                    onError(CBError.defaultSytemError(statusCode: 404, message: "Subscription Not found"))
                }else {
                    onSuccess(data.list)
                }
            } else {
                onError(CBError.defaultSytemError(statusCode: 480, message: "json serialization failure"))
            }

        }, onError: onError)
    }

}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
