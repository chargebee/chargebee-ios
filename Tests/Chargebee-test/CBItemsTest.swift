//
//  CBItemsTest.swift
//  
//
//  Created by cb-imay on 04/02/22.
//

import XCTest
@testable import Chargebee
// public typealias ItemListHandler = (CBResult<CBItemListWrapper>) -> Void
//
// public typealias ItemHandler = (CBResult<CBItem>) -> Void

struct MockItemsResource: CBAPIResource {
    typealias ModelType = CBItemListWrapper
    typealias ErrorType = String

    var methodPath: String {
        return "GET"
    }

    var baseUrl: String {
        return "https://www.chargebee.com"
    }
    var url: URLRequest {
        return URLRequest.init(url: URL.init(string: baseUrl)!)
    }

}
struct MockItemResource: CBAPIResource {
    typealias ModelType = CBItem
    typealias ErrorType = String

    var methodPath: String {
        return "GET"
    }

    var baseUrl: String {
        return "https://www.chargebee.com"
    }
    var url: URLRequest {
        return URLRequest.init(url: URL.init(string: baseUrl)!)
    }

}

class MockRequestItems<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequestItems: CBNetworkRequest {

    func load(withCompletion completion: SuccessHandler<CBItemListWrapper>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func decode(_ data: Data) -> CBItemListWrapper? {
        let item = CBItem.init(id: "sub_123", name: "name", description: "description", status: "active", resourceVersion: 12, updatedAt: 123, itemFamilyId: "itemFamilyId", type: "type", isShippable: false, isGiftable: false, enabledForCheckout: false, enabledInPortal: false, metered: false, object: "obj")
        return CBItemListWrapper.init(list: [CBItemWrapper.init(item: item), CBItemWrapper.init(item: item)], nextOffset: "next")
    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBItemListWrapper
    typealias ErrorType = String

}

class MockRequestItem<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequestItem: CBNetworkRequest {
    func load(withCompletion completion: SuccessHandler<CBItem>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func decode(_ data: Data) -> CBItem? {
        return CBItem.init(id: "sub_123", name: "name", description: "description", status: "active", resourceVersion: 12, updatedAt: 123, itemFamilyId: "itemFamilyId", type: "type", isShippable: false, isGiftable: false, enabledForCheckout: false, enabledInPortal: false, metered: false, object: "obj")
    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBItem
    typealias ErrorType = String

}

class CBItemsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchingItems() {
        let exp = expectation(description: "Items")
        let mockRequ = MockRequestItems.init(resource: MockItemsResource())
        NetworkClient().retrieve(network: mockRequ, logger: CBLogger(name: "", action: "")) { (result:CBResult<CBItemListWrapper>) in
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

    func testFetchingItem() {
        let exp = expectation(description: "Item")
        let mockRequ = MockRequestItem.init(resource: MockItemResource())
        NetworkClient().retrieve(network: mockRequ, logger: CBLogger(name: "", action: "")) { (result:CBResult<CBItem>) in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.name, "name")
                XCTAssertEqual(status.id, "sub_123")
                exp.fulfill()
            case .error:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testItemResource() {
        let resource = CBItemResource.init("12345")
        Chargebee.configure(site: "imay-test", apiKey: "apikey")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.methodPath, "/v2/items/12345")
    }
    func testItemsResource() {
        let resource = CBItemListResource.init(queryParams: ["page": "1"])
        Chargebee.configure(site: "imay-test", apiKey: "apikey")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.methodPath, "/v2/items")
        XCTAssertEqual(resource.queryParams, ["page": "1"])

    }

}
