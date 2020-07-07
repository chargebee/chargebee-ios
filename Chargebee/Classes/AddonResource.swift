//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
class AddonResource: APIResource {
    typealias ModelType = AddonWrapper
    var headers: [String: String]
    var authHeader: String
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2"

    init() {
        self.authHeader = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah".data(using: .utf8)?.base64EncodedString() ?? ""
        self.headers = ["Authorization": "Basic \(self.authHeader)"]
    }

    func setAddon(_ addonId: String) {
        self.methodPath = self.methodPath + "/\(addonId)"
    }

    private(set) var methodPath: String = "/addons"
}
