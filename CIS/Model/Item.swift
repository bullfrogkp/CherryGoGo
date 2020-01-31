//
//  Item.swift
//  CherryGo
//
//  Created by Kevin Pan on 2019-06-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Item {
    var name: String
    var quantity: Int16
    
    var comment: String?
    var image: Image?
    var customer: Customer?
    var priceBought: NSDecimalNumber?
    var priceSold: NSDecimalNumber?
    
    var itemMO: ItemMO?
    
    init(name: String, quantity: Int16) {
        self.name = name
        self.quantity = quantity
    }
}
