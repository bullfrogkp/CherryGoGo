//
//  CustomTableView.swift
//  CIS
//
//  Created by Kevin Pan on 2019-07-15.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
