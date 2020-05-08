//
//  CustomerItemTypeTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-07.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerItemTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var typeBrandLabel: UILabel!
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var quantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
