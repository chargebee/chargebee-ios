//
//  CBRestorePurchaseManager.swift
//  Chargebee
//
//  Created by ramesh_g on 20/02/23.
//

import Foundation
import StoreKit

public typealias CBRestorePurchaseHandler = (CBResult<CBRestorePurchase>) -> Void

// MARK: - CBRestorePurchase
public struct CBRestorePurchase: Decodable {
    let inAppSubscriptions: [InAppSubscription]

    enum CodingKeys: String, CodingKey {
        case inAppSubscriptions = "in_app_subscriptions"
    }
}

// MARK: - InAppSubscription
public struct InAppSubscription: Decodable {
    public let subscriptionID: String
    public let planID: String
    public let storeStatus: String
    
    enum CodingKeys: String, CodingKey {
        case subscriptionID = "subscription_id"
        case planID = "plan_id"
        case storeStatus = "store_status"
    }
}

class CBRestorePurchaseManager{
    
    public  func restorePurchases(receipt: String, completion handler: @escaping CBRestorePurchaseHandler) {
        let logger = CBLogger(name: "restore", action: "restore_purchases")
        logger.info()
        
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
        let request = CBAPIRequest(resource: CBRestorePurchaseResource(receipt: receipt))
        request.create(withCompletion: { (res: CBRestorePurchase?) in
            if let response = res{
                onSuccess(response)
            }
        }, onError: onError)
    }
}

