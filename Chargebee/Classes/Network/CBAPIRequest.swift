//
// Created by Mac Book on 6/7/20.
//

import Foundation
protocol URLEncodedRequestBody {
    func toFormBody() -> [String: String]
}

protocol CBAPIResource {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable

    var methodPath: String { get }
    var baseUrl: String { get }
    var authHeader: String? { get }
    var header: [String: String]? { get }
    var url: URLRequest { get }
    var requestBody: URLEncodedRequestBody? { get }
    func create() -> URLRequest
    var queryParams: [String: String]? { get set}

}

extension CBAPIResource {

    var authHeader: String? {
        return nil
    }
    var header: [String: String]? {
        return nil
    }

    var queryParams: [String: String]? {
        get { return nil } set {}
    }

    var requestBody: URLEncodedRequestBody? {
        return nil
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
        var components = URLComponents(string: baseUrl)
        components!.path += methodPath

        if let queryParams = queryParams {
            components?.queryItems = queryItems(dictionary: queryParams)
        }

        var urlRequest = URLRequest(url: components!.url!)
        if let authHeader = authHeader {
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        header?.forEach({ (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })
        urlRequest.addValue(sdkVersion, forHTTPHeaderField: "version")
        urlRequest.addValue(platform, forHTTPHeaderField: "platform")
        return urlRequest
    }
}

class CBAPIRequest<Resource: CBAPIResource> {
    var resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension CBAPIRequest: CBNetworkRequest {

    func decode(_ data: Data) -> Resource.ModelType? {
        return try? JSONDecoder().decode(Resource.ModelType.self, from: data)
    }

    func decodeError(_ data: Data) -> Resource.ErrorType? {
        return try? JSONDecoder().decode(Resource.ErrorType.self, from: data)
    }

    func load(withCompletion completion: SuccessHandler<Resource.ModelType>? = nil, onError: ErrorHandler? = nil) {
        load(CBEnvironment.session, urlRequest: resource.url, withCompletion: completion, onError: onError)
    }

    func create(withCompletion completion: SuccessHandler<Resource.ModelType>? = nil, onError: ErrorHandler? = nil) {
        load(CBEnvironment.session, urlRequest: resource.create(), withCompletion: completion, onError: onError)
    }
}

func queryItems(dictionary: [String: String]) -> [URLQueryItem] {
    return dictionary.map {
        // Swift 4
        URLQueryItem(name: $0.0, value: $0.1)
    }
}

protocol NetworkSession {
    func loadData(from url: URL,
                  completionHandler: @escaping (Data?, Error?) -> Void)
}

extension URLSession: NetworkSession {
    func loadData(from url: URL,
                  completionHandler: @escaping (Data?, Error?) -> Void) {
        let task = dataTask(with: url) { (data, _, error) in
            completionHandler(data, error)
        }

        task.resume()
    }
}

struct NetworkClient {

    func retrieve<T: CBNetworkRequest, U>(network: T, logger: CBLogger, handler: @escaping (CBResult<U>) -> Void) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
    network.load(withCompletion: { result in
            if let data = result as? U {
                onSuccess(data)
            } else {
                onError(CBError.defaultSytemError(statusCode: 480, message: "json serialization failure"))
            }
        }, onError: onError)
    }
}
