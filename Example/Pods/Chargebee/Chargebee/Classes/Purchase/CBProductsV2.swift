//
//  CBProductsV2.swift
//  Chargebee
//
//  Created by CB/IT/01/1039 on 21/09/21.
//

import UIKit

class CBProductsV2: NSObject {
   
    static func getProducts(queryParams : [String:String]? = nil , _ completion: @escaping ((_ products: CBProductIDWrapper) -> Void)) {

        CBItem.retrieveAllItems(queryParams:queryParams ) { result in
            switch result {
            case let .success(itemsWrapper):
                var ids  = [String]()
                for item in  itemsWrapper.list {
                    ids.append(item.item.id)
                }
                completion(CBProductIDWrapper.init(ids: ids, offset: itemsWrapper.nextOffset))
            case let .error(error):
                debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }

}
