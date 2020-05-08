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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
