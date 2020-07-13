//
//  PlanViewController.swift
//  Chargebee_Example
//
//  Created by Mac Book on 9/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

class PlanViewController: UIViewController {

    @IBOutlet weak var planCode: UITextField!
    @IBOutlet weak var planName: UILabel!
    @IBOutlet weak var planStatus: UILabel!
    @IBOutlet weak var planCurrencyCode: UILabel!
    @IBOutlet weak var planError: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getPlan() {
        clearAllFields()
        CBPlan.retrieve(self.planCode.text!) { (planResult) in
            switch planResult {
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

    func clearAllFields() -> Void {
        self.planName.text = ""
        self.planStatus.text = ""
        self.planCurrencyCode.text = ""
        self.planError.text = ""
    }

}
