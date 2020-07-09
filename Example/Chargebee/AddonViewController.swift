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
    @IBOutlet weak var addonDescription: UILabel!
    @IBOutlet weak var addonCurrencyCode: UILabel!
    @IBOutlet weak var addonError: UILabel!
    

    @IBAction func getAddonDetail() {
        CBManager().getAddon(addonCode.text!, completion: { (addon) in
            self.addonName.text = addon.name
            self.addonDescription.text = addon.description
            self.addonCurrencyCode.text = addon.currencyCode
        }) { (error) in
            self.addonError.text = error.localizedDescription
        }
    }
    
    
}
