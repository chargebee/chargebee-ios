//
//  CBDemoPersistance.swift
//  Chargebee
//
//  Created by ramesh_g on 03/02/23.
//

import Foundation

protocol CBPersistanceProtocal {
    static func saveProductIdentifierOnPurchase(for productId: String)
    static func isPurchaseProductIDAvailable() ->Bool
    static func getProductIDFromCache() -> String?
    static func clearPurchaseIDCache()
}


fileprivate let CBUserDefaults = UserDefaults.standard

public struct CBDemoPersistance: CBPersistanceProtocal {
    static  let Product_Id = "Product_Id"
    
    static func isPurchaseProductIDAvailable() -> Bool {
        if (CBUserDefaults.value(forKey: Product_Id) != nil) {
            return true
        }
        return false
    }
    
    static func saveProductIdentifierOnPurchase(for productId: String) {
        CBUserDefaults.set(productId.toBase64(), forKey: Product_Id)
    }
    
   static  func getProductIDFromCache() -> String? {
        if isPurchaseProductIDAvailable() {
            let id = CBUserDefaults.value(forKey: Product_Id) as! String
            return id.fromBase64()
        }
        return nil
    }
    
    static func clearPurchaseIDCache(){
        if isPurchaseProductIDAvailable() {
            debugPrint("Cleared cache")
            CBUserDefaults.removeObject(forKey: Product_Id)
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
