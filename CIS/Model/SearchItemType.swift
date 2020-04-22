//
//  SearchItemType.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-20.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class SearchItemType {
    var attributedItemTypeName: NSMutableAttributedString?
    var attributedBrandName: NSMutableAttributedString?
    var allAttributedName : NSMutableAttributedString?
    
    var itemTypeName: String
    var brandName: String
    var itemTypeMO: ItemTypeMO?

    public init(itemTypeName: String, brandName: String) {
        self.itemTypeName = itemTypeName
        self.brandName = brandName
    }
    
    public func getFormatedText() -> NSMutableAttributedString{
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedItemTypeName!)
        allAttributedName!.append(NSMutableAttributedString(string: ", "))
        allAttributedName!.append(attributedBrandName!)
        
        return allAttributedName!
    }
    
    public func getStringText() -> String{
        return "\(itemTypeName), \(brandName)"
    }

}
