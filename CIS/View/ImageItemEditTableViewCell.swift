//
//  ImageItemEditTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-22.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ImageItemEditTableViewCell: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    var imageItemEditViewController: ImageItemEditViewController!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBAction func deleteItem(_ sender: Any) {
        imageItemEditViewController.deleteCell(cell: self)
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
