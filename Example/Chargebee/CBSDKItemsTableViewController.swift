//
//  CBProductsTableViewController.swift
//  Chargebee_Example
//
//
//  Created by Harish Bharadwaj on 23/07/21.
//  Copyright © 2021 CocoaPods. All rights reserved.

import UIKit
import Chargebee

final class CBSDKItemsTableViewController: UITableViewController {

    var items: [CBItemWrapper] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        CBSDKItemTableViewCell.registerCellXib(with: self.tableView)
        self.title = "Items"

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CBSDKItemTableViewCell.self), for: indexPath) as! CBSDKItemTableViewCell
        let item: CBItemWrapper = items[indexPath.row]
        cell.item = item
        cell.nameLabel.text = item.item.name
//        cell.idLabel.text = item.item.id

        return cell

    }

}
