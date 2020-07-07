//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

struct SubscriptionOptions {
    let currency: String
    let type: String
}

@available(macCatalyst 13.0, *)
public class CBManager {
    public init() {
        
    }

    public func getPlan(_ planId: String, completion handler: @escaping (Plan?) -> Void) {
        let planResource = PlanResource()
        planResource.setPlan(planId)
        let request = APIRequest(resource: planResource)
        request.load() { planWrapper in
            handler(planWrapper?.plan)
        }
    }

    public func getAddon(_ addonId: String, completion handler: @escaping (Addon?) -> Void) {
        let addonResource = AddonResource()
        addonResource.setAddon(addonId)
        let request = APIRequest(resource: addonResource)
        request.load() { planWrapper in
            handler(planWrapper?.addon)
        }
    }

    public func getTemporaryToken(completion handler: @escaping (String?) -> Void) {
        let options: SubscriptionOptions = SubscriptionOptions(currency: "USD", type: "card")
        ApiClient().getPaymentConfigs() {
            value in
            print(value)
            guard (value != nil) else {
                return
            }
            let paymentProviderConfig: String? = self.getPaymentProviderConfig(paymentConfig: value!, options: options)
            print("got this value \(paymentProviderConfig)")
            guard paymentProviderConfig != nil else {
                return
            }
            self.tokenize(paymentKey: paymentProviderConfig!, completion: handler)
            return
        }
    }

    func getPaymentProviderConfig(paymentConfig: CBWrapper, options: SubscriptionOptions) -> String? {
        let paymentMethod: PaymentMethod? = paymentConfig
                .apmConfig[options.currency]?
                .paymentMethods.first(where: { $0.type == "card" && $0.gatewayName == "STRIPE" })
        return paymentMethod?.tokenizationConfig.STRIPE.clientId
    }

    func tokenize(paymentKey: String, completion handler: @escaping ((String?) -> Void)) {
        StripeTokenizer().tokenize(paymentKey: paymentKey) { response in
            print("after stripe--------------")
            print(response)
            if response != nil {
                print("toekn \(response!.id)")
                CBTemporaryToken().createToken(vaultId: response!.id) { response in
                    print("*********response")
                    print(response)
                    handler(response)
                }
            }
        }
    }
}

struct StripeResponse: Decodable {
    let id: String
    let object: String
}

@available(macCatalyst 13.0, *)
class StripeTokenizer {
    let paymentConfigUrl = "https://api.stripe.com/v1/tokens"
    func tokenize(paymentKey: String, completion handler: @escaping ((StripeResponse?) -> Void)) {

        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [URLQueryItem(name: "card[number]", value: "4242424242424242"),
                                     URLQueryItem(name: "key", value: paymentKey),
                                     URLQueryItem(name: "card[cvc]", value: "123"),
                                     URLQueryItem(name: "card[exp_month]", value: "12"),
                                     URLQueryItem(name: "card[exp_year]", value: "2029")]

        var urlRequest = URLRequest(url: URL(string: paymentConfigUrl)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            guard let data = data else {
                handler(nil)
                return
            }
            let wrapper = try? JSONDecoder().decode(StripeResponse.self, from: data)
            handler(wrapper)
        })
        task.resume()
    }

}

struct TokenWrapper: Decodable {
    let token: TemporaryToken
}

struct TemporaryToken: Decodable {
    let id: String
}

@available(macCatalyst 13.0, *)
class CBTemporaryToken {
    func createToken(vaultId: String, completion handler: @escaping (String?) -> Void) {
        let resource = CBTokenResource()
//        resource.createTempToken(paymentMethodType: "card", token: vaultId, gatewayId: "gw_16CPK9S2d87Uj9M")
        let request = APIRequest(resource: resource)
        let body = [
            "payment_method_type": "card",
            "id_at_vault": vaultId,
            "gateway_account_id": "gw_16CPK9S2d87Uj9M",
        ]
        request.create(body: body) { (res: TokenWrapper?) in
            print("Varuthu \(res)")
            if res != nil {
                handler(res?.token.id)
            }
        }
    }
}
