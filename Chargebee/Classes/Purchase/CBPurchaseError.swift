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
    case invalidClient
    case networkConnectionFailed
    case privacyAcknowledgementRequired
    case unknown
    case paymentNotAllowed
    case productNotAvailable
    case invalidOffer
    case invalidPromoCode
    case invalidPrice
    case invalidPromoOffer
    case invalidSandbox


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
        case .invalidCustomerId: return "Customer ID is invalid."
        case .invalidCatalogVersion: return "Invalid catalog version"
        case .userCancelled: return "User cancelled the payment."
        case .paymentFailed: return "Payment is failed."
        case .invalidPurchase: return "Your subscription already exists for this product/Invalid Purchase."
        case .invalidClient: return "Purchase is restricted. Please change your account or device."
        case .networkConnectionFailed: return "Device does not have a network connection. Please connect the network and try again."
        case .privacyAcknowledgementRequired: return "User need to acknowledge Apple's privacy policy."
        case .unknown: return "Purchase is unavailable due to unknown or unexpected reason. Please try again later."
        case .paymentNotAllowed: return "The purchase is not available for the selected payment method."
        case .productNotAvailable: return "Product is not available in the selected store. Please change the store and try again."
        case .invalidOffer: return "Offer is invalid or expired."
        case .invalidPromoCode: return "Promo code is invalid or expired."
        case .invalidPrice: return "Price displayed in the App Store is invalid."
        case .invalidPromoOffer: return "Promotional offer is invalid or expired."
        case .invalidSandbox: return "Storekit not configured."

        }
    }
}
