//
//  Item.swift
//  CherryGo
//
//  Created by Kevin Pan on 2019-06-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Item {
    var changed: Bool
    
    var itemType: ItemType?
    var quantity: Int16?
    var createdDatetime: Date?
    var createdUser: String?
    var updatedDatetime: Date?
    var updatedUser: String?
    var comment: String?
    var image: Image?
    var customer: Customer?
    
    var street: String?
    var city: String?
    var postalCode: String?
    var country: String?
    var unit: String?
    
    var priceBought: NSDecimalNumber?
    var priceSold: NSDecimalNumber?
    
    var itemMO: ItemMO?
    
    init() {
        self.changed = false
    }
    
    convenience init(itemType: ItemType, quantity: Int16) {
        self.init()
        self.itemType = itemType
        self.quantity = quantity
    }
}
