//
//  PurchaseViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 18/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKPurchaseViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var txtproductID: UITextField!
    @IBOutlet private weak var txtPrice: UITextField!
        

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtproductID:
            txtPrice.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            return true
        }
        return false
    }
        
    @IBAction private func submitBtnClicked(_ sender: Any) {
        func hideLoader() {
            DispatchQueue.main.async {
                self.view.activityStopAnimating()
            }
        }
        
        guard let productId = txtproductID.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let price = txtPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
        }
        
        guard CBAuthenticationManager.isSDKKeyPresent() else { return } // do handle if SDK Key wasn't been set
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        CBAuthenticationManager.isSDKKeyValid { status in
            if status {
                CBPurchase.shared.validateReceipt(for: productId, price, currencyCode: "USD",customerId: "") { result in
                    switch result {
                    case let .success(status):
                        debugPrint("Successfully validated. \(status)")
                    case let .failure(error):
                        debugPrint("Error while validation \(error.localizedDescription)")
                    }
                }
            } else {
                hideLoader()
                debugPrint("Please config the SDK Again! Your SDK Key is invalid")
            }
        }
    }
}

