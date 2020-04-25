//
//  ItemType.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-20.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

class ItemType {
    var itemTypeName: ItemTypeName
    var itemTypeBrand: ItemTypeBrand
    
    var itemTypeMO: ItemTypeMO?
    
    init(itemTypeName: itemTypeBrand, itemTypeBrand: ItemTypeBrand) {
        self.itemTypeName = itemTypeName
        self.itemTypeBrand = itemTypeBrand
    }
}
