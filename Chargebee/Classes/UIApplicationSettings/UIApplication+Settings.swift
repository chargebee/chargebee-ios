//
//  UIApplication+Settings.swift
//  Chargebee
//
//  Created by ramesh_g on 13/06/23.
//

import Foundation
import UIKit
import StoreKit

extension UIApplication {
    //This is to Open Appstore App Account settings Page
    @objc class func openAppleIDSubscriptionsPage() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        self.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // This opens Subscriptions Management settings
    @available(iOS 15.0, *)
    @objc class func showManageSubscriptions() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              !ProcessInfo.processInfo.isiOSAppOnMac else {
                  UIApplication.openAppleIDSubscriptionsPage()
                  return
        }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                UIApplication.openAppleIDSubscriptionsPage()
            }
        }
    }
}
