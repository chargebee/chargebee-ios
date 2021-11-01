//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public class Chargebee {
    public init() {
    }

    public static func configure(site: String, publishableApiKey: String, sdkKey: String? = nil, allowErrorLogging: Bool = true, completion: (() -> Void)? = nil) {
        CBEnvironment.configure(site: site, publishableApiKey: publishableApiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey, completion: completion)
    }
}
