//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public class Chargebee {
    public init() {
    }

    public static func configure(site: String, apiKey: String, sdkKey: String? = nil, allowErrorLogging: Bool = true) {
        CBEnvironment.configure(site: site, apiKey: apiKey, allowErrorLogging: allowErrorLogging, sdkKey: sdkKey)
    }
}
