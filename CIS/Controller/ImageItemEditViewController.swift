//
//  ImageItemEditViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-22.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class ImageItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var itemImageButton: UIButton!
     @IBOutlet weak var customerItemTableView: UITableView!
    
    @IBAction func itemImageButtonTapped(_ sender: Any) {
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 1
        
//        vc.takePhotoIcon = UIImage(named: "chat")
//
//        vc.albumButton.tintColor = UIColor.green
//        vc.cancelButton.tintColor = UIColor.red
//        vc.doneButton.tintColor = UIColor.purple
//        vc.selectionCharacter = "✓"
//        vc.selectionFillColor = UIColor.gray
//        vc.selectionStrokeColor = UIColor.yellow
//        vc.selectionShadowColor = UIColor.red
//        vc.selectionTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
//        vc.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
//            switch (verticalSize, horizontalSize) {
//            case (.compact, .regular): // iPhone5-6 portrait
//                return 2
//            case (.compact, .compact): // iPhone5-6 landscape
//                return 2
//            case (.regular, .regular): // iPad portrait/landscape
//                return 3
//            default:
//                return 2
//            }
//        }
//
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                
            }, deselect: { (asset: PHAsset) -> Void in
                
            }, cancel: { (assets: [PHAsset]) -> Void in
                
            }, finish: { (assets: [PHAsset]) -> Void in
                self.itemImageButton.setBackgroundImage(Utils.shared.getAssetThumbnail(assets[0]), for: .normal)
                self.newImage.imageFile = Utils.shared.getAssetThumbnail(assets[0]).pngData()!
                
            }, completion: nil)
    }
    
    @IBAction func saveImageItemButton(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if(image == nil) {
            shippingDetailViewController.addImage(newImage)
        } else {
            shippingDetailViewController.updateImage(newImage, imageIndex!)
            
            imageItemViewController!.image = newImage
            imageItemViewController!.itemImageView.image = UIImage(data: newImage.imageFile as Data)
            imageItemViewController!.customerItemTableView.reloadData()
        }
        
        shippingDetailViewController.customerItemTableView.reloadData()
        shippingDetailViewController.imageCollectionView.reloadData()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCustomer(_ sender: Any) {
        self.view.endEditing(true)
        
        let customer = Customer(name: "")
        customer.images = [newImage]
        if(newImage.customers == nil) {
            newImage.customers = []
        }
        newImage.customers!.insert(customer, at: 0)
            
        customerItemTableView.reloadData()
    }
    
    var image: Image?
    var imageIndex: Int?
    var shippingDetailViewController: ShippingDetailViewController!
    var imageItemViewController: ImageItemViewController?
    var newImage = Image(name: "test")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        
        customerItemTableView.backgroundColor = UIColor.white
        
        let nib = UINib(nibName: "ImageItemHeader", bundle: nil)
        customerItemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "imageSectionHeader")
        
        if(image != nil) {
            newImage.name = image!.name
            newImage.imageFile = image!.imageFile
            
            if(image!.customers != nil) {
                for cus in image!.customers! {
                    let newCus = Customer(name: cus.name)
                    
                    if(cus.phone != nil) {
                        newCus.phone = cus.phone!
                    }
                    
                    if(cus.wechat != nil) {
                        newCus.wechat = cus.wechat!
                    }
                    
                    if(cus.comment != nil) {
                        newCus.comment = cus.comment!
                    }
                    
                    newCus.images = [newImage]
                    
                    if(cus.items != nil) {
                        for itm in cus.items! {
                            let newItm = Item(name: itm.name, quantity: itm.quantity)
                            newItm.customer = newCus
                            if(itm.comment != nil) {
                                newItm.comment = itm.comment
                            }
                            
                            if(itm.priceBought != nil) {
                                newItm.priceBought = itm.priceBought
                            }
                            
                            if(itm.priceSold != nil) {
                                newItm.priceSold = itm.priceSold
                            }
                            
                            newItm.image = newImage
                            
                            if(newCus.items == nil) {
                                newCus.items = []
                            }
                            
                            newCus.items!.append(newItm)
                        }
                    }
                    
                    if(newImage.customers == nil) {
                        newImage.customers = []
                    }
                    newImage.customers!.append(newCus)
                    
                    cus.newCustomer = newCus
                }
            }
        }
        
        itemImageButton.setBackgroundImage(UIImage(data: newImage.imageFile as Data), for: .normal)
        itemImageButton.clipsToBounds = true
        itemImageButton.layer.cornerRadius = 5
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return newImage.customers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newImage.customers?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemEditTableViewCell
        
        let item = newImage.customers![indexPath.section].items![indexPath.row]
        
        cell.nameTextField.text = item.name
        cell.quantityTextField.text = "\(item.quantity)"
        
        if(item.priceSold != nil) {
            cell.priceSoldTextField.text = "\(item.priceSold!)"
        }
        
        if(item.priceBought != nil) {
            cell.priceBoughtTextField.text = "\(item.priceBought!)"
        }
        
        if(item.comment != nil) {
            cell.descriptionTextView.text = "\(item.comment!)"
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let header = customerItemTableView.dequeueReusableHeaderFooterView(withIdentifier: "imageSectionHeader") as! ImageItemSectionHeaderView
        
        header.customerNameTextField.text = newImage.customers![section].name
        
        header.customerNameTextField.tag = section
        header.customerNameTextField.addTarget(self, action: #selector(updateCustomerName(sender:)), for: .editingDidEnd)
        
        header.addItemButton.tag = section
        header.addItemButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)

        header.deleteCustomerButton.tag = section
        header.deleteCustomerButton.addTarget(self, action: #selector(deleteCustomer(sender:)), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 103
    }
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            if(newImage.items != nil) {
                for (idx, itm) in newImage.items!.enumerated() {
                    if(itm === newImage.customers![deletionIndexPath.section].items![deletionIndexPath.row]) {
                        newImage.items!.remove(at: idx)
                        break
                    }
                }
            }
            
            newImage.customers![deletionIndexPath.section].items!.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    //MARK: - Custom Cell Functions
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
    }
    
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextView textView: UITextView) {
        
    }
    
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
           
            let itm = newImage.customers![(indexPath.section)].items![indexPath.row]
                
            switch textField.tag {
            case 1: itm.name = textField.text!
            case 2: itm.quantity = Int16(textField.text!)!
            case 3: itm.priceBought = NSDecimalNumber(string: textField.text!)
            case 4: itm.priceSold = NSDecimalNumber(string: textField.text!)
            default: print("Error")
            }
        }
    }
    
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextView textView: UITextView) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
            let itm = newImage.customers![(indexPath.section)].items![indexPath.row]
            itm.comment = textView.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Helper Functions
    @objc func updateCustomerName(sender:UIButton) {
        self.view.endEditing(true)
        
        let header = customerItemTableView.headerView(forSection: sender.tag) as! ImageItemSectionHeaderView
        newImage.customers![sender.tag].name = header.customerNameTextField.text!
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let itm = Item(name: "", quantity: 1)
        itm.customer = newImage.customers![sender.tag]
        itm.image = newImage
        
        if(newImage.customers![sender.tag].items == nil) {
            newImage.customers![sender.tag].items = []
        }
        newImage.customers![sender.tag].items!.insert(itm, at: 0)
        
        customerItemTableView.reloadData()
    }
    
    @objc func deleteCustomer(sender:UIButton)
    {
        self.view.endEditing(true)
        
        if(newImage.customers![sender.tag].items != nil) {
            for dItem in newImage.customers![sender.tag].items! {
                if(newImage.items != nil) {
                    for (idx, itm) in newImage.items!.enumerated() {
                        if(itm === dItem) {
                            newImage.items!.remove(at: idx)
                            break
                        }
                    }
                }
            }
        }
        
        newImage.customers!.remove(at: sender.tag)
        
        customerItemTableView.reloadData()
    }
}
