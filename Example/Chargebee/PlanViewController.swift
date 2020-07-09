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
        CBManager().getPlan(self.planCode.text!, completion: { (s: Plan) in
            print(s)

            self.planName.text = s.name
            self.planStatus.text = s.status
            self.planCurrencyCode.text = s.currencyCode
        }, onError: { (error) in
            print("Error\(error)")

            self.planError.text = error.localizedDescription
        })
    }

    func clearAllFields() -> Void {
        self.planName.text = ""
        self.planStatus.text = ""
        self.planCurrencyCode.text = ""
        self.planError.text = ""
    }

}
