//
//  CustomerItemEditTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-22.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerItemEditTableViewCell: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    var customerItemEditViewController: CustomerItemEditViewController!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    
    @IBOutlet weak var priceBoughtTextField: UITextField!
    @IBOutlet weak var priceSoldTextField: UITextField!
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBAction func deleteItem(_ sender: Any) {
        customerItemEditViewController.deleteCell(cell: self)
    }
    
    @IBAction func didChangeTextFieldValue(_ sender: UITextField) {
        delegate?.cell(self, didUpdateTextField: sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
