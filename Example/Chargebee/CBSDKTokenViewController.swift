//
//  TokenViewController.swift
//  Chargebee_Example
//
//  Created by Mac Book on 9/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKTokenViewController: UIViewController {
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var cardNumber: UITextField!
    @IBOutlet private weak var expiryMonth: UITextField!
    @IBOutlet private weak var expiryYear: UITextField!
    @IBOutlet private weak var cvc: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction private func tokenize() {
        let card = CBCard(
                cardNumber: self.cardNumber.text!,
                expiryMonth: self.expiryMonth.text!,
                expiryYear: self.expiryYear.text!,
                cvc: self.cvc.text!)
        print(card, "card details")
        let paymentDetail = CBPaymentDetail(type: CBPaymentType.Card, currencyCode: "USD", card: card)
        CBToken.createTempToken(paymentDetail: paymentDetail) { tokenResult in
            switch tokenResult {
            case .success(let token):
                print("Final CB Token \(token)")
                self.resultLabel.text = token
            case .error(let error):
                print("Error\(error)")
                self.resultLabel.text = error.localizedDescription
            }
        }
    }

}
