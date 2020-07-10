//
//  CBResult.swift
//  Chargebee
//
//  Created by Haripriyan on 7/10/20.
//

typealias SuccessHandler<T> = (T) -> Void
typealias ErrorHandler = (CBError) -> Void
typealias CBResultHandler<T> = (CBResult<T>) -> Void

public enum CBResult<T> {
    case success(_ data: T)
    case error(_ error: CBError)
    
    static func buildResultHandlers(_ handler: @escaping CBResultHandler<T>) -> (SuccessHandler<T>, ErrorHandler) {
        let onSuccess = {model in handler(.success(model)) }
        let onError = {error in handler(.error(error))}
        return (onSuccess, onError)
    }
}
