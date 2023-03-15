//
//  RestoreError.swift
//  Chargebee
//
//  Created by ramesh_g on 09/03/23.
//


import StoreKit

public enum RestoreError: Error {
    case noReceipt
    case refreshReceiptFailed
    case restoreFailed
    case invalidReceiptURL
    case invalidReceiptData
    case noProductsToRestore
    case serviceError(error: String)
}

extension RestoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noReceipt:
            return "No receipt found"
        case .refreshReceiptFailed:
            return "Refresh receipt failed"
        case .restoreFailed:
            return "Failed to restore Purchases"
        case .invalidReceiptURL:
            return "Invalid Receipt bundle URL"
        case .noProductsToRestore:
            return "Currently you dont have any active products to restore"
        case .invalidReceiptData:
            return "Rceipt data is not valid"
        case .serviceError(error: let errorMessage):
           return  errorMessage
        }
    }
}
