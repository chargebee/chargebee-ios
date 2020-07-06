//
//  ViewController.swift
//  Chargebee
//
//  Created by cb-prabu on 07/06/2020.
//  Copyright (c) 2020 cb-prabu. All rights reserved.
//

import UIKit
import Chargebee

class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var expiryMonthField: UITextField!
    @IBOutlet weak var expiryYearField: UITextField!
    @IBOutlet weak var cvcField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tokenize() {
        let cardInfo = CardInfo(number: self.cardTextField.text!,
                expiryMonth: self.expiryMonthField.text!,
                cvc: self.cvcField.text!,
                expiryYear: self.expiryYearField.text!)
        let details = SubscriptionOptions(currency: "USD", type: "card", cardInfo: cardInfo)
        CBManager().getTemporaryToken(details: details) { token in
            self.resultLabel.text = token!
        }
    }
}

