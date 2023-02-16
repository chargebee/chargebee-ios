//
//  CBCustomerInfo.swift
//  Chargebee
//
//  Created by ramesh_g on 06/02/23.
//

import Foundation


public struct CBCustomer{
    public var customerID: String
    public var first_name: String
    public var last_name: String
    public var email: String
    
    public init(customerID: String,first_name: String,last_name:String,email:String) {
        self.customerID = customerID
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
    }
}
