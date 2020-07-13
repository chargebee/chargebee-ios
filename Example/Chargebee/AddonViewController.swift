//
//  AddonViewController.swift
//  Chargebee_Example
//
//  Created by Mac Book on 9/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

class AddonViewController: UIViewController {

    @IBOutlet weak var addonCode: UITextField!
    @IBOutlet weak var addonName: UILabel!
    @IBOutlet weak var addonStatus: UILabel!
    @IBOutlet weak var addonCurrencyCode: UILabel!
    @IBOutlet weak var addonError: UILabel!

    @IBAction func getAddonDetail() {
        clearAllFields()
        CBAddon.retrieve(addonCode.text!) { (addonResult) in
            switch addonResult {
            case .success(let addon):
                print(addon)
                self.addonName.text = addon.name
                self.addonStatus.text = addon.status
                self.addonCurrencyCode.text = addon.currencyCode
            case .error(let error):
                print("Error\(error)")
                self.addonError.text = error.localizedDescription
            }
        }
    }

    func clearAllFields() -> Void {
        self.addonName.text = ""
        self.addonStatus.text = ""
        self.addonCurrencyCode.text = ""
        self.addonError.text = ""
    }
}
