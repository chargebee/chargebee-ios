//
//  CBSDKItemViewController.swift
//  Chargebee_Example
//
//  Created by Harish Bharadwaj on 23/07/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Chargebee

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
        
        CBItem.getItem(self.ItemId.text!){ (itemResult) in
            switch itemResult {
            case .success(let item):
                print(item)
                self.itemName.text = item.name
                self.itemStatus.text = item.status
                
            case .error(let error):
                print("Error\(error)")
                self.error.text = error.localizedDescription
            }
        }
    }
    
    private func clearAllFields() -> Void {
        self.itemName.text = ""
        self.itemStatus.text = ""
        
    }
    
}


