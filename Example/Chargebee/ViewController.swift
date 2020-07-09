//
//  ViewController.swift
//  Chargebee
//
//  Created by cb-prabu on 07/07/2020.
//  Copyright (c) 2020 cb-prabu. All rights reserved.
//

import UIKit
import Chargebee

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!


    @IBAction func tokenize() {
        let card = CBCard(cardNumber: "4242424242424242", expiryMonth: "09", expiryYear: "29", cvc: "123")
        let paymentDetail = CBPaymentDetail(type: "card", currencyCode: "USD", card: card)

        CBManager().getTemporaryToken(paymentDetail: paymentDetail, completion: { s in
            print("Final CB Token \(s)")
            self.resultLabel.text = s
        }, onError: {(error) in
            print("Error\(error)")
            self.resultLabel.text = error.localizedDescription
        })

//        CBManager().getPlan("cb-demo-no-trial") { res in
//            print("Plan Details", res)
//        }

//        CBManager().getAddon("cbdemo_setuphelp") { res in
//            print("Addon Details", res)
//        }
//        resultLabel.text = "Clicked value"
    }
}
