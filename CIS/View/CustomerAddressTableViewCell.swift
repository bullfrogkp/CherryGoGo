//
//  CustomerAddressTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-08.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
