//
//  CBDemoPersistance.swift
//  Chargebee
//
//  Created by ramesh_g on 03/02/23.
//

import Foundation
import Chargebee

protocol CBPersistanceProtocal {
    static func saveProductIdentifierOnPurchase(for productId: String,type:String?)
    static func isPurchaseProductIDAvailable() ->Bool
    static func getProductIDFromCache() -> String?
    static func clearPurchaseIDFromCache()
    static func getProductTypeFromCache() -> ProductType?
    static func clearPurchaseProductType()
}


fileprivate let CBUserDefaults = UserDefaults.standard

public struct CBDemoPersistance: CBPersistanceProtocal {
    //MARK: - CBDemoPersistance struct properties
    static  let Product_Id = "Product_Id"
    static  let Product_type = "Product_type"
    static  var productTypeValue: ProductType = .unknown

    //MARK: - CBDemoPersistance struct functions
    static func isPurchaseProductIDAvailable() -> Bool {
        if (CBUserDefaults.value(forKey: Product_Id) != nil) {
            return true
        }
        return false
    }
    
    static func saveProductIdentifierOnPurchase(for productId: String, type: String? = "") {
        CBUserDefaults.set(productId.toBase64(), forKey: Product_Id)
        if let typeValue = type{
            CBUserDefaults.set(typeValue, forKey: "Product_type")
            debugPrint("Product type saved to cache :",typeValue)
        }
    }
    
    static  func getProductTypeFromCache() -> ProductType? {
        if let type =  CBUserDefaults.value(forKey: "Product_type") as? String{
            debugPrint("Retrieving saved Product type value from cache  :",type)
            if type == ProductType.Consumable.rawValue {
                productTypeValue = .Consumable
            }else if type == ProductType.NonConsumable.rawValue{
                productTypeValue = .NonConsumable
            }else{
                productTypeValue = .NonRenewingSubscription
            }
            return productTypeValue
        }
        return .unknown
    }
    
   static  func getProductIDFromCache() -> String? {
        if isPurchaseProductIDAvailable() {
            let id = CBUserDefaults.value(forKey: Product_Id) as! String
            return id.fromBase64()
        }
        return nil
    }
    
    static func clearPurchaseIDFromCache(){
        if isPurchaseProductIDAvailable() {
            CBUserDefaults.removeObject(forKey: Product_Id)
        }
     
    }
    
    static func clearPurchaseProductType(){
        if CBUserDefaults.value(forKey: "Product_type") != nil {
            CBUserDefaults.removeObject(forKey: "Product_type")
            debugPrint("Product_type removed from cache")
        }
    }

}

extension String {
    // Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    // Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
