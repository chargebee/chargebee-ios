//
// Created by Mac Book on 6/7/20.
//

import Foundation

@available(macCatalyst 13.0, *)
protocol NetworkRequest {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable
    
    func decode(_ data: Data) -> ModelType?
    func decodeError(_ data: Data) -> ErrorType?
    func load(withCompletion completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) -> Void)
}

@available(macCatalyst 13.0, *)
extension NetworkRequest {
    func load(_ urlRequest: URLRequest, withCompletion completion: @escaping (ModelType?) -> Void, onError: @escaping (Error) ->Void) {
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
        guard let data = data else {
            return CBError.unknown()
        }
        let errorDetail = self.decodeError(data)
        return (errorDetail as? ErrorDetail)?.toCBError() ?? CBError.unknown()
    }
}
