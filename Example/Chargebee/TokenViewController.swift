//
//  TokenViewController.swift
//  Chargebee_Example
//
//  Created by Mac Book on 9/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

class TokenViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var expiryMonth: UITextField!
    @IBOutlet weak var expiryYear: UITextField!
    @IBOutlet weak var cvc: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func tokenize() {
        let card = CBCard(
                cardNumber: self.cardNumber.text!,
                expiryMonth: self.expiryMonth.text!,
                expiryYear: self.expiryYear.text!,
                cvc: self.cvc.text!)
        print(card, "card details")
        let paymentDetail = CBPaymentDetail(type: CBPaymentType.Card, currencyCode: "USD", card: card)

        Chargebee().getTemporaryToken(paymentDetail: paymentDetail, completion: { s in
            print("Final CB Token \(s)")
            self.resultLabel.text = s
        }, onError: { (error) in
            print("Error\(error)")
            self.resultLabel.text = error.localizedDescription
        })
    }

}
