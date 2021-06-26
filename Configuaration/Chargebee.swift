//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public class Chargebee {
    public init() {
    }

    public static func configure(site: String, publishableApiKey: String, sdkKey: String, customerID: String, allowErrorLogging: Bool = true) {
        CBEnvironment.configure(site: site, publishableApiKey: publishableApiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey, customerID: customerID)
    }
}
