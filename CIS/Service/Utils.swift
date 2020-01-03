//
//  Utils.swift
//  CIS
//
//  Created by Kevin Pan on 2019-09-19.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation

final class Utils {
    
    static let shared: Utils = Utils()
    
    private init() { }
    
    func cleanupImages(_ shipping: Shipping) {
        for (idx, img) in shipping.images.enumerated() {
            var itemCount = 0
            for itm in shipping.items {
                if(itm.image === img) {
                    itemCount += 1
                }
            }
            if(itemCount == 0) {
                shipping.images.remove(at: idx)
            }
        }
    }
    
    func cleanupCustomers(_ shipping: Shipping) {
        for (idx, cus) in shipping.customers.enumerated() {
            var itemCount = 0
            for itm in shipping.items {
                if(itm.customer === cus) {
                    itemCount += 1
                }
            }
            if(itemCount == 0) {
                shipping.customers.remove(at: idx)
            }
        }
    }
    
    func assignItems(_ customer: Customer, _ items: [Item]) -> Customer {
        
        for img in customer.images {
            img.items.removeAll()
        }
        
        for itm in items {
            for img in customer.images {
                if(itm.image === img) {
                    img.items.append(itm)
                    break
                }
            }
        }
        
        
//        var customers: [Customer] = []
//        var foundCustomer = false
//        var foundImage = false
//
//        for item in items {
//            foundCustomer = false
//
//            for customer in customers {
//                if(customer === item.customer) {
//                    foundImage = false
//                    for image in customer.images {
//                        if(image === item.image) {
//                            image.items.append(item)
//                            foundImage = true
//                            break
//                        }
//                    }
//
//                    if(foundImage == false) {
//                        item.image.items = [item]
//                        customer.images.append(item.image)
//                    }
//
//                    foundCustomer = true
//                    break
//                }
//            }
//
//            if(foundCustomer == false) {
//                item.image.items = [item]
//                item.customer.images = [item.image]
//                customers.append(item.customer)
//            }
//        }
        
        return customer
    }
}


