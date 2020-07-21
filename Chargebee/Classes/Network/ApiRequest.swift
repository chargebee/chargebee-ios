//
// Created by Mac Book on 6/7/20.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable

    var methodPath: String { get }
    var baseUrl: String { get }
    var authHeader: String? { get }
    var header: [String: String]? { get }
    var url: URLRequest { get }
    var requestBody: URLEncodedRequestBody? { get }
    
    func create() -> URLRequest
}

extension APIResource {
    var authHeader: String? {
        get {
            nil
        }
    }
    var header: [String: String]? {
        get {
            nil
        }
    }
    
    var requestBody: URLEncodedRequestBody? {
        get {
            nil
        }
    }
    
    var url: URLRequest {
        buildBaseRequest()
    }

    func create() -> URLRequest {
        var urlRequest = buildBaseRequest()
        urlRequest.httpMethod = "post"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = requestBody?.toFormBody().map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        urlRequest.httpBody = bodyComponents.query?.data(using: .utf8)
        return urlRequest
    }

    private func buildBaseRequest() -> URLRequest {
        // TODO: Remove force unwrapping
        var components = URLComponents(string: baseUrl)
        components!.path += methodPath

        var urlRequest = URLRequest(url: components!.url!)
        if let authHeader = authHeader {
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        }
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

extension APIRequest: NetworkRequest {
    
    func decode(_ data: Data) -> Resource.ModelType? {
        return try? JSONDecoder().decode(Resource.ModelType.self, from: data)
    }

    func decodeError(_ data: Data) -> Resource.ErrorType? {
        return try? JSONDecoder().decode(Resource.ErrorType.self, from: data)
    }
    
    func load(withCompletion completion: SuccessHandler<Resource.ModelType>? = nil, onError: ErrorHandler? = nil) {
        load(resource.url, withCompletion: completion, onError: onError)
    }

    func create(withCompletion completion: SuccessHandler<Resource.ModelType>? = nil, onError: ErrorHandler? = nil) {
        load(resource.create(), withCompletion: completion, onError: onError)
    }
}
