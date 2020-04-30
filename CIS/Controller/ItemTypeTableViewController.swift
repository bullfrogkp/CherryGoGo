//
//  ProductTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-29.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class ItemTypeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var fetchResultController: NSFetchedResultsController<ItemTypeMO>!
    var itemTypes: [ItemTypeMO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        loadRecentItemTypes()
        addSideBarMenu(leftMenuButton: menuButton)
    }
    
    @objc func loadRecentItemTypes() {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ItemTypeMO> = ItemTypeMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "itemTypeName.name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    itemTypes = fetchedObjects
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
        return itemTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemTypeId", for: indexPath) as! ItemTypeTableViewCell
        
        cell.name.text = "\(itemTypes[indexPath.row].itemTypeName!.name!), \(itemTypes[indexPath.row].itemTypeBrand!.name!)"

        return cell
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
//                let context = appDelegate.persistentContainer.viewContext
//                context.delete(itemTypes[indexPath.row])
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }

    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addItemType" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let naviView: UINavigationController = segue.destination as!  UINavigationController
//                let shippingView: ItemTypeDetailViewController = naviView.viewControllers[0] as! ItemTypeDetail
//                shippingView.itemTypeTableViewController = self
//            }
//            
//        } else if segue.identifier == "editItemType" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let naviView: UINavigationController = segue.destination as!  UINavigationController
//                let shippingView: ItemTypeDetailViewController = naviView.viewControllers[0] as! ItemTypeDetail
//                shippingView.itemType = itemTypes[indexPath.row]
//                shippingView.itemTypeTableViewController = self
//            }
//        }
//    }
}
