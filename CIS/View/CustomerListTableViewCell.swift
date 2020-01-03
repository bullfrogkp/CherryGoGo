//
//  CustomerListTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-01.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerListTableViewCell: UITableViewCell {
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerItemsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
