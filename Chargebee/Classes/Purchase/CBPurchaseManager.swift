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

public class CBPurchase: NSObject {
    public static let shared = CBPurchase()
    
    private var productIDs: [String] = []
    public var receiveProductsHandler: ((_ result: Result<[CBProduct], CBPurchaseError>) -> Void)?
    public var buyProductHandler: ((Result<Bool, Error>) -> Void)?
    private var restoredPurchasesCount = 0
    var datasource: CBPurchaseDataSource?
    private var activeProduct: SKProduct?
    var customerID : String = ""
    
    // MARK: - Init
    private override init() {
        super.init()
        startPaymentQueueObserver()
    }
}

public struct CBProduct {
    public let product: SKProduct
    init(product: SKProduct) {
        self.product = product
    }
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

public extension CBPurchase {
    //MARK: - Public methods
    //MARK: Purchase methods
    //Get the products with Product ID's
    func retrieveProducts(withProductID productIDs: [String], completion receiveProductsHandler: @escaping (_ result: Result<[CBProduct], CBPurchaseError>) -> Void) {
        self.receiveProductsHandler = receiveProductsHandler
        
        // To Be commented for Local testing of Get Products
        var _productIDs: [String] = []
        if productIDs.count > 0 {
            _productIDs = productIDs
        } else {
            // Get the product identifiers.
            guard let productIDArray = datasource?.productIDs() else {
                receiveProductsHandler(.failure(.productIDNotFound))
                return
            }
            _productIDs = productIDArray
        }
 
        let request = SKProductsRequest(productIdentifiers: Set(_productIDs))
        // End of To Be Commented region for Local testing of Get Products
        
        // To Be uncommented for Local testing of Get Products
        //let request = SKProductsRequest(productIdentifiers: Set(["Chargebee02","Chargebee03","Chargebee04", "Chargebee05", "Chargebee06"]))
        // End of To Be uncommented for Local testing of Get Products
        request.delegate = self
        request.start()
    }
  
    //Get the products without Product ID's
    func retrieveProductIdentifers(queryParams : [String:String]? = nil, completion handler: @escaping ((_ result: Result<CBProductIDWrapper, Error>) -> Void)) {
        var params = queryParams ?? [String:String]()
        params["channel[is]"] = "app_store"
        switch CBEnvironment.version {
        case .v1:
            CBProductsV1.getProducts(queryParams: params) { wrapper in
                handler(.success(wrapper))
                return
            }
        case .v2:
            CBProductsV2.getProducts(queryParams: params) { wrapper in
                handler(.success(wrapper))
                return
            }
        case .unknown:
            handler(.failure(CBPurchaseError.invalidCatalogVersion))
            return
        }
        
    }
    

    //Buy the product
    func purchaseProduct(product: CBProduct, customerId : String ,completion handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        buyProductHandler = handler
        activeProduct = product.product
        customerID = customerId
        guard CBAuthenticationManager.isSDKKeyPresent() else {
            handler(.failure(CBPurchaseError.cannotMakePayments))
            return
        }
        
        if !CBPurchase.shared.canMakePayments() {
            handler(.failure(CBPurchaseError.cannotMakePayments))
        } else {
            CBAuthenticationManager.isSDKKeyValid { status in
                if status {
                    let payment = SKPayment(product: product.product)
                    SKPaymentQueue.default().add(payment)

                } else {
                    handler(.failure(CBPurchaseError.invalidSDKKey))
                }
            }
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
extension CBPurchase {
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
extension CBPurchase: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugPrint("response: \(response)")
        let products = response.products.cbProducts
        products.count > 0 ? receiveProductsHandler?(.success(products)) : receiveProductsHandler?(.failure(.productsNotFound))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
        receiveProductsHandler?(.failure(.skRequestFailed))
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        //if needed
    }
    
}

// MARK: - SKPaymentTransactionObserver delegates
extension CBPurchase: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if let productId = activeProduct?.productIdentifier,
                   let price = activeProduct?.price,
                   let currencyCode = activeProduct?.priceLocale.currencyCode {
                   let priceValue : Int = Int((price.doubleValue) * Double(100))
                   let name = activeProduct?.localizedTitle ?? productId
                    validateReceipt(for: productId, name: name, String(priceValue), currencyCode: currencyCode, customerId:customerID,completion: buyProductHandler)
                }
            case .restored:
                restoredPurchasesCount += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    print(error)
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
public extension CBPurchase {
    func validateReceipt(for productID: String,name:String,  _ price: String, currencyCode: String, customerId :String,completion: ((Result<Bool, Error>) -> Void)?) {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            debugPrint("No receipt Exist")
            return
        }
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            
            let receiptString = receiptData.base64EncodedString(options: [])
//            print("Receipt String is :\(receiptString)")
            debugPrint("Apple Purchase - success")

            CBReceiptValidationManager.validateReceipt(receipt: receiptString, productId: productID,name: name, price: price, currencyCode: currencyCode, customerId: customerID ) {
                (receiptResult) in DispatchQueue.main.async {
                    switch receiptResult {
                    case .success(let receipt):
                        debugPrint("Receipt: \(receipt)")
                        if receipt.subscriptionId.isEmpty {
                            completion?(.failure(CBError.defaultSytemError(statusCode: 400, message: "Invalid Purchase")))
                            return
                        }
                        //TODO: Refactor here
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            CBSubscription.retrieveSubscription(forID: receipt.subscriptionId) { subscriptionStatusResult in
                                switch subscriptionStatusResult {
                                case .success:
                                    completion?(.success(true))
                                case .error(let error):
                                    completion?(.failure(error))
                                }
                            }
                        }
                    case .error(let error):
                        debugPrint("Chargebee - Receipt Upload - Failure")
                        completion?(.failure(error))
                    }
                }
            }
        }
        catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
    }
}
