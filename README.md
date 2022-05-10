Chargebee iOS
=============

This is the official  Software Development Kit (SDK) for Chargebee iOS. This SDK makes it efficient and comfortable to build an impressive subscription experience in your iOS app.

Post-installation, initialization, and authentication with the Chargebee site, this SDK will support the following process.

-   **Sync In-App Subscriptions with Chargebee**: [Integrate](https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html) with [Apple Store Connect](https://appstoreconnect.apple.com/login) to process in-app purchase subscriptions, and track them on your Chargebee account for a single source of truth for subscriptions across the Web and Apple App Store. Use this if you are selling digital goods or services, or are REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/).
    **For SDK methods to work, ensure that** [**prerequisites**](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#configure-prerequisites) **are configured in Chargebee.** To import products configured in Apple App Store and existing subscriptions, read [more](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#import-products).

-   **Tokenisation of credit card**: Tokenize credit card information while presenting your own user interface. Use this if you are selling physical goods or offline services or are NOT REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/).

Requirements
------------

The following requirements must be set up prior to installing Chargebee's iOS SDK

-   iOS 8+

-   Swift 5+

Installation
------------

Choose from the following options to install Chargeee iOS SDK.

### Github

Add the following snippet to the Podfile to install directly from Github.

```swift
pod 'Chargebee', :git => 'https://github.com/chargebee/chargebee-ios', :tag => '1.0.5'
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

For example, query params above can be *"limit": "100"*.

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

Pass the product and customer identifiers to the following function when the user chooses the product to purchase.

customerId - Optional parameter. We need the unique ID of your customer as customerId. If your unique list of customers is maintained in your database or a third-party system, send us the unique ID from that source.

```swift
CBPurchase.shared.purchaseProduct(product: "CBProduct",customerId: "CustomerID") { result in
    switch result {
        case .success(let result):
            print(result.status)
            print(result.subscriptionId) // this will print the subscription ID object
        case .failure(let error):
            // Handle error here
    }
}
```

The above function will handle the purchase against App Store Connect and send the IAP receipt for server-side receipt verification to your Chargebee account. Use the Subscription ID returned by the above function, to check for Subscription status on Chargebee and confirm the access - granted or denied.

#### Get Subscription Status for Existing Subscribers

The following are methods for checking the subscription status.


##### Get Subscription Status for Existing Subscribers using Query Parameters

Use query parameters - Subscription ID, Customer ID, or Status for checking the Subscription status on Chargebee and confirm the access - granted or denied.

```swift
CBSubscription.retrieveSubscriptions(queryParams :["String" : "String"]") { result in
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
CBSubscription.retrieveSubscription(forSubscriptionID: "SubscriptionID") { result in
    switch result {
    case let .success(result):
        print("Status \(result.status)")
    case let .error(error):
        // Handle error here
    }
}
```

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

For example, query params above can be *"sort_by[desc]" : "name"* OR *"limit": "100"*.

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

For example, query params above can be *"sort_by[desc]" : "name"* OR *"limit": "100"*.

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

CBToken.createTempToken(paymentDetail: paymentDetail) { tokenResult in
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
