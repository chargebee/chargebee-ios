//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class PlanResource: APIResource {
    typealias ModelType = PlanWrapper
    var headers: [String: String]
    var authHeader: String
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2"

    init() {
        self.authHeader = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah".data(using: .utf8)?.base64EncodedString() ?? ""
        self.headers = ["Authorization": "Basic \(self.authHeader)"]
    }

    func setPlan(_ planId: String) {
        self.methodPath = self.methodPath + "/\(planId)"
    }

    private(set) var methodPath: String = "/plans"
}
