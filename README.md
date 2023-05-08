Chargebee iOS
=============

This is the official  Software Development Kit (SDK) for Chargebee iOS. This SDK makes it efficient and comfortable to build an impressive subscription experience in your iOS app.

Post-installation, initialization, and authentication with the Chargebee site, this SDK will support the following process.

-   **Sync In-App Subscriptions with Chargebee**: [Integrate](https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html) with [Apple Store Connect](https://appstoreconnect.apple.com/login) to process in-app purchase subscriptions, and track them on your Chargebee account for a single source of truth for subscriptions across the Web and Apple App Store. Use this if you are selling digital goods or services, or are REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/).
    **For SDK funtions to work, ensure that** [**prerequisites**](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#configure-prerequisites) **are configured in Chargebee.** To import products configured in Apple App Store and existing subscriptions, read [more](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#import-products).

-   **Tokenisation of credit card**: Tokenize credit card information while presenting your own user interface. Use this if you are selling physical goods or offline services or are NOT REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/).

-  **Note**: This SDK doesn’t support Apps developed using Objective C. If your app is developed using Objective C then we can guide you to integrate Objective C with our SDK code. Please reach out to support@chargebee.com

Requirements
------------

The following requirements must be set up prior to installing Chargebee's iOS SDK

-   iOS 12+

-   Swift 5+

Installation
------------

Choose from the following options to install Chargeee iOS SDK.

### Github

Add the following snippet to the Podfile to install directly from Github.

```swift
pod 'Chargebee', :git => 'https://github.com/chargebee/chargebee-ios', :tag => '1.0.22'
```

### CocoaPods

Add the following line to your Podfile to install using [CocoaPods](https://cocoapods.org/pods/Chargebee).

```swift
pod 'Chargebee'
```

### Swift Package Manager

Follow the step to install SDK using Swift Package Manager.

-   Select File > Swift Packages > Add Package Dependency

-   Add repository URL https://github.com/chargebee/chargebee-ios

Example project
---------------

This is an optional step that helps you to verify the SDK implementation using this example project. You can download or clone the example project via GitHub.

To run the example project, follow these steps.

-   Clone the repo - https://github.com/chargebee/chargebee-ios.

-   Run pod install from the Example directory.

Configuring SDK
---------------

There are two types of configuration.

-   Configuration for In-App Purchases

-   Configuration for credit card using tokenization

### Configuration for In-App Purchases

To configure the Chargebee iOS SDK for completing and managing In-App Purchases, follow these steps.

-   [Integrate](https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html) the [App Store Connect](https://appstoreconnect.apple.com/login) with your [Chargebee site](https://app.chargebee.com/login).

-   On the **Sync Overview** page of the web app, click **View Keys** and use the value of generated [**App ID**](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#connection-keys_app-id) as the **SDK Key**.

-   On the Chargebee site, navigate to **Configure Chargebee** *>* [**API Keys**](https://www.chargebee.com/docs/2.0/api_keys.html#create-an-api-key) to create a new **Publishable API Key** or use an existing [**Publishable API Key**](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key).
    **Note:** During the publishable API key creation you must allow **read-only** access to plans/items otherwise this key will not work in the following step. Read [more](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key).

-   Initialize the SDK with your Chargebee site, Publishable API Key, and SDK Key by including the following snippets in your app delegate during app startup.

```swift
import Chargebee

Chargebee.configure(site: "your-site",
                    apiKey: "publishable_api_key",
                    sdkKey: "ResourceID/SDK Key")
}
```

### Configuration for credit card using tokenization

To configure SDK only for tokenizing credit card details, follow these steps.

-   Initialize the SDK with your Chargebee Site and Publishable/Full Access Key.

-   Initialize the SDK during your app startup by including the following snippets in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "your-site", apiKey: "publishable_api_key")
```

SDK Integration Processes
-------------------------

This section describes the SDK integration processes.

-   Integrating In-App Purchases

-   Integrating credit card tokenization

### Integrating In-App Purchases

The following section describes how to use the SDK to integrate In-App Purchase information. For details on In-App Purchase, read [more](https://www.chargebee.com/docs/2.0/mobile-in-app-purchases.html).

#### Get all IAP Product IDs from Chargebee

Every In-App Purchase subscription product you configure in your App Store Connect account can be configured in Chargebee as a Plan. Start by retrieving the Apple IAP Product IDs from your Chargebee account.

```swift
CBPurchase.shared.retrieveProductIdentifers(queryParams :["String": "String"], completion:  { result in
switch result {
    case let .success(products):
        print("array of Products Id's \(products)")
    case let .failure(error):
        // Handle error here
}
})
```

For example, query parameters can be passed as **"limit": "100"**.

The above function will automatically determine your product catalog version in Chargebee and call the relevant APIs to retrieve the Chargebee Plans that correspond to Apple IAP products and their Apple IAP Product IDs.

#### Get IAP Products

You can then convert the IAP Product IDs to Apple IAP Product objects with the following function.

```swift
CBPurchase.shared.retrieveProducts(withProductID : ["Product ID from Apple"],completion: { result in
    switch result {
    case let .success(products):
        print("array of Products \(products)")
    case let .failure(error):
        // Handle error here
}
}
```

You can present any of the above products to your users for them to purchase.

#### Buy or Subscribe Product

Pass the `CBProduct` and  `CBCustomer` objects to the following function when the user chooses the product to purchase.

`CBCustomer` - **Optional object**. Although this is an optional object, we recommend passing the necessary customer details, such as `customerID`, `firstName`, `lastName`, and `email` if it is available before the user subscribes to your App. This ensures that the customer details in your database match the customer details in Chargebee. If the `customerID` is not passed in the customer's details, then the value of `customerID` will be the same as the `SubscriptionId` created in Chargebee.

**Note**: The `customer` parameter in the below code snippet is an instance of `CBCustomer` class that contains the details of the customer who wants to subscribe or buy the product.

```swift

    let product = CBProduct(product: SKProduct())
    let customer = CBCustomer(customerID: "",firstName:"",lastName: "",email: "")
    CBPurchase.shared.purchaseProduct(product: product,customer: customer) { result in
    switch result {
        case .success(let result):
            print(result.status)
            print(result.subscriptionId) // this will print the subscription ID 
            print(result.planId) // this will print the Plan ID 
        case .failure(let error):
            // Handle error here
    }
}
```

The above function will handle the purchase against App Store Connect and send the IAP receipt for server-side receipt verification to your Chargebee account. Use the Subscription ID returned by the above function, to check for Subscription status on Chargebee and confirm the access - granted or denied.

##### Returns Plan Object

This function returns the plan ID associated with a subscription. You can associate JSON metadata with the Apple App Store plans in Chargebee and retrieve the same by passing plan ID to the SDK function - [retrievePlan](https://github.com/chargebee/chargebee-ios#get-plan-details)(PC 1.0) or [retrieveItem](https://github.com/chargebee/chargebee-ios#get-item-details)(PC 2.0).

#### One-Time Purchases

The `purchaseNonSubscriptionProduct` function handles the one-time purchase against App Store Connect and sends the IAP receipt for server-side receipt verification to your Chargebee account. Post verification a Charge corresponding to this one-time purchase will be created in Chargebee. There are three types of one-time purchases `consumable`, `non_consumable`, and `non_renewing_subscription`.

```swift
let product = CBProduct(product: SKProduct())
    let customer = CBCustomer(customerID: "",firstName:"",lastName: "",email: "")
    let typeOfProduct: productType = .non_consumable
    CBPurchase.shared.purchaseNonSubscriptionProduct(product: withproduct,customer: customer,productType: typeOfProduct) { result in
      switch result {
      case .success(let success):
        print(result.customerID)
        print(result.chargeID ?? "")
        print(result.invoiceID ?? "")
      case .failure(let failure):
        //Hanler error here
      }
    }
```

The given code defines a closure-based function named `purchaseNonSubscriptionProduct` in the `CBPurchase` class, which takes three input parameters:
- `product`: An instance of `CBProduct` class, initialized with a `SKProduct` instance representing the product to be purchased from the Apple App Store.
- `customer`: An instance of `CBCustomer` class, initialized with the customer's details such as `customerID`, `firstName`, `lastName`, and `email`.
- `productType`: An enum instance of `productType` type, indicating the type of product to be purchased. It can be either .`consumable`, .`non_consumable`, or .`non_renewing_subscription`.

The function is called asynchronously, and it returns a `Result` object with a `success` or `failure` case, which can be handled in the closure.
- If the purchase is successful, the closure will be called with the `success` case, which includes the `customerID`, `chargeID`, and `invoiceID` associated with the purchase.
- If there is any failure during the purchase, the closure will be called with the `failure` case, which includes an error object that can be used to handle the error.

#### Restore purchase

The `restorePurchases()` function helps to recover your app user's previous purchases without making them pay again. Sometimes, your app user may want to restore their previous purchases after switching to a new device or reinstalling your app. You can use the `restorePurchases()` function to allow your app user to easily restore their previous purchases.

To retrieve **inactive** purchases along with the **active** purchases for your app user, you can call the `restorePurchases()` function with the `includeInActiveProducts` parameter set to `true`. If you only want to restore active subscriptions, set the parameter to `false`. Here is an example of how to use the `restorePurchases()` function in your code with the `includeInActiveProducts` parameter set to `true`.

```swift
CBPurchase.shared.restorePurchases(includeInActiveProducts: true) { result in
      switch result {
      case .success(let response):
        for subscription in response {
          if subscription.storeStatus.rawValue == StoreStatus.Active.rawValue{
            print("Successfully restored purchases")
          }
        }
      case .failure(let error):
        // Handle error here
        print("Error:",error)
      }
    }
```
##### Return Subscriptions Object

The `restorePurchases()` function returns an array of subscription objects and each object holds three attributes `subscription_id`, `plan_id`, and `store_status`. The value of `store_status` can be used to verify subscription status.

##### Error Handling

In the event of any failures during the refresh and validation process or while finding associated subscriptions for the restored items, iOS SDK will return an error, as mentioned in the following table.

###### Error Codes

These are the possible error codes and their descriptions:
| Error Code                        | Description                                                                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| `RestoreError.noReceipt`            | This error occurs when the user attempts to restore a purchase, but there is no receipt associated with the purchase.       |
| `RestoreError.refreshReceiptFailed` | This error occurs when the attempt to refresh the receipt for a purchase fails.                                             |
| `RestoreError.restoreFailed`        | This error occurs when the attempt to restore a purchase fails for reasons other than a missing or invalid receipt.         |
| `RestoreError.invalidReceiptURL`    | This error occurs when the URL for the receipt bundle provided during the restore process is invalid or cannot be accessed. |
| `RestoreError.invalidReceiptData`   | This error occurs when the data contained within the receipt is not valid or cannot be parsed.                              |
| `RestoreError.noProductsToRestore`  | This error occurs when there are no products available to restore.                                                          |
| `RestoreError.serviceError`         | This error occurs when there is an error with the Chargebee service during the restore process.                             |

**Note**: These error codes are implemented in our example app. [Learn more](https://github.com/chargebee/chargebee-ios/blob/master/Example/Chargebee/CBSDKOptionsViewController.swift#L202-L224).

#### Synchronization of Apple App Store Purchases with Chargebee through Receipt Validation

Receipt validation is crucial to ensure that the purchases made by your users are synced with Chargebee. In rare cases, when a purchase is made at the Apple App Store, and the network connection goes off, the purchase details may not be updated in Chargebee. In such cases, you can use a retry mechanism by following these steps:
-   Add a network observer, as shown in the example project.
-   Save the product identifier in the cache once the purchase is initiated and clear the cache once the purchase is successful.
-   When the network connectivity is lost after the purchase is completed at Apple App Store but not synced with Chargebee, retrieve the product ID from the cache once the network connection is back and initiate `validateReceipt()`/`validateReceiptForNonSubscriptions()` by passing `CBProduct` as input. This will validate the purchase receipt and sync the purchase in Chargebee as a subscription or one-time purchase.
For subscriptions, use the function `validateReceipt()`; for one-time purchases, use the function `validateReceiptForNonSubscriptions()`.

Use the function available for the retry mechanism.

**Function for subscriptions**

```swift
CBPurchase.shared.validateReceipt(product) { result in
      switch result {
      case .success(let result):
        print(result.status )
        // Clear persisted product details once the validation succeeds.
      case .failure(let error):
        print("error",error.localizedDescription)
        // Retry based on the error
      }
    }
```

**Function for one-time purchases**

```swift
CBPurchase.shared.validateReceiptForNonSubscriptions(product,type) { result in
        switch result {
        case .success(let result):
          // Clear persisted product details once the validation succeeds.
        case .failure(let error):
       // Retry based on the error
        }
      }
```

#### Get Subscription Status for Existing Subscribers

The following are funtions for checking the subscription status of a subscriber who already purchased the product.

##### Get Subscription Status for Existing Subscribers using Query Parameters

Use query parameters - Subscription ID, Customer ID, or Status for checking the Subscription status on Chargebee and confirm the access - granted or denied.

```swift
Chargebee.shared.retrieveSubscriptions(queryParams :["String" : "String"]") { result in
    switch result {
    case let .success(resultarray):
        print("Status \(resultarray.first.subscription.status)")
    case let .error(error):
        // Handle error here
    }
}
```

For example, query parameters can be passed as **"customer_id" : "id"**, **"subscription_id": "id"**, or **"status": "active"**.

##### Get Subscription Status for Existing Subscribers using Subscription ID

Use only Subscription ID for checking the Subscription status on Chargebee and confirm the access - granted or denied.

```swift
Chargebee.shared.retrieveSubscription(forID: "SubscriptionID") { result in
    switch result {
    case let .success(result):
        print("Status \(result.status)")
    case let .error(error):
        // Handle error here
    }
}
```

##### Returns Plan Object

The above functions return the plan ID associated with a subscription. You can associate JSON metadata with the Apple App Store plans in Chargebee and retrieve the same by passing plan ID to the SDK function - [retrievePlan](https://github.com/chargebee/chargebee-ios#get-plan-details)(PC 1.0) or [retrieveItem](https://github.com/chargebee/chargebee-ios#get-item-details)(PC 2.0).

#### Retrieve Entitlements of a Subscription

Use the Subscription ID for fetching the list of [entitlements](https://www.chargebee.com/docs/2.0/entitlements.html) associated with the subscription. 

```swift
Chargebee.shared.retrieveEntitlements(forID: "SubscriptionID") { result in
    switch result {
    case let .success(result):
        print("Status \(result.status)")
    case let .error(error):
        // Handle error here
    }
}
```

**Note**: Entitlements feature is available only if your Chargebee site is on [Product Catalog 2.0](https://www.chargebee.com/docs/2.0/product-catalog.html).



### Integrating credit card tokenization

The following section describes how to use the SDK to tokenize credit card information.

#### Product Catalog 2.0

If your Chargebee site is configured to PC 2.0, use the following functions to retrieve the product or product list for purchase.

##### Get all items

Retrieve the list of items using the following function.

```swift
  CBItem.retrieveAllItems(queryParams :["String" : "String"], completion:  { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(itemLst):
                        self.items =  itemLst.list
                        debugPrint("items: \(self.items)")
                        self.performSegue(withIdentifier: "itemList", sender: self)
                    case let .error(error):
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                }
    })
```

For example, query parameters can be passed as **"sort_by[desc]" : "name"** or **"limit": "100"**.

##### Get item details

Retrieve specific item details using the following function. Use the Item ID that you received from the previous function - Get all items.

```swift
CBItem.retrieveItem("Item ID"){ (itemResult) in
            switch itemResult {
            case .success(let item):
                print(item)
                self.itemName.text = item.name
                self.itemStatus.text = item.status

            case .error(let error):
                print("Error\(error)")
                self.error.text = error.localizedDescription
            }
        }
```

#### Product Catalog 1.0

If your Chargebee site is configured to PC 1.0, use the relevant functions to retrieve the product or product list for purchase.

##### Get All Plans

Retrieve a list of plans using the following function.

```swift
CBPlan.retrieveAllPlans(queryParams: ["String":"String" ]) { (result) in
    switch result {
    case .success(let plan):
        print("Plan Array: \(plan)")
        // Use plan details here
    case .error(let error):
        // Handle error here
    }
}
```

For example, query parameters can be passed as **"sort_by[desc]" : "name"** or **"limit": "100"**.

##### Get Plan Details

Retrieve specific plan details passing plan ID in the following function.

```swift
CBPlan.retrieve("planId") { (planResult) in
    switch planResult {
    case .success(let plan):
        print("Plan Name: \(plan.name)")
        // Use plan details here
    case .error(let error):
        // Handle error here
    }
}
```

##### Get Addon Details

Retrieve specific addon details passing addon ID in the following function.

```swift
CBAddon.retrieve("addonId") { (addonResult) in
    switch addonResult {
    case .success(let addon):
        print("Addon Name: \(addon.name)")
        // Use addon details here
    case .error(let error):
        // Handle error here
    }
}
```

### Get Payment Token

Once the user selects the product to purchase, and you collect the credit card information, use the following function to tokenize the credit card details against Stripe. You need to have connected your Stripe account to your Chargebee site.

```swift
let card = CBCard(
        cardNumber: "4321567890123456",
        expiryMonth: "12",
        expiryYear: "29",
        cvc: "123")

let paymentDetail = CBPaymentDetail(type: CBPaymentType.Card, currencyCode: "USD", card: card)

Chargebee.shared.createTempToken(paymentDetail: paymentDetail) { tokenResult in
    switch tokenResult {
    case .success(let token):
        print("Chargebee Token \(token)")
        // Use token here
    case .error(let error):
        // Handle error here
    }
}
```

### Use the Chargebee Token

After the customer's card data is processed and stored and a Chargebee token reference is returned to you, use the token in subsequent API calls to process transactions.

The following are some endpoints that accept Chargebee tokens for processing subscriptions.

-   [Create a Payment Source for the customer](https://apidocs.chargebee.com/docs/api/payment_sources#create_using_chargebee_token)

-   [Create a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#create_a_subscription)

-   [Update a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#update_a_subscription)

Please refer to the [Chargebee API Docs](https://apidocs.chargebee.com/docs/api) for subsequent integration steps.

License
-------

Chargebee is available under the [MIT license](https://opensource.org/licenses/MIT). For more information, see the LICENSE file.
