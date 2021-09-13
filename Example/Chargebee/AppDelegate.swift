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
//        Chargebee.configure(site: "christopherselvaraj-test",
//                            publishableApiKey: "test_FVK4gS1DfkVnuvQVW5mr2p3U4DDcuLQ2E",sdkKey: "cb-b22l33j4bve3ngf7k3hnfacvqm")

        Chargebee.configure(site: "cb-imay-test",
                            publishableApiKey: "test_EojsGoGFeHoc3VpGPQDOZGAxYy3d0FF3",sdkKey: "cb-b22l33j4bve3ngf7k3hnfacvqm")
//
        //        Chargebee.configure(site: "[sitename]",
//                            publishableApiKey: "[apikey]")
        // pass in SDK Key if available
        // https://omnichannel-test.predev37.in/subscriptions/289013/details
        return true
    }
}
