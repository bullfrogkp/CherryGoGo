//
//  ItemCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-06-28.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    var itemTableViewController: ItemTableViewController!
    let cellId = "itemCellId"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("删除货物", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    let itemNameTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "名字"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.borderStyle = UITextField.BorderStyle.roundedRect
        name.sizeToFit()
        return name
    }()
    
    let itemPriceBoughtTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "进价"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.borderStyle = UITextField.BorderStyle.roundedRect
        name.sizeToFit()
        return name
    }()
    
    let itemPriceSoldTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "卖价"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.borderStyle = UITextField.BorderStyle.roundedRect
        name.sizeToFit()
        return name
    }()
    
    let itemQuantityTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "数量"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.borderStyle = UITextField.BorderStyle.roundedRect
        name.sizeToFit()
        return name
    }()
    
    let itemCommentTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "描述"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.borderStyle = UITextField.BorderStyle.roundedRect
        name.sizeToFit()
        return name
    }()
    
    func setupViews() {
        let views: [String: Any] = [
            "deleteItemButton": deleteItemButton,
            "itemPriceBoughtTextField": itemPriceBoughtTextField,
            "itemPriceSoldTextField": itemPriceSoldTextField,
            "itemQuantityTextField": itemQuantityTextField,
            "itemCommentTextField": itemCommentTextField,
            "itemNameTextField": itemNameTextField]
        
        addSubview(deleteItemButton)
        addSubview(itemNameTextField)
        addSubview(itemPriceBoughtTextField)
        addSubview(itemPriceSoldTextField)
        addSubview(itemQuantityTextField)
        addSubview(itemCommentTextField)
        
        deleteItemButton.addTarget(self, action: Selector(("deleteItem")), for: .touchUpInside)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemNameTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemPriceBoughtTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemPriceSoldTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemQuantityTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemCommentTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[deleteItemButton(100)]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[itemNameTextField]-[itemPriceBoughtTextField]-[itemPriceSoldTextField]-[itemQuantityTextField]-[itemCommentTextField]-[deleteItemButton]-15-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views))
    }
    /*
    @objc func deleteItem() {
        itemTableViewController?.deleteCell(cell: self)
    }
    */
}
