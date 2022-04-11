//
//  CBAuthenticationResource.swift
//  Chargebee
//
//  Created by Imayaselvan on 23/06/21.
//

import Foundation

final class CBAuthenticationResource: CBAPIResource {
    typealias ModelType = CBAuthenticationStatus
    typealias ErrorType = CBErrorDetail

    var authHeader: String? {
        return "Basic \(CBEnvironment.encodedApiKey)"
    }
    var baseUrl: String
    var requestBody: URLEncodedRequestBody?
    var methodPath: String {
        return "/v2/in_app_details/\(CBEnvironment.sdkKey)/verify_app_detail"
    }

    var url: URLRequest {
        var components = URLComponents(string: baseUrl)
        components!.path += methodPath
        var urlRequest = URLRequest(url: components!.url!)
        urlRequest.httpMethod = "post"
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = requestBody?.toFormBody().map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(authHeader!, forHTTPHeaderField: "Authorization")
        urlRequest.addValue(sdkVersion, forHTTPHeaderField: "version")
        urlRequest.addValue(platform, forHTTPHeaderField: "platform")
        return urlRequest
    }

    init(key: String, bundleId: String,
         appName: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.requestBody = CBAuthenticationBody.init(key: key, bundleId: bundleId, appName: appName)
    }
}

// MARK: Model Object
struct CBAuthenticationBody: URLEncodedRequestBody {
    let key: String
    let bundleId: String
    let appName: String
    let channel: String = "app_store"

    func toFormBody() -> [String: String] {
        [
            "shared_secret": key,
            "app_id": bundleId,
            "app_name": appName,
            "channel": channel
        ]
    }
}

public struct CBAuthenticationStatus: Codable {

    public let details: CBAuthentication

    enum CodingKeys: String, CodingKey {
        case details = "in_app_detail"
    }
}

public enum CatalogVersion: String, Codable {
    case v1
    case v2
    case unknown

}

public struct CBAuthentication: Codable {

    public let appId: String?
    public let status: String?
    public let version: CatalogVersion?

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case status
        case version = "product_catalog_version"
    }
}
