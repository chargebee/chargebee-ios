//
//  InappPurchaseManager.swift
//  Chargebee
//
//  Created by Imayaselvan on 09/05/21.
//

import Foundation
import StoreKit

public class CBPurchase: NSObject {
    public static let shared = CBPurchase()
    private var productIDs: [String] = []
    public var receiveProductsHandler: ((_ result: Result<[CBProduct], CBPurchaseError>) -> Void)?
    public var buyProductHandler: ((Result<(status:Bool, subscriptionId:String?), Error>) -> Void)?
    
    private var authenticationManager = CBAuthenticationManager()
    var productRequest: SKProductsRequestFactory = SKProductsRequestFactory()

    private var restoredPurchasesCount = 0
    private var activeProduct: SKProduct?
    var customerID: String = ""

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
    // MARK: - Public methods
    // MARK: Purchase methods
    // Get the products with Product ID's
    func retrieveProducts(withProductID productIDs: [String], completion receiveProductsHandler: @escaping (_ result: Result<[CBProduct], CBPurchaseError>) -> Void) {
        self.receiveProductsHandler = receiveProductsHandler

        let request = self.productRequest.request(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    /// Get the products without Product ID's
    func retrieveProductIdentifers(queryParams: [String: String]? = nil, completion handler: @escaping ((_ result: Result<CBProductIDWrapper, Error>) -> Void)) {
        var params = queryParams ?? [String: String]()
        params["channel[is]"] = "app_store"
        /// Based on user Cataloge version Plan will fetch from chargebee system

        func retrieveProducts() {
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
        /// Check the Environment Version

        if CBEnvironment.version == .unknown {
            authenticationManager.authenticate(forSDKKey: CBEnvironment.sdkKey) { result in
                switch result {
                case .success(let status):
                    CBEnvironment.version = status.details.version ?? .unknown
                    retrieveProducts()
                case .error(let error):
                     print(error)
                    handler(.failure(CBPurchaseError.invalidCatalogVersion))
                }
            }
        } else {
            retrieveProducts()
        }
    }

    //Buy the product
    func purchaseProduct(product: CBProduct, customerId : String? = "" ,completion handler: @escaping ((_ result: Result<(status:Bool, subscriptionId:String?), Error>) -> Void)) {
        buyProductHandler = handler
        activeProduct = product.product
        customerID = customerId ?? ""
        guard CBAuthenticationManager.isSDKKeyPresent() else {
            handler(.failure(CBPurchaseError.cannotMakePayments))
            return
        }

        if !CBPurchase.shared.canMakePayments() {
            handler(.failure(CBPurchaseError.cannotMakePayments))
        } else {
            authenticationManager.isSDKKeyValid { status in
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
    func restorePurchases(completion handler: @escaping ((_ result: Result<(status:Bool, subscriptionId:String?), Error>) -> Void)) {
        buyProductHandler = handler
        restoredPurchasesCount = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - Private methods
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

// MARK: - SKProductsRequestDelegate methods
extension CBPurchase: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugPrint("response: \(response)")
        let products = response.products.cbProducts
        if products.isEmpty {
            receiveProductsHandler?(.failure(.productsNotFound))
            } else {
                receiveProductsHandler?(.success(products))
            }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
        receiveProductsHandler?(.failure(.skRequestFailed))
    }

    public func requestDidFinish(_ request: SKRequest) {
        // if needed
    }

}

// MARK: - SKPaymentTransactionObserver delegates
extension CBPurchase: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if let product = activeProduct {
                    validateReceipt(product, completion: buyProductHandler)
                }
            case .restored:
                restoredPurchasesCount += 1
                SKPaymentQueue.default().finishTransaction(transaction)

            case .failed:
                if let error = transaction.error as? SKError {
                    print(error)
                    debugPrint(transaction.error)
                    buyProductHandler?(.failure(error))
                }
                SKPaymentQueue.default().finishTransaction(transaction)

            case .deferred, .purchasing:
                // TODO: - Handle as required
                break
            @unknown default: break
            }
        }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if restoredPurchasesCount != 0 {
            buyProductHandler?(.success((true, nil)))
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

// chargebee methods
public extension CBPurchase {
    func validateReceipt(_ product: SKProduct?,completion: ((Result<(status:Bool, subscriptionId:String?), Error>) -> Void)?) {

        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            debugPrint("No receipt Exist")
            return
        }
        guard let product = product, let currencyCode = product.priceLocale.currencyCode, let period = product.subscriptionPeriod?.numberOfUnits, let unit = product.subscriptionPeriod?.unit.rawValue  else {
            return
        }
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)

            let receiptString = receiptData.base64EncodedString(options: [])
            debugPrint("Apple Purchase - success")
            let receipt = CBReceipt(name: product.localizedTitle, token: receiptString, productID: product.productIdentifier, price: "\(product.price)", currencyCode: currencyCode, customerId: self.customerID, period: period, periodUnit: Int(unit))
            CBReceiptValidationManager.validateReceipt(receipt: receipt) {
                (receiptResult) in DispatchQueue.main.async {
                    switch receiptResult {
                    case .success(let receipt):
                        debugPrint("Receipt: \(receipt)")
                        if receipt.subscriptionId.isEmpty {
                            completion?(.failure(CBError.defaultSytemError(statusCode: 400, message: "Invalid Purchase")))
                            return
                        }
                        completion?(.success((true, receipt.subscriptionId)))
                    case .error(let error):
                        debugPrint(" Chargebee - Receipt Upload - Failure")
                        completion?(.failure(error))
                    }
                }
            }
        } catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }

    }
}

class SKProductsRequestFactory {
    func request(productIdentifiers: Set<String>) -> SKProductsRequest {
        return SKProductsRequest(productIdentifiers: productIdentifiers)
    }

}
