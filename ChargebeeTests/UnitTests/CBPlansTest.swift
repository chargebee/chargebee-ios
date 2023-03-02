//
//  CBPlansTest.swift
//  
//
//  Created by cb-imay on 16/02/22.
//

import XCTest
@testable import Chargebee

class MockRequestPlans<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequestPlans: CBNetworkRequest {

    func load(withCompletion completion: SuccessHandler<CBPlansWrapper>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)

    }

    func decode(_ data: Data) -> CBPlansWrapper? {
        let item = CBPlan.init(addonApplicability: "", chargeModel: "", currencyCode: "", enabledInHostedPages: true, enabledInPortal: true, freeQuantity: 1, giftable: true, id: "", invoiceName: "", isShippable: true, name: "", object: "", period: 1, periodUnit: "", price: 1, pricingModel: "", resourceVersion: 1, status: "", taxable: true, updatedAt: 1, metadata: nil)

        return CBPlansWrapper.init(list: [CBPlanWrapper.init(plan: item), CBPlanWrapper.init(plan: item)], nextOffset: "2")
    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBPlansWrapper
    typealias ErrorType = String

}

class MockRequestPlan<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequestPlan: CBNetworkRequest {
    func load(withCompletion completion: SuccessHandler<CBPlan>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func decode(_ data: Data) -> CBPlan? {
        return CBPlan.init(addonApplicability: "", chargeModel: "", currencyCode: "", enabledInHostedPages: true, enabledInPortal: true, freeQuantity: 1, giftable: true, id: "", invoiceName: "", isShippable: true, name: "", object: "", period: 1, periodUnit: "", price: 1, pricingModel: "", resourceVersion: 1, status: "", taxable: true, updatedAt: 1, metadata: nil)

    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBPlan
    typealias ErrorType = String

}

class CBPlansTest: XCTestCase {

    func testPlanResource() {
        let resource = CBPlanResource("12345")
        Chargebee.configure(site: "imay-test", apiKey: "apikey")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.methodPath, "/v2/plans/12345")
    }

    func testallPlanResource() {
        let resource = CBPlansResource(queryParams: ["page": "1"])
        Chargebee.configure(site: "imay-test", apiKey: "apikey")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.queryParams, ["page": "1"])
    }

    func testFetchingPlans() {
        let exp = expectation(description: "Plans")
        let mockRequ = MockRequestPlans.init(resource: MockItemsResource())
        NetworkClient().retrieve(network: mockRequ, logger: CBLogger(name: "", action: "")) { (result :CBResult<CBPlansWrapper>) in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.list.count, 2)
                exp.fulfill()
            case .error:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testFetchingItemPlan() {
        let exp = expectation(description: "Plan")
        let mockRequ = MockRequestPlan.init(resource: MockItemResource())
        NetworkClient().retrieve(network: mockRequ, logger: CBLogger(name: "", action: "")) { (result :CBResult<CBPlan>) in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.price, 1)
                XCTAssertEqual(status.taxable, true)
                exp.fulfill()
            case .error:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10)
    }

}
