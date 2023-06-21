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

    @objc class func showExternalManageSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        self.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @available(iOS 15.0, *)
    @objc class func showManageSubscriptions() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              !ProcessInfo.processInfo.isiOSAppOnMac else {
                  UIApplication.showExternalManageSubscriptions()
                  return
        }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                UIApplication.showExternalManageSubscriptions()
            }
        }
    }
}
