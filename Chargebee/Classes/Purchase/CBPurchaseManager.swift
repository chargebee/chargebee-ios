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
    public var buyProductHandler: ((Result<(status:Bool, subscriptionId:String?, planId:String?), Error>) -> Void)?
    private var buyNonSubscriptionProductHandler: ((Result<NonSubscription, Error>) -> Void)?

    private var authenticationManager = CBAuthenticationManager()
    var productRequest: SKProductsRequestFactory = SKProductsRequestFactory()

    var restoredPurchasesCount = 0
    private var activeProduct: CBProduct?
    var customer: CBCustomer?
    
    var restoreResponseHandler: ((Result<[InAppSubscription], RestoreError>) -> Void)?
    var refreshHandler: RestoreResultCompletion<String>?
    var includeInActiveProducts = false
    private var productType: ProductType?

    // MARK: - Init
    private override init() {
        super.init()
        startPaymentQueueObserver()
    }

    deinit{
        stopPaymentQueueObserver()
    }
}

public struct CBProduct {
    public let product: SKProduct
    public var discount: SKPaymentDiscount?
    public init(product: SKProduct, discount: SKPaymentDiscount? = nil) {
        self.product = product
        self.discount = discount
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
        
    func purchaseNonSubscriptionProduct(product: CBProduct, customer : CBCustomer? = nil ,productType : ProductType, completion handler: @escaping ((_ result: Result<NonSubscription, Error>) -> Void)) {
        buyNonSubscriptionProductHandler = handler
        activeProduct = product
        self.productType = productType
        self.customer = customer
        self.purchaseProductHandler(product: product, completion: handler)
    }
    
    //Buy the product
    @available(*, deprecated, message: "This will be removed in upcoming versions, Please use this API func purchaseProduct(product: CBProduct, customer : CBCustomer? = nil, completion)")
    func purchaseProduct(product: CBProduct, customerId : String? = "",completion handler: @escaping ((_ result: Result<(status:Bool, subscriptionId:String?, planId:String?), Error>) -> Void)) {
        buyProductHandler = handler
        activeProduct = product
        self.customer = CBCustomer(customerID: customerId ?? "")
        self.purchaseProductHandler(product: product, completion: handler)
    }
    
    func purchaseProduct(product: CBProduct, customer : CBCustomer? = nil, completion handler: @escaping ((_ result: Result<(status:Bool, subscriptionId:String?, planId:String?), Error>) -> Void)) {
        buyProductHandler = handler
        activeProduct = product
        self.customer = customer
        self.purchaseProductHandler(product: product, completion: handler)
    }
    
    func restorePurchases(includeInActiveProducts:Bool = false ,completion handler: @escaping ((_ result: Result<[InAppSubscription], RestoreError>) -> Void)) {
        self.restoreResponseHandler = handler
        self.includeInActiveProducts = includeInActiveProducts
        self.restoredPurchasesCount = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func purchaseProductHandler<T>(product: CBProduct,completion handler: @escaping ((_ result: Result<T, Error>) -> Void)) {
        
        guard CBAuthenticationManager.isSDKKeyPresent() else {
            handler(.failure(CBPurchaseError.cannotMakePayments))
            return
        }
        
        if !CBPurchase.shared.canMakePayments() {
            handler(.failure(CBPurchaseError.cannotMakePayments))
        } else {
            authenticationManager.isSDKKeyValid { status in
                if status {
                    let payment = SKMutablePayment(product: product.product)
                    if let discount = product.discount {
                        payment.paymentDiscount = discount
                    }
                    SKPaymentQueue.default().add(payment)
                    
                } else {
                    handler(.failure(CBPurchaseError.invalidSDKKey))
                }
            }
        }
    }
}

// MARK: - Private methods
extension CBPurchase {
    func startPaymentQueueObserver() {
        SKPaymentQueue.default().add(self)
    }

    func stopPaymentQueueObserver() {
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
        if request is SKReceiptRefreshRequest {
            completedRefresh(error: error)
        }else{
            receiveProductsHandler?(.failure(.skRequestFailed))
        }
        request.cancel()
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
                    if let _ = product.product.subscriptionPeriod {
                        validateReceipt(product, completion: buyProductHandler)
                    }else{
                        validateReceiptForNonSubscriptions(product, self.productType, completion: buyNonSubscriptionProductHandler)
                    }
                }
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                receivedRestoredTransaction()
            case .failed:
                if let error = transaction.error as? SKError{
                    debugPrint("Error :",error)
                    switch  error.errorCode {
                    case 0:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.unknown)
                    case 1:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidClient)
                    case 2:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.userCancelled)
                    case 3:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.paymentFailed)
                    case 4:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.paymentNotAllowed)
                    case 5:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.productNotAvailable)
                    case 7:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.networkConnectionFailed)
                    case 8:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidSandbox)
                    case 9:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.privacyAcknowledgementRequired)
                    case 11:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidOffer)
                    case 12:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidPromoCode)
                    case 13:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidPromoOffer)
                    case 14:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.invalidPrice)
                    case 15:
                        self.invokeProductHandler(forProduct: self.activeProduct?.product, error: CBPurchaseError.userCancelled)
                    default:
                        if let _ = activeProduct?.product.subscriptionPeriod {
                            buyProductHandler?(.failure(error))
                        }else {
                            buyNonSubscriptionProductHandler?(.failure(error))
                        }
                    }
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
        receiveRestoredTransactionsFinished(nil)
    }

    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? RestoreError {
            receiveRestoredTransactionsFinished(error)
        }
    }
}

// chargebee methods
public extension CBPurchase {
    
    func validateReceiptForNonSubscriptions(_ product: CBProduct?,_ productType:
         ProductType?, completion: ((Result<NonSubscription, Error>) -> Void)?) {
        self.productType = productType
        
        guard let receipt = getReceipt(product: product) else {
            debugPrint("Couldn't read receipt data with error")
            completion?(.failure(CBError.defaultSytemError(statusCode: 0, message: "Could not read receipt data")))
            return
        }
        
        CBReceiptValidationManager.validateReceiptForNonSubscriptions(receipt: receipt) {
            (receiptResult) in DispatchQueue.main.async {
                switch receiptResult {
                case .success(let result):
                    debugPrint("Receipt: \(result)")
                    self.activeProduct = nil
                    completion?(.success(result))
                case .error(let error):
                    debugPrint(" Chargebee - Receipt Upload - Failure")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func validateReceipt(_ product: CBProduct?,completion: ((Result<(status:Bool, subscriptionId:String?, planId:String?), Error>) -> Void)?) {
        
        guard let receipt = getReceipt(product: product) else {
            debugPrint("Couldn't read receipt data with error")
            completion?(.failure(CBError.defaultSytemError(statusCode: 0, message: "Could not read receipt data")))
            return
        }
        
        CBReceiptValidationManager.validateReceipt(receipt: receipt) {
            (receiptResult) in DispatchQueue.main.async {
                switch receiptResult {
                case .success(let receipt):
                    debugPrint("Receipt: \(receipt)")
                    if receipt.subscriptionId.isEmpty {
                        completion?(.failure(CBError.defaultSytemError(statusCode: 400, message: "Invalid Purchase")))
                        return
                    }
                    self.activeProduct = nil
                    completion?(.success((true, receipt.subscriptionId, receipt.planId)))
                case .error(let error):
                    debugPrint(" Chargebee - Receipt Upload - Failure")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    private func getReceipt(product: CBProduct?) -> CBReceipt? {
        var receipt: CBReceipt?
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            debugPrint("No receipt Exist")
            return nil
        }
        guard let skProduct = product?.product, let currencyCode = skProduct.priceLocale.currencyCode else {
            return nil
        }
        do {
            let discountId = product?.discount?.identifier
            debugPrint("DiscountId: \(String(describing: discountId))")
            let price = skProduct.discounts.first(where: { $0.identifier == discountId })?.price ?? skProduct.price
            debugPrint("Using price: \(price)")
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            
            let receiptString = receiptData.base64EncodedString(options: [])
            debugPrint("Apple Purchase - success")
            receipt = CBReceipt(name: skProduct.localizedTitle, token: receiptString, productID: skProduct.productIdentifier, price: "\(price)", currencyCode: currencyCode, period: skProduct.subscriptionPeriod?.numberOfUnits ?? 0, periodUnit: Int(skProduct.subscriptionPeriod?.unit.rawValue ?? 0), customer: customer, productType: self.productType ?? .unknown)
        } catch {
            print("Couldn't read receipt data with error: " + error.localizedDescription)
        }
        return receipt
    }
    
    private func invokeProductHandler(forProduct product: SKProduct?, error: CBPurchaseError) {
        if let _ = product?.subscriptionPeriod {
            buyProductHandler?(.failure(error))
        }else {
            buyNonSubscriptionProductHandler?(.failure(error))
        }
    }
}

class SKProductsRequestFactory {
    func request(productIdentifiers: Set<String>) -> SKProductsRequest {
        return SKProductsRequest(productIdentifiers: productIdentifiers)
    }

}
