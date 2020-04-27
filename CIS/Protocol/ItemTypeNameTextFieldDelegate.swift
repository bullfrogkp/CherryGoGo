//
//  ItemTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-21.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol ItemTypeNameTextFieldDelegate: class {
    func setItemTypeNameData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeNameMO: ItemTypeNameMO)
}
