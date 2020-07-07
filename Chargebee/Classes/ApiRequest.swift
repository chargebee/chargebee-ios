//
// Created by Mac Book on 6/7/20.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Decodable
    var methodPath: String { get }
    var baseUrl: String { get set }
    var authHeader: String { get set }
    var url: URLRequest { get }
}

@available(macCatalyst 13.0, *)
extension APIResource {
    var url: URLRequest {
        let url = URL(string: baseUrl + methodPath)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        return urlRequest
    }

    func create<T: URLEncodedRequestBody>(body: T, isUrlEncoded: Bool = true) -> URLRequest {
        let url = URL(string: baseUrl + methodPath)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        urlRequest.httpMethod = "post"
        if isUrlEncoded {
            urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = body.toFormBody().map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        return urlRequest
    }
}

class APIRequest<Resource: APIResource> {
    let resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

@available(macCatalyst 13.0, *)
extension APIRequest: NetworkRequest {

    func decode(_ data: Data) -> Resource.ModelType? {
        return try? JSONDecoder().decode(Resource.ModelType.self, from: data)
    }

    func load(withCompletion completion: @escaping (Resource.ModelType?) -> Void) {
        print("got this url \(resource.url)")
        load(resource.url, withCompletion: completion)
    }

    func create<T: URLEncodedRequestBody>(body: T, withCompletion completion: @escaping (Resource.ModelType?) -> Void) {
        print("got this url \(resource.url)")
        load(resource.create(body: body), withCompletion: completion)
    }
}

struct TempTokenBody: URLEncodedRequestBody {
    let paymentMethodType: String
    let token: String
    let gatewayId: String
    
    func toFormBody() -> [String : String] {
        return [
            "payment_method_type": paymentMethodType,
            "id_at_vault": token,
            "gateway_account_id": gatewayId,
        ]
    }
}

@available(macCatalyst 13.0, *)
class CBTokenResource: APIResource {
    var authHeader: String
    var baseUrl: String = "https://test-ashwin1-test.chargebee.com/api/v2/tokens/create_using_temp_token"
    typealias ModelType = TokenWrapper
    let methodPath: String = ""

    init() {
        let encodedKey = "test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah".data(using: .utf8)?.base64EncodedString() ?? ""
        self.authHeader = "Basic \(encodedKey)"
    }

    
}


