//
//  SearchBrand.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-26.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class SearchItemTypeBrand {
    var attributedItemTypeBrand: NSMutableAttributedString?
    var allAttributedName : NSMutableAttributedString?
    
    var brandName: String
    var itemTypeBrandMO: ItemTypeBrandMO?

    public init(brandName: String) {
        self.brandName = brandName
    }
    
    public func getFormatedText() -> NSMutableAttributedString{
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedItemTypeBrand!)
        
        return allAttributedName!
    }
    
    public func getStringText() -> String{
        return brandName
    }

}
