//
//  CustomerItemEditTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-22.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerItemEditTableViewCell: UITableViewCell, UITextViewDelegate {
    weak var delegate: CustomCellDelegate?
    var customerItemEditViewController: CustomerItemEditViewController!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var priceBoughtTextField: UITextField!
    @IBOutlet weak var priceSoldTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBAction func deleteItem(_ sender: Any) {
        customerItemEditViewController.deleteCell(cell: self)
    }
    
    @IBAction func didChangeTextFieldValue(_ sender: UITextField) {
        delegate?.cell(self, didUpdateTextField: sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.cell(self, didUpdateTextView: textView)
    }
}
