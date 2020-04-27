//
//  SearchItemType.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-20.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class SearchItemTypeName {
    var attributedItemTypeName: NSMutableAttributedString?
    var allAttributedName : NSMutableAttributedString?
    
    var typeName: String
    var itemTypeNameMO: ItemTypeNameMO?

    public init(typeName: String) {
        self.typeName = typeName
    }
    
    public func getFormatedText() -> NSMutableAttributedString{
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedItemTypeName!)
        
        return allAttributedName!
    }
    
    public func getStringText() -> String{
        return typeName
    }

}
