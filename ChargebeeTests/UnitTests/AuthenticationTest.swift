//
//  AuthenticationTest.swift
//  
//
//  Created by cb-imay on 24/02/22.
//

import XCTest
@testable import Chargebee
struct MockResourceAuthentication: CBAPIResource {
    typealias ModelType = CBAuthenticationStatus
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

class MockRequestAuthentication<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension MockRequestAuthentication: CBNetworkRequest {

    func decode(_ data: Data) -> CBAuthenticationStatus? {
        return CBAuthenticationStatus.init(details: CBAuthentication.init(appId: "1234", status: "success", version: .v2))
    }

    func load(withCompletion completion: SuccessHandler<CBAuthenticationStatus>?, onError: ErrorHandler?) {
        load(URLSessionMock(), urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func decodeError(_ data: Data) -> String? {
        return nil
    }

    typealias ModelType = CBAuthenticationStatus
    typealias ErrorType = String

}
class AuthenticationTest: XCTestCase {
    let manager = CBAuthenticationManager()

    override func setUp() {
        super.setUp()
        Chargebee.configure(site: "test", apiKey: "12345", sdkKey: "6789", allowErrorLogging: true)

    }

    func testEnvironmentValues() {
        XCTAssertEqual(CBEnvironment.site, "test")
        XCTAssertEqual(CBEnvironment.baseUrl, "https://test.chargebee.com/api")
        XCTAssertEqual(CBEnvironment.apiKey, "12345")
        XCTAssertEqual(CBEnvironment.sdkKey, "6789")
        XCTAssertEqual(CBAuthenticationManager.isSDKKeyPresent(), true)
        XCTAssertEqual(CBAuthenticationManager.isCatalogV1(), true)

    }
    func testAuthenticationResource() {
        CBEnvironment.sdkKey = "12345"
        let resource = CBAuthenticationResource.init(key: "123", bundleId: "com.chargebee.example", appName: "example")
        XCTAssertNotNil(resource.authHeader)
        XCTAssertEqual(resource.methodPath, "/v2/in_app_details/12345/verify_app_detail")
        XCTAssertNotNil(resource.requestBody)

    }

    func testAuthenticationManger() {
        let exp = expectation(description: "Authentication")
        let mockRequ = MockRequestAuthentication.init(resource: MockResourceAuthentication())

        manager.authenticateRestClient(network: mockRequ, logger: CBLogger(name: "", action: "")) { result in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.details.status, "success")
                XCTAssertEqual(status.details.appId, "1234")
                XCTAssertEqual(status.details.version, .v2)

                exp.fulfill()
            case .error:
                XCTFail()
            }

        }
        waitForExpectations(timeout: 10)

    }

    func testSDKKey() {
    }

}
