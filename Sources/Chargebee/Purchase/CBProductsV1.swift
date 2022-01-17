//
//  CBProductsV1.swift
//  Chargebee
//
//  Created by CB/IT/01/1039 on 21/09/21.
//
import Foundation
public typealias ProductIdentifierHandler = (CBResult<CBProductIDWrapper>) -> Void

public struct CBProductIDWrapper {
   public let ids: [String]
   public let offset:String?
}
public extension String {
  func indexInt(of char: Character) -> Int? {
    return firstIndex(of: char)?.utf16Offset(in: self)
  }
}

class CBProductsV1: NSObject {
   
    static func getProducts(queryParams : [String:String]? = nil , _ completion: @escaping ((_ products: CBProductIDWrapper) -> Void)) {
        let updatedParams = queryParams?.merging(["channel[is]":"app_store"]) { (current, _) in current }
        CBPlan.retrieveAllPlans(queryParams:updatedParams ) { result in
            switch result {
            case let .success(plansList):
                var ids  = [String]()
                for plan in  plansList.list {
                    //Remove Currency Prefix
                    var id = plan.plan.id
                    if let _ = id.range(of: "-\(plan.plan.currencyCode)") {
                        id = String(id.dropLast(plan.plan.currencyCode.count + 1))
                    }
                    ids.append(id)
                }
                completion(CBProductIDWrapper.init(ids: ids, offset: plansList.nextOffset))
            case let .error(error):
                debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }

}
