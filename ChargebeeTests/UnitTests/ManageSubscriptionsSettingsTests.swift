//
//  ManageSubscriptionsSettingsTests.swift
//  ChargebeeTests
//
//  Created by ramesh_g on 26/06/23.
//

import XCTest
@testable import Chargebee

final class ManageSubscriptionsSettingsTests: XCTestCase {
    
    override  func  setUp() {
        super.setUp()
    }
    override  func  tearDown() {
        super.tearDown()
    }
    
    func  test_showManageSubscriptions() {
        XCTAssertNotNil(UIApplication.showManageSubscriptions())
    }
    
    func  test_showExternalManageSubscriptions() {
        XCTAssertNotNil(UIApplication.showExternalManageSubscriptions())
    }
    
}
