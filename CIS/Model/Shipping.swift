//
//  Shipping.swift
//  CherryGo
//
//  Created by Kevin Pan on 2019-06-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Shipping {
    var shippingDate: Date
    var city: String
    
    var comment: String?
    var deposit: NSDecimalNumber?
    var feeInternational: NSDecimalNumber?
    var feeNational: NSDecimalNumber?
    var status: String?
    var boxQuantity: String?
    var items: [Item]?
    var images: [Image]?
    var customers: [Customer]?
    var shippingMO: ShippingMO?
    
    init(comment: String, city: String, deposit: NSDecimalNumber, feeInternational: NSDecimalNumber, feeNational: NSDecimalNumber, shippingDate: Date, status: String, boxQuantity: String, items: [Item], images: [Image], customers: [Customer]) {
        self.comment = comment
        self.deposit = deposit
        self.city = city
        self.feeInternational = feeInternational
        self.feeNational = feeNational
        self.shippingDate = shippingDate
        self.status = status
        self.boxQuantity = boxQuantity
        self.items = items
        self.images = images
        self.customers = customers
    }
    
    convenience init() {
        self.init(comment: "", city: "", deposit: 0, feeInternational: 0, feeNational: 0, shippingDate: Date(), status: "", boxQuantity: "", items: [], images: [], customers: [])
    }
}
