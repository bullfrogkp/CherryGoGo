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
    
    var shipping: Shipping!
    var cellIndex: Int!
    var shippingListTableViewController: ShippingListTableViewController!
    
    @IBAction func addImages(_ sender: Any) {
        let vc = BSImagePickerViewController()

        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                
            }, deselect: { (asset: PHAsset) -> Void in
                
            }, cancel: { (assets: [PHAsset]) -> Void in
                
            }, finish: { (assets: [PHAsset]) -> Void in
                for ast in assets {
                    self.addImage(Image(imageFile: Utils.shared.getAssetThumbnail(ast).pngData()!))
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
            
            self.shippingListTableViewController.deleteShipping(self.cellIndex)
            
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
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        scrollView.contentInsetAdjustmentBehavior = .never
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        shippingDateLabel.text = ""
        shippingBoxQuantityLabel.text = ""
        shippingCityLabel.text = ""
        shippingPriceNationalLabel.text = ""
        shippingPriceInternationalLabel.text = ""
        shippingDepositLabel.text = ""
        shippingCommentLabel.text = ""
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        shippingDateLabel.text = dateFormatterPrint.string(from: shipping!.shippingDate)
        shippingCityLabel.text = shipping!.city
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if(shipping!.boxQuantity != nil) {
            shippingBoxQuantityLabel.text = shipping!.boxQuantity!
        }
        if(shipping!.feeNational != nil) {
            shippingPriceNationalLabel.text = "\(formatter.string(from: shipping!.feeNational!)!)"
        }
        if(shipping!.feeInternational != nil) {
            shippingPriceInternationalLabel.text = "\(formatter.string(from: shipping!.feeInternational!)!)"
        }
        if(shipping!.deposit != nil) {
            shippingDepositLabel.text = "\(formatter.string(from: shipping!.deposit!)!)"
        }
        if(shipping!.comment != nil) {
            shippingCommentLabel.text = "\(shipping!.comment!)"
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomer" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let customerView: CustomerItemEditViewController = naviView.viewControllers[0] as! CustomerItemEditViewController
            
            customerView.shippingDetailViewController = self
        } else if segue.identifier == "addImage" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let imageView: ImageItemEditViewController = naviView.viewControllers[0] as! ImageItemEditViewController
            
            imageView.shippingDetailViewController = self
        } else if segue.identifier == "editShippingDetail" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let shippingView: ShippingInfoViewController = naviView.viewControllers[0] as! ShippingInfoViewController
            shippingView.shipping = shipping
            shippingView.shippingDetailViewController = self
        } else if segue.identifier == "showCustomerDetail" {
            if let indexPath = customerItemTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! CustomerItemViewController
                
                let customer = shipping.customers![indexPath.row]
                
                var items = [Item]()
                
                if(shipping.items != nil) {
                    for itm in shipping.items! {
                        if(itm.customer === customer) {
                            items.append(itm)
                        }
                    }
                }
                
                destinationController.customer = customer
                destinationController.items = items
                destinationController.customerIndex = indexPath.row
                destinationController.shippingDetailViewController = self
                
                navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "返回", style: .plain, target: nil, action: nil)
            }
        } else if segue.identifier == "showImageDetail" {
            if let indexPaths = imageCollectionView.indexPathsForSelectedItems {
                let destinationController = segue.destination as! ImageItemViewController
                
                let image = shipping.images![indexPaths[0].row]
                
                var items = [Item]()
                
                if(shipping.items != nil) {
                    for itm in shipping.items! {
                        if(itm.image === image) {
                            items.append(itm)
                        }
                    }
                }
                
                destinationController.image = image
                destinationController.items = items
                destinationController.imageIndex = indexPaths[0].row
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
        return shipping.customers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath as IndexPath) as! CustomerListTableViewCell 
        
        cell.customerNameLabel.text = shipping.customers![indexPath.row].name
        
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
        return shipping.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageId", for: indexPath) as! ImageCollectionViewCell
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        cell.shippingImageView.image = UIImage(data: shipping.images![indexPath.row].imageFile as Data)

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
    
    func addCustomer(_ customer: Customer) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            var customerMO: CustomerMO!
            
            customerMO = getCustomerMO(name: customer.name)
            customerMO.comment = customer.comment
            customerMO.phone = customer.phone
            customerMO.wechat = customer.wechat
            customerMO.shipping = shipping.shippingMO
            
            customerMO.createdDatetime = Date()
            customerMO.createdUser = Utils.shared.getUser()
            customerMO.updatedDatetime = Date()
            customerMO.updatedUser = Utils.shared.getUser()
            
            customer.createdDatetime = Date()
            customer.createdUser = Utils.shared.getUser()
            customer.updatedDatetime = Date()
            customer.updatedUser = Utils.shared.getUser()
            customer.changed = false
            
            customer.customerMO = customerMO
            
            if(customer.images != nil) {
                for img in customer.images! {
                    
                    let imageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
                    imageMO.name = img.name
                    imageMO.imageFile = img.imageFile
                    imageMO.addToCustomers(customerMO)
                    imageMO.shipping = shipping.shippingMO
                    
                    imageMO.createdDatetime = Date()
                    imageMO.createdUser = Utils.shared.getUser()
                    imageMO.updatedDatetime = Date()
                    imageMO.updatedUser = Utils.shared.getUser()
                    
                    img.createdDatetime = Date()
                    img.createdUser = Utils.shared.getUser()
                    img.updatedDatetime = Date()
                    img.updatedUser = Utils.shared.getUser()
                    img.changed = false
                    
                    img.imageMO = imageMO
                    customerMO.addToImages(imageMO)
                    
                    shipping.shippingMO!.addToImages(imageMO)
                    if(shipping.images == nil) {
                        shipping.images = []
                    }
                    shipping.images!.insert(img, at: 0)
                    
                    if(img.items != nil) {
                        for itm in img.items! {
                            let itemMO = ItemMO(context: appDelegate.persistentContainer.viewContext)
                            
                            itm.itemType = getItemType(name: itm.itemType!.itemTypeName.name, brand: itm.itemType!.itemTypeBrand.name)
                            itemMO.itemType = itm.itemType!.itemTypeMO
                            
                            itemMO.comment = itm.comment
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customerMO
                            itemMO.image = imageMO
                            itemMO.quantity = itm.quantity!
                            itemMO.shipping = shipping.shippingMO
                            
                            itemMO.createdDatetime = Date()
                            itemMO.createdUser = Utils.shared.getUser()
                            itemMO.updatedDatetime = Date()
                            itemMO.updatedUser = Utils.shared.getUser()
                            
                            itm.createdDatetime = Date()
                            itm.createdUser = Utils.shared.getUser()
                            itm.updatedDatetime = Date()
                            itm.updatedUser = Utils.shared.getUser()
                            itm.changed = false
                            
                            itm.itemMO = itemMO
                            
                            itm.itemType!.itemTypeMO!.addToItems(itemMO)
                            shipping.shippingMO!.addToItems(itemMO)
                            
                            if(shipping.items == nil) {
                                shipping.items = []
                            }
                            shipping.items!.insert(itm, at: 0)
                        }
                    }
                }
            }
            
            if(shipping.customers == nil) {
                shipping.customers = []
            }
            shipping.customers!.insert(customer, at: 0)
            shipping.shippingMO!.addToCustomers(customerMO)
            
            customerItemTableView.reloadData()
            imageCollectionView.reloadData()
            appDelegate.saveContext()
        }
    }
    
    func updateCustomer(_ customer: Customer, _ customerIndex: Int) {
        let oCus = shipping.customers![customerIndex]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            var newCustomerMO: CustomerMO!
            
            newCustomerMO = getCustomerMO(name: customer.name)
            newCustomerMO.phone = customer.phone
            newCustomerMO.comment = customer.comment
            newCustomerMO.wechat = customer.wechat
            newCustomerMO.shipping = shipping.shippingMO
            
            newCustomerMO.createdDatetime = oCus.createdDatetime
            newCustomerMO.createdUser = oCus.createdUser
            newCustomerMO.updatedDatetime = Date()
            newCustomerMO.updatedUser = Utils.shared.getUser()
            
            customer.createdDatetime = oCus.createdDatetime
            customer.createdUser = oCus.createdUser
            customer.updatedDatetime = Date()
            customer.updatedUser = Utils.shared.getUser()
            customer.changed = false
            
            customer.customerMO = newCustomerMO
            
            if(oCus.images != nil) {
                for img in oCus.images! {
                    let removedItems = shipping.items?.filter{$0.image === img && $0.customer === oCus}
                    
                    if(removedItems != nil) {
                        for itm in removedItems! {
                            context.delete(itm.itemMO!)
                        }
                    }
                    
                    shipping.items?.removeAll(where: {$0.image === img && $0.customer === oCus})
                    
                    if(shipping.images != nil) {
                        for (idx, img2) in shipping.images!.enumerated() {
                            if(img === img2) {
                                context.delete(shipping.images![idx].imageMO!)
                                shipping.images!.remove(at: idx)
                                break
                            }
                        }
                    }
                    
                    let newImageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
                    newImageMO.name = img.newImage!.name
                    newImageMO.imageFile = img.newImage!.imageFile
                    newImageMO.shipping = shipping.shippingMO
                    
                    newImageMO.createdDatetime = img.createdDatetime
                    newImageMO.createdUser = img.createdUser
                    newImageMO.updatedDatetime = img.updatedDatetime
                    newImageMO.updatedUser = img.updatedUser
                    
                    img.newImage!.imageMO = newImageMO
                    
                    if(img.customers != nil) {
                        for cus in img.customers! {
                            if(cus !== oCus) {
                                newImageMO.addToCustomers(cus.customerMO!)
                                
                                if(img.newImage!.customers == nil) {
                                    img.newImage!.customers = []
                                }
                                img.newImage!.customers!.append(cus)
                                
                                if(cus.images != nil) {
                                    for (idx, img2) in cus.images!.enumerated() {
                                        if(img2 === img) {
                                            cus.customerMO!.removeFromImages(cus.images![idx].imageMO!)
                                            cus.customerMO!.addToImages(newImageMO)
                                            cus.images![idx] = img.newImage!
                                            break
                                        }
                                    }
                                }
                                
                                if(shipping.items != nil) {
                                    for itm in shipping.items! {
                                        if(itm.image === img && itm.customer === cus) {
                                            itm.itemMO!.image = newImageMO
                                            itm.image = img.newImage!
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(customer.images != nil) {
                for img in customer.images! {
                    
                    if(img.imageMO == nil) {
                        let newImageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
                        newImageMO.name = img.name
                        newImageMO.imageFile = img.imageFile
                        newImageMO.shipping = shipping.shippingMO
                        newImageMO.addToCustomers(customer.customerMO!)
                        
                        newImageMO.createdDatetime = img.createdDatetime
                        newImageMO.createdUser = img.createdUser
                        
                        if(img.changed == true) {
                            newImageMO.updatedDatetime = Date()
                            newImageMO.updatedUser = Utils.shared.getUser()
                            
                            if(img.createdDatetime == nil) {
                                img.createdDatetime = Date()
                            }
                            
                            if(img.createdUser == nil) {
                                img.createdUser = Utils.shared.getUser()
                            }
                            
                            img.updatedDatetime = Date()
                            img.updatedUser = Utils.shared.getUser()
                        } else {
                            newImageMO.updatedDatetime = img.updatedDatetime
                            newImageMO.updatedUser = img.updatedUser
                        }
                        
                        img.changed = false
                        img.imageMO = newImageMO
                    }
                    
                    newCustomerMO.addToImages(img.imageMO!)
                    
                    if(shipping.images == nil) {
                        shipping.images = []
                    }
                    shipping.images!.insert(img, at: 0)
                    
                    if(img.items != nil) {
                        for itm in img.items! {
                            let itemMO = ItemMO(context: appDelegate.persistentContainer.viewContext)
                            
                            itm.itemType = getItemType(name: itm.itemType!.itemTypeName.name, brand: itm.itemType!.itemTypeBrand.name)
                            itemMO.itemType = itm.itemType!.itemTypeMO
                            
                            itemMO.comment = itm.comment
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customer.customerMO
                            itemMO.image = img.imageMO
                            itemMO.quantity = itm.quantity!
                            itemMO.shipping = shipping.shippingMO
                            
                            itemMO.createdDatetime = itm.createdDatetime
                            itemMO.createdUser = itm.createdUser
                            
                            if(itm.changed == true) {
                                itemMO.updatedDatetime = Date()
                                itemMO.updatedUser = Utils.shared.getUser()
                                
                                if(itm.createdDatetime == nil) {
                                    itm.createdDatetime = Date()
                                }
                                
                                if(itm.createdUser == nil) {
                                    itm.createdUser = Utils.shared.getUser()
                                }
                                
                                itm.updatedDatetime = Date()
                                itm.updatedUser = Utils.shared.getUser()
                            } else {
                                itemMO.updatedDatetime = itm.updatedDatetime
                                itemMO.updatedUser = itm.updatedUser
                            }
                            
                            itm.changed = false
                            itm.itemMO = itemMO
                            
                            shipping.shippingMO!.addToItems(itemMO)
                            
                            if(shipping.items == nil) {
                                shipping.items = []
                            }
                            shipping.items!.insert(itm, at: 0)
                        }
                    }
                }
            }
            
            shipping.shippingMO!.removeFromCustomers(oCus.customerMO!)
            shipping.shippingMO!.addToCustomers(customer.customerMO!)
            shipping.customers![customerIndex] = customer
            
            customerItemTableView.reloadData()
            imageCollectionView.reloadData()
            appDelegate.saveContext()
        }
    }
    
    func deleteCustomerByIndex(rowIndex: Int) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            let removedItems = shipping.items?.filter{$0.customer === shipping.customers![rowIndex]}
            
            if(removedItems != nil) {
                for itm in removedItems! {
                    if(itm.itemMO != nil) {
                        context.delete(itm.itemMO!)
                    }
                }
            }
            
            shipping.items?.removeAll(where: {$0.customer === shipping.customers![rowIndex]})
            
            if(shipping.images != nil) {
                for img in shipping.images! {
                    if(img.customers != nil) {
                        for (idx, cus) in img.customers!.enumerated() {
                            if(cus === shipping.customers![rowIndex]) {
                                img.imageMO!.removeFromCustomers(cus.customerMO!)
                                img.customers!.remove(at: idx)
                                break
                            }
                        }
                    }
                }
            }
            shipping.shippingMO!.removeFromCustomers(shipping.customers![rowIndex].customerMO!)
            shipping.customers!.remove(at: rowIndex)
            customerItemTableView.reloadData()
            imageCollectionView.reloadData()
        }
    }
    
    func addImage(_ image: Image) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let imageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
            
            imageMO.imageFile = image.imageFile
            imageMO.name = image.name
            imageMO.shipping = shipping.shippingMO
            
            imageMO.createdDatetime = Date()
            imageMO.createdUser = Utils.shared.getUser()
            imageMO.updatedDatetime = Date()
            imageMO.updatedUser = Utils.shared.getUser()
            
            image.createdDatetime = Date()
            image.createdUser = Utils.shared.getUser()
            image.updatedDatetime = Date()
            image.updatedUser = Utils.shared.getUser()
            image.changed = false
            
            image.imageMO = imageMO
            
            if(image.customers != nil) {
                for cus in image.customers! {
                    
                    let customerMO = getCustomerMO(name: cus.name)
                    customerMO.comment = cus.comment
                    customerMO.phone = cus.phone
                    customerMO.wechat = cus.wechat
                    customerMO.shipping = shipping.shippingMO
                    
                    customerMO.createdDatetime = Date()
                    customerMO.createdUser = Utils.shared.getUser()
                    customerMO.updatedDatetime = Date()
                    customerMO.updatedUser = Utils.shared.getUser()
                    
                    cus.createdDatetime = Date()
                    cus.createdUser = Utils.shared.getUser()
                    cus.updatedDatetime = Date()
                    cus.updatedUser = Utils.shared.getUser()
                    cus.changed = false
                    
                    cus.customerMO = customerMO
                    imageMO.addToCustomers(customerMO)
                    
                    shipping.shippingMO!.addToCustomers(customerMO)
                    
                    if(shipping.customers == nil) {
                        shipping.customers = []
                    }
                    shipping.customers!.insert(cus, at: 0)
                    
                    if(cus.items != nil) {
                        for itm in cus.items! {
                            let itemMO = ItemMO(context: appDelegate.persistentContainer.viewContext)
                            
                            itm.itemType = getItemType(name: itm.itemType!.itemTypeName.name, brand: itm.itemType!.itemTypeBrand.name)
                            itemMO.itemType = itm.itemType!.itemTypeMO
                            
                            itemMO.comment = itm.comment
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customerMO
                            itemMO.image = imageMO
                            itemMO.quantity = itm.quantity!
                            itemMO.shipping = shipping.shippingMO
                            
                            itemMO.createdDatetime = Date()
                            itemMO.createdUser = Utils.shared.getUser()
                            itemMO.updatedDatetime = Date()
                            itemMO.updatedUser = Utils.shared.getUser()
                            
                            itm.createdDatetime = Date()
                            itm.createdUser = Utils.shared.getUser()
                            itm.updatedDatetime = Date()
                            itm.updatedUser = Utils.shared.getUser()
                            itm.changed = false
                            
                            itm.itemMO = itemMO
                            
                            shipping.shippingMO!.addToItems(itemMO)
                            
                            if(shipping.items != nil) {
                                shipping.items = []
                            }
                            shipping.items!.insert(itm, at: 0)
                        }
                    }
                }
            }
            
            if(shipping.images == nil) {
                shipping.images = []
            }
            shipping.images!.insert(image, at: 0)
            shipping.shippingMO!.addToImages(imageMO)
            
            let indexPath = IndexPath(row:0, section: 0)
            imageCollectionView.insertItems(at: [indexPath])
            customerItemTableView.reloadData()
            appDelegate.saveContext()
        }
    }
    
    func updateImage(_ image: Image, _ imageIndex: Int) {
        let oImg = shipping.images![imageIndex]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            let newImageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
            newImageMO.name = image.name
            newImageMO.imageFile = image.imageFile
            newImageMO.shipping = shipping.shippingMO
            
            newImageMO.createdDatetime = oImg.createdDatetime
            newImageMO.createdUser = oImg.createdUser
            newImageMO.updatedDatetime = Date()
            newImageMO.updatedUser = Utils.shared.getUser()
            
            image.createdDatetime = oImg.createdDatetime
            image.createdUser = oImg.createdUser
            image.updatedDatetime = Date()
            image.updatedUser = Utils.shared.getUser()
            image.changed = false
            
            image.imageMO = newImageMO
            
            if(oImg.customers != nil) {
                for cus in oImg.customers! {
                    let removedItems = shipping.items?.filter{$0.image === oImg && $0.customer === cus}
                    
                    if(removedItems != nil) {
                        for itm in removedItems! {
                            context.delete(itm.itemMO!)
                        }
                    }
                    
                    shipping.items?.removeAll(where: {$0.image === oImg && $0.customer === cus})
                    
                    if(shipping.customers != nil) {
                        for (idx, cus2) in shipping.customers!.enumerated() {
                            if(cus === cus2) {
                                context.delete(shipping.customers![idx].customerMO!)
                                shipping.customers!.remove(at: idx)
                                break
                            }
                        }
                    }
                    
                    let newCustomerMO = getCustomerMO(name: cus.name)
                    newCustomerMO.comment = cus.newCustomer!.comment
                    newCustomerMO.phone = cus.newCustomer!.phone
                    newCustomerMO.wechat = cus.newCustomer!.wechat
                    newCustomerMO.shipping = shipping.shippingMO
                    
                    newCustomerMO.createdDatetime = cus.createdDatetime
                    newCustomerMO.createdUser = cus.createdUser
                    newCustomerMO.updatedDatetime = cus.updatedDatetime
                    newCustomerMO.updatedUser = cus.updatedUser
                    
                    cus.newCustomer!.customerMO = newCustomerMO
                    
                    if(cus.images != nil) {
                        for img in cus.images! {
                            if(img !== oImg) {
                                newCustomerMO.addToImages(img.imageMO!)
                                
                                if(cus.newCustomer!.images == nil) {
                                    cus.newCustomer!.images = []
                                }
                                cus.newCustomer!.images!.append(img)
                                
                                if(img.customers != nil) {
                                    for (idx, cus2) in img.customers!.enumerated() {
                                        if(cus2 === cus) {
                                            img.imageMO!.removeFromCustomers(img.customers![idx].customerMO!)
                                            img.imageMO!.addToCustomers(newCustomerMO)
                                            img.customers![idx] = cus.newCustomer!
                                            break
                                        }
                                    }
                                }
                                
                                if(shipping.items != nil) {
                                    for itm in shipping.items! {
                                        if(itm.image === img && itm.customer === cus) {
                                            itm.itemMO!.customer = newCustomerMO
                                            itm.customer = cus.newCustomer!
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(image.customers != nil) {
                for cus in image.customers! {
                    
                    if(cus.customerMO == nil) {
                        let newCustomerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
                        newCustomerMO.name = cus.name
                        newCustomerMO.shipping = shipping.shippingMO
                        newCustomerMO.addToImages(image.imageMO!)
                        
                        newCustomerMO.createdDatetime = cus.createdDatetime
                        newCustomerMO.createdUser = cus.createdUser
                        
                        if(cus.changed == true) {
                            newCustomerMO.updatedDatetime = Date()
                            newCustomerMO.updatedUser = Utils.shared.getUser()
                            
                            if(cus.createdDatetime == nil) {
                                cus.createdDatetime = Date()
                            }
                            
                            if(cus.createdUser == nil) {
                                cus.createdUser = Utils.shared.getUser()
                            }
                            
                            cus.updatedDatetime = Date()
                            cus.updatedUser = Utils.shared.getUser()
                        } else {
                            newCustomerMO.updatedDatetime = cus.updatedDatetime
                            newCustomerMO.updatedUser = cus.updatedUser
                        }
                        
                        cus.changed = false
                        cus.customerMO = newCustomerMO
                    }
                    
                    newImageMO.addToCustomers(cus.customerMO!)
                    
                    if(shipping.customers == nil) {
                        shipping.customers = []
                    }
                    shipping.customers!.insert(cus, at: 0)
                    
                    if(cus.items != nil) {
                        for itm in cus.items! {
                            let itemMO = ItemMO(context: appDelegate.persistentContainer.viewContext)
                            
                            itm.itemType = getItemType(name: itm.itemType!.itemTypeName.name, brand: itm.itemType!.itemTypeBrand.name)
                            itemMO.itemType = itm.itemType!.itemTypeMO
                            
                            itemMO.comment = itm.comment
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = cus.customerMO
                            itemMO.image = image.imageMO
                            itemMO.quantity = itm.quantity!
                            itemMO.shipping = shipping.shippingMO
                            
                            itemMO.createdDatetime = itm.createdDatetime
                            itemMO.createdUser = itm.createdUser
                            
                            if(itm.changed == true) {
                                itemMO.updatedDatetime = Date()
                                itemMO.updatedUser = Utils.shared.getUser()
                                
                                if(itm.createdDatetime == nil) {
                                    itm.createdDatetime = Date()
                                }
                                
                                if(itm.createdUser == nil) {
                                    itm.createdUser = Utils.shared.getUser()
                                }
                                
                                itm.updatedDatetime = Date()
                                itm.updatedUser = Utils.shared.getUser()
                            } else {
                                itemMO.updatedDatetime = itm.updatedDatetime
                                itemMO.updatedUser = itm.updatedUser
                            }
                            
                            itm.changed = false
                            
                            itm.itemMO = itemMO
                            
                            shipping.shippingMO!.addToItems(itemMO)
                            
                            if(shipping.items == nil) {
                                shipping.items = []
                            }
                            shipping.items!.insert(itm, at: 0)
                        }
                    }
                }
            }
            
            shipping.shippingMO!.removeFromImages(oImg.imageMO!)
            shipping.shippingMO!.addToImages(image.imageMO!)
            shipping.images![imageIndex] = image
            
            let indexPath = IndexPath(row:imageIndex, section: 0)
            imageCollectionView.reloadItems(at: [indexPath])
            customerItemTableView.reloadData()
            appDelegate.saveContext()
        }
    }
    
    func deleteImageByIndex(_ rowIndex: Int) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            let removedItems = shipping.items?.filter{$0.image === shipping.images![rowIndex]}
            
            if(removedItems != nil) {
                for itm in removedItems! {
                    if(itm.itemMO != nil) {
                        context.delete(itm.itemMO!)
                    }
                }
            }
            
            shipping.items?.removeAll(where: {$0.image === shipping.images![rowIndex]})
            
            if(shipping.customers != nil) {
                for cus in shipping.customers! {
                    if(cus.images != nil) {
                        for (idx, img) in cus.images!.enumerated() {
                            if(img === shipping.images![rowIndex]) {
                                cus.customerMO!.removeFromImages(img.imageMO!)
                                cus.images!.remove(at: idx)
                                break
                            }
                        }
                    }
                }
            }
            
            shipping.shippingMO!.removeFromImages(shipping.images![rowIndex].imageMO!)
            shipping.images!.remove(at: rowIndex)
            imageCollectionView.deleteItems(at: [IndexPath(row: rowIndex, section: 0)])
        }
    }
    
    func updateShipping(_ sp: Shipping) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        shipping.city = sp.city
        shipping.shippingDate = sp.shippingDate
        shippingDateLabel.text = dateFormatterPrint.string(from: shipping.shippingDate)
        shippingCityLabel.text = shipping.city
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if(sp.comment != nil) {
            shipping.comment = sp.comment!
            shippingCommentLabel.text = "\(shipping.comment!)"
        } else {
            shippingCommentLabel.text = ""
        }
        
        if(sp.deposit != nil) {
            shipping.deposit = sp.deposit!
            shippingDepositLabel.text = "\(formatter.string(from: shipping.deposit!)!)"
        } else {
            shippingDepositLabel.text = ""
        }
        
        if(sp.boxQuantity != nil) {
            shipping.boxQuantity = sp.boxQuantity!
            shippingBoxQuantityLabel.text = shipping.boxQuantity!
        } else {
            shippingBoxQuantityLabel.text = ""
        }
        
        if(sp.feeInternational != nil) {
            shipping.feeInternational = sp.feeInternational!
            shippingPriceInternationalLabel.text = "\(formatter.string(from: shipping.feeInternational!)!)"
        } else {
            shippingPriceInternationalLabel.text = ""
        }
        
        if(sp.feeNational != nil) {
            shipping.feeNational = sp.feeNational!
            shippingPriceNationalLabel.text = "\(formatter.string(from: shipping.feeNational!)!)"
        } else {
            shippingPriceNationalLabel.text = ""
        }
        
        if(sp.status != nil) {
            shipping.status = sp.status!
        }
        
        sp.updatedDatetime = Date()
        sp.updatedUser = Utils.shared.getUser()
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let shippingMO = shipping.shippingMO!
            
            shippingMO.shippingDate = sp.shippingDate
            shippingMO.city = sp.city
            
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
            
            shippingMO.updatedDatetime = Date()
            shippingMO.updatedUser = Utils.shared.getUser()

            appDelegate.saveContext()
        }
        
        shippingListTableViewController.tableView.reloadRows(at: [IndexPath(row: cellIndex, section: 0)], with: .automatic)
    }
    
    func getItemType(name: String, brand: String) -> ItemType {
        
        let itemTypeName = ItemTypeName(name: name)
        let itemTypeBrand = ItemTypeBrand(name: brand)
        let itemType = ItemType(itemTypeName: itemTypeName, itemTypeBrand: itemTypeBrand)
        
        var itemTypeNameArray : [ItemTypeNameMO] = [ItemTypeNameMO]()
        var itemTypeBrandArray : [ItemTypeBrandMO] = [ItemTypeBrandMO]()
        var itemTypeArray : [ItemTypeMO] = [ItemTypeMO]()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //Item Type Name
        let predicateItemTypeName = NSPredicate(format: "name = %@", name)
        let requestItemTypeName : NSFetchRequest<ItemTypeNameMO> = ItemTypeNameMO.fetchRequest()
        requestItemTypeName.predicate = predicateItemTypeName
        
        do {
            itemTypeNameArray = try context.fetch(requestItemTypeName)
        } catch {
            print("Error while fetching data: \(error)")
        }
        
        if(itemTypeNameArray.count == 1) {
            itemTypeName.itemTypeNameMO = itemTypeNameArray[0]
        } else {
            let newItemTypeNameMO = ItemTypeNameMO(context: context)
            newItemTypeNameMO.name = name
            itemTypeName.itemTypeNameMO = newItemTypeNameMO
        }
        
        //Item Type Brand
        let predicateItemTypeBrand = NSPredicate(format: "name = %@", brand)
        let requestItemTypeBrand : NSFetchRequest<ItemTypeBrandMO> = ItemTypeBrandMO.fetchRequest()
        requestItemTypeBrand.predicate = predicateItemTypeBrand
        
        do {
            itemTypeBrandArray = try context.fetch(requestItemTypeBrand)
        } catch {
            print("Error while fetching data: \(error)")
        }
        
        if(itemTypeBrandArray.count == 1) {
            itemTypeBrand.itemTypeBrandMO = itemTypeBrandArray[0]
        } else {
            let newItemTypeBrandMO = ItemTypeBrandMO(context: context)
            newItemTypeBrandMO.name = brand
            itemTypeBrand.itemTypeBrandMO = newItemTypeBrandMO
        }
        
        //Item Type
        let predicate = NSPredicate(format: "itemTypeName.name = %@ AND itemTypeBrand.name = %@", name, brand)
        let request : NSFetchRequest<ItemTypeMO> = ItemTypeMO.fetchRequest()
        request.predicate = predicate
        
        do {
            itemTypeArray = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
        
        if(itemTypeArray.count == 1) {
            itemType.itemTypeMO = itemTypeArray[0]
        } else {
            let newItemTypeMO = ItemTypeMO(context: context)
            newItemTypeMO.itemTypeName = itemTypeName.itemTypeNameMO
            newItemTypeMO.itemTypeBrand = itemTypeBrand.itemTypeBrandMO
            itemType.itemTypeMO = newItemTypeMO
        }
        
        do {
            try context.save()
        } catch {
            print("Error while saving items: \(error)")
        }
        
        return itemType
    }
    
    func getCustomerMO(name: String) -> CustomerMO {
        var dataList : [CustomerMO] = [CustomerMO]()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "name = %@", name)
        let request : NSFetchRequest<CustomerMO> = CustomerMO.fetchRequest()
        request.predicate = predicate
        
        do {
            dataList = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
        
        if(dataList.count == 1) {
            return dataList[0]
        } else {
            let newCustomerMO = CustomerMO(context: context)
            newCustomerMO.name = name
            
            do {
                try context.save()
            } catch {
                print("Error while saving items: \(error)")
            }
            
            return newCustomerMO
        }
    }
}
