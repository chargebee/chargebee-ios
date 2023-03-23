//
//  CBSDKOptionsViewController.swift
//  Chargebee
//
//  Created by cb-prabu on 07/07/2020.
//  Copyright (c) 2020 cb-prabu. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKOptionsViewController: UIViewController, UITextFieldDelegate {
    private var products: [CBProduct] = []
    private var items: [CBItemWrapper] = []
    private var plans: [CBPlan] = []

    private lazy var actions: [ClientAction] = [.initializeInApp, .getAllPlan, .getPlan, .getItems, .getItem, .getEntitlements, .getAddon, .createToken, .getProductIDs, .getProducts, .getSubscriptionStatus ,.restore]

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
}

extension CBSDKOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = actions[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle selection
        let selectedAction = actions[indexPath.row]
        switch  selectedAction {
        case .getPlan,
             .getAddon,
             .createToken,
             .getSubscriptionStatus,
             .initializeInApp,
             .processReceipt,
             .getItem:
            performSegue(withIdentifier: selectedAction.title, sender: self)
        case .getProductIDs:
            print("Get Product ID's")
            CBPurchase.shared.retrieveProductIdentifers(queryParams: ["limit": "100"], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(dataWrapper):
                        debugPrint("items: \(dataWrapper)")
                        print(dataWrapper.ids)
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            let alertController = UIAlertController(title: "Chargebee", message: "\(dataWrapper.ids.joined(separator: "\n"))", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)

                        }

                    case let .failure(error):
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                }
            })

        case .getProducts:
            let alert = UIAlertController(title: "",
                                          message: "Please enter Product id's (comma separated)",
                                          preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
                if let textFields = alert.textFields, let customerTextField = textFields.first {
                    CBPurchase.shared.retrieveProducts(withProductID: customerTextField.text?.components(separatedBy: ",") ?? [String](), completion: { result in
                        DispatchQueue.main.async {
                            switch result {
                            case let .success(products):
                                self.products = products
                                debugPrint("products: \(products)")
                                self.performSegue(withIdentifier: "productList", sender: self)
                            case let .failure(error):
                                debugPrint("Error: \(error.localizedDescription)")
                            }
                        }
                    })
                }
            }
            defaultAction.isEnabled = true
            alert.addAction(defaultAction)
            alert.addTextField { (textField) in
                 textField.delegate = self
            }
            present(alert, animated: true, completion: nil)

        case .getItems:
            Chargebee.shared.retrieveAllItems(queryParams: ["limit": "8", "sort_by[desc]": "name"], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(itemLst):
                        self.items =  itemLst.list
                        debugPrint("items: \(self.items)")
                        self.performSegue(withIdentifier: "itemList", sender: self)
                    case let .error(error):
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                }
            })
        case .getEntitlements:
            let alert = UIAlertController(title: "",
                                          message: "Please enter the subscriptionID",
                                          preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
                if let textFields = alert.textFields, let customerTextField = textFields.first {
                    Chargebee.shared.retrieveEntitlements(forSubscriptionID: customerTextField.text ?? "AzZlGJTC9U3tw4nF") { result in
                        switch result {
                        case let .success(entitlements):
                            debugPrint("items: \(entitlements)")
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Chargebee", message: "\(entitlements.list.count) entitlements found", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alertController, animated: true, completion: nil)

                            }

                        case let .error(error):
                            debugPrint("Error: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Chargebee", message: "\(error.localizedDescription)", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alertController, animated: true, completion: nil)

                            }

                        }
                        
                    }
                }
            }
            defaultAction.isEnabled = true
            alert.addAction(defaultAction)
            alert.addTextField { (textField) in
                 textField.delegate = self
            }
            present(alert, animated: true, completion: nil)

        case .getAllPlan:
            print("List All Plans")
            Chargebee.shared.retrieveAllPlans(queryParams: ["sort_by[desc]": "name", "channel[is]": "app_store"   ]) { result in
                switch result {
                case let .success(plansList):
                    var plans  = [CBPlan]()
                    for plan in  plansList.list {
                        plans.append(plan.plan)
                    }
                    self.plans = plans
                    debugPrint("items: \(self.plans)")
                    DispatchQueue.main.async {
                        let vc = CBSDKPlansViewController()
                        vc.render(self.plans)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }

                case let .error(error):
                    debugPrint("Error: \(error.localizedDescription)")
                }
            }
        case .restore:
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            CBPurchase.shared.restorePurchases(includeInActiveProducts: true) { result in
                switch result {
                case .success(let response):
                    if response.count > 0 {
                        print("Purchase products history:",response)
                        for subscription in response {
                            if subscription.storeStatus.rawValue == StoreStatus.Active.rawValue{
                                DispatchQueue.main.async {
                                    self.view.activityStopAnimating()
                                    let alertController = UIAlertController(title: "Chargebee", message: "Successfully restored purchases", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }else {
                                DispatchQueue.main.async {
                                    self.view.activityStopAnimating()
                                    
                                    let alertController = UIAlertController(title: "Chargebee", message: "No Active products to Restore", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                        
                        
                    }else {
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            
                            let alertController = UIAlertController(title: "Chargebee", message: "No products to Restore", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                case .failure(let error):
                    var errorMessage: String?
                    switch error {
                    case .noReceipt:
                        debugPrint("noReceipt",error)
                        errorMessage = error.localizedDescription
                    case .refreshReceiptFailed:
                        debugPrint("refreshReceiptFailed",error)
                        errorMessage = error.localizedDescription
                    case .restoreFailed:
                        debugPrint("restoreFailed",error)
                        errorMessage = error.localizedDescription
                    case .invalidReceiptURL:
                        debugPrint("invalidReceiptURL",error)
                        errorMessage = error.localizedDescription
                    case .invalidReceiptData:
                        debugPrint("invalidReceiptData",error)
                        errorMessage = error.localizedDescription
                    case .noProductsToRestore:
                        debugPrint("noProductsToRestore",error)
                        errorMessage = error.localizedDescription
                    case .serviceError(error: let error):
                        debugPrint("serviceError",error)
                        errorMessage = error
                    }
                    
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "\(errorMessage ?? "")", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension CBSDKOptionsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productList" {
            if let destinationVC = segue.destination as? CBSDKProductsTableViewController {
                destinationVC.products = self.products
            }
        } else if segue.identifier == "itemList" {
            if let destinationVC = segue.destination as?
                CBSDKItemsTableViewController {
                destinationVC.items = self.items
            }
        }
    }

}

enum ClientAction {
    case getPlan
    case getAllPlan
    case getAddon
    case createToken
    case initializeInApp
    case getProductIDs
    case getProducts
    case getSubscriptionStatus
    case processReceipt
    case getItems
    case getItem
    case getEntitlements
    case restore

}

extension ClientAction {
    var title: String {
        switch self {
        case .getAllPlan:
            return "Get Plans"
        case .getPlan:
            return "Get Plan"
        case .getAddon:
            return "Get Addon Details"
        case .createToken:
            return "Create Tokens"
        case .getProducts:
            return "Get Products"
        case .getSubscriptionStatus:
            return "Get Subscription Status"
        case .processReceipt:
            return "Verify Receipt"
        case .initializeInApp:
            return "Configure"
        case .getItems:
            return "Get Items"
        case .getItem:
            return "Get Item"
        case .getEntitlements:
            return "Get Entitlements"
        case .getProductIDs:
            return "Get Apple Specific Product Identifiers"
        case .restore:
            return "Restore Purcahses"
        }

    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIView {

    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647

        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false

        backgroundView.addSubview(activityIndicator)

        self.addSubview(backgroundView)
    }

    func activityStopAnimating() {
        if let background = viewWithTag(475647) {
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
}
