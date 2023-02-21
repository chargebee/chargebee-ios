//
//  CBCustomer.swift
//  Chargebee
//
//  Created by ramesh_g on 06/02/23.
//

import Foundation


public struct CBCustomer{
    public let customerID: String?
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    
    public init(customerID: String? = "",firstName: String? = "",lastName:String? = "",
                email:String? = "") {
        self.customerID = customerID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
