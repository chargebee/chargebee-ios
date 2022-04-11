//
//  CBProductsTest.swift
//  
//
//  Created by cb-imay on 28/02/22.
//

import XCTest
@testable import Chargebee

struct MockResource: CBAPIResource {
    var methodPath: String

    var baseUrl: String

    typealias ModelType = String
    typealias ErrorType = String

}

class CBProductsTest: XCTestCase {

    func testAPIResoruce() {
        let req = MockResource.init(methodPath: "", baseUrl: "")
        XCTAssertEqual(req.authHeader, nil)
        XCTAssertEqual(req.header, nil)
        XCTAssertEqual(req.queryParams, nil)
        XCTAssertNotNil(req.url)

    }

    func testAuthent() {
        let exp = expectation(description: "Authentication")
        let mockRequ = MockRequestAuthentication.init(resource: MockResourceAuthentication())

        CBAuthenticationManager().authenticateRestClient(network: mockRequ, logger: CBLogger(name: "", action: "")) { result in
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

}
