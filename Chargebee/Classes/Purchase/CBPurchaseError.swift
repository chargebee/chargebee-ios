//
//  CBPurchaseError.swift
//  Chargebee
//
//  Created by Imayaselvan on 23/05/21.
//

import Foundation

public enum CBPurchaseError: Error {
    case productIDNotFound
    case productsNotFound
    case skRequestFailed
    case cannotMakePayments
    case noProductToRestore
    case invalidSDKKey
    case invalidCustomerId
    case invalidCatalogVersion
    
    case userCancelled
    case paymentFailed
    case invalidPurchase
    case invalidProduct
    case networkConnectionFailed

}

extension CBPurchaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .productIDNotFound: return "Product identifiers not found."
        case .productsNotFound: return "Products not found."
        case .skRequestFailed: return "Request Failed. Please try again."
        case .cannotMakePayments: return "User cannot make payments"
        case .noProductToRestore: return "No products found to restore."
        case .invalidSDKKey:return "SDK key is invalid"
        case .invalidCustomerId: return "Customer Id is invalid"
        case .invalidCatalogVersion: return "Invalid Catalog Version"
        case .userCancelled: return "User Cancelled the Payment."
        case .paymentFailed: return "Payment Failed."
        case .invalidPurchase: return "You are already subscribed to this product."
        case .invalidProduct: return "Product id mismatch with the receipt"
        case .networkConnectionFailed: return " Device could not connect to the network."

        }
    }
}
