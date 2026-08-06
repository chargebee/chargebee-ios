//
//  AppDelegate.swift
//  Chargebee
//
//  Created by cb-prabu on 07/07/2020.
//  Copyright (c) 2020 cb-prabu. All rights reserved.
//

import UIKit
import Chargebee

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure the SDK with a mobile token fetched from your server instead of
        // embedding a publishable API key in the app.
        Chargebee.configure(
            site: "cb-abc-test",
            sdkKey: "SDK-KEY",
            tokenProvider: { completion in
                // Ask your server for a fresh mobile token (it mints one via
                // `create_mobile_token`), then hand the raw token back to the SDK.
                AppDelegate.fetchMobileToken(completion: completion)
            },
            handler: { result in
                switch result {
                case .success(let status):
                    debugPrint("Chargebee configured: \(status)")
                case .error(let error):
                    debugPrint("Chargebee configuration failed: \(error)")
                }
            }
        )

       return true
    }

    /// Stand-in for the call to your own server that returns a Chargebee mobile token.
    /// Replace the body with a real network request to your server.
    private static func fetchMobileToken(completion: @escaping (String?) -> Void) {
        completion("cb_mob_replace_with_token_from_your_backend")
    }
}
