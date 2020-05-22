//
//  ShippingListTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-07-26.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class ShippingListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, SelectedCellProtocol {
    
    @IBOutlet var emptyShippingView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var fetchResultController: NSFetchedResultsController<ShippingMO>!
    var shippingMOs: [ShippingMO] = []
    var searchController: UISearchController!
    var fetchOffset = 0
    var fetchLimit = 7
    var isLoading = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyShippingView
        tableView.backgroundView?.isHidden = true
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        let resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as! SearchResultTableViewController
        resultsTableController.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchBar.delegate = resultsTableController
        searchController.searchResultsUpdater = resultsTableController
        searchController.searchBar.placeholder = "搜索"
        searchController.searchBar.setValue("取消", forKey:"cancelButtonText")
        searchController.searchBar.scopeButtonTitles = ["客户","产品"]
        
        
        definesPresentationContext = true
        
        self.navigationItem.searchController = searchController
        
        // Configure the pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadRecentShippings), for: UIControl.Event.valueChanged)

        // Load recent posts
        loadRecentShippings()
        
        addSideBarMenu(leftMenuButton: menuButton)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if shippingMOs.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shippingMOs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shippingId", for: indexPath as IndexPath) as! ShippingListTableViewCell

        let shippingDetail = shippingMOs[indexPath.row]
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        cell.shippingCityLabel.text = shippingDetail.city
        cell.shippingDateLabel.text = dateFormatterPrint.string(from: shippingDetail.shippingDate!)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if(shippingDetail.status != nil) {
            cell.shippingStatusLabel.text = shippingDetail.status!
        } else {
            cell.shippingStatusLabel.text = ""
        }
        
        if(shippingDetail.deposit != nil) {
            cell.shippingDepositLabel.text = "\(formatter.string(from: shippingDetail.deposit!)!)"
        } else {
            cell.shippingDepositLabel.text = ""
        }
        
        if(shippingDetail.feeInternational != nil) {
            cell.shippingFeeLbel.text = "\(formatter.string(from: shippingDetail.feeInternational!)!)"
        } else {
            cell.shippingFeeLbel.text = ""
        }
        
        if(shippingDetail.boxQuantity != nil) {
            cell.shippingBoxLabel.text = shippingDetail.boxQuantity!
        } else {
            cell.shippingBoxLabel.text = ""
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            let shippingMO = shippingMOs[indexPath.row]
//            context.delete(shippingMO)
//            if(shippingMO.items != nil) {
//                for itmMO in shippingMO.items! {
//                    context.delete(itmMO as! ItemMO)
//                }
//            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isLoading, shippingMOs.count > 6, shippingMOs.count - indexPath.row == 1 else {
            return
        }

        isLoading = true

        let oldShippings = getMore(currentFetchOffset: fetchOffset, currentFetchLimit: fetchLimit)
        
        if(oldShippings.count > 0) {
            DispatchQueue.main.async {
                var indexPaths:[IndexPath] = []
                tableView.beginUpdates()
                for oldShipping in oldShippings {
                    self.shippingMOs.append(oldShipping)
                    let iPath = IndexPath(row: self.shippingMOs.count - 1, section: 0)
                    indexPaths.append(iPath)
                }
                tableView.insertRows(at: indexPaths, with: .fade)
                tableView.endUpdates()
                
                self.fetchOffset += self.fetchLimit
            }
        }

        isLoading = false
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShippingDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ShippingDetailViewController
                destinationController.shippingMO = shippingMOs[indexPath.row]
                destinationController.indexPath = indexPath
                destinationController.shippingListTableViewController = self
            }
            
        } else if segue.identifier == "addShippingDetail" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let shippingView: ShippingInfoViewController = naviView.viewControllers[0] as! ShippingInfoViewController
            shippingView.shippingListTableViewController = self
        }
    }
    
    // MARK: - Helper Functions
    @objc func loadRecentShippings() {
        isLoading = true
        fetchOffset = 0
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.includesPendingChanges = false
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    shippingMOs = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
        
        isLoading = false
        tableView.reloadData()
        
        if let _ = self.refreshControl?.isRefreshing {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    func didSelectedCell(shippingMO: ShippingMO) {
        let shippingDetailViewController =
        self.storyboard?.instantiateViewController(withIdentifier: "ShippingDetailViewController") as! ShippingDetailViewController
        shippingDetailViewController.shippingMO = shippingMO
        self.navigationController!.pushViewController(shippingDetailViewController, animated: true)
    }
    
    func getMore(currentFetchOffset: Int, currentFetchLimit: Int) -> [ShippingMO] {
        let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = currentFetchOffset
        fetchRequest.fetchLimit = currentFetchLimit
        fetchRequest.includesPendingChanges = false
        
        var oldShippings: [ShippingMO] = []
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    oldShippings.append(contentsOf: fetchedObjects)
                }
            } catch {
                print(error)
            }
        }
        
        return oldShippings
    }
    
    func deleteShipping(_ indexPath: IndexPath) {
        shippingMOs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
    }

    func addShipping(_ shippingMO: ShippingMO) {
        shippingMOs.insert(shippingMO, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func updateShipping(_ indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .top)
    }
}
