//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
protocol NetworkRequest {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable
    
    func decode(_ data: Data) -> ModelType?
    func load(withCompletion completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) -> Void)
    func decodeError(_ data: Data) -> ErrorType?
}

@available(macCatalyst 13.0, *)
extension NetworkRequest {
    func load(_ urlRequest: URLRequest, withCompletion completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) ->Void) {
        makeRequest(urlRequest: urlRequest, completion: completion, onError: onError)
    }

    func create(_ urlRequest: URLRequest, body: [String: String], withCompletion completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) ->Void) {
        let url: URL? = urlRequest.url
        var request = URLRequest(url: url!)
        request.httpMethod = "post"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = body.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        request.httpBody = bodyComponents.query?.data(using: .utf8)

        makeRequest(urlRequest: request, completion: completion, onError: onError)
    }

    private func makeRequest(urlRequest: URLRequest, completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) -> Void) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error{
                onError(error)
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
                onError(self.getCBError(data))
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            completion(self.decode(data))
        })
        task.resume()
    }
    
    private func getCBError(_ data: Data?) -> CBError {
        if let data = data {
            let errorDetail = self.decodeError(data)
            return (errorDetail as? ErrorDetail)?.toCBError() ?? CBError.unknown()
        }
        return CBError.unknown()
    }
}
