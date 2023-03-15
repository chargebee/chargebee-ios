//
//  CBPurchaseManager+Extension.swift
//  Chargebee
//
//  Created by ramesh_g on 17/02/23.
//

import Foundation
import StoreKit

public typealias ReceiptResult<Success> = Swift.Result<Success, RestoreError>
public typealias RestoreResultCompletion<Success> = (ReceiptResult<Success>) -> Void

extension CBPurchase {
    func receivedRestoredTransaction(_ transaction: SKPaymentTransaction) {
        self.restoredPurchasesCount += 1
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func receiveRestoredTransactionsFinished(_ error: RestoreError?) {
        if let error = error {
            debugPrint("Failed to restore purchases: \(error.localizedDescription)")
            self.restoreResponseHandler?(.failure(.restoreFailed))
            return
        }
        
        if self.restoredPurchasesCount == 0 {
            debugPrint("Successfully restored zero purchases.")
        }
        
        self.validateReceipt(refreshIfEmpty: true)
    }
    
    func getReceipt(refreshIfEmpty: Bool, _ completion: @escaping RestoreResultCompletion<String>) {
        let result = self.bundleReceipt()
        self.refreshHandler = completion
        
        switch result {
        case .success:
            completion(result)
            return
        case .failure:
            if refreshIfEmpty {
                self.refreshReceipt(completion)
            } else {
                completion(result)
                self.refreshReceipt{_ in}
            }
        }
    }
    
    func bundleReceipt() -> ReceiptResult<String> {
        
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            debugPrint("No receipt Exist")
            return .failure(.noReceipt)
        }
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            let receiptString = receiptData.base64EncodedString(options: [])
            return .success(receiptString)
        }catch{
            debugPrint("Couldn't read receipt data with error: " + error.localizedDescription)
            return .failure(.invalidReceiptData)
        }
    }
    
    private func refreshReceipt(_ completion: @escaping RestoreResultCompletion<String>) {
        self.refreshHandler = completion
        debugPrint("Start refresh receipt")
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        self.restoreHandlerisActive = true
        request.start()
    }
}

extension CBPurchase{
    public func validateReceipt(refreshIfEmpty: Bool) {
        
        getReceipt(refreshIfEmpty: refreshIfEmpty) { receiptString in
            switch receiptString {
            case .success(let receiptString):
                self.receiptVerification(receipt: receiptString, self.restoreResponseHandler)
            case .failure(let error):
                debugPrint("Error While trying to fetch receipt",error)
                self.restoreResponseHandler?(.failure(error))
            }
        }
    }
    
    func receiptVerification(receipt: String, _ completion: ((Result<[InAppSubscription], RestoreError>) -> Void)?) {
        
        CBRestorePurchaseManager().restorePurchases(receipt: receipt) { result in
            switch result{
            case .success(let restoreResult):
                if self.includeInActiveProducts{
                    completion?(.success(restoreResult.inAppSubscriptions))
                }else{
                    let  activeSubscriptionsList = restoreResult.inAppSubscriptions.filter {
                        return $0.storeStatus == "active"  || $0.storeStatus == "in_trial"
                    }
                    completion?(.success(activeSubscriptionsList))
                }
                
                let productIdsList = restoreResult.inAppSubscriptions.map { planID in
                    if let planID = planID.planID {
                        return planID
                    }
                    return ""
                }
                if productIdsList.count > 0 {
                    self.getPruchaseProductsList(productIds: productIdsList)
                }
            case .error(let error):
                debugPrint("Error While Restoring:",error.localizedDescription)
                completion?(.failure(.serviceError(error: error.localizedDescription)))
            }
        }
    }
    
    func getPruchaseProductsList(productIds:[String]) {
        
        self.retrieveProducts(withProductID:productIds) { result in
            switch result {
            case .success(let products):
                self.syncPurhcasesWithChargebee(products: products)
            case.failure(let error):
                debugPrint("Error While retriving products to sync with Chargebeee:",error)
            }
        }
    }
    
    func syncPurhcasesWithChargebee(products:[CBProduct]) {
        
        var operationQueue: BackgroundOperationQueue? = BackgroundOperationQueue()
        for product in products {
            operationQueue?.addOperation{
                self.validateReceipt(product.product, completion: nil)
            }
        }
        operationQueue?.waitUntilAllOperationsAreFinished()
        operationQueue?.completionBlock = {
            operationQueue = nil
        }
    }
    
    public func complatedRefresh(error: Error?) {
        
        if let error = error {
            debugPrint("Refresh receipt failed. \(error.localizedDescription)")
            self.refreshHandler?(.failure(.refreshReceiptFailed))
        } else {
            debugPrint("Refresh receipt success.")
            result = self.bundleReceipt()
        }
        switch result {
        case .success(let receiptString):
            self.refreshHandler?(.success(receiptString))
        case .failure(_):
            self.refreshHandler?(.failure(.refreshReceiptFailed))
        case .none:
            print("Default:")
        }
    }
    
}

extension CBPurchase: SKRequestDelegate {
    public func requestDidFinish(_ request: SKRequest) {
        guard request is SKReceiptRefreshRequest else { return }
        complatedRefresh(error: nil)
        self.restoreHandlerisActive = false
        request.cancel()
    }
    
}

