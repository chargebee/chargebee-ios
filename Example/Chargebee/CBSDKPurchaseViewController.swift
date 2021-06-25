//
//  PurchaseViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 18/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

protocol ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool)
    func willStartLongProcess()
    func didFinishLongProcess()
    func showIAPRelatedError(_ error: Error)
    func shouldUpdateUI()
    func didFinishRestoringPurchasesWithZeroProducts()
    func didFinishRestoringPurchasedProducts()
}

final class CBSDKPurchaseViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var txtSiteId: UITextField!
    @IBOutlet private weak var txtApiKey: UITextField!
    @IBOutlet private weak var txtDomain: UITextField!
    @IBOutlet private weak var txtproductID: UITextField!
    @IBOutlet private weak var txtCustomerId: UITextField!
    @IBOutlet private weak var txtResourceId: UITextField!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    
    private var delegate: ViewModelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSiteId.delegate = self;
        txtApiKey.delegate = self;
        txtDomain.delegate = self;
        txtproductID.delegate = self;
        txtCustomerId.delegate = self;
        txtResourceId.delegate = self;
    }
    
    // Methods or Functions
    func hideKeyboard() {
        txtSiteId.resignFirstResponder();
        txtApiKey.resignFirstResponder();
        txtDomain.resignFirstResponder();
        txtproductID.resignFirstResponder();
        txtCustomerId.resignFirstResponder();
        txtResourceId.resignFirstResponder();
    }
    
    // UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return pressed")
        hideKeyboard()
        return true
    }
        
    @IBAction private func submitBtnClicked(_ sender: Any) {
        
        guard let apiKey = txtApiKey.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let domain = txtDomain.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let siteId = txtSiteId.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let productId = txtproductID.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let customerId = txtCustomerId.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let resourceId = txtResourceId.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
        }

        delegate?.willStartLongProcess()
        let string: String = infoLabel.text ?? ""
        infoLabel.text = string + "Calling Apple Product API \n"
        /*IAPManager.shared.getProducts(productId: productId) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let products): do {
                    let string: String = self.infoLabel.text ?? ""
                    self.infoLabel.text = string+"Product Retrieved \n"
                }
                    case .failure(let error):
                        self.infoLabel.text = "Error in retrieve product Apple API"
                        self.delegate?.showIAPRelatedError(error)
                }
            }
        }*/
    }
}

