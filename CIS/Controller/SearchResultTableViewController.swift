//
//  SearchResultTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-10.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

var shippings: [Shipping] = []

class SearchResultTableViewController: UITableViewController, UISearchResultsUpdating,  NSFetchedResultsControllerDelegate {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        var isSearchBarEmpty: Bool {
          return searchController.searchBar.text?.isEmpty ?? true
        }
        
        if !isSearchBarEmpty {
            let searchText = searchController.searchBar.text!
            
            let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if(searchController.searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex] == "客户") {
                fetchRequest.predicate = NSPredicate(format: "firstName == %@", firstName)
            }
            
            else if(searchController.searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex] == "产品") {
                fetchRequest.predicate = NSPredicate(format: "firstName == %@", firstName)
            }
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchResultController.delegate = self
                
                do {
                    try fetchResultController.performFetch()
                    if let fetchedObjects = fetchResultController.fetchedObjects {
                        shippingMOs = fetchedObjects
                        shippings = convertToShipping(shippingMOs)
                        
                        tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shippings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath as IndexPath) as! SearchResultTableViewCell
        let shipping = shippings[indexPath.row]
        cell.shippingDateLabel.text = "\(shipping.shippingDate)"
        cell.shippingCityLabel.text = shipping.city
        cell.customerName.text =
        cell.items.text =
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationController = segue.destination as! CustomerItemViewController
            destinationController.customer = filteredCustomers[indexPath.row]
            destinationController.cellIndex = indexPath.row
            destinationController.searchResultTableViewCOntroller = self
        }

    }

}
