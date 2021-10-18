//
//  CBItem.swift
//  Chargebee
//
//  Created by Harish Bharadwaj on 22/07/21.
//

import Foundation

public typealias ItemListHandler = (CBResult<CBItemListWrapper>) -> Void

public typealias ItemHandler = (CBResult<CBItem>) -> Void

public struct CBItemListWrapper: Decodable {
    public let list: [CBItemWrapper]
    public  let nextOffset: String?
    enum CodingKeys: String, CodingKey {
        case list
        case nextOffset = "next_offset"
    }
}

public struct CBItemWrapper: Decodable {
    public let item: CBItem
}

public class CBItem: Decodable {
    public let id: String
    public let name: String
    public let description: String?
    public let status: String
    public let resourceVersion: UInt64
    public let updatedAt: UInt64
    public let itemFamilyId: String
    public let type: String
    public let isShippable: Bool
    public let isGiftable: Bool
    public let enabledForCheckout: Bool
    public let enabledInPortal: Bool
    public let metered: Bool
    public let object: String
    

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case status = "status"
        case description = "description"
        case resourceVersion = "resource_version"
        case updatedAt = "updated_at"
        case itemFamilyId = "item_family_id"
        case type = "type"
        case isShippable = "is_shippable"
        case isGiftable = "is_giftable"
        case enabledForCheckout = "enabled_for_checkout"
        case enabledInPortal = "enabled_in_portal"
        case metered = "metered"
        case object = "object"
        
    }
    
    public static func retrieveAllItems(queryParams : [String:String]? = nil ,completion handler: @escaping ItemListHandler) {
        let logger = CBLogger(name: "item", action: "getAllItems")
        logger.info()
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        let request = CBAPIRequest(resource: CBItemListResource(queryParams :queryParams ))
        
        request.load(withCompletion: { itemListWrapper in
            onSuccess(itemListWrapper)
        }, onError: onError)
    }
    
    public static func retrieveItem(_ itemId: String,completion handler: @escaping ItemHandler) {
        let logger = CBLogger(name: "item", action: "getItem")
        logger.info()
        let (onSuccess, onError) = CBResult.buildResultHandlers(handler, logger)
        if itemId.isEmpty {
            return onError(CBError.defaultSytemError(statusCode: 400, message: "Item id is empty"))
        }
        let request = CBAPIRequest(resource: CBItemResource(itemId))
        
        request.load(withCompletion: { itemWrapper in
            onSuccess(itemWrapper.item)
        }, onError: onError)
    }

}

