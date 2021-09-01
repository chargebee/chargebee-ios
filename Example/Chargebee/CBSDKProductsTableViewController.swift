//
//  CBProductsTableViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 23/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKProductsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var products: [CBProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        CBSDKProductTableViewCell.registerCellXib(with: self.tableView)
        self.title = "Products"

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CBSDKProductTableViewCell.self), for: indexPath) as! CBSDKProductTableViewCell
        let product: CBProduct = products[indexPath.row]
        cell.product = product
        cell.titleLabel.text = product.product.localizedTitle
        cell.priceLabel.text = product.product.localizedDescription
        var buttonTitle: String = "Buy"
        cell.delegate = self
        if #available(iOS 11.2, *) {
            if let _ = product.product.subscriptionPeriod {
                buttonTitle = "Subscripe"
            }
        } else {
            // Fallback on earlier versions
        }
        cell.btnAction.setTitle(buttonTitle, for: .normal)
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


extension CBSDKProductsTableViewController : ProductTableViewCellDelegate {
        
    func buyClicked(withProdct: CBProduct) {

        func purchase(customerID: String) {
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            
            CBPurchase.shared.purchaseProduct(product: withProdct,customerId: customerID) { result in
                print(result)
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "success", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let alert = UIAlertController(title: "",
                                      message: "Please enter customerID",
                                      preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            if let textFields = alert.textFields, let customerTextField = textFields.first {
                purchase(customerID: customerTextField.text ?? "")
            }
        }
        defaultAction.isEnabled = true
        alert.addAction(defaultAction)
        alert.addTextField { (textField) in
             textField.delegate = self
        }
        present(alert, animated: true, completion: nil)


    }
}
