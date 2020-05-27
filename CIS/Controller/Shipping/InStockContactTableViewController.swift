//
//  InStockContactTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-26.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class InStockContactTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchResultController: NSFetchedResultsController<CustomerMO>!
    var contacts: [CustomerMO] = []
    var customerMO: CustomerMO!
    var customerItemEditViewController: CustomerItemEditViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        let fetchRequest: NSFetchRequest<CustomerMO> = CustomerMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.includesPendingChanges = false
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    contacts = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactId", for: indexPath) as! InStockContactTableViewCell
        cell.nameLabel.text = contacts[indexPath.row].name
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInStockItem" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! InStockItemTableViewController
                destinationController.contactMO = contacts[indexPath.row]
                destinationController.customerItemEditViewController = customerItemEditViewController
            }
            
        }
    }
}
