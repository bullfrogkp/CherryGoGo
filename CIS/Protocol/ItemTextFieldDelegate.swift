//
//  ItemTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-21.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol ItemTextFieldDelegate: class {
    func setItemData(_ sectionIndex: Int, _ rowIndex: Int, _ val: String, _ itemTypeMO: ItemTypeMO)
}
