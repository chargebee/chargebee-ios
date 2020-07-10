# Chargebee iOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Chargebee is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Chargebee'
```

## Usage

# Configure
To use the Chargebee iOS SDK, you must initialize the SDK with your Chargebee Site Code and API key. You can initialize during your app startup by including this in your app delegate.

```
import Chargebee

...

CBManager.configure(site: "site-code", apiKey: "api_key")

```

# Get Plan Details

```
Chargebee().getPlan("planCode", completion: { (plan: Plan) in
            print("Plan Name: \(plan.name)")
            ... Use plan details here
        }, onError: { (error) in
            ... Handle error here
        })
```

# Get Addon Details

```
Chargebee().getAddon("addonCode", completion: { (addon: Addon) in
    print("Addon Name: \(addon.name)")
            ... Use addon here
}) { (error) in
    ... Handle error here
}
```

# Get Payment Token
```
let card = CBCard(
        cardNumber: "4321567890123456",
        expiryMonth: "12",
        expiryYear: "29",
        cvc: "123")
let paymentDetail = CBPaymentDetail(type: CBPaymentType.Card, currencyCode: "USD", card: card)

Chargebee().getTemporaryToken(paymentDetail: paymentDetail, completion: { (token: String)) in
    print("Chargebee Token \(token)")
    ... Use addon here
}, onError: { (error) in
    ... Handle error here
})
```
## Author

cb-prabu, meetprabu88@gmail.com

## License

Chargebee is available under the MIT license. See the LICENSE file for more info.
