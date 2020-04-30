//
//  ItemTypeTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-30.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class ItemTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
