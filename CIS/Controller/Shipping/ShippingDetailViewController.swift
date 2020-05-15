//
//  ShippingDetailViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-09-10.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import CoreData

class ShippingDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var shippingDateLabel: UILabel!
    @IBOutlet weak var shippingBoxQuantityLabel: UILabel!
    @IBOutlet weak var shippingCityLabel: UILabel!
    @IBOutlet weak var shippingPriceNationalLabel: UILabel!
    @IBOutlet weak var shippingPriceInternationalLabel: UILabel!
    @IBOutlet weak var shippingDepositLabel: UILabel!
    @IBOutlet weak var shippingCommentLabel: UILabel!
    @IBOutlet weak var customerItemTableView: SelfSizedTableView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    var shippingMO: ShippingMO!
    var indexPath: IndexPath!
    var shippingListTableViewController: ShippingListTableViewController!
    var customerMOs: [CustomerMO] = []
    var imageMOs: [ImageMO] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func addImages(_ sender: Any) {
        let vc = BSImagePickerViewController()

        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                
            }, deselect: { (asset: PHAsset) -> Void in
                
            }, cancel: { (assets: [PHAsset]) -> Void in
                
            }, finish: { (assets: [PHAsset]) -> Void in
                let context = self.appDelegate.persistentContainer.viewContext
                
                for ast in assets {
                    let imageMO = ImageMO(context: context)
                    imageMO.imageFile = Utils.shared.getAssetThumbnail(ast).pngData()!
                    imageMO.shipping = self.shippingMO
                }
                self.imageCollectionView.reloadData()
            }, completion: nil)
    }
    
    @IBAction func deleteShipping(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "操真的删除吗?", preferredStyle: .actionSheet)
        
        // Add actions to the menu
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let checkInAction = UIAlertAction(title: "删除　", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            let context = self.appDelegate.persistentContainer.viewContext
            context.delete(self.shippingMO)
            
            if(self.shippingMO.items != nil) {
                for itmMO in self.shippingMO.items! {
                    context.delete(itmMO as! ItemMO)
                }
            }
            
            if(self.shippingMO.images != nil) {
                for imgMO in self.shippingMO.images! {
                    context.delete(imgMO as! ImageMO)
                }
            }
            
            self.appDelegate.saveContext()
            self.shippingListTableViewController.deleteShipping(self.indexPath)
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(checkInAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.dataSource = self
        customerItemTableView.delegate = self
        customerItemTableView.layer.masksToBounds = true
        customerItemTableView.layer.borderColor = UIColor( red: 224/255, green: 224/255, blue:224/255, alpha: 1.0 ).cgColor
        customerItemTableView.layer.borderWidth = 1.0
        scrollView.contentInsetAdjustmentBehavior = .never
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        shippingDateLabel.text = dateFormatterPrint.string(from: shippingMO.shippingDate!)
        shippingCityLabel.text = shippingMO!.city
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if(shippingMO!.boxQuantity != nil) {
            shippingBoxQuantityLabel.text = shippingMO!.boxQuantity!
        } else {
            shippingBoxQuantityLabel.text = ""
        }
        if(shippingMO!.feeNational != nil) {
            shippingPriceNationalLabel.text = "\(formatter.string(from: shippingMO!.feeNational!)!)"
        } else {
            shippingPriceNationalLabel.text = ""
        }
        if(shippingMO!.feeInternational != nil) {
            shippingPriceInternationalLabel.text = "\(formatter.string(from: shippingMO!.feeInternational!)!)"
        } else {
            shippingPriceInternationalLabel.text = ""
        }
        if(shippingMO!.deposit != nil) {
            shippingDepositLabel.text = "\(formatter.string(from: shippingMO!.deposit!)!)"
        } else {
            shippingDepositLabel.text = ""
        }
        if(shippingMO!.comment != nil) {
            shippingCommentLabel.text = "\(shippingMO!.comment!)"
        } else {
            shippingCommentLabel.text = ""
        }
        
        if(shippingMO.customers != nil) {
            customerMOs = shippingMO.customers!.allObjects as! [CustomerMO]
        }
        if(shippingMO.images != nil) {
            imageMOs = shippingMO.images!.allObjects as! [ImageMO]
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomer" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let customerView: CustomerItemEditViewController = naviView.viewControllers[0] as! CustomerItemEditViewController
            customerView.shippingMO = shippingMO
            customerView.shippingDetailViewController = self
        } else if segue.identifier == "addImage" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let imageView: ImageItemEditViewController = naviView.viewControllers[0] as! ImageItemEditViewController
            imageView.shippingMO = shippingMO
            imageView.shippingDetailViewController = self
        } else if segue.identifier == "editShippingDetail" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let shippingView: ShippingInfoViewController = naviView.viewControllers[0] as! ShippingInfoViewController
            shippingView.shippingMO = shippingMO
            shippingView.shippingDetailViewController = self
        } else if segue.identifier == "showCustomerDetail" {
            if let indexPath = customerItemTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! CustomerItemViewController
                let customerMO = customerMOs[indexPath.row]
                destinationController.shippingMO = shippingMO
                destinationController.customerMO = customerMO
                destinationController.indexPath = indexPath
                destinationController.shippingDetailViewController = self
                navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "返回", style: .plain, target: nil, action: nil)
            }
        } else if segue.identifier == "showImageDetail" {
            if let indexPaths = imageCollectionView.indexPathsForSelectedItems {
                let destinationController = segue.destination as! ImageItemViewController
                let imageMO = imageMOs[indexPaths[0].row]
                destinationController.shippingMO = shippingMO
                destinationController.imageMO = imageMO
                destinationController.indexPath = indexPaths[0]
                destinationController.shippingDetailViewController = self
                imageCollectionView.deselectItem(at: indexPaths[0], animated: false)
                navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "返回", style: .plain, target: nil, action: nil)
            }
        }
    }
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shippingMO.customers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath as IndexPath) as! CustomerListTableViewCell 
        
        cell.customerNameLabel.text = customerMOs[indexPath.row].name
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - CollectionView Functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shippingMO.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageId", for: indexPath) as! ImageCollectionViewCell
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        cell.shippingImageView.image = UIImage(data: imageMOs[indexPath.row].imageFile! as Data)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 4
        let spacingBetweenCells:CGFloat = 6
        
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = imageCollectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imageCollectionView.reloadData()
    }
    
    //MARK: - Helper Functions
    func bulletPointList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        let stringAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        let string = strings.map({ "•\t\($0)" }).joined(separator: "\n")
        
        return NSAttributedString(string: string,
                                  attributes: stringAttributes)
    }
    
    func deleteCustomerByIndexPath(_ indexPath: IndexPath) {
        customerItemTableView.deleteRows(at: [indexPath], with: .top)
    }
    
    func deleteImageByIndexPath(_ indexPath: IndexPath) {
        imageCollectionView.deleteItems(at: [indexPath])
    }
    
    func updateShipping() {
        shippingListTableViewController.updateShipping(indexPath)
    }
    
    func addCustomer(_ customerMO: CustomerMO) {
        customerMOs.insert(customerMO, at: 0)
        customerItemTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func updateImage() {
        imageCollectionView.reloadData()
    }
    
//    func getItemType(name: String, brand: String) -> ItemType {
//        let itemTypeName = ItemTypeName(name: name)
//        let itemTypeBrand = ItemTypeBrand(name: brand)
//        let itemType = ItemType(itemTypeName: itemTypeName, itemTypeBrand: itemTypeBrand)
//        
//        var itemTypeNameArray : [ItemTypeNameMO] = [ItemTypeNameMO]()
//        var itemTypeBrandArray : [ItemTypeBrandMO] = [ItemTypeBrandMO]()
//        var itemTypeArray : [ItemTypeMO] = [ItemTypeMO]()
//        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        
//        //Item Type Name
//        let predicateItemTypeName = NSPredicate(format: "name = %@", name)
//        let requestItemTypeName : NSFetchRequest<ItemTypeNameMO> = ItemTypeNameMO.fetchRequest()
//        requestItemTypeName.predicate = predicateItemTypeName
//        
//        do {
//            itemTypeNameArray = try context.fetch(requestItemTypeName)
//        } catch {
//            print("Error while fetching data: \(error)")
//        }
//        
//        if(itemTypeNameArray.count == 1) {
//            itemTypeName.itemTypeNameMO = itemTypeNameArray[0]
//        } else {
//            let newItemTypeNameMO = ItemTypeNameMO(context: context)
//            newItemTypeNameMO.name = name
//            itemTypeName.itemTypeNameMO = newItemTypeNameMO
//        }
//        
//        //Item Type Brand
//        let predicateItemTypeBrand = NSPredicate(format: "name = %@", brand)
//        let requestItemTypeBrand : NSFetchRequest<ItemTypeBrandMO> = ItemTypeBrandMO.fetchRequest()
//        requestItemTypeBrand.predicate = predicateItemTypeBrand
//        
//        do {
//            itemTypeBrandArray = try context.fetch(requestItemTypeBrand)
//        } catch {
//            print("Error while fetching data: \(error)")
//        }
//        
//        if(itemTypeBrandArray.count == 1) {
//            itemTypeBrand.itemTypeBrandMO = itemTypeBrandArray[0]
//        } else {
//            let newItemTypeBrandMO = ItemTypeBrandMO(context: context)
//            newItemTypeBrandMO.name = brand
//            itemTypeBrand.itemTypeBrandMO = newItemTypeBrandMO
//        }
//        
//        //Item Type
//        let predicate = NSPredicate(format: "itemTypeName.name = %@ AND itemTypeBrand.name = %@", name, brand)
//        let request : NSFetchRequest<ItemTypeMO> = ItemTypeMO.fetchRequest()
//        request.predicate = predicate
//        
//        do {
//            itemTypeArray = try context.fetch(request)
//        } catch {
//            print("Error while fetching data: \(error)")
//        }
//        
//        if(itemTypeArray.count == 1) {
//            itemType.itemTypeMO = itemTypeArray[0]
//        } else {
//            let newItemTypeMO = ItemTypeMO(context: context)
//            newItemTypeMO.itemTypeName = itemTypeName.itemTypeNameMO
//            newItemTypeMO.itemTypeBrand = itemTypeBrand.itemTypeBrandMO
//            itemType.itemTypeMO = newItemTypeMO
//        }
//        
//        do {
//            try context.save()
//        } catch {
//            print("Error while saving items: \(error)")
//        }
//        
//        return itemType
//    }
//    
//    func getCustomerMO(name: String) -> CustomerMO {
//        var dataList : [CustomerMO] = [CustomerMO]()
//        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let predicate = NSPredicate(format: "name = %@", name)
//        let request : NSFetchRequest<CustomerMO> = CustomerMO.fetchRequest()
//        request.predicate = predicate
//        
//        do {
//            dataList = try context.fetch(request)
//        } catch {
//            print("Error while fetching data: \(error)")
//        }
//        
//        if(dataList.count == 1) {
//            return dataList[0]
//        } else {
//            let newCustomerMO = CustomerMO(context: context)
//            newCustomerMO.name = name
//            
//            do {
//                try context.save()
//            } catch {
//                print("Error while saving items: \(error)")
//            }
//            
//            return newCustomerMO
//        }
//    }
}
