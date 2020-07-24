# Chargebee iOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

### Github
The Chargebee iOS can be installed directly from github, by adding this to the Podfile:

    pod 'Chargebee', :git => 'https://github.com/chargebee/chargebee-ios', :tag => '0.3.0'

### CocoaPods

Chargebee is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod 'Chargebee', '~> 0.3'


## Usage

### Configure
To use the Chargebee iOS SDK, you must initialize the SDK with your Chargebee Site Code and Publishable API key. You can initialize during your app startup by including this in your app delegate.

```swift
import Chargebee

Chargebee.configure(site: "site-code", publishableApiKey: "api_key")

```

### Get Plan Details

```swift
CBPlan.retrieve("planCode") { (planResult) in
    switch planResult {
    case .success(let plan):
        print("Plan Name: \(plan.name)")
        // Use plan details here
    case .error(let error):
        // Handle error here
    }
}
```

### Get Addon Details

```swift
CBAddon.retrieve("addonCode") { (addonResult) in
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

## License

Chargebee is available under the MIT license. See the LICENSE file for more info.
