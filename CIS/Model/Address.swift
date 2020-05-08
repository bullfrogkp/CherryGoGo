//
//  Address.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-08.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class Address {
    
    var street: String
    var city: String
    var postalCode: String
    var country: String
    var unit: String?
    
    var customer: Customer?
    
    init(street: String, city: String, postalCode: String, country: String) {
        self.street = street
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
}
