//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation

public struct SubscriptionOptions {
    public init(currency: String, type: String, cardInfo: CardInfo) {
        self.currency = currency
        self.type = type
        self.cardInfo = cardInfo
    }
    
    let currency: String
    let type: String
    let cardInfo: CardInfo
}

public struct CardInfo {
    public init(number: String, expiryMonth: String, cvc: String, expiryYear: String) {
        self.number = number
        self.expiryMonth = expiryMonth
        self.cvc = cvc
        self.expiryYear = expiryYear
    }
    
    let number: String
    let expiryMonth: String
    let cvc: String
    let expiryYear: String
}

public class CBManager {
    public init() {
        
    }

    public func getTemporaryToken(details: SubscriptionOptions, completion handler: @escaping ((String?) -> Void)) {
        ApiClient().getPaymentConfigs() {
            value in
            guard (value != nil) else {
                return
            }
            let paymentProviderConfig: String? = self.getPaymentProviderConfig(paymentConfig: value!, options: details)
            print("got this value \(paymentProviderConfig)")
            guard paymentProviderConfig != nil else {
                return
            }
            self.tokenize(paymentKey: paymentProviderConfig!, cardInfo: details.cardInfo, completion: handler)
            return
        }
    }

    func getPaymentProviderConfig(paymentConfig: CBWrapper, options: SubscriptionOptions) -> String? {
        let paymentMethod: PaymentMethod? = paymentConfig
                .apmConfig[options.currency]?
                .paymentMethods.first(where: { $0.type == "card" && $0.gatewayName == "STRIPE" })
        return paymentMethod?.tokenizationConfig.STRIPE.clientId
    }

    func tokenize(paymentKey: String, cardInfo: CardInfo, completion handler: @escaping ((String?) -> Void)) {
        StripeTokenizer().tokenize(paymentKey: paymentKey, cardInfo: cardInfo) { response in
            print("after stripe--------------")
            print(response)
            if response != nil {
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

class StripeTokenizer {
    let paymentConfigUrl = "https://api.stripe.com/v1/tokens"
    func tokenize(paymentKey: String, cardInfo: CardInfo, completion handler: @escaping ((StripeResponse?) -> Void)) {

        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [URLQueryItem(name: "card[number]", value: cardInfo.number),
                                     URLQueryItem(name: "key", value: paymentKey),
                                     URLQueryItem(name: "card[cvc]", value: cardInfo.cvc),
                                     URLQueryItem(name: "card[exp_month]", value: cardInfo.expiryMonth),
                                     URLQueryItem(name: "card[exp_year]", value: cardInfo.expiryYear)]

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
let temporaryUrl = "https://test-ashwin1-test.chargebee.com/api/v2/tokens/create_using_temp_token"
class CBTemporaryToken {
    func createToken(vaultId: String, completion handler: @escaping ((String?) -> Void)) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [URLQueryItem(name: "payment_method_type", value: "card"),
                                     URLQueryItem(name: "id_at_vault", value: vaultId)]

        var urlRequest = URLRequest(url: URL(string: temporaryUrl)!)
        let apiKey = "test_uMJh75cuR3HwwuEAzDcs2ewJEhLjhIbWf"
        print("apiKey.data(using: .utf8)?.base64EncodedString()")
        let encodedString: String? = apiKey.data(using: .utf8)?.base64EncodedString()
        print(encodedString)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        urlRequest.addValue("Basic " + encodedString!, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            guard let data = data else {
                handler(nil)
                return
            }
            let wrapper = try? JSONDecoder().decode(TokenWrapper.self, from: data)
            print("after temporary")
            print(response)
            handler(wrapper?.token.id)
        })
        task.resume()

    }
}
