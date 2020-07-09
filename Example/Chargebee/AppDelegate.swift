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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application
        
        // Configure the Chargebee site and Api Key
        CBManager.configure(site: "test-ashwin1-test", apiKey: "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah")

        return true
    }
}
