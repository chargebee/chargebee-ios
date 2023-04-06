//
// Created by Mac Book on 6/7/20.
//

import Foundation

public protocol CBNetworkRequest {
    associatedtype ModelType: Decodable
    associatedtype ErrorType: Decodable

    func decode(_ data: Data) -> ModelType?
    func decodeError(_ data: Data) -> ErrorType?
    func load(withCompletion completion: SuccessHandler<ModelType>?, onError: ErrorHandler?)
}

@available(macCatalyst 13.0, *)
extension CBNetworkRequest {
    func load(_ session: URLSession = URLSession.shared, urlRequest: URLRequest, withCompletion completion: SuccessHandler<ModelType>? = nil, onError: ErrorHandler? = nil) {

        let task = CBEnvironment.session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
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

    func buildCBError(_ data: Data?, statusCode: Int) -> CBError {
        guard let data = data else {
            return CBError.defaultSytemError(statusCode: statusCode)
        }
        let errorDetail = self.decodeError(data)
        return (errorDetail as? ErrorDetail)?.toCBError(statusCode) ?? CBError.defaultSytemError(statusCode: statusCode)
    }
}
