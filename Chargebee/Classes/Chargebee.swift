//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

@available(macCatalyst 13.0, *)
public class Chargebee {
    public init() {
    }

    public static func configure(site: String, apiKey: String) {
        CBEnvironment.configure(site: site, apiKey: apiKey)
    }
}
