//
//  CBProductsTableViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 23/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKItemsTableViewController: UITableViewController {
    
    var items: [CBItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        CBSDKItemsTableViewCell.registerCellXib(with: self.tableView)
        self.title = "Items"

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CBSDKItemsTableViewCell.self), for: indexPath) as! CBSDKItemsTableViewCell
        let item: CBItem = items[indexPath.row]
        cell.item = item
        cell.titleLabel.text = item.name
        cell.priceLabel.text = item.id
        var buttonTitle: String = "Buy"
        //cell.delegate = self
//        if #available(iOS 11.2, *) {
//            if let _ = product.product.subscriptionPeriod {
//                buttonTitle = "Subscripe"
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        //cell.btnAction.setTitle(buttonTitle, for: .normal)
        return cell

    }

}

extension UITableViewCell {
// Not using static as it wont be possible to override to provide custom storyboardID then
class var storyboardID : String {
    return "\(self)"
  }

static func registerCellXib(with tableview: UITableView){
    let nib = UINib(nibName: self.storyboardID, bundle: nil)
    tableview.register(nib, forCellReuseIdentifier: self.storyboardID)
  }
}


