//
//  CustomerItemTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-13.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
//    @IBAction func deleteItemButton(_ sender: Any) {
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
