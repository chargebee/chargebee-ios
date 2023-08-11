import Foundation

typealias CBValidateReceiptHandler = (CBResult<CBValidateReceipt>) -> Void
typealias CBValidateNonSubscriptionHanlder = (CBResult<NonSubscription>) -> Void

public enum ProductType: String {
    case unknown = ""
    case Consumable = "consumable"
    case NonConsumable = "non_consumable"
    case NonRenewingSubscription = "non_renewing_subscription"
}

struct CBValidateNonSubscriptionReceiptWrapper: Decodable {
    let nonSubscription: NonSubscription

    enum CodingKeys: String, CodingKey {
        case nonSubscription = "non_subscription"
    }
}

// MARK: - NonSubscription
public struct NonSubscription: Decodable {
   public let customerID, invoiceID, chargeID: String

    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case invoiceID = "invoice_id"
        case chargeID = "charge_id"
    }
}


struct CBValidateReceiptWrapper: Decodable {
    let inAppSubscription: CBValidateReceipt

    enum CodingKeys: String, CodingKey {
        case inAppSubscription = "in_app_subscription"
    }
}

struct CBValidateReceipt: Decodable {
    public let subscriptionId: String
    public let customerId: String
    public let planId: String

    enum CodingKeys: String, CodingKey {
        case subscriptionId =  "subscription_id"
        case customerId =  "customer_id"
        case planId =  "plan_id"
    }
}

struct CBReceipt {
    let name: String
    let token: String
    let productID: String
    let price: String
    let currencyCode: String
    let period:Int
    let periodUnit:Int
    let customer: CBCustomer?
    let productType: ProductType?
}

class CBReceiptValidationManager {
    
    static func validateReceiptForNonSubscriptions(receipt: CBReceipt,
                                                   completion handler: @escaping CBValidateNonSubscriptionHanlder) {
        let logger = CBLogger(name: "buy", action: "one_time_purchase")
        logger.info()
        
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
        let request = CBAPIRequest(resource: CBValidateNonSubscriptionResource(receipt: receipt))
        request.create(withCompletion: { (res: CBValidateNonSubscriptionReceiptWrapper?) in
            if let response = res{
                onSuccess(response.nonSubscription)
            }
        }, onError: onError)
    }
    
    static func validateReceipt(receipt: CBReceipt,
                                completion handler: @escaping CBValidateReceiptHandler) {
        let logger = CBLogger(name: "buy", action: "process_purchase_command")
        logger.info()
        
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
        let request = CBAPIRequest(resource: CBValidateReceiptResource(receipt: receipt))
        request.create(withCompletion: { (res: CBValidateReceiptWrapper?) in
            if let inApp = res?.inAppSubscription {
                onSuccess(inApp)
            }
        }, onError: onError)
    }
}
