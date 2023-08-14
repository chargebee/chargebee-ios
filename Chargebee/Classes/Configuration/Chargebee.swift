//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation
import StoreKit

public class Chargebee {
    public static let shared = Chargebee()
    private var client = NetworkClient()
    public static var environment: String = "cb_ios_sdk"
    init() {}

    public static func configure(site: String, apiKey: String, sdkKey: String? = nil, allowErrorLogging: Bool = true) {
        CBEnvironment.environment = self.environment
        CBEnvironment().configure(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey)
    }

    public static func configure(site: String, apiKey: String, sdkKey: String? = nil, allowErrorLogging: Bool = true, handler: @escaping CBAuthenticationHandler) {
            let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)

            CBEnvironment.environment = self.environment
            CBEnvironment().configure(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey){ result in
                switch result {
                case .success(let status):
                    onSuccess(status)
                case .error(let error):
                    onError(error)
                }
            }
        }
    
    public func retrieveSubscription(forSubscriptionID id: String, handler: @escaping CBSubscriptionHandler) {
        let logger = CBLogger(name: "Subscription", action: "Fetch Subscription")
        logger.info()

        let request = CBAPIRequest(resource: CBSubscriptionResource(id))
        CBSubscriptionManager().retrieveSubscription(network: request, logger: logger, handler: handler)
    }
   
    
    @available(*, deprecated, message: "This will be removed in upcoming versions, Please use this API func retrieveSubscriptionsList(queryParams: [String: String]? = nil, handler: @escaping RetrieveSubscriptionHandler)")
    public func retrieveSubscriptions(queryParams: [String: String]? = nil, handler: @escaping SubscriptionHandler) {
        let logger = CBLogger(name: "Subscription", action: "Fetch Subscription using customerId")
        logger.info()
        
        let request = CBAPIRequest(resource: SubscriptionResource(queryParams: queryParams))
        CBSubscriptionManager().retrieveSubscriptions(network: request, logger: logger, handler: handler)
    }

    public func retrieveSubscriptions(queryParams: [String: String]? = nil, handler: @escaping RetrieveSubscriptionHandler) {
        let logger = CBLogger(name: "Subscription", action: "Fetch Subscription using customerId")
        logger.info()
        
        let request = CBAPIRequest(resource: SubscriptionResource(queryParams: queryParams))
        CBSubscriptionManager().retrieveSubscriptions(network: request, logger: logger, handler: handler)
    }

    public  func retrieveItem(forID id: String, handler: @escaping ItemHandler) {
        let logger = CBLogger(name: "item", action: "retrieve_item")
        logger.info()

        let request = CBAPIRequest(resource: CBItemResource(id))
        client.retrieve(network: request, logger: logger, handler: handler)
    }

    public  func retrieveAllItems(queryParams: [String: String]? = nil, completion handler: @escaping ItemListHandler) {
        let logger = CBLogger(name: "items", action: "retrieve_allitems")
        logger.info()

        let request = CBAPIRequest(resource: CBItemListResource(queryParams: queryParams ))
        client.retrieve(network: request, logger: logger, handler: handler)
    }

    public  func retrievePlan(forID id: String, handler: @escaping PlanHandler) {
        let logger = CBLogger(name: "plan", action: "retrieve_plan")
        logger.info()

        let request = CBAPIRequest(resource: CBPlanResource(id))
        client.retrieve(network: request, logger: logger, handler: handler)
    }

    public  func retrieveAllPlans(queryParams: [String: String]? = nil, completion handler: @escaping AllPlanHandler) {
        let logger = CBLogger(name: "plan", action: "retrieve_allplans")
        logger.info()

        let request = CBAPIRequest(resource: CBPlansResource(queryParams: queryParams ))
        client.retrieve(network: request, logger: logger, handler: handler)
    }
    
    public func retrieveEntitlements(forSubscriptionID id: String, handler: @escaping EntitlementHandler) {
        let logger = CBLogger(name: "Entitlements", action: "retrieve_entitlements")
        logger.info()

        let request = CBAPIRequest(resource: CBEntitlementResource(id))
        client.retrieve(network: request, logger: logger, handler: handler)
    }


    public  func retrieveAddon(_ addonId: String, completion handler: @escaping AddonHandler) {
        let logger = CBLogger(name: "addOn", action: "retrieve_addon")
        logger.info()

        let request = CBAPIRequest(resource: CBAddOnResource(addonId))
        client.retrieve(network: request, logger: logger, handler: handler)
    }
  
    public func createTempToken(paymentDetail: CBPaymentDetail, completion handler: @escaping (CBResult<String>) -> Void) {
        let logger = CBLogger(name: "cb_temp_token", action: "create_temp_token")
        logger.info()
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        CBToken().tokenize(options: paymentDetail, completion: onSuccess, onError: onError)
    }
    
   public func showManageSubscriptionsSettings() {
        if #available(iOS 15.0, *) {
            UIApplication.showManageSubscriptions()
        } else {
            UIApplication.showExternalManageSubscriptions()
        }
    }
}
