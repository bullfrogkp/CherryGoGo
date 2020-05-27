//
//  InStockItemTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-26.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class InStockItemTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchResultController: NSFetchedResultsController<CustomerMO>!
    var contactMO: CustomerMO!
    var items: [ItemMO] = []
    var customerItemEditViewController: CustomerItemEditViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        if(contactMO.items != nil) {
            items = contactMO.items!.allObjects as! [ItemMO]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactItemId", for: indexPath) as! InStockItemTableViewCell

        cell.nameLabel.text = items[indexPath.row].itemType!.itemTypeName!.name!
        cell.brandLabel.text = items[indexPath.row].itemType!.itemTypeName!.name!
        cell.quantityLabel.text = "\(items[indexPath.row].quantity)"

        return cell
    }
}
