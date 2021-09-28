# Chargebee iOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 8+
- Swift 5+

## Installation

### Github
The Chargebee iOS SDK can be installed directly from github, by adding this to the Podfile:

pod 'Chargebee', :git => 'https://github.com/chargebee/chargebee-ios', :tag => '0.3.0'

### CocoaPods

It's also available through [CocoaPods](https://cocoapods.org/pods/Chargebee). To install
it, simply add the following line to your Podfile:

pod 'Chargebee', '~> 0.3'


## Usage

### Configure
To use the Chargebee iOS SDK, you must initialize the SDK with your Chargebee Site and Publishable API key. You can initialize during your app startup by including this in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "your-site", publishableApiKey: "api_key")

```


### Configure In App Purchase SDK
To use the Chargebee iOS SDK, you must initialize the SDK with your Chargebee Site and Publishable API key. You can initialize during your app startup by including this in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "your-site",
publishableApiKey: "api_key",
sdkKey: "sdk_key",
allowErrorLogging: true)
}

```




### Get Addon Details

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


### Get All Plans
// Sample Query Param "sort_by[desc]" : "name"  , "limit": "100"
```swift
CBPlan.retrieveAllPlansCBPlan.retrieveAllPlans(queryParams: ["String":"String" ]) { (result) in
switch result {
case .success(let plan):
print("Plan Array: \(plan)")
// Use plan details here
case .error(let error):
// Handle error here
}
}
```
### Get Plan Details

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

### Get all Items

```swift
CBItem.retrieveAllItems(queryParams :["limit": "8","sort_by[desc]" : "name"], completion:  { result in
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

### Get Item

```swift
CBItem.retrieveItem(self.ItemId.text!){ (itemResult) in
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

### List ProductID's From Apple Connect
```swift
//Sample query Param : "limit": "100"

CBPurchase.shared.retrieveProductIdentifers(queryParams :["String": "String"], completion:  { result in
switch result {
case let .success(productsID):
print("array of Products Id's \(products)")
case let .error(error):
// Handle error here
}

})

```

### List Products 
```swift
CBPurchase.shared.retrieveProducts(withProductID : ["Product ID from Apple"],completion: { result in
switch result {
case let .success(products):
print("array of Products \(products)")
case let .error(error):
// Handle error here
}
}


```

### Buy / Subscribe  Product
```swift

CBPurchase.shared.purchase(product: withProdct,customerId: customerID) { result in
switch result {
case .success:
print("success")
case .failure(let error):
// Handle error here
}
}

```

### Get Subscription Status
```swift
CBSubscription.retrieveSubscription(forID: subscriptionID) { result in
switch result {
case let .success(result):
print("Status \(result.status)")
case let .error(error):
// Handle error here
}
}
```



### Get Payment Token
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

Once your customer’s card data is processed and stored, and a Chargebee token reference is returned to you, you can use the token in subsequent API calls to process transactions. The following are some endpoints that accept Chargebee tokens for processing.

- [Create a Payment Source for the customer](https://apidocs.chargebee.com/docs/api/payment_sources#create_using_chargebee_token)
- [Create a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#create_a_subscription)
- [Update a Subscription](https://apidocs.chargebee.com/docs/api/subscriptions#update_a_subscription)

Please refer to the [Chargebee API Docs](https://apidocs.chargebee.com/docs/api) for subsequent integration steps.



## License

Chargebee is available under the MIT license. See the LICENSE file for more info.
