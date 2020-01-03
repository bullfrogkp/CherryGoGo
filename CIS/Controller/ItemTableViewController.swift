//
//  ItemTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-07-08.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController {

    var items:[Item]!
    var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ItemCell.self, forCellReuseIdentifier: "itemCellId")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath as IndexPath) as! ItemCell
        
        myCell.itemNameTextField.text = items[indexPath.row].name
        myCell.itemCommentTextField.text = items[indexPath.row].comment
        myCell.itemQuantityTextField.text = items[indexPath.row].quantity.description
        myCell.itemPriceSoldTextField.text = items[indexPath.row].priceSold.description
        myCell.itemPriceBoughtTextField.text = items[indexPath.row].priceBought.description
        myCell.itemTableViewController = self
        return myCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func insert() {
        items.append(Item())
        
        let insertionIndexPath = NSIndexPath(row: items.count - 1, section: 0)
        
        itemTableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
    }
    
    @objc func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = itemTableView.indexPath(for: cell) {
            items.remove(at: deletionIndexPath.row)
            itemTableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }

}
