//
// Created by Mac Book on 6/7/20.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable
    
    var methodPath: String { get }
    var baseUrl: String { get set }
    var authHeader: String { get set }
    var header: [String:String]? { get }
    var url: URLRequest { get }
}

@available(macCatalyst 13.0, *)
extension APIResource {
    var header: [String: String]? {
        get {
            nil
        }
    }
    
    var url: URLRequest {
        buildBaseRequest()
    }

    func create<T: URLEncodedRequestBody>(body: T, isUrlEncoded: Bool = true) -> URLRequest {
        var urlRequest = buildBaseRequest()

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

    private func buildBaseRequest() -> URLRequest {
        let url = URL(string: baseUrl + methodPath)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        header?.forEach({ (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })
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

    func decodeError(_ data: Data) -> Resource.ErrorType? {
        return try? JSONDecoder().decode(Resource.ErrorType.self, from: data)
    }
    
    func load(withCompletion completion: @escaping (Resource.ModelType?) -> Void, onError: @escaping (Error) -> Void) {
        print("Get Request url: \(resource.url)")
        load(resource.url, withCompletion: completion, onError: onError)
    }

    func create<T: URLEncodedRequestBody>(body: T, withCompletion completion: @escaping (Resource.ModelType?) -> Void, onError: @escaping (Error) ->Void) {
        print("Post request url: \(resource.url)")
        load(resource.create(body: body), withCompletion: completion, onError: onError)
    }
}
