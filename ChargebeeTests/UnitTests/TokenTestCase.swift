//
//  TokenTestCase.swift
//  
//
//  Created by cb-imay on 24/02/22.
//

import XCTest
@testable import Chargebee

class TokenTestCase: XCTestCase {

    func testTokenResource() {
        let resource = CBTokenResource.init(paymentMethodType: .card, token: "1234", gatewayId: "5678")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.methodPath, "/v2/tokens/create_using_temp_token")
        XCTAssertNotNil(resource.requestBody)
    }

    func testStripeResource() {
        let resource = StripeTokenResource.init(apiKey: "123456", card: StripeCard.init(number: "123445", expiryMonth: "123", expiryYear: "234", cvc: "234"))
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.baseUrl, "https://api.stripe.com/v1")
        XCTAssertNotNil(resource.requestBody)

    }

}
