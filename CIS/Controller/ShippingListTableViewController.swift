//
//  ShippingListTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-07-26.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class ShippingListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet var emptyShippingView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var fetchResultController: NSFetchedResultsController<ShippingMO>!
    var shippings: [Shipping] = []
    var shippingMOs: [ShippingMO] = []
    var searchController: UISearchController!
    var fetchOffset = 0
    var fetchLimit = 7
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyShippingView
        tableView.backgroundView?.isHidden = true
        
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.estimatedRowHeight = 1000
        
        let resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController") as? SearchResultTableViewController
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = resultsTableController
        searchController.searchBar.placeholder = "搜索"
        searchController.searchBar.setValue("取消", forKey:"cancelButtonText")
        self.navigationItem.searchController = searchController
        
//        deleteAllData(entity: "Item")
//        deleteAllData(entity: "Customer")
//        deleteAllData(entity: "Image")
//        deleteAllData(entity: "Shipping")
        
        // Configure the pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadRecentShippings), for: UIControl.Event.valueChanged)

        // Load recent posts
        loadRecentShippings()
        
        addSideBarMenu(leftMenuButton: menuButton)
    }
    
    @objc func loadRecentShippings() {
        
        isLoading = true
        fetchOffset = 0
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = fetchLimit
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    shippingMOs = fetchedObjects
                    shippings = convertToShipping(shippingMOs)
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if shippings.count > 0 {
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
        return shippings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shippingId", for: indexPath as IndexPath) as! ShippingListTableViewCell

        let shippingDetail = shippings[indexPath.row]
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        cell.shippingCityLabel.text = shippingDetail.city
        cell.shippingDateLabel.text = dateFormatterPrint.string(from: shippingDetail.shippingDate)
        
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shippings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isLoading, shippings.count - indexPath.row == 1 else {
            return
        }

        isLoading = true

        let oldShippings = getMore(currentFetchOffset: fetchOffset, currentFetchLimit: fetchLimit)
        // Add new posts to existing arrays and table view
        if(oldShippings.count > 0) {
            DispatchQueue.main.async {
                var indexPaths:[IndexPath] = []
                tableView.beginUpdates()
                for oldShipping in oldShippings {
                    self.shippings.append(oldShipping)
                    let iPath = IndexPath(row: self.shippings.count - 1, section: 0)
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
                destinationController.shipping = shippings[indexPath.row]
                destinationController.cellIndex = indexPath.row
                destinationController.shippingListTableViewController = self
            }
            
        } else if segue.identifier == "addShippingDetail" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let shippingView: ShippingInfoViewController = naviView.viewControllers[0] as! ShippingInfoViewController
            shippingView.shippingListTableViewController = self
        }
    }
    
    // MARK: - Helper Functions
    func getMore(currentFetchOffset: Int, currentFetchLimit: Int) -> [Shipping] {
        let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = currentFetchOffset
        fetchRequest.fetchLimit = currentFetchLimit
        
        var oldShippings: [Shipping] = []
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    oldShippings.append(contentsOf: convertToShipping(fetchedObjects))
                }
            } catch {
                print(error)
            }
        }
        
        return oldShippings
    }
    
    private func convertToShipping(_ shippingMOs: [ShippingMO]) -> [Shipping] {
        
        var shippingArray: [Shipping] = []
        
        var imageDict: [ImageMO: Image] = [:]
        var customerDict: [CustomerMO: Customer] = [:]
        
        for shippingMO in shippingMOs {
            let newShipping = Shipping(city: shippingMO.city!, shippingDate: shippingMO.shippingDate!)
            
            newShipping.createdDatetime = shippingMO.createdDatetime
            newShipping.createdUser = shippingMO.createdUser
            newShipping.updatedDatetime = shippingMO.updatedDatetime
            newShipping.updatedUser = shippingMO.updatedUser
            
            if(shippingMO.status != nil) {
                newShipping.status = shippingMO.status!
            }
            if(shippingMO.boxQuantity != nil) {
                newShipping.boxQuantity = shippingMO.boxQuantity!
            }
            if(shippingMO.comment != nil) {
                newShipping.comment = shippingMO.comment!
            }
            if(shippingMO.deposit != nil) {
                newShipping.deposit = shippingMO.deposit!
            }
            if(shippingMO.feeNational != nil) {
                newShipping.feeNational = shippingMO.feeNational!
            }
            if(shippingMO.feeInternational != nil) {
                newShipping.feeInternational = shippingMO.feeInternational!
            }
            
            newShipping.shippingMO = shippingMO
            
            if(shippingMO.images != nil) {
                for img in shippingMO.images! {
                    let imgMO = img as! ImageMO
                    let newImg = Image(imageFile: imgMO.imageFile!)
                    
                    newImg.createdDatetime = imgMO.createdDatetime
                    newImg.createdUser = imgMO.createdUser
                    newImg.updatedDatetime = imgMO.updatedDatetime
                    newImg.updatedUser = imgMO.updatedUser
                    newImg.changed = false
                    
                    if(imgMO.name != nil) {
                        newImg.name = imgMO.name!
                    }
                    newImg.imageMO = imgMO
                    
                    imageDict[imgMO] = newImg
                    
                    if(newShipping.images == nil) {
                        newShipping.images = []
                    }
                    newShipping.images!.append(newImg)
                }
            }
            
            if(shippingMO.customers != nil) {
                for cus in shippingMO.customers! {
                    let cusMO = cus as! CustomerMO
                    let newCus = Customer(name: cusMO.name!)
                    
                    newCus.createdDatetime = cusMO.createdDatetime
                    newCus.createdUser = cusMO.createdUser
                    newCus.updatedDatetime = cusMO.updatedDatetime
                    newCus.updatedUser = cusMO.updatedUser
                    newCus.changed = false
                    
                    if(cusMO.comment != nil) {
                        newCus.comment = cusMO.comment!
                    }
                    if(cusMO.wechat != nil) {
                        newCus.wechat = cusMO.wechat!
                    }
                    if(cusMO.phone != nil) {
                        newCus.phone = cusMO.phone!
                    }
                    newCus.customerMO = cusMO
                    
                    customerDict[cusMO] = newCus
                    
                    if(newShipping.customers == nil) {
                        newShipping.customers = []
                    }
                    newShipping.customers!.append(newCus)
                }
            }
            
            if(newShipping.images != nil) {
                for img in newShipping.images! {
                    if(img.imageMO!.customers != nil) {
                        for cus in img.imageMO!.customers! {
                            let cusMO = cus as! CustomerMO
                            
                            if(img.customers == nil) {
                                img.customers = []
                            }
                            img.customers!.append(customerDict[cusMO]!)
                        }
                    }
                }
            }
            
            if(newShipping.customers != nil) {
                for cus in newShipping.customers! {
                    if(cus.customerMO!.images != nil) {
                        for img in cus.customerMO!.images! {
                            let imgMO = img as! ImageMO
                            
                            if(cus.images == nil) {
                                cus.images = []
                            }
                            cus.images!.append(imageDict[imgMO]!)
                        }
                    }
                }
            }
            
            if(shippingMO.items != nil) {
                for itm in shippingMO.items! {
                    let itmMO = itm as! ItemMO
                    let newItm = Item(name: itmMO.name!, quantity: itmMO.quantity)
                    
                    newItm.createdDatetime = itmMO.createdDatetime
                    newItm.createdUser = itmMO.createdUser
                    newItm.updatedDatetime = itmMO.updatedDatetime
                    newItm.updatedUser = itmMO.updatedUser
                    newItm.changed = false
                    
                    if(itmMO.comment != nil) {
                        newItm.comment = itmMO.comment!
                    }
                    
                    if(itmMO.priceSold != nil) {
                        newItm.priceSold = itmMO.priceSold!
                    }
                    
                    if(itmMO.priceBought != nil) {
                        newItm.priceBought = itmMO.priceBought!
                    }
                    
                    newItm.customer = customerDict[itmMO.customer!]!
                    newItm.image = imageDict[itmMO.image!]!
                    newItm.itemMO = itmMO
                    
                    if(newShipping.items == nil) {
                        newShipping.items = []
                    }
                    newShipping.items!.append(newItm)
                }
            }
            
            shippingArray.append(newShipping)
        }
        
        return shippingArray
    }
    
    func deleteShipping(_ rowIndex: Int) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            context.delete(shippings[rowIndex].shippingMO!)

            appDelegate.saveContext()
        }
        
        shippings.remove(at: rowIndex)
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .top)
    }

    func addShipping(_ sp: Shipping) {
        
        sp.createdDatetime = Date()
        sp.createdUser = Utils.shared.getUser()
        sp.updatedDatetime = Date()
        sp.updatedUser = Utils.shared.getUser()
        
        shippings.insert(sp, at: 0)
               
        let insertionIndexPath = NSIndexPath(row: 0, section: 0)
        tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .top)
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            let shippingMO = ShippingMO(context: appDelegate.persistentContainer.viewContext)
            shippingMO.shippingDate = sp.shippingDate
            shippingMO.city = sp.city
            
            shippingMO.createdDatetime = Date()
            shippingMO.createdUser = Utils.shared.getUser()
            shippingMO.updatedDatetime = Date()
            shippingMO.updatedUser = Utils.shared.getUser()
            
            if(sp.status != nil) {
                shippingMO.status = sp.status!
            }
            if(sp.boxQuantity != nil) {
                shippingMO.boxQuantity = sp.boxQuantity!
            }
            if(sp.comment != nil) {
                shippingMO.comment = sp.comment!
            }
            if(sp.deposit != nil) {
                shippingMO.deposit = sp.deposit!
            }
            if(sp.feeNational != nil) {
                shippingMO.feeNational = sp.feeNational!
            }
            if(sp.feeInternational != nil) {
                shippingMO.feeInternational = sp.feeInternational!
            }
            
            appDelegate.saveContext()
            sp.shippingMO = shippingMO
        }
    }
    
    private func deleteAllData(entity: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false

        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
            appDelegate.saveContext()
        } catch let error as NSError {
            print("Delete all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
