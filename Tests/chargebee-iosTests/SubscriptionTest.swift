//
//  SubscriptionTest.swift
//  
//
//  Created by cb-imay on 24/02/22.
//

import XCTest
@testable import Chargebee
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    // override resume and call the closure

    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    // data and error can be set to provide data or an error
    var data: Data?
    var error: Error?
    override func dataTask(
        with url: URL,
        completionHandler: @escaping CompletionHandler
        ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

struct MockSubResource: CBAPIResource {
    typealias ModelType = CBSubscriptionStatus
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

class MockRequest<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequest: CBNetworkRequest {
    func load(withCompletion completion: SuccessHandler<CBSubscriptionStatus>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func decode(_ data: Data) -> CBSubscriptionStatus? {
        return CBSubscriptionStatus.init(subscription: Subscription.init(activatedAt: 12222.0, status: "active", planAmount: 2332.0, id: "123456", customerId: "ima-123", currentTermEnd: 1233233.0, currentTermStart: 123323323.0))
    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBSubscriptionStatus
    typealias ErrorType = String

}

class SubscriptionTest: XCTestCase {
    func testFetchingSubscription() {
        let exp = expectation(description: "SubscriptionStatus")
        let mockRequ = MockRequest.init(resource: MockSubResource())
        CBSubscriptionManager().retrieveSubscription(network: mockRequ, logger: CBLogger(name: "", action: "")) { result in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.subscription.customerId, "ima-123")
                exp.fulfill()
            case .error:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 20)
    }

    func testSubscriptionResource() {
        let resource = CBSubscriptionResource.init("12345")
        Chargebee.configure(site: "imay-test", apiKey: "apikey")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertNotNil(resource.url)
        XCTAssertEqual(resource.methodPath, "/v2/in_app_subscriptions/12345")

    }

}
