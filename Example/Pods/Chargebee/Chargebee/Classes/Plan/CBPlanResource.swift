//
// Created by Mac Book on 6/7/20.
//

import Foundation

final class CBPlanResource: CBAPIResource {
    
    typealias ModelType = CBPlanWrapper
    typealias ErrorType = CBErrorDetail
    
    var authHeader: String? {
        get {
          "Basic \(CBEnvironment.encodedApiKey)"
        }
    }
    var baseUrl: String
    var methodPath: String = "/v2/plans"
    
    init(_ planId: String) {
        self.baseUrl = CBEnvironment.baseUrl
        self.methodPath += "/\(planId)"
    }
}


final class CBPlansResource: CBAPIResource {
    
    typealias ModelType = CBPlansWrapper
    typealias ErrorType = CBErrorDetail
    
    var authHeader: String? {
        get {
          "Basic \(CBEnvironment.encodedApiKey)"
        }
    }
    var baseUrl: String
    var methodPath: String = "/v2/plans"
    var queryParams : [String:String]? = nil
    
    init(queryParams : [String:String]? = nil) {
        self.baseUrl = CBEnvironment.baseUrl
        if let queryParams = queryParams{
            self.queryParams = queryParams
        }
    }
    
   
}
