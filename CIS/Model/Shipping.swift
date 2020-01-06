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
    var deposit: Decimal
    var feeInternational: Decimal
    var feeNational: Decimal
    var shippingDate: Date
    var shippingStatus: String
    var items: [Item]
    var images: [Image]
    var customers: [Customer]
    var shippingMO: ShippingMO?
    
    init(comment: String, city: String, deposit: Decimal, feeInternational: Decimal, feeNational: Decimal, shippingDate: Date, shippingStatus: String, items: [Item], images: [Image], customers: [Customer]) {
        self.comment = comment
        self.deposit = deposit
        self.city = city
        self.feeInternational = feeInternational
        self.feeNational = feeNational
        self.shippingDate = shippingDate
        self.shippingStatus = shippingStatus
        self.items = items
        self.images = images
        self.customers = customers
    }
    
    convenience init() {
        self.init(comment: "", city: "", deposit: 0, feeInternational: 0, feeNational: 0, shippingDate: Date(), shippingStatus: "", items: [], images: [], customers: [])
    }
}
