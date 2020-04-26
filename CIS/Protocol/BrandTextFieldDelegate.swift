//
//  BrandTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-26.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol BrandTextFieldDelegate: class {
    func setBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ val: String, _ itemTypeBrandMO: ItemTypeBrandMO)
}
