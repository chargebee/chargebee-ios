//
//  PlanViewController.swift
//  Chargebee_Example
//
//  Created by Mac Book on 9/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKPlanViewController: UIViewController {

    @IBOutlet private weak var planCode: UITextField!
    @IBOutlet private weak var planName: UILabel!
    @IBOutlet private weak var planStatus: UILabel!
    @IBOutlet private weak var planCurrencyCode: UILabel!
    @IBOutlet private weak var planError: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func getPlan() {
        clearAllFields()
        guard let planId = self.planCode.text else {
            return
        }
        Chargebee.shared.retrievePlan(forID: planId) { result in
            switch result {
            case .success(let plan):
                print(plan)
                self.planName.text = plan.name
                self.planStatus.text = plan.status
                self.planCurrencyCode.text = plan.currencyCode
            case .error(let error):
                print("Error\(error)")
                self.planError.text = error.localizedDescription
            }

        }
    }

    private func clearAllFields() {
        self.planName.text = ""
        self.planStatus.text = ""
        self.planCurrencyCode.text = ""
        self.planError.text = ""
    }

}
