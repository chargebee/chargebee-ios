
import Foundation

typealias CBValidateReceiptHandler = (CBResult<CBValidateReceipt>) -> Void

struct CBValidateReceiptWrapper: Decodable {
    let inAppSubscription: CBValidateReceipt
    
    enum CodingKeys : String, CodingKey {
        case inAppSubscription = "in_app_subscription"
    }
}

struct CBValidateReceipt: Decodable {
    public let subscriptionId : String
    public let customerId : String
    public let isValid : Bool
    public let planId : String
    
    enum CodingKeys: String, CodingKey {
        case subscriptionId =  "subscription_id"
        case customerId =  "customer_id"
        case isValid =  "is_valid"
        case planId =  "plan_id"
    }
}

<<<<<<< HEAD:ReceiptValidation/CBValidateReceipt.swift
class CBValidateReceipt {
=======
class CBReceiptValidationManager {
>>>>>>> feature/codeCleanup:ReceiptValidation/CBReceiptValidationManager.swift
    public static func validateReceipt(receipt: String,
                                       productId: String,
                                       price: String,
                                       currencyCode : String,
                                       customerId : String,
<<<<<<< HEAD:ReceiptValidation/CBValidateReceipt.swift
                                       completion handler: @escaping ValidateReceiptHandler) {
=======
                                       completion handler: @escaping CBValidateReceiptHandler) {
>>>>>>> feature/codeCleanup:ReceiptValidation/CBReceiptValidationManager.swift
    
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler,nil)
        
        let request = CBAPIRequest(resource: CBValidateReceiptResource(receipt: receipt, productId: productId,
                                                                     price: price, currencyCode : currencyCode,
                                                                     customerId : customerId))
        request.create(withCompletion: { (res: CBValidateReceiptWrapper?) in
            onSuccess(res!.inAppSubscription)
        }, onError: onError)
    }
}
