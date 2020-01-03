//
//  CustomerCell.swift
//  CIS
//
//  Created by Kevin Pan on 2019-06-28.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    
    var customerTableViewController: CustomerTableViewController!
    var itemTableView: UITableView!
    var itemTableController: ItemTableViewController!
    var items: [Item] = []
    
    let cellId = "itemCellId"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteCustomerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("删除客户", for: .normal)
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
    
    let addItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加货物", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0.8, alpha: 1.0)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    let customerNameTextField: UITextField = {
        let textField =  UITextField()
        textField.placeholder = "客户名字"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.sizeToFit()
        return textField
    }()
    
    func setupVars(items customerItems: [Item]) {
        self.items = customerItems
    }
    
    func setupViews() {
        addSubview(deleteCustomerButton)
        addSubview(addItemButton)
        addSubview(customerNameTextField)
        
        itemTableController = ItemTableViewController()
        
        itemTableView = CustomTableView()
        itemTableView.delegate = itemTableController
        itemTableView.dataSource = itemTableController
        itemTableView.register(ItemCell.self, forCellReuseIdentifier: cellId)
        itemTableView.translatesAutoresizingMaskIntoConstraints = false
        itemTableView.allowsSelection = false
        itemTableController.itemTableView = itemTableView
        itemTableController.items = self.items
        
        addSubview(itemTableView)
        
        deleteCustomerButton.addTarget(self, action: Selector(("deleteCustomer")), for: .touchUpInside)
        addItemButton.addTarget(self, action: Selector(("addItem")), for: .touchUpInside)
        
        let views: [String: Any] = [
            "deleteCustomerButton": deleteCustomerButton,
            "addItemButton": addItemButton,
            "customerNameTextField": customerNameTextField,
            "itemTableView": itemTableView!]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[customerNameTextField]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[deleteCustomerButton(100)]-20-[addItemButton]-15-|", options: .alignAllCenterY, metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[customerNameTextField]-20-[deleteCustomerButton]-20-[itemTableView]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[customerNameTextField]-20-[addItemButton]-20-[itemTableView]-15-|", metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[itemTableView]-15-|", metrics: nil, views: views))
        }
    
    @objc func deleteCustomer() {
        customerTableViewController?.deleteCell(cell: self)
    }
    
    @objc func addItem() {
        itemTableController.insert()
    }
}
