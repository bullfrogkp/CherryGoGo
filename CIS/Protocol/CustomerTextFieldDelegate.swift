//
//  CustomerTextFieldDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-21.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import Foundation

protocol CustomerTextFieldDelegate: class {
    func setData(_ idx: Int, _ val: String)
}
