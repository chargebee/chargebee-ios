//
//  CBProductsTableViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 23/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee
import SwiftyReachability

final class CBSDKProductsTableViewController: UITableViewController, UITextFieldDelegate,SwiftyReachabilityObserver {
    
    var products: [CBProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CBSDKProductTableViewCell.registerCellXib(with: self.tableView)
        self.title = "Products"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    func didChangeConnectionStatus(_ status: SwiftyConnectionStatus) {
        DispatchQueue.main.async {
            switch status {
                case .online:
                debugPrint("Connected")
                if CBDemoPersistance.isPurchaseProductIDAvailable(){
                    self.validateReceiptOnceInternetIsAvailable()
                }
                case .offline:
                debugPrint("Offline")
            }
        }
    }
    
    func didChangeConnectionType(_ type: SwiftyConnectionType?) {
        DispatchQueue.main.async {
            guard let connectionType = type else {
                return
            }
            switch connectionType {
            case .cellular(_):
                debugPrint("Cellular Network Connection")
            case .wifi:
                debugPrint("Wifi Network Connection")
            case .ethernet:
                debugPrint("Ethernet Network Connection")
              
            }
        }
    }

    func validateReceiptForNonSubscriptions(_ product: CBProduct){
        
        if let type = CBDemoPersistance.getProductTypeFromCache()  {
            CBPurchase.shared.validateReceiptForNonSubscriptions(product,type) { result in
                switch result {
                case .success(let result):
                    if CBDemoPersistance.isPurchaseProductIDAvailable(){
                        CBDemoPersistance.clearPurchaseIDFromCache()
                    }
                    if (CBDemoPersistance.getProductTypeFromCache() != nil) {
                        CBDemoPersistance.clearPurchaseProductType()
                    }
                    print(result.chargeID )
                    print(result.invoiceID)
                    print(result.customerID)
                case .failure(let error):
                    print("error",error.localizedDescription)
                }
            }
        }
    }
    
    func ValidateReceipt(_ product: CBProduct){
        CBPurchase.shared.validateReceipt(product) { result in
            switch result {
            case .success(let result):
                print(result.status )
                print(result.subscriptionId ?? "")
                print(result.planId ?? "")
                if CBDemoPersistance.isPurchaseProductIDAvailable(){
                    CBDemoPersistance.clearPurchaseIDFromCache()
                }
            case .failure(let error):
                print("error",error.localizedDescription)
            }
        }
    }
    
    func validateReceiptOnceInternetIsAvailable() {
        if let productID = CBDemoPersistance.getProductIDFromCache() {
            // Getting the productID from Cache and with ProductID we will get the product using retrieveProducts API and Validate Receipt
            self.view.activityStartAnimating(activityColor: .gray, backgroundColor: .gray)
            CBPurchase.shared.retrieveProducts(withProductID: [productID] as! [String]) { result in
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                switch result {
                case let .success(products):
                    if let product = products.first {
                        if let _ = product.product.subscriptionPeriod {
                            self.ValidateReceipt(product)
                        }else{
                            self.validateReceiptForNonSubscriptions(product)
                        }
                    }
                case let .failure(error):
                    debugPrint("Error while trying to retreive product on receipt validation: \(error.localizedDescription)")
                }
            }
        }
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CBSDKProductTableViewCell.self), for: indexPath) as! CBSDKProductTableViewCell
        let product: CBProduct = products[indexPath.row]
        cell.product = product
        cell.titleLabel.text = product.product.localizedTitle
        cell.priceLabel.text = "\(product.product.price)"
        var buttonTitle: String = "Buy"
        cell.delegate = self
        if #available(iOS 11.2, *) {
            if let _ = product.product.subscriptionPeriod {
                buttonTitle = "Subscribe"
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
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func registerCellXib(with tableview: UITableView) {
        let nib = UINib(nibName: self.storyboardID, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: self.storyboardID)
    }
}

extension CBSDKProductsTableViewController: ProductTableViewCellDelegate {
    
    func buyOnetimePurchase(withproduct: CBProduct) {
        func purchase(customerID: String,productTypeString:String) {
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            let customer = CBCustomer(customerID: customerID,firstName:"",lastName: "",email: "")
            
            let type: ProductType!
            if productTypeString == ProductType.Consumable.rawValue{
                type = .Consumable
            }else if productTypeString == ProductType.NonConsumable.rawValue{
                type = .NonConsumable
            }else if productTypeString == ProductType.NonRenewingSubscription.rawValue{
                type = .NonRenewingSubscription
            }else{
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    let alertController = UIAlertController(title: "Chargebee", message: "Please enter product type", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            print("product Type:",type.rawValue)
            // Note: Make sure we clear the cache after completion of respective task if your trying to validate receipt in offline case

            if CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.clearPurchaseIDFromCache()
            }
            if !CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.saveProductIdentifierOnPurchase(for: withproduct.product.productIdentifier,type: productTypeString)
            }
            
            
            CBPurchase.shared.purchaseNonSubscriptionProduct(product: withproduct,customer: customer,productType: type) { result in
                print(result)
                switch result {
                case .success(let result):
                    print("customerID:",result.customerID)
                    print("chargeID:",result.chargeID )
                    print("invoiceID:",result.invoiceID )
                    
                    if CBDemoPersistance.isPurchaseProductIDAvailable(){
                        CBDemoPersistance.clearPurchaseIDFromCache()
                    }
                    if (CBDemoPersistance.getProductTypeFromCache() != nil) {
                        CBDemoPersistance.clearPurchaseProductType()
                    }
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
                                      preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
            if let textFields = alert.textFields, let customerTextField = textFields.first {
                let alert = UIAlertController(title: "",
                                              message: "Please enter ProductType",
                                              preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
                    if let textFields = alert.textFields, let productTypeField = textFields.first {
                        if ((productTypeField.text?.isEmpty) != nil) {
                            purchase(customerID: customerTextField.text ?? "",productTypeString: productTypeField.text ?? "")
                        }
                    }
                }
                defaultAction.isEnabled = true
                alert.addAction(defaultAction)
                alert.addTextField { (textField) in
                    textField.delegate = self
                }
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        defaultAction.isEnabled = true
        alert.addAction(defaultAction)
        alert.addTextField { (textField) in
            textField.delegate = self
        }
        present(alert, animated: true, completion: nil)
    }
    
    func buyProduct(withProduct: CBProduct) {
        
        func purchase(customerID: String) {
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            // Note: Make sure we clear the cache after completion of respective task if your trying to validate receipt in offline case
            if CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.clearPurchaseIDFromCache()
            }
            
            if !CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.saveProductIdentifierOnPurchase(for: withProduct.product.productIdentifier)
            }
            let customer = CBCustomer(customerID: customerID,firstName:"",lastName: "",email: "")
            CBPurchase.shared.purchaseProduct(product: withProduct,customer: customer) { result in
                print(result)
                switch result {
                case .success(let result):
                    print(result.status)
                    print(result.subscriptionId ?? "")
                    print(result.planId ?? "")
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "success", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    if CBDemoPersistance.isPurchaseProductIDAvailable(){
                        CBDemoPersistance.clearPurchaseIDFromCache()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    guard let errorDetails = error as? CBError else{
                        print("error has been casted to CBError")
                        return
                    }
                    switch errorDetails {
                    case .operationFailed(errorResponse: let errorResponse),
                            .invalidRequest(errorResponse: let errorResponse),      .paymentFailed(errorResponse: let errorResponse):
                        print("errorResponse",errorResponse)
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            let alertController = UIAlertController(title: "Chargebee", message: "\(error.localizedDescription)", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    case .serverError(let errorResponse):
                        // Retry Validating receipt here with below method in case server is not responding.
                        print("Error:",errorResponse)
                        if let _ = withProduct.product.subscriptionPeriod {
                            self.ValidateReceipt(withProduct)
                        }else {
                            self.validateReceiptForNonSubscriptions(withProduct)
                        }
                    }
                }
            }
        }
        
        let alert = UIAlertController(title: "",
                                      message: "Please enter customerID",
                                      preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
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
    
    
    func buyClicked(withProduct: CBProduct) {
        
        func purchase(customerID: String) {
            if CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.clearPurchaseIDFromCache()
            }
            // Note: Make sure we clear the cache after completion of respective task if your trying to validate receipt in offline case

            if !CBDemoPersistance.isPurchaseProductIDAvailable(){
                CBDemoPersistance.saveProductIdentifierOnPurchase(for: withProduct.product.productIdentifier)
            }
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            CBPurchase.shared.purchaseProduct(product: withProduct,customerId: customerID) { result in
                
                print(result)
                switch result {
                case .success(let result):
                    print(result.status)
                    print(result.subscriptionId ?? "")
                    print(result.planId ?? "")
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "success", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    if CBDemoPersistance.isPurchaseProductIDAvailable(){
                        CBDemoPersistance.clearPurchaseIDFromCache()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    guard let errorDetails = error as? CBError else{
                        print("error has been casted to CBError")
                        return
                    }
                    switch errorDetails {
                    case .operationFailed(errorResponse: let errorResponse),
                            .invalidRequest(errorResponse: let errorResponse),      .paymentFailed(errorResponse: let errorResponse):
                        print("errorResponse",errorResponse)
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            let alertController = UIAlertController(title: "Chargebee", message: "\(error.localizedDescription)", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    case .serverError(let errorResponse):
                        // Retry Validating receipt here with below method in case server is not responding.
                        print("Error:",errorResponse)
                        
                        if let _ = withProduct.product.subscriptionPeriod {
                            self.ValidateReceipt(withProduct)
                        }else{
                            self.validateReceiptForNonSubscriptions(withProduct)
                        }
                        
                    }
                }
            }
        }
        
        let alert = UIAlertController(title: "",
                                      message: "Please enter customerID",
                                      preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
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
