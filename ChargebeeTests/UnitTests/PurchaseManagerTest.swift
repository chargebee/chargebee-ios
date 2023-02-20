//
//  PurchaseManagerTest.swift
//  
//
//  Created by cb-imay on 21/02/22.
//

import XCTest
import StoreKit
@testable import Chargebee
class MockSK1Product: SKProduct {
    var mockProductIdentifier: String

    init(mockProductIdentifier: String, mockSubscriptionGroupIdentifier: String? = nil) {
        self.mockProductIdentifier = mockProductIdentifier
        self.mockSubscriptionGroupIdentifier = mockSubscriptionGroupIdentifier
        super.init()
    }

    override var productIdentifier: String {
        return self.mockProductIdentifier
    }

    var mockSubscriptionGroupIdentifier: String?
    override var subscriptionGroupIdentifier: String? {
        return self.mockSubscriptionGroupIdentifier
    }

    var mockPriceLocale: Locale?
    override var priceLocale: Locale {
        return mockPriceLocale ?? Locale(identifier: "en_US")
    }

    var mockPrice: Decimal?
    override var price: NSDecimalNumber {
        return (mockPrice ?? 2.99) as NSDecimalNumber
    }

    @available(iOS 11.2, macCatalyst 13.0, tvOS 11.2, macOS 10.13.2, *)
    override var introductoryPrice: SKProductDiscount? {
        return mockDiscount
    }

    @available(iOS 11.2, macCatalyst 13.0, tvOS 11.2, macOS 10.13.2, *)
    lazy var mockDiscount: SKProductDiscount? = nil

    @available(iOS 12.2, macCatalyst 13.0, tvOS 12.2, macOS 10.13.2, *)
    override var discounts: [SKProductDiscount] {
        return (mockDiscount != nil) ? [mockDiscount!] : []
    }

//    @available(iOS 11.2, macCatalyst 13.0, tvOS 11.2, macOS 10.13.2, *)
//    lazy var mockSubscriptionPeriod: SKProductSubscriptionPeriod? = SKProductSubscriptionPeriod(numberOfUnits: 1, unit: .month)

//    @available(iOS 11.2, macCatalyst 13.0, tvOS 11.2, macOS 10.13.2, *)
//    override var subscriptionPeriod: SKProductSubscriptionPeriod? {
//        return mockSubscriptionPeriod
//    }
}

class MockProductResponse: SKProductsResponse {
    var mockProducts: [MockSK1Product]

    init(productIdentifiers: Set<String>) {
        self.mockProducts = productIdentifiers.map { identifier in
            return MockSK1Product(mockProductIdentifier: identifier)
        }
        super.init()
    }

    override var products: [SKProduct] {
        return self.mockProducts
    }
}

class MockProductsRequest: SKProductsRequest {

    enum Error: Swift.Error {
        case unknown
    }

    var startCalled = false
    var cancelCalled = false
    var requestedIdentifiers: Set<String>
    var fails = false
    var responseTime: DispatchTimeInterval

    init(productIdentifiers: Set<String>, responseTime: DispatchTimeInterval = .seconds(0)) {
        self.requestedIdentifiers = productIdentifiers
        self.responseTime = responseTime
        super.init()
    }

    override func start() {
        startCalled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + self.responseTime) {
            if self.fails {
                self.delegate?.request!(self, didFailWithError: Error.unknown)
            } else {
                let response = MockProductResponse(productIdentifiers: self.requestedIdentifiers)
                self.delegate?.productsRequest(self, didReceive: response)
            }
        }
    }

    override func cancel() {
        cancelCalled = true
    }

}
class MockProductsRequestFactory: SKProductsRequestFactory {

    var invokedRequest = false
    var invokedRequestCount = 0
    var invokedRequestParameters: Set<String>?
    var invokedRequestParametersList = [Set<String>]()
    var stubbedRequestResult: MockProductsRequest!
    var requestResponseTime: DispatchTimeInterval = .seconds(0)

    override func request(productIdentifiers: Set<String>) -> SKProductsRequest {
        invokedRequest = true
        invokedRequestCount += 1
        invokedRequestParameters = productIdentifiers
        invokedRequestParametersList.append(productIdentifiers)
        return stubbedRequestResult ?? MockProductsRequest(productIdentifiers: productIdentifiers,
                                                           responseTime: requestResponseTime)
    }
}

class PurchaseManagerTest: XCTestCase {

    var products = [CBProduct]()
    let manager = CBPurchase.shared
    override func setUp() {
        super.setUp()

        manager.productRequest = MockProductsRequestFactory()
    }

    func testListProductsMock() {
        let exp = expectation(description: "List Products")
        manager.retrieveProducts(withProductID: ["Premium", "CBPro"]) { result in
            switch result {
            case let .success(products):
                self.products = products
                XCTAssertEqual(self.products.count, 2)
                exp.fulfill()
            case .failure:
                print("error")
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testListProductIdentifiersUnknow() {
//        let exp = expectation(description: "List Products")
//        manager.retrieveProductIdentifers(queryParams: ["page": "1"]) { result in
//            switch result {
//            case let .success(products):
//                XCTAssertEqual(products.ids.count, 2)
//                exp.fulfill()
//            case .failure:
//                print("error")
//                XCTFail()
//            }
//
//        }
//        waitForExpectations(timeout: 10)
    }

}
