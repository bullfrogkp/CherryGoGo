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
    var customer: Customer
    var quantity: Int16
    
    var comment: String?
    var image: Image?
    var priceBought: NSDecimalNumber?
    var priceSold: NSDecimalNumber?
    
    var itemMO: ItemMO?
    
    init(comment: String, image: Image, name: String, priceBought: NSDecimalNumber, priceSold: NSDecimalNumber, quantity: Int16, customer: Customer) {
        self.comment = comment
        self.image = image
        self.name = name
        self.priceBought = priceBought
        self.priceSold = priceSold
        self.quantity = quantity
        self.customer = customer
    }
    
    convenience init() {
        self.init(comment: "", image: Image(), name: "", priceBought: 0, priceSold: 0, quantity: 0, customer: Customer())
    }
}
