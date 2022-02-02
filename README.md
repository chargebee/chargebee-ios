# Chargebee iOS
The official Chargebee iOS SDK.

After installing and initializing the SDK with the Chargebee site authentication, this SDK can be used for,

1. integrating with App Store connect, processing in-app purchase subscriptions, and tracking them on your Chargebee account for a single source of subscription truth across Web subscriptions & iOS IAP. Use this if you are selling digital goods or services, or are REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/)

2. tokenizing credit card information while presenting your own UI. Use this if you are selling physical goods or offline services, or are NOT REQUIRED to use Apple's in-app purchases as per their [app review guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Requirements
- iOS 8+
- Swift 5+

## Installation

### Github
The Chargebee iOS SDK can be installed directly from github, by adding this to the Podfile:

    pod 'Chargebee', :git => 'https://github.com/chargebee/chargebee-ios', :tag => '1.0.5'
    
### CocoaPods

It's also available through [CocoaPods](https://cocoapods.org/pods/Chargebee). To install
it, simply add the following line to your Podfile:

    pod 'Chargebee'
    
### Swift Package Manager

- Select File > Swift Packages > Add Package Dependency
- Add repository URL `https://github.com/chargebee/chargebee-ios`


## Example project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Configuration

### Configuration for using In-App Purchases
To use the Chargebee iOS SDK for making and managing in-app purchases, you must initialize the SDK with your Chargebee Site, Publishable API key and the SDK Key. You can find your Publishable API key, or create a new one, in your Chargebee account under _Configure Chargebee > API Keys_ . Once you setup the Apple App Store integration on your Chargebee account, you can find the SDK Key under the name of _Resource ID_ when you click on _View Keys_.

You can initialize the SDK during your app startup by including the following in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "your-site",
                    apiKey: "publishable_api_key",
                    sdkKey: "ResourceID/SDK Key")
}

```

### Configuration for using tokenization only
If you want to use the Chargebee iOS SDK only for tokenizing credit card details, you can initialize the SDK with your Chargebee Site and  API key alone. You can initialize the SDK during your app startup by including the following in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "your-site", apiKey: "publishable_api_key")

```

## Usage

### Integrating In-App Purchases

#### Get all IAP Product IDs from Chargebee

Every In-App Purchase subscription product that you configure in your App Store Connect account, can be configured in Chargebee as a Plan. Start by retrieving the Apple IAP Product IDs from your Chargebee account.

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
For eg. query params above can be _"limit": "100"_.

The above function will determine your product catalog version in Chargebee and hit the relevant APIs automatically, to retrieve the Chargebee Plans that correspond to Apple IAP products, along with their Apple IAP Product IDs.


#### Get IAP Products 

You can then convert these to Apple IAP Product objects with the following function.


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

#### Buy / Subscribe  Product

When the user chooses the product to purchase, pass in the product and customer identifiers to the following function.

customer id - optional Parameter
We need the unique ID of your customer for customer_id. If your unique list of customers is maintained in your database or a 3rd party system , send us the unique ID from there. If you rely on Chargebee for the unique list of customers, then you can send us a random unique string for this ID.

```swift

CBPurchase.shared.purchaseProduct(product: "CBProduct",customerId: "CustomerID") { result in
    switch result {
        case .success(let result):
            print(result.status)
            print(result.subscription) // this will print the subscription details object
        case .failure(let error):
            // Handle error here
    }
}

```
The above function will handle the purchase against App Store Connect, and send the IAP receipt for server-side receipt verification to your Chargebee account.

#### Get Subscription Status

Use the Subscription ID returned by the previous function, to check for Subscription status against Chargebee, and for delivering purchased entitlements.
```swift
CBSubscription.retrieveSubscription(forID: "SubscriptionID") { result in
    switch result {
    case let .success(result):
        print("Status \(result.status)")
    case let .error(error):
        // Handle error here
    }
}
```

### Integrating credit card tokenization

The following section describes how to use the SDK to directly tokenize credit card information if you are NOT REQUIRED to use Apple's in-app purchases.

If you are using **Product Catalog 2.0** in your Chargebee site, then you can use the following functions to retrieve the product to be presented for users to purchase.

#### Get all Items


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
For eg. query params above can be _"sort_by[desc]" : "name"_ OR _"limit": "100"_.

#### Get Item Details

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

If you are using **Product Catalog 1.0** in your Chargebee site, then you can use any of the following relevant functions to retrieve the product to be presented for users to purchase.

#### Get All Plans

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
For eg. query params above can be _"sort_by[desc]" : "name"_ OR _"limit": "100"_.

#### Get Plan Details

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

#### Get Addon Details

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

#### Get Payment Token

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

#### Use the Chargebee Token

Once your customer’s card data is processed and stored, and a Chargebee token reference is returned to you, you can use the token in subsequent API calls to process transactions. The following are some endpoints that accept Chargebee tokens for processing.

- [Create a Payment Source for the customer](https://apidocs.chargebee.com/docs/api/payment_sources#create_using_chargebee_token)
- [Create a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#create_a_subscription)
- [Update a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#update_a_subscription)

Please refer to the [Chargebee API Docs](https://apidocs.chargebee.com/docs/api) for subsequent integration steps.



## License

Chargebee is available under the MIT license. See the LICENSE file for more info.
