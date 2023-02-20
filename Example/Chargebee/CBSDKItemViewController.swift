//
//  CBSDKItemViewController.swift
//  Chargebee_Example
//
//  Created by Harish Bharadwaj on 23/07/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Chargebee
import UIKit

final class CBSDKItemViewController: UIViewController {

    @IBOutlet weak var ItemId: UITextField!

    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var error: UILabel!

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getItem() {
        clearAllFields()
        guard let itemId = self.ItemId.text else {
            return
        }
        Chargebee.shared.retrieveItem(forID: itemId) { result in
            switch result {
            case .success(let list):
                print(list)
                DispatchQueue.main.async {
                    self.itemName.text = list.item.name
                    self.itemStatus.text = list.item.status
                }

            case .error(let error):
                print("Error\(error)")
                DispatchQueue.main.async {
                    self.error.text = error.localizedDescription
                }
            }

        }
    }

    private func clearAllFields() {
        self.itemName.text = ""
        self.itemStatus.text = ""

    }

}
