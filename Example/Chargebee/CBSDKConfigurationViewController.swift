//
//  InAppConfigurationViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 24/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKConfigurationViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var siteNameTextField: UITextField!
    @IBOutlet private weak var sdkKeyTextField: UITextField!
    @IBOutlet private weak var apiKeyTextField: UITextField!
    @IBOutlet private weak var customerIDTextField: UITextField!
    
    // MARK: - Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "Configure"
        // Do any additional setup after loading the view.
    }
    
    private func canInitialise() -> Bool {
        return siteNameTextField.isNotEmpty && sdkKeyTextField.isNotEmpty && apiKeyTextField.isNotEmpty && customerIDTextField.isNotEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case siteNameTextField:
            sdkKeyTextField.becomeFirstResponder()
        case sdkKeyTextField:
            apiKeyTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    @IBAction private func initializeClicked(_ sender: UIButton) {
//        guard canInitialise() else { return }
        Chargebee.configure(site: siteNameTextField.unwrappedText,
                            apiKey: apiKeyTextField.unwrappedText,
                            sdkKey: sdkKeyTextField.unwrappedText,
                            allowErrorLogging: true)
        }
    }

extension UITextField {
    var unwrappedText: String {
        return text ?? ""
    }
}
