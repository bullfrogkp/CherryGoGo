//
//  CustomerItemTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-06.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class CustomerItemTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var customer: CustomerMO!
    var fetchResultController: NSFetchedResultsController<ItemMO>!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        loadRecentItems()
    }
    
    @objc func loadRecentItems() {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ItemMO> = ItemMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shipping.shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "formattedShippingDate", cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemTypeTableViewCell

        let itmMO = fetchResultController.sections![indexPath.section].objects![indexPath.row] as! ItemMO
        
        cell.typeNameLabel.text = itmMO.itemType!.itemTypeName!.name
        cell.typeBrandLabel.text = itmMO.itemType!.itemTypeBrand!.name
        cell.quantity.text = "\(itmMO.quantity)"
        
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let destinationController = segue.destination as! ShippingDetailViewController
//            let itmMO = fetchResultController.sections![indexPath.section].objects![indexPath.row] as! ItemMO
//            let shipping = Utils.shared.convertToShipping([itmMO.shipping!])[0]
//            
//            destinationController.shipping = shipping
//            
//            navigationItem.backBarButtonItem = UIBarButtonItem(
//            title: "返回", style: .plain, target: nil, action: nil)
//        }
//    }
}
