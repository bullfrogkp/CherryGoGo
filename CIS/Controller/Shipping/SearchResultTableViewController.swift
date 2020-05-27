//
//  SearchResultTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-10.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class SearchResultTableViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    var fetchResultController: NSFetchedResultsController<ItemMO>!
    var items: [ItemMO] = []
    var fetchOffset = 0
    var fetchLimit = 7
    var isLoading = false
    var searchString = ""
    var searchCategory = ""
    var delegate:SelectedCellProtocol?
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    private func filterContentForSearchText(_ searchText: String,
                                    category: String) {
      
        let fetchRequest: NSFetchRequest<ItemMO> = ItemMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDatetime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.includesPendingChanges = false
        
        if(category == "客户") {
            fetchRequest.predicate = NSPredicate(format: "customer.name CONTAINS[cd] %@", searchText)
        }
        
        else if(category == "产品") {
            fetchRequest.predicate = NSPredicate(format: "itemType.itemTypeName.name CONTAINS[cd] %@ OR itemType.itemTypeBrand.name CONTAINS[cd] %@", searchText, searchText)
        }
        
        let context = appDelegate.persistentContainer.viewContext
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects {
                items = fetchedObjects
                tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
//    func searchBar(_ searchBar: UISearchBar,
//        selectedScopeButtonIndexDidChange selectedScope: Int) {
//
//        var isSearchBarEmpty: Bool {
//          return searchBar.text?.isEmpty ?? true
//        }
//
//        if !isSearchBarEmpty {
//            let category = searchBar.scopeButtonTitles![selectedScope]
//            filterContentForSearchText(searchBar.text!, category: category)
//        }
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        var isSearchBarEmpty: Bool {
          return searchController.searchBar.text?.isEmpty ?? true
        }
        
        if !isSearchBarEmpty {
            searchString = searchController.searchBar.text!
            searchCategory = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            
            filterContentForSearchText(searchString, category:searchCategory)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemId", for: indexPath as IndexPath) as! SearchResultTableViewCell
        let item = items[indexPath.row]
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        cell.customerNameLabel.text = item.customer?.name ?? ""
        cell.shippingDateLabel.text = dateFormatterPrint.string(from: item.shipping!.shippingDate!)
        cell.shippingCityLabel.text = item.shipping?.city ?? ""
        cell.itemNameLabel.text = "\(item.itemType!.itemTypeName!.name), \(item.itemType!.itemTypeBrand!.name)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isLoading, items.count > 6, items.count - indexPath.row == 1 else {
            return
        }

        isLoading = true

        let oldItems = getMore(currentFetchOffset: fetchOffset, currentFetchLimit: fetchLimit, sText: searchString, sCategory: searchCategory)
        
        if(oldItems.count > 0) {
            DispatchQueue.main.async {
                var indexPaths:[IndexPath] = []
                tableView.beginUpdates()
                for itm in oldItems {
                    self.items.append(itm)
                    let iPath = IndexPath(row: self.items.count - 1, section: 0)
                    indexPaths.append(iPath)
                }
                tableView.insertRows(at: indexPaths, with: .fade)
                tableView.endUpdates()
                
                self.fetchOffset += self.fetchLimit
            }
        }

        isLoading = false
    }
    /*
    override func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let customerLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21))
            label.text = "\(shippings[section].shippingDate)"
            
            return label
        }()
        
        headerView.addSubview(customerLabel)
        
        return headerView
    }
     */

    // MARK: - Navigation

    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let shippingMO = items[indexPath.section].shipping!
            self.delegate?.didSelectedCell(shippingMO: shippingMO)
        }
    }
    
    // MARK: - Helper Functions
    func getMore(currentFetchOffset: Int, currentFetchLimit: Int, sText: String, sCategory: String) -> [ItemMO] {
        let fetchRequest: NSFetchRequest<ItemMO> = ItemMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDatetime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = currentFetchOffset
        fetchRequest.fetchLimit = currentFetchLimit
        fetchRequest.includesPendingChanges = false
        
        if(sCategory == "客户") {
            fetchRequest.predicate = NSPredicate(format: "customer.name CONTAINS[c] %@", sText)
        }
        
        else if(sCategory == "产品") {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", sText)
        }
        
        var oldItems: [ItemMO] = []
        
        let context = appDelegate.persistentContainer.viewContext
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects {
                oldItems.append(contentsOf: fetchedObjects)
            }
        } catch {
            print(error)
        }
        
        return oldItems
    }

}
