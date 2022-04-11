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
        // Override point for customization after application

        Chargebee.configure(site: "cb-imay-test",
                            apiKey: "test_EojsGoGFeHoc3VpGPQDOZGAxYy3d0FF3", sdkKey: "cb-njjoibyzbrhyjg7yz4hkwg2ywq")
        
        
       return true
    }
}
