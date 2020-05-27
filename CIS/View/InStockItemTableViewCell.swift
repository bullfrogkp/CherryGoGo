//
//  InStockItemTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-26.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class InStockItemTableViewCell: UITableViewCell {

    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
