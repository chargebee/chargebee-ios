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

    @IBAction func fetchSubscriptionStatus(_ sender: UIButton) {

        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))

        guard let subscriptionID = subscriptioniDTextField.text, subscriptionID.isNotEmpty else {
            return
        }
        Chargebee.shared.retrieveSubscription(forSubscriptionID: subscriptionID) { result in
            switch result {
            case let .success(statusResult):
                debugPrint("Subscription Status Fetched: \(statusResult)")
                DispatchQueue.main.async {
                    if let status = statusResult.status, let amount = statusResult.planAmount {
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

    @IBAction func getStatusUsingCustomerId(_ sender: Any) {
        callRetreiveSubscriptions()
    }
    
    func callRetreiveSubscriptions(){
        self.activityStartAnimating()
        guard let id = subscriptioniDTextField.text, id.isNotEmpty else {
            return
        }
        Chargebee.shared.retrieveSubscriptionsList(queryParams: ["customer_id": id,"offset":""]) { result in
            switch result {
            case let .success(result):
                debugPrint("Subscription Status Fetched: \(result)")
                if let value = result.nextOffset {
                    let offset = value
                    DispatchQueue.main.async {
                        self.getSubcription(offset: offset)
                    }
                }else{
                    DispatchQueue.main.async {
                        if  let status = result.list.first?.subscription.status, let amount = result.list.first?.subscription.planAmount {
                            let alertController = UIAlertController(title: "Chargebee", message: "Status :\(status)\n Plan amount:\(amount).", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                self.activityStopAnimating()
            case let .error(error):
                debugPrint("Error Fetched: \(error)")
                self.showError(error: error)
            }
        }
    }
    
    func getSubcription(offset: String){
        self.activityStartAnimating()
        guard let id = subscriptioniDTextField.text, id.isNotEmpty else {
            return
        }
        
        Chargebee.shared.retrieveSubscriptionsList(queryParams: ["customer_id": id,"offset":offset]) { result in
            switch result {
            case let .success(result):
                debugPrint("Subscription Status Fetched: \(result)")
                DispatchQueue.main.async {
                    if  let status = result.list.first?.subscription.status, let amount = result.list.first?.subscription.planAmount {
                        let alertController = UIAlertController(title: "Chargebee", message: "Status :\(status)\n Plan amount:\(amount).", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.activityStopAnimating()
            case let .error(error):
                debugPrint("Error Fetched: \(error)")
                self.showError(error: error)
                
            }
        }
    }
    
    func activityStartAnimating(){
        DispatchQueue.main.async {
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        }
    }
    func activityStopAnimating(){
        DispatchQueue.main.async {
            self.view.activityStopAnimating()
        }
    }
    
    func showError(error:Error){
        DispatchQueue.main.async {
            self.view.activityStopAnimating()
            self.statusLabel.text = error.localizedDescription
            self.subscriptioniDTextField.resignFirstResponder()
        }
        self.activityStopAnimating()
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
