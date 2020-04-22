//
//  Item.swift
//  CherryGo
//
//  Created by Kevin Pan on 2019-06-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Item {
    var itemType: ItemType
    var quantity: Int16
    var changed: Bool
    
    var createdDatetime: Date?
    var createdUser: String?
    var updatedDatetime: Date?
    var updatedUser: String?
    var comment: String?
    var image: Image?
    var customer: Customer?
    
    var priceBought: NSDecimalNumber?
    var priceSold: NSDecimalNumber?
    
    var itemMO: ItemMO?
    
    init(itemType: ItemType, quantity: Int16) {
        self.itemType = itemType
        self.quantity = quantity
        self.changed = false
    }
}
