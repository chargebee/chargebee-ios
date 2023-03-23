import Foundation

typealias CBValidateReceiptHandler = (CBResult<CBValidateReceipt>) -> Void
typealias CBValidateNonSubscriptionHanlder = (CBResult<NonSubscription>) -> Void



struct CBValidateNonSubscriptionReceiptWrapper: Decodable {
    let nonSubscription: NonSubscription

    enum CodingKeys: String, CodingKey {
        case nonSubscription = "non_subscription"
    }
}

// MARK: - NonSubscription
struct NonSubscription: Decodable {
    let customerID, invoiceID, chargeID: String

    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case invoiceID = "invoice_id"
        case chargeID = "charge_id"
    }
}


struct CBValidateReceiptWrapper: Decodable {
    let inAppSubscription: CBValidateReceipt?
    let nonSubscription: NonSubscription?


    enum CodingKeys: String, CodingKey {
        case inAppSubscription = "in_app_subscription"
        case nonSubscription = "non_subscription"

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
            onSuccess(res!.nonSubscription)
        }, onError: onError)
    }
    
    static func validateReceipt(receipt: CBReceipt,
                      completion handler: @escaping CBValidateReceiptHandler) {
        let logger = CBLogger(name: "buy", action: "process_purchase_command")
        logger.info()

        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, nil)
        let request = CBAPIRequest(resource: CBValidateReceiptResource(receipt: receipt))
        request.create(withCompletion: { (res: CBValidateReceiptWrapper?) in
            if let inApp = res!.inAppSubscription {
                onSuccess(inApp)
            }
        }, onError: onError)
    }
}
