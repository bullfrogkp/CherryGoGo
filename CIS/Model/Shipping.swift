//
//  Shipping.swift
//  CherryGo
//
//  Created by Kevin Pan on 2019-06-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Shipping {
    var comment: String
    var city: String
    var deposit: NSDecimalNumber
    var feeInternational: NSDecimalNumber
    var feeNational: NSDecimalNumber
    var shippingDate: Date
    var status: String
    var items: [Item]
    var images: [Image]
    var customers: [Customer]
    var shippingMO: ShippingMO?
    
    init(comment: String, city: String, deposit: NSDecimalNumber, feeInternational: NSDecimalNumber, feeNational: NSDecimalNumber, shippingDate: Date, status: String, items: [Item], images: [Image], customers: [Customer]) {
        self.comment = comment
        self.deposit = deposit
        self.city = city
        self.feeInternational = feeInternational
        self.feeNational = feeNational
        self.shippingDate = shippingDate
        self.status = status
        self.items = items
        self.images = images
        self.customers = customers
    }
    
    convenience init() {
        self.init(comment: "", city: "", deposit: 0, feeInternational: 0, feeNational: 0, shippingDate: Date(), status: "", items: [], images: [], customers: [])
    }
}
