//
//  SearchCustomer.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-19.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class SearchCustomer {
    var attributedCustomerName: NSMutableAttributedString?
    var allAttributedName : NSMutableAttributedString?
    
    var customerName: String
    var customerMO: CustomerMO?

    public init(customerName: String) {
        self.customerName = customerName
    }
    
    public func getFormatedText() -> NSMutableAttributedString{
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedCustomerName!)
        
        return allAttributedName!
    }
    
    public func getStringText() -> String{
        return customerName
    }

}
