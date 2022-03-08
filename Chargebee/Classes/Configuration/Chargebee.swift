//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public class Chargebee {
    public static let shared = Chargebee()

    init() {}

    public static func configure(site: String, apiKey: String, sdkKey: String? = nil, allowErrorLogging: Bool = true) {
        CBEnvironment().configure(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey)
    }

    public func retrieveSubscription(forID id: String, handler: @escaping CBSubscriptionHandler) {
        let logger = CBLogger(name: "Subscription", action: "Fetch Subscription")
        logger.info()

        let request = CBAPIRequest(resource: CBSubscriptionResource(id))
        CBSubscriptionManager().retrieveSubscription(network: request, logger: logger, handler: handler)
    }

    public  func retrieveItem(forID id: String, handler: @escaping ItemHandler) {
        let logger = CBLogger(name: "item", action: "getItem")
        logger.info()

        let request = CBAPIRequest(resource: CBItemResource(id))
        NetworkClient().retrieveItem(network: request, logger: logger, handler: handler)
    }

    public  func retrieveAllItems(queryParams: [String: String]? = nil, completion handler: @escaping ItemListHandler) {
        let logger = CBLogger(name: "item", action: "getAllItems")
        logger.info()

        let request = CBAPIRequest(resource: CBItemListResource(queryParams: queryParams ))
        NetworkClient().retrieveAllItems(network: request, logger: logger, handler: handler)
    }

    public  func retrievePlan(forID id: String, handler: @escaping PlanHandler) {
        let logger = CBLogger(name: "plan", action: "retrieve_plan")
        logger.info()

        let request = CBAPIRequest(resource: CBItemResource(id))
        NetworkClient().retrievePlan(network: request, logger: logger, handler: handler)
    }

    public  func retrieveAllPlans(queryParams: [String: String]? = nil, completion handler: @escaping AllPlanHandler) {
        let logger = CBLogger(name: "item", action: "getAllItems")
        logger.info()

        let request = CBAPIRequest(resource: CBItemListResource(queryParams: queryParams ))
        NetworkClient().retrieveAllPlans(network: request, logger: logger, handler: handler)
    }

    public  func retrieveAddon(_ addonId: String, completion handler: @escaping AddonHandler) {
        let logger = CBLogger(name: "addOn", action: "retrieve_addon")
        logger.info()

        let request = CBAPIRequest(resource: CBAddOnResource(addonId))
        NetworkClient().retrieveAddon(network: request, logger: logger, handler: handler)
    }
  
    public func createTempToken(paymentDetail: CBPaymentDetail, completion handler: @escaping (CBResult<String>) -> Void) {
        let logger = CBLogger(name: "cb_temp_token", action: "create_temp_token")
        logger.info()
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        CBToken().tokenize(options: paymentDetail, completion: onSuccess, onError: onError)
    }
    
}
