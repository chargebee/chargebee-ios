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
    private var currentBuyProduct: SKProduct?
    
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
        currentBuyProduct = product.product
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
//                buyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
                processReceiptFromApple()
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
extension CBPurchaseManager {
    fileprivate func processReceiptFromApple() {
    
        // Get the receipt if it's available
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                let price : Int = Int((currentBuyProduct?.price.doubleValue ?? 0.0) * Double(100));
                print(receiptString)
                print(price)
                print(currentBuyProduct?.priceLocale.currencyCode ?? "nil")
  
                CBReceiptValidationManager.validateReceipt(receipt: receiptString, productId: currentBuyProduct?.productIdentifier ?? "", price: String(price), currencyCode: currentBuyProduct?.priceLocale.currencyCode ?? "USD", customerId: CBEnvironment.customerID ) {
                    (receiptResult) in DispatchQueue.main.async {
                        switch receiptResult {
                        case .success(let receipt):
                            print(receipt)
                            if receipt.subscriptionId.isEmpty || !receipt.isValid {
                                self.buyProductHandler?(.failure(CBError.defaultSytemError(statusCode: 400, message: "Invalid Purchase")))
                                return
                            }
                            CBSubscriptionManager.fetchSubscriptionStatus(forID: receipt.subscriptionId) { subscriptionStatusResult in
                                switch subscriptionStatusResult {
                                case .success(let status):
                                    self.buyProductHandler?(.success(true))
                                    break
                                case .error(let error):
                                    self.buyProductHandler?(.failure(error))
                                    break
                                }
                            }
                        case .error(let error):
                            self.buyProductHandler?(.failure(error))
                            break
                        }
                    }
                }
                
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
}
