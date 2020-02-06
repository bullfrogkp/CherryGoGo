//
//  CustomCellDelegate.swift
//  CIS
//
//  Created by Kevin Pan on 2019-10-07.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation
import UIKit

protocol CustomCellDelegate: class {
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField)
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField)
}
