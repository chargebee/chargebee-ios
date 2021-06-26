//
//  InappPurchaseManager.swift
//  Chargebee
//
//  Created by Imayaselvan on 09/05/21.
//

import Foundation
import StoreKit

protocol CBPurchaseDataSource {
    func productIDs() -> [String]
}

public class CBPurchaseManager: NSObject {
    public static let shared = CBPurchaseManager()
    
    private var productIDs: [String] = []
    public var receiveProductsHandler: ((_ result: Result<[CBProduct], CBPurchaseError>) -> Void)?
    public var buyProductHandler: ((Result<Bool, Error>) -> Void)?
    private var restoredPurchasesCount = 0
    var datasource: CBPurchaseDataSource?
    private var activeProduct: SKProduct?
    
    // MARK: - Init
    private override init() {
        super.init()
        startPaymentQueueObserver()
    }
}

public struct CBProduct {
    public let product: SKProduct
}

extension Array where Element == SKProduct {
    var cbProducts: [CBProduct] {
        return self.map { $0.cbProduct }
    }
}

extension SKProduct {
    var cbProduct: CBProduct {
        CBProduct(product: self)
    }
}

public extension CBPurchaseManager {
    //MARK: - Public methods
    //MARK: Purchase methods
    //Get the products
    func retrieveProducts(withProductID productID: String = "", completion receiveProductsHandler: @escaping (_ result: Result<[CBProduct], CBPurchaseError>) -> Void) {
        self.receiveProductsHandler = receiveProductsHandler
        
//        var productIDs: [String] = []
//        if productID.count > 0 {
//            productIDs = [productID]
//        } else {
//            // Get the product identifiers.
//            guard let productIDArray = datasource?.productIDs() else {
//                receiveProductsHandler(.failure(.productIDNotFound))
//                return
//            }
//            productIDs = productIDArray
//        }
 
        //let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        let request = SKProductsRequest(productIdentifiers: Set(["Chargebee02","Chargebee03","Chargebee04", "Chargebee05", "Chargebee06"]))
        request.delegate = self
        request.start()
    }
    
    //Buy the product
    func buy(product: CBProduct, completion handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        buyProductHandler = handler
        activeProduct = product.product
        if !CBPurchaseManager.shared.canMakePayments() {
            handler(.failure(CBPurchaseError.cannotMakePayments))
        } else {
            let payment = SKPayment(product: product.product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    //Restore the purchase
    func restorePurchases(completion handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        buyProductHandler = handler
        restoredPurchasesCount = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

//MARK: - Private methods
extension CBPurchaseManager {
    private func startPaymentQueueObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    private func stopPaymentQueueObserver() {
        SKPaymentQueue.default().remove(self)
    }
    
    private func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

//MARK: - SKProductsRequestDelegate methods
extension CBPurchaseManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugPrint("response: \(response)")
        let products = response.products.cbProducts
        products.count > 0 ? receiveProductsHandler?(.success(products)) : receiveProductsHandler?(.failure(.productsNotFound))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        receiveProductsHandler?(.failure(.skRequestFailed))
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        //if needed
    }
    
}

// MARK: - SKPaymentTransactionObserver delegates
extension CBPurchaseManager: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if let productId = activeProduct?.productIdentifier,
                   let price = activeProduct?.price,
                   let currencyCode = activeProduct?.priceLocale.currencyCode {
                    let priceValue : Int = Int((price.doubleValue) * Double(100))
                    validateReceipt(for: productId, String(priceValue), currencyCode: currencyCode, completion: buyProductHandler)
                }
            case .restored:
                restoredPurchasesCount += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    buyProductHandler?(.failure(error))
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing:
                //TODO: - Handle as required
                break
            @unknown default: break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if restoredPurchasesCount != 0 {
            buyProductHandler?(.success(true))
        } else {
            buyProductHandler?(.failure(CBPurchaseError.noProductToRestore))
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            buyProductHandler?(.failure(error))
        }
    }
}

//chargebee methods
public extension CBPurchaseManager {
    func validateReceipt(for productID: String, _ price: String, currencyCode: String, completion: ((Result<Bool, Error>) -> Void)?) {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            debugPrint("No receipt Exist")
            return
        }
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            print(receiptData)
            
            let receiptString = receiptData.base64EncodedString(options: [])

            CBReceiptValidationManager.validateReceipt(receipt: receiptString, productId: productID, price: price, currencyCode: currencyCode, customerId: CBEnvironment.customerID ) {
                (receiptResult) in DispatchQueue.main.async {
                    switch receiptResult {
                    case .success(let receipt):
                        debugPrint("Receipt: \(receipt)")
                        if receipt.subscriptionId.isEmpty || !receipt.isValid {
                            completion?(.failure(CBError.defaultSytemError(statusCode: 400, message: "Invalid Purchase")))
                            return
                        }
                        CBSubscriptionManager.fetchSubscriptionStatus(forID: receipt.subscriptionId) { subscriptionStatusResult in
                            switch subscriptionStatusResult {
                            case .success:
                                completion?(.success(true))
                            case .error(let error):
                                completion?(.failure(error))
                            }
                        }
                    case .error(let error):
                        completion?(.failure(error))
                    }
                }
            }
            
        }
        catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
    }
}
