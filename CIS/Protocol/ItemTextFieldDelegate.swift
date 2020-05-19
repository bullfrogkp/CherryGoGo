//
//  ItemTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-18.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol ItemTextFieldDelegate: class {
    func setItemNameData(_ sectionIndex: Int, _ rowIndex: Int, _ name: String)
    func setItemBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ name: String)
}
