//
//  CBResult.swift
//  Chargebee
//
//  Created by Haripriyan on 7/10/20.
//

public typealias SuccessHandler<T> = (T) -> Void
public typealias ErrorHandler = (CBError) -> Void
public typealias CBResultHandler<T> = (CBResult<T>) -> Void

public enum CBResult<T> {
    case success(_ data: T)
    case error(_ error: CBError)

    static func buildResultHandlers(_ handler: @escaping CBResultHandler<T>, _ logger: CBLogger?) -> (SuccessHandler<T>, ErrorHandler) {
        let onSuccess = {model in handler(.success(model)) }
        let onError = {(error: CBError) -> Void in
            logError(error, logger)
            handler(.error(error))
        }
        return (onSuccess, onError)
    }

    private static func logError(_ error: CBError, _ logger: CBLogger?) {
        switch error {
        case .invalidRequest(let errorResponse),
             .operationFailed(errorResponse: let errorResponse),
             .paymentFailed(errorResponse: let errorResponse):
            logger?.error(message: errorResponse.message, code: errorResponse.httpStatusCode)
        }
    }

}
