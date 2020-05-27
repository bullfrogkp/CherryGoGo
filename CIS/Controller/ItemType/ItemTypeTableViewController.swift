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
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
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
        let sortDescriptor = NSSortDescriptor(key: "itemTypeBrand.name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.includesPendingChanges = false
        
        let context = appDelegate.persistentContainer.viewContext
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "itemTypeBrand.name", cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemTypeId", for: indexPath) as! ItemTypeTableViewCell
        
        let itmTypeMO = fetchResultController.sections![indexPath.section].objects![indexPath.row] as! ItemTypeMO
        
        cell.name.text = "\(itmTypeMO.itemTypeName!.name!)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = fetchResultController.sections?[section].name ?? ""
        return "    " + title
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

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
