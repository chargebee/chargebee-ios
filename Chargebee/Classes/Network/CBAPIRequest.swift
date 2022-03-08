//
// Created by Mac Book on 6/7/20.
//

import Foundation

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
        func buildCBError(_ data: Data?, statusCode: Int) -> CBError {
            guard let data = data else {
                return CBError.defaultSytemError(statusCode: statusCode)
            }
            let errorDetail = self.decodeError(data)
            return (errorDetail as? ErrorDetail)?.toCBError(statusCode) ?? CBError.defaultSytemError(statusCode: statusCode)
        }

        let task = CBEnvironment.session.dataTask(with: resource.url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                onError?(CBError.defaultSytemError(statusCode: 400, message: error.localizedDescription))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
                onError?(self.buildCBError(data, statusCode: response.statusCode))
                return
            }
            guard let data = data,
                  let decodedData = self.decode(data) else {
                onError?(CBError.defaultSytemError(statusCode: 400, message: "Response has no/invalid body"))
                return
            }
            completion?(decodedData)
        })
        task.resume()

    }

    func create(withCompletion completion: SuccessHandler<Resource.ModelType>? = nil, onError: ErrorHandler? = nil) {}
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
    func retrieveAllItems<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping ItemListHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { data in
            if let data = data as? CBItemListWrapper {
                onSuccess(data)
            }
        }, onError: onError)
    }
    func retrieveItem<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping ItemHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { data in
            if let data = data as? CBItem {
                onSuccess(data)
            }
        }, onError: onError)
    }

    func retrieveAllPlans<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping AllPlanHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { data in
            if let data = data as? CBPlansWrapper {
                onSuccess(data)
            } 
        }, onError: onError)
    }

    func retrievePlan<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping PlanHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { data in
            if let data = data as? CBPlan {
                onSuccess(data)
            }
        }, onError: onError)
    }
   
    func retrieveAddon<T: CBNetworkRequest>(network: T, logger: CBLogger, handler: @escaping AddonHandler) {
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        network.load(withCompletion: { data in
            if let data = data as? CBAddon {
                onSuccess(data)
            }
        }, onError: onError)
    }

}
