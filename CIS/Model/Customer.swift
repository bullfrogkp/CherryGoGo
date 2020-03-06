//
//  Customer.swift
//  CIS
//
//  Created by Kevin Pan on 2019-07-21.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

class Customer {
    var name: String
    var changed: Bool
    
    var createdDatetime: Date?
    var createdUser: String?
    var updatedDatetime: Date?
    var updatedUser: String?
    var comment: String?
    var phone: String?
    var wechat: String?
    var items: [Item]?
    var images: [Image]?
    var newCustomer: Customer?
    var customerMO: CustomerMO?
    
    init(name: String) {
        self.name = name
        self.changed = false
    }
}
