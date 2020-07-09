//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public typealias PlanHandler = (Plan) -> Void
public typealias AddonHandler = (Addon) -> Void
public typealias TokenHandler = (String) -> Void
public typealias ErrorHandler = (Error) -> Void

public func defaultErrorHandler(_ error: Error) -> Void {
}

@available(macCatalyst 13.0, *)
public class Chargebee {
    public init() {
    }

    public static func configure(site: String, apiKey: String) {
        CBEnvironment.configure(site: site, apiKey: apiKey)
    }

    public func getPlan(_ planId: String, completion handler: @escaping PlanHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        if planId.isEmpty {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "Plan id is empty"))
        }

        let request = APIRequest(resource: PlanResource(planId))
        request.load(withCompletion: { planWrapper in
            handler(planWrapper!.plan)
        }, onError: onError)
    }

    public func getAddon(_ addonId: String, completion handler: @escaping AddonHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        if addonId.isEmpty {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "Addon id is empty"))
        }

        let request = APIRequest(resource: AddonResource(addonId))
        request.load(withCompletion: { planWrapper in
            handler(planWrapper!.addon)
        }, onError: onError)
    }

    public func getTemporaryToken(paymentDetail: CBPaymentDetail, completion handler: @escaping TokenHandler, onError: @escaping ErrorHandler = defaultErrorHandler) {
        CBTokenizer().tokenize(options: paymentDetail, completion: handler, onError: onError)
    }
}
