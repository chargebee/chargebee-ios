//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
protocol NetworkRequest {
    associatedtype ModelType
    func decode(_ data: Data) -> ModelType?
    func load(withCompletion completion: @escaping (ModelType?) -> Void)
}

@available(macCatalyst 13.0, *)
extension NetworkRequest {
    func load(_ urlRequest: URLRequest, withCompletion completion: @escaping (ModelType?) -> Void) {
        makeRequest(urlRequest: urlRequest, completion: completion)
    }

    func create(_ urlRequest: URLRequest, body: [String: String], withCompletion completion: @escaping (ModelType?) -> Void) {
        let url: URL? = urlRequest.url
        var request = URLRequest(url: url!)
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.httpMethod = "post"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = body.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: value)
        })
        request.httpBody = bodyComponents.query?.data(using: .utf8)

        makeRequest(urlRequest: request, completion: completion)
    }

    private func makeRequest(urlRequest: URLRequest, completion: @escaping (ModelType?) -> ()) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(self.decode(data))
        })
        task.resume()
    }
}
