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

class ShippingDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var shippingDateLabel: UILabel!
    @IBOutlet weak var shippingStatusLabel: UILabel!
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
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        customerItemTableView.contentInset = UIEdgeInsets(top: 0, left: -14, bottom: 0, right: 0)
        
        if shipping != nil {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            
            shippingDateLabel.text = dateFormatterPrint.string(from: shipping!.shippingDate)
            shippingStatusLabel.text = shipping!.status
            shippingCityLabel.text = shipping!.city
            
            if(shipping!.feeNational != nil) {
                shippingPriceNationalLabel.text = "\(shipping!.feeNational!)"
            }
            if(shipping!.feeInternational != nil) {
                shippingPriceInternationalLabel.text = "\(shipping!.feeInternational!)"
            }
            if(shipping!.deposit != nil) {
                shippingDepositLabel.text = "\(shipping!.deposit!)"
            }
            if(shipping!.comment != nil) {
                shippingCommentLabel.text = "\(shipping!.comment!)"
            }
        } else {
            deleteButton.isHidden = true
            
            let screenSize: CGRect = UIScreen.main.bounds
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
            let navItem = UINavigationItem(title: "新货单")
            let backButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
            let saveButton = UIBarButtonItem(title: "完成", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveData))
            navItem.leftBarButtonItem = backButton
            navItem.rightBarButtonItem = saveButton
            navBar.setItems([navItem], animated: false)
            navBar.isTranslucent = false
            self.view.addSubview(navBar)
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
            let customerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
            
            customerMO.comment = customer.comment
            customerMO.name = customer.name
            customerMO.phone = customer.phone
            customerMO.wechat = customer.wechat
            customerMO.shipping = shipping.shippingMO
            
            customer.customerMO = customerMO
            
            if(customer.images != nil) {
                for img in customer.images! {
                    
                    let imageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
                    imageMO.name = img.name
                    imageMO.imageFile = img.imageFile
                    imageMO.addToCustomers(customerMO)
                    imageMO.shipping = shipping.shippingMO
                    
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
                            itemMO.comment = itm.comment
                            itemMO.name = itm.name
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customerMO
                            itemMO.image = imageMO
                            itemMO.quantity = itm.quantity
                            itemMO.shipping = shipping.shippingMO
                            
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
            
            if(shipping.customers == nil) {
                shipping.customers = []
            }
            shipping.customers!.insert(customer, at: 0)
            shipping.shippingMO!.addToCustomers(customerMO)
            
            appDelegate.saveContext()
        }
    }
    
    func updateCustomer(_ customer: Customer, _ customerIndex: Int) {
        let oCus = shipping.customers![customerIndex]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            let newCustomerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
            newCustomerMO.name = customer.name
            newCustomerMO.phone = customer.phone
            newCustomerMO.comment = customer.comment
            newCustomerMO.wechat = customer.wechat
            newCustomerMO.shipping = shipping.shippingMO
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
                            itemMO.comment = itm.comment
                            itemMO.name = itm.name
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customer.customerMO
                            itemMO.image = img.imageMO
                            itemMO.quantity = itm.quantity
                            itemMO.shipping = shipping.shippingMO
                            
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
            customerItemTableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
        }
    }
    
    func addImage(_ image: Image) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let imageMO = ImageMO(context: appDelegate.persistentContainer.viewContext)
            
            imageMO.imageFile = image.imageFile
            imageMO.name = image.name
            imageMO.shipping = shipping.shippingMO
            
            image.imageMO = imageMO
            
            if(image.customers != nil) {
                for cus in image.customers! {
                    
                    let customerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
                    customerMO.comment = cus.comment
                    customerMO.name = cus.name
                    customerMO.phone = cus.phone
                    customerMO.wechat = cus.wechat
                    customerMO.shipping = shipping.shippingMO
                    
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
                            itemMO.comment = itm.comment
                            itemMO.name = itm.name
                            itemMO.priceBought = itm.priceBought
                            itemMO.priceSold = itm.priceSold
                            itemMO.customer = customerMO
                            itemMO.image = imageMO
                            itemMO.quantity = itm.quantity
                            itemMO.shipping = shipping.shippingMO
                            
                            itm.itemMO = itemMO
                            
                            shipping.shippingMO!.addToItems(itemMO)
                            
                            if(shipping.items) {
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
                    
                    let newCustomerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
                    newCustomerMO.comment = cus.newCustomer!.comment
                    newCustomerMO.name = cus.newCustomer!.name
                    newCustomerMO.phone = cus.newCustomer!.phone
                    newCustomerMO.wechat = cus.newCustomer!.wechat
                    newCustomerMO.shipping = shipping.shippingMO
                    
                    cus.newCustomer!.customerMO = newCustomerMO
                    
                    for img in cus.images {
                        if(img !== oImg) {
                            newCustomerMO.addToImages(img.imageMO!)
                            cus.newCustomer!.images.append(img)
                            
                            for (idx, cus2) in img.customers.enumerated() {
                                if(cus2 === cus) {
                                    img.imageMO!.removeFromCustomers(img.customers[idx].customerMO!)
                                    img.imageMO!.addToCustomers(newCustomerMO)
                                    img.customers[idx] = cus.newCustomer!
                                    break
                                }
                            }
                            
                            for itm in shipping.items {
                                if(itm.image === img && itm.customer === cus) {
                                    itm.itemMO!.customer = newCustomerMO
                                    itm.customer = cus.newCustomer!
                                }
                            }
                        }
                    }
                }
            }
            
            for cus in image.customers {
                
                if(cus.customerMO == nil) {
                    let newCustomerMO = CustomerMO(context: appDelegate.persistentContainer.viewContext)
                    newCustomerMO.name = cus.name
                    newCustomerMO.shipping = shipping.shippingMO
                    newCustomerMO.addToImages(image.imageMO!)
                    
                    cus.customerMO = newCustomerMO
                }
                
                newImageMO.addToCustomers(cus.customerMO!)
                
                shipping.customers.insert(cus, at: 0)
                
                for itm in cus.items {
                    let itemMO = ItemMO(context: appDelegate.persistentContainer.viewContext)
                    itemMO.comment = itm.comment
                    itemMO.name = itm.name
                    itemMO.priceBought = itm.priceBought
                    itemMO.priceSold = itm.priceSold
                    itemMO.customer = cus.customerMO
                    itemMO.image = image.imageMO
                    itemMO.quantity = itm.quantity
                    itemMO.shipping = shipping.shippingMO
                    
                    itm.itemMO = itemMO
                    
                    shipping.shippingMO!.addToItems(itemMO)
                    shipping.items.insert(itm, at: 0)
                }
            }
            
            shipping.shippingMO!.removeFromImages(oImg.imageMO!)
            shipping.shippingMO!.addToImages(image.imageMO!)
            shipping.images[imageIndex] = image
            
            appDelegate.saveContext()
        }
    }
    
    func deleteImageByIndex(_ rowIndex: Int) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            let removedItems = shipping.items.filter{$0.image === shipping.images[rowIndex]}
            
            for itm in removedItems {
                if(itm.itemMO != nil) {
                    context.delete(itm.itemMO!)
                }
            }
            
            shipping.items.removeAll(where: {$0.image === shipping.images[rowIndex]})
            
            for cus in shipping.customers {
                for (idx, img) in cus.images.enumerated() {
                    if(img === shipping.images[rowIndex]) {
                        cus.customerMO!.removeFromImages(img.imageMO!)
                        cus.images.remove(at: idx)
                        break
                    }
                }
            }
            
            shipping.shippingMO!.removeFromImages(shipping.images[rowIndex].imageMO!)
            shipping.images.remove(at: rowIndex)
            customerItemTableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
        }
    }
    
    func updateShipping(_ sp: Shipping) {
        shipping.city = sp.city
        shipping.comment = sp.comment
        shipping.deposit = sp.deposit
        shipping.feeInternational = sp.feeInternational
        shipping.feeNational = sp.feeNational
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let shippingMO = shipping.shippingMO!
            
            shippingMO.shippingDate = sp.shippingDate
            shippingMO.city = sp.city
            shippingMO.status = sp.status
            shippingMO.comment = sp.comment
            shippingMO.deposit = sp.deposit
            shippingMO.feeNational = sp.feeNational
            shippingMO.feeInternational = sp.feeInternational

            appDelegate.saveContext()
        }
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"

        shippingDateLabel.text = dateFormatterPrint.string(from: shipping.shippingDate)
        shippingStatusLabel.text = shipping.status
        shippingCityLabel.text = shipping.city
        shippingPriceNationalLabel.text = "\(shipping.feeNational)"
        shippingPriceInternationalLabel.text = "\(shipping.feeInternational)"
        shippingDepositLabel.text = "\(shipping.deposit)"
        shippingCommentLabel.text = "\(shipping.comment)"
        
        shippingListTableViewController.tableView.reloadRows(at: [IndexPath(row: cellIndex, section: 0)], with: .automatic)
    }
    
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveData(){
        dismiss(animated: true, completion: nil)
    }
}
