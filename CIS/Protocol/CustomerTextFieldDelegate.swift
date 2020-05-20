//
//  CustomerTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-19.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol CustomerTextFieldDelegate: class {
    func setCustomerNameData(_ sectionIndex: Int, _ name: String)
}
