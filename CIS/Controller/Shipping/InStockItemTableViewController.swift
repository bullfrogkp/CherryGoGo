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

    var fetchResultController: NSFetchedResultsController<ItemMO>!
    var contactMO: CustomerMO!
    var items: [ItemMO] = []
    var customerItemEditViewController: CustomerItemEditViewController?
    var imageItemEditViewController: ImageItemEditViewController?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<ItemMO> = ItemMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDatetime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.includesPendingChanges = false
        fetchRequest.predicate = NSPredicate(format: "customer = %@ and quantity > 0", contactMO)
        
        let context = appDelegate.persistentContainer.viewContext
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects {
                items = fetchedObjects
            }
        } catch {
            print(error)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(customerItemEditViewController != nil) {
            customerItemEditViewController!.addStockItem(items[indexPath.row])
        }
        
        if(imageItemEditViewController != nil) {
            imageItemEditViewController!.addStockItem(items[indexPath.row])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
