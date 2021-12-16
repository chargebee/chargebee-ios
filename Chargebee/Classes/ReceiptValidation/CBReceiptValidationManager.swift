
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
    public let planId : String
    
    enum CodingKeys: String, CodingKey {
        case subscriptionId =  "subscription_id"
        case customerId =  "customer_id"
        case planId =  "plan_id"
    }
}

class CBReceiptValidationManager {
    public static func validateReceipt(receipt: String,
                                       productId: String,
                                       name: String,
                                       price: String,
                                       currencyCode : String,
                                       customerId : String? = "",
                                       completion handler: @escaping CBValidateReceiptHandler) {
        let logger = CBLogger(name: "buy", action: "process_purchase_command")
        logger.info()

    
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler,nil)
        let request = CBAPIRequest(resource: CBValidateReceiptResource(receipt: receipt, productId: productId,name: name,
                                                                     price: price, currencyCode : currencyCode,
                                                                     customerId : customerId ?? ""))
        request.create(withCompletion: { (res: CBValidateReceiptWrapper?) in
            onSuccess(res!.inAppSubscription)
        }, onError: onError)
    }
}
