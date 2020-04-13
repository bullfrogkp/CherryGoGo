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
        return shippings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shippings[section].customers!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath as IndexPath) as! SearchResultTableViewCell
        
        let customer = shippings[indexPath.section].customers![indexPath.row]
        
        cell.customerName.text = customer.name
        
        if(customer.items != nil) {
            var itms = ""
            for itm in customer.items! {
                itms += itm.name + "/r/n"
            }
            
            cell.items.text = itms
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let customerLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21))
            label.text = image.customers![section].name
            
            return label
        }()
        
        headerView.addSubview(customerLabel)
        
        return headerView
    }

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
