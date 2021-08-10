//
//  CBSDKOptionsViewController.swift
//  Chargebee
//
//  Created by cb-prabu on 07/07/2020.
//  Copyright (c) 2020 cb-prabu. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKOptionsViewController: UIViewController {
    
    private var products: [CBProduct] = []
    private var items : [CBItemWrapper] = []
    private lazy var actions: [ClientAction] = [.getPlan, .getAddon, .createToken, .initializeInApp, .getProducts, .getSubscribtionStatus, .processReceipt, .getItems , .getItem]
    
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
             .getSubscribtionStatus,
             .initializeInApp,
             .processReceipt,
             .getItem:
              performSegue(withIdentifier: selectedAction.title, sender: self)
        case .getProducts:
            CBPurchaseManager.shared.fetchProductsfromStore { result in
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
            }
        case .getItems:
            CBItem.getAllItems(queryParams :["limit": "8","sort_by[desc]" : "name"], completion:  { result in
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
    case getAddon
    case createToken
    case initializeInApp
    case getProducts
    case getSubscribtionStatus
    case processReceipt
    case getItems
    case getItem
}

extension ClientAction {
    var title: String {
        switch self {
        case .getPlan:
            return "Get Plan Details"
        case .getAddon:
            return "Get Addon Details"
        case .createToken:
            return "Create Tokens"
        case .getProducts:
            return "Get Products"
        case .getSubscribtionStatus:
            return "Get Subscription Status"
        case .processReceipt:
            return "Verify Receipt"
        case .initializeInApp:
            return "Configure"
        case .getItems:
            return "V2 Get Items"
        case .getItem:
            return "V2 Get Item"
            
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


extension UIView{
    
    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)
        
        self.addSubview(backgroundView)
    }
    
    func activityStopAnimating() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
}

