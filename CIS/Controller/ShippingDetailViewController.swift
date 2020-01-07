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

class ShippingDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource {
    
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
                    self.addShippingImage(Image(imageFile: self.getAssetThumbnail(ast).pngData()!))
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
            shippingPriceNationalLabel.text = "\(shipping!.feeNational)"
            shippingPriceInternationalLabel.text = "\(shipping!.feeInternational)"
            shippingDepositLabel.text = "\(shipping!.deposit)"
            shippingCommentLabel.text = "\(shipping!.comment)"
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
            
            shippingDateLabel.text = ""
            shippingStatusLabel.text = ""
            shippingCityLabel.text = ""
            shippingPriceNationalLabel.text = ""
            shippingPriceInternationalLabel.text = ""
            shippingDepositLabel.text = ""
            shippingCommentLabel.text = ""
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomer" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let customerView: CustomerItemEditViewController = naviView.viewControllers[0] as! CustomerItemEditViewController
            
            customerView.shippingDetailViewController = self
        } else if segue.identifier == "editShippingDetail" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let shippingView: ShippingInfoViewController = naviView.viewControllers[0] as! ShippingInfoViewController
            shippingView.shipping = shipping
            shippingView.shippingDetailViewController = self
        } else if segue.identifier == "showCustomerDetail" {
            if let indexPath = customerItemTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! CustomerItemViewController
                
                let customer = shipping.customers[indexPath.row]
                
                var items = [Item]()
                
                for itm in shipping.items {
                    if(itm.customer === customer) {
                        items.append(itm)
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
                
                let image = shipping.images[indexPaths[0].row]
                
                var items = [Item]()
                
                for itm in shipping.items {
                    if(itm.image === image) {
                        items.append(itm)
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
        return shipping.customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerId", for: indexPath as IndexPath) as! CustomerListTableViewCell
        
        cell.customerNameLabel.text = shipping.customers[indexPath.row].name
        
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
        return shipping.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageId", for: indexPath) as! ImageCollectionViewCell

        cell.shippingImageView.image = UIImage(data: shipping.images[indexPath.row].imageFile as Data)

        return cell
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
        
        shipping.customers.insert(customer, at: 0)
        
        for img in customer.images {
            shipping.images.insert(img, at: 0)
            
            for itm in img.items {
                shipping.items.insert(itm, at: 0)
            }
        }
    }
    
    func updateCustomer(_ customer: Customer, _ customerIndex: Int) {
        let oCus = shipping.customers[customerIndex]

        for img in oCus.images {
            shipping.items.removeAll(where: {$0.image === img && $0.customer === oCus})
            
            for (idx, img2) in shipping.images.enumerated() {
                if(img === img2) {
                    shipping.images.remove(at: idx)
                    break
                }
            }
            
            for cus in img.customers {
                if(cus !== oCus) {
                    img.newImage!.customers.append(cus)
                    
                    for (idx, img2) in cus.images.enumerated() {
                        if(img2 === img) {
                            cus.images[idx] = img.newImage!
                            break
                        }
                    }
                    
                    for itm in shipping.items {
                        if(itm.image === img && itm.customer === cus) {
                            itm.image = img.newImage!
                        }
                    }
                }
            }
        }
        
        for img in customer.images {
            shipping.images.insert(img, at: 0)
            
            for itm in img.items {
                shipping.items.insert(itm, at: 0)
            }
        }
        
        shipping.customers[customerIndex] = customer
    }
    
    func deleteCustomerByIndex(rowIndex: Int) {
        
        shipping.items.removeAll(where: {$0.customer === shipping.customers[rowIndex]})
        
        for img in shipping.images {
            for (idx, cus) in img.customers.enumerated() {
                if(cus === shipping.customers[rowIndex]) {
                    img.customers.remove(at: idx)
                    break
                }
            }
        }
        
        shipping.customers.remove(at: rowIndex)
        customerItemTableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
    }
    
    
    func addImage(_ customer: Customer) {
        
        shipping.customers.insert(customer, at: 0)
        
        for img in customer.images {
            shipping.images.insert(img, at: 0)
            
            for itm in img.items {
                shipping.items.insert(itm, at: 0)
            }
        }
    }
    
    func updateImage(_ customer: Customer, _ customerIndex: Int) {
        let oCus = shipping.customers[customerIndex]

        for img in oCus.images {
            shipping.items.removeAll(where: {$0.image === img && $0.customer === oCus})
            
            for (idx, img2) in shipping.images.enumerated() {
                if(img === img2) {
                    shipping.images.remove(at: idx)
                    break
                }
            }
            
            for cus in img.customers {
                if(cus !== oCus) {
                    img.newImage!.customers.append(cus)
                    
                    for (idx, img2) in cus.images.enumerated() {
                        if(img2 === img) {
                            cus.images[idx] = img.newImage!
                            break
                        }
                    }
                    
                    for itm in shipping.items {
                        if(itm.image === img && itm.customer === cus) {
                            itm.image = img.newImage!
                        }
                    }
                }
            }
        }
        
        for img in customer.images {
            shipping.images.insert(img, at: 0)
            
            for itm in img.items {
                shipping.items.insert(itm, at: 0)
            }
        }
        
        shipping.customers[customerIndex] = customer
    }
    
    func deleteImageByIndex(rowIndex: Int) {
        
        shipping.items.removeAll(where: {$0.customer === shipping.customers[rowIndex]})
        
        for img in shipping.images {
            for (idx, cus) in img.customers.enumerated() {
                if(cus === shipping.customers[rowIndex]) {
                    img.customers.remove(at: idx)
                    break
                }
            }
        }
        
        shipping.customers.remove(at: rowIndex)
        imageCollectionView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
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
//
//    func addImage(_ image: Image) {
//        shipping.images.insert(image, at: 0)
//
//        for cus in newImage.customers {
//            shippingDetailViewController.addCustomer(cus)
//        }
//    }
//
//    func deleteCustomer(_ customer: Customer, _ image: Image) {
//
//        shipping.items.removeAll(where: {$0.customer === customer && $0.image === image})
//
//        for (idx, cus) in shipping.customers.enumerated() {
//            if(customer === cus) {
//                shipping.customers.remove(at: idx)
//                break
//            }
//        }
//    }
//
//    func updateImageData(_ image: Image, _ imageIndex: Int) {
//        let oImg = shipping.images[imageIndex]
//
//        for cus in image!.customers {
//            shippingDetailViewController.deleteCustomer(cus, image!)
//        }
//
//        for cus in oImg.customers {
//            for img in cus.images {
//                if(img !== oImg) {
//                    cus.newCustomer!.images.append(img)
//
//                    for (idx, cus2) in img.customers.enumerated() {
//                        if(cus2 === cus) {
//                            img.customers[idx] = cus.newCustomer!
//                            break
//                        }
//                    }
//
//                    for itm in shipping.items {
//                        if(itm.image === img && itm.customer === cus) {
//                            itm.customer = cus.newCustomer!
//                        }
//                    }
//                }
//            }
//        }
//
//        shipping.images[imageIndex] = image
//    }
//
//    func deleteImageByIndex(imgIndex: Int) {
//
//        shipping.items.removeAll(where: {$0.image === shipping.images[imgIndex]})
//
//        for cus in shipping.customers {
//            for (idx, img) in cus.images.enumerated() {
//                if(img === shipping.images[imgIndex]) {
//                    cus.images.remove(at: idx)
//                    break
//                }
//            }
//        }
//
//        shipping.images.remove(at: imgIndex)
//        imageCollectionView.deleteItems(at: [IndexPath(row: imgIndex, section: 0)])
//    }
//
    func getAssetThumbnail(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveData(){
        dismiss(animated: true, completion: nil)
    }
}
