//
//  CBSubscriptionStatusViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 24/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKSubscriptionStatusViewController: UIViewController {
    
    @IBOutlet private weak var subscriptioniDTextField: UITextField!
    @IBOutlet private weak var fetchSubscriptionutton: UIButton!
    @IBOutlet private weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableFetchButton(shouldEnable: subscriptioniDTextField.isNotEmpty)
    }
    
    private func enableFetchButton(shouldEnable: Bool) {
        fetchSubscriptionutton.isEnabled = shouldEnable
    }
    
    @IBAction func fetchSubscribtionStatus(_ sender: UIButton) {
        
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))

        guard let subscriptionID = subscriptioniDTextField.text , subscriptionID.isNotEmpty else {
            return
        }
        CBSubscription.retrieveSubscription(forID: subscriptionID) { result in
            switch result {
            case let .success(statusResult):
                debugPrint("Subscribtion Status Fetched: \(statusResult)")
                DispatchQueue.main.async {
                    if let status = statusResult.subscription.status, let amount = statusResult.subscription.planAmount {
                        let alertController = UIAlertController(title: "Chargebee", message: "Status :\(status)\n Plan amount:\(amount).", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    self.view.activityStopAnimating()
                }
            case let .error(error):
                debugPrint("Error Fetched: \(error)")
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    self.statusLabel.text = error.localizedDescription
                    self.subscriptioniDTextField.resignFirstResponder()

                }

            }
        }
    }
    
    @IBAction private func textFieldDidEndEdit(_ sender: UITextField) {
        enableFetchButton(shouldEnable: sender.isNotEmpty)
    }
}

extension UITextField {
    var isEmpty: Bool {
        return text?.isEmpty ?? true
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
