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
    
    var fetchResultController: NSFetchedResultsController<ShippingMO>!
    var shippings: [Shipping] = []
    var shippingMOs: [ShippingMO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyShippingView
        tableView.backgroundView?.isHidden = true
        
//        deleteAllData(entity: "Item")
//        deleteAllData(entity: "Customer")
//        deleteAllData(entity: "Image")
//        deleteAllData(entity: "Shipping")
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ShippingMO> = ShippingMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shippingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
        cell.shippingStatusLabel.text = shippingDetail.status
        cell.shippingDepositLabel.text = "\(shippingDetail.deposit)"
        
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
    func convertToShipping(_ shippingMOs: [ShippingMO]) -> [Shipping] {
        
        var shippingArray: [Shipping] = []
        
        var imageDict: [ImageMO: Image] = [:]
        var customerDict: [CustomerMO: Customer] = [:]
        
        for shippingMO in shippingMOs {
            let newShipping = Shipping()
            newShipping.city = shippingMO.city!
            newShipping.shippingDate = shippingMO.shippingDate!
            newShipping.shippingMO = shippingMO
            
            if(shippingMO.images != nil) {
                for img in shippingMO.images! {
                    let imgMO = img as! ImageMO
                    let newImg = Image()
                    newImg.imageFile = imgMO.imageFile!
                    newImg.name = imgMO.name!
                    newImg.imageMO = imgMO
                    
                    imageDict[imgMO] = newImg
                    newShipping.images.append(newImg)
                }
            }
            
            if(shippingMO.customers != nil) {
                for cus in shippingMO.customers! {
                    let cusMO = cus as! CustomerMO
                    let newCus = Customer()
                    newCus.comment = cusMO.comment!
                    newCus.name = cusMO.name!
                    newCus.customerMO = cusMO
                    
                    customerDict[cusMO] = newCus
                    newShipping.customers.append(newCus)
                }
            }
            
            for img in newShipping.images {
                if(img.imageMO!.customers != nil) {
                    for cus in img.imageMO!.customers! {
                        let cusMO = cus as! CustomerMO
                        img.customers.append(customerDict[cusMO]!)
                    }
                }
            }
            
            for cus in newShipping.customers {
                if(cus.customerMO!.images != nil) {
                    for img in cus.customerMO!.images! {
                        let imgMO = img as! ImageMO
                        cus.images.append(imageDict[imgMO]!)
                    }
                }
            }
            
            if(shippingMO.items != nil) {
                for itm in shippingMO.items! {
                    let itmMO = itm as! ItemMO
                    let newItm = Item()
                    newItm.name = itmMO.name!
                    newItm.quantity = itmMO.quantity
                    newItm.customer = customerDict[itmMO.customer!]!
                    newItm.image = imageDict[itmMO.image!]!
                    
                    newShipping.items.append(newItm)
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
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
    }

    func addShipping(_ sp: Shipping) {
        shippings.insert(sp, at: 0)
               
        let insertionIndexPath = NSIndexPath(row: 0, section: 0)
        tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .top)
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            let shippingMO = ShippingMO(context: appDelegate.persistentContainer.viewContext)
            shippingMO.shippingDate = sp.shippingDate
            shippingMO.city = sp.city
            shippingMO.status = sp.status
            shippingMO.comment = sp.comment
            shippingMO.deposit = sp.deposit
            shippingMO.feeNational = sp.feeNational
            shippingMO.feeInternational = sp.feeInternational
            
            appDelegate.saveContext()
            sp.shippingMO = shippingMO
        }
    }
    
    func deleteAllData(entity: String) {
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
