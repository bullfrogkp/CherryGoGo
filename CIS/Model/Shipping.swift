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
    
    init(city: String, shippingDate: Date) {
        self.city = city
        self.shippingDate = shippingDate
    }
}
