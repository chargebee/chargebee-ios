//
//  CBError.swift
//  Chargebee
//
//  Created by Haripriyan on 7/8/20.
//

import Foundation

public enum CBError: Error {
    case unknown(String? = nil)
    case authenticationError
    case resourceNotFound
}
