//
//  CustomerTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-30.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class CustomerTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var fetchResultController: NSFetchedResultsController<CustomerMO>!
    var customers: [CustomerMO] = []
    
    var customerDict = [String: [String]]()
    var customerSectionTitles = [String]()
    let customerIndexTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        loadRecentCustomers()
        createCustomerDict()
        addSideBarMenu(leftMenuButton: menuButton)
    }
    
    @objc func loadRecentCustomers() {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<CustomerMO> = CustomerMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    customers = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    func createCustomerDict() {
        for cus in customers {
            // Get the first letter of the animal name and build the dictionary
            let customerKey = cus.pinyin!
            
            if var customerValues = customerDict[customerKey] {
                customerValues.append(cus.name!)
                customerDict[customerKey] = customerValues
            } else {
                customerDict[customerKey] = [cus.name!]
            }
        }
        
        // Get the section titles from the dictionary's keys and sort them in ascending order
        customerSectionTitles = [String](customerDict.keys)
        customerSectionTitles = customerSectionTitles.sorted(by: { $0 < $1 })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return customerSectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let customerKey = customerSectionTitles[section]
        guard let customerValues = customerDict[customerKey] else {
            return 0
        }
        
        return customerValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath) as! CustomerTableViewCell
        
        // Configure the cell...
        let customerKey = customerSectionTitles[indexPath.section]
        if let customerValues = customerDict[customerKey] {
            cell.name.text = customerValues[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let headerView = view as! UITableViewHeaderFooterView
//        headerView.backgroundView?.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
//        headerView.textLabel?.textColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
//
//        headerView.textLabel?.font = UIFont(name: "Avenir", size: 20.0)
//    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return customerIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

        guard let index = customerSectionTitles.firstIndex(of: title) else {
            return -1
        }

        return index
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "    " + customerSectionTitles[section].uppercased()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "返回", style: .plain, target: nil, action: nil)
        
        let barViewControllers = segue.destination as! UITabBarController
        let infoNavController = barViewControllers.viewControllers![0] as! UINavigationController
        let itemNavController = barViewControllers.viewControllers![1] as! UINavigationController
        let addrNavController = barViewControllers.viewControllers![2] as! UINavigationController
        
        let infoViewController = infoNavController.topViewController as! CustomerInfoViewController
        let itemTableViewController = itemNavController.topViewController as! CustomerItemTableViewController
        let addrTableViewController = addrNavController.topViewController as! CustomerAddressTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let cus = customers[indexPath.row]
            infoViewController.customer = cus
            itemTableViewController.customer = cus
            addrTableViewController.customer = cus
        }
    }
}
