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
        case apiKeyTextField:
            customerIDTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    @IBAction private func initializeClicked(_ sender: UIButton) {
        guard canInitialise() else { return }
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))

        Chargebee.configure(site: siteNameTextField.unwrappedText,
                            publishableApiKey: apiKeyTextField.unwrappedText,
                            sdkKey: sdkKeyTextField.unwrappedText,
                            customerID: customerIDTextField.unwrappedText,
                            allowErrorLogging: true)
        
        CBAuthenticationManager.authenticate(forSDKKey: sdkKeyTextField.unwrappedText) { result in
            
            switch result {
            case .success(let status):
                print(status)
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Chargebee", message: "Configuration Added.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.view.activityStopAnimating()

                }

                
            case .error(let error):
                print(error)
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Chargebee", message: "Configuration Failed.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.view.activityStopAnimating()
                }


            }
        }
    }
}

extension UITextField {
    var unwrappedText: String {
        return text ?? ""
    }
}
