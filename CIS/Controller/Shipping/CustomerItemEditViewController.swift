//
//  CustomerItemEditViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-22.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import CoreData

class CustomerItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ItemTextFieldDelegate {
    
    
    @IBOutlet weak var customerNameTextField: CustomerSearchTextField!
    @IBOutlet weak var customerItemTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
        let context = appDelegate.persistentContainer.viewContext
        context.rollback()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: Any) {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        let imageMO = ImageMO(context: context)
        imageMO.shipping = shippingMO
        imageMO.imageFile = UIImage(named: "test")!.pngData()!
        imageMO.createdUser = Utils.shared.getUser()
        imageMO.createdDatetime = Date()
        imageMO.updatedUser = Utils.shared.getUser()
        imageMO.updatedDatetime = Date()
        
        imageMO.addToCustomers(customerMO!)
        customerMO!.addToImages(imageMO)
        
        let imgMOStruct = ImageMOStruct(imageMO: imageMO, itemMOStructArray: [], status: "new")
        imageMOStructArray.insert(imgMOStruct, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCurlDown,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @IBAction func saveCustomerItem(_ sender: Any) {
        self.view.endEditing(true)
        
        var currentCustomerMO: CustomerMO?
        
        if(customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            let alertController = UIAlertController(title: "请填写正确数据", message: "请填写客户名字", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else if (!itemValueIsValid()) {
            let alertController = UIAlertController(title: "请填写正确数据", message: "请填物品信息", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            if(customerItemViewController == nil) {
                currentCustomerMO = Utils.shared.getCustomerMO(name: customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), excludeMO: customerMO!)
                
                if(currentCustomerMO != nil) {
                    
                    shippingMO.addToCustomers(currentCustomerMO!)
                    currentCustomerMO!.addToShippings(shippingMO)
                    
                    for imgMOStruct in imageMOStructArray {
                        let imgMO = imgMOStruct.imageMO
                        imgMO.removeFromCustomers(customerMO!)
                        customerMO!.removeFromImages(imgMO)
                        imgMO.addToCustomers(currentCustomerMO!)
                        currentCustomerMO!.addToImages(imgMO)
                        
                        for itmMOStruct in imgMOStruct.itemMOStructArray {
                            itmMOStruct.itemMO.customer = currentCustomerMO!
                        }
                    }
                    
                    context.delete(customerMO!)
                } else {
                    customerMO!.name = customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    customerMO!.pinyin = customerMO!.name!.getCapitalLetter()
                }
            }
            
            if(imageMOStructArray.count > 0) {
                for imgMOStruct in imageMOStructArray {
                    if(imgMOStruct.itemMOStructArray.count > 0) {
                        for itmMOStruct in imgMOStruct.itemMOStructArray {
                            let itmMO = itmMOStruct.itemMO
                            let existingItemTypeMO = Utils.shared.getItemTypeMO(name: itmMO.itemType!.itemTypeName!.name!, brand: itmMO.itemType!.itemTypeBrand!.name!, excludeMO: itmMO.itemType!)
                            if(existingItemTypeMO != nil) {
                                context.delete(itmMO.itemType!.itemTypeName!)
                                context.delete(itmMO.itemType!.itemTypeBrand!)
                                context.delete(itmMO.itemType!)
                                itmMO.itemType = existingItemTypeMO
                            } else {
                                var currentItemTypeNameMO = itmMO.itemType!.itemTypeName!
                                let existingItemTypeNameMO = Utils.shared.getItemTypeNameMO(name: currentItemTypeNameMO.name!, excludeMO: currentItemTypeNameMO)
                                if(existingItemTypeNameMO != nil) {
                                    context.delete(currentItemTypeNameMO)
                                    currentItemTypeNameMO = existingItemTypeNameMO!
                                }
                                
                                var currentItemTypeBrandMO = itmMO.itemType!.itemTypeBrand!
                                let existingItemTypeBrandMO = Utils.shared.getItemTypeBrandMO(brand: currentItemTypeBrandMO.name!, excludeMO: currentItemTypeBrandMO)
                                if(existingItemTypeBrandMO != nil) {
                                    context.delete(currentItemTypeBrandMO)
                                    currentItemTypeBrandMO = existingItemTypeBrandMO!
                                }
                                
                                itmMO.itemType!.itemTypeName = currentItemTypeNameMO
                                itmMO.itemType!.itemTypeBrand = currentItemTypeBrandMO
                            }
                        }
                    }
                }
            }
            
            appDelegate.saveContext()
            
            if(customerItemViewController != nil) {
                customerItemViewController!.updateCustomerMO(currentCustomerMO!)
            }
            
            shippingDetailViewController.updateShippingDetail()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var customerMO: CustomerMO?
    var shippingMO: ShippingMO!
    var imageMOStructArray: [ImageMOStruct] = []
    var imageMODict: [ImageMO:Int] = [:]
    var shippingDetailViewController: ShippingDetailViewController!
    var customerItemViewController: CustomerItemViewController?
    var currentImageSection = -1
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        customerItemTableView.backgroundColor = UIColor.white
        customerItemTableView.keyboardDismissMode = .onDrag
        
        let nib = UINib(nibName: "CustomerItemHeader", bundle: nil)
        customerItemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        customerNameTextField.delegate = self
        
        if(customerMO == nil) {
            let context = appDelegate.persistentContainer.viewContext
            customerMO = CustomerMO(context: context)
            shippingMO!.addToCustomers(customerMO!)
            customerMO!.addToShippings(shippingMO!)
            customerMO!.createdUser = Utils.shared.getUser()
            customerMO!.createdDatetime = Date()
            customerMO!.updatedUser = Utils.shared.getUser()
            customerMO!.updatedDatetime = Date()
        } else {
            customerNameTextField.text = customerMO!.name
            customerNameTextField.isUserInteractionEnabled = false
            
            if(customerMO!.images != nil) {
                for img in customerMO!.images! {
                    let imgMO = img as! ImageMO
                    var imgFound = false
                   
                    for (idx,imgStruct) in imageMOStructArray.enumerated() {
                        if(imgMO === imgStruct.imageMO) {
                            imageMODict[imgMO] = idx
                            imgFound = true
                            break
                        }
                    }
                   
                    if(imgFound == false) {
                        imageMOStructArray.append(ImageMOStruct(imageMO: imgMO, itemMOStructArray: [], status: "old"))
                        imageMODict[imgMO] = imageMOStructArray.count - 1
                    }
                }
            
                if(shippingMO.items != nil) {
                    for itm in shippingMO.items! {
                        let itmMO = itm as! ItemMO
                        
                        if(itmMO.customer === customerMO) {
                            let imgMO = itmMO.image!
                            let idx = imageMODict[imgMO]!
                            imageMOStructArray[idx].itemMOStructArray.append(ItemMOStruct(itemMO: itmMO, status: "old"))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageMOStructArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemMOStructArray = imageMOStructArray[section].itemMOStructArray
        return itemMOStructArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemEditTableViewCell
        
        let itmMO = imageMOStructArray[indexPath.section].itemMOStructArray[indexPath.row].itemMO
        
        let iNameTextField = cell.nameTextField as! ItemTypeSearchTextField
        iNameTextField.text = "\(itmMO.itemType!.itemTypeName!.name!)"
        iNameTextField.sectionIndex = indexPath.section
        iNameTextField.rowIndex = indexPath.row
        iNameTextField.itemTextFieldDelegate = self
        if(iNameTextField.text != "") {
            iNameTextField.isUserInteractionEnabled = false
        } else {
            iNameTextField.isUserInteractionEnabled = true
        }
        
        let iBrandTextField = cell.brandTextField as! ItemTypeBrandSearchTextField
        iBrandTextField.text = "\(itmMO.itemType!.itemTypeBrand!.name!)"
        iBrandTextField.sectionIndex = indexPath.section
        iBrandTextField.rowIndex = indexPath.row
        iBrandTextField.itemTextFieldDelegate = self
        if(iBrandTextField.text != "") {
            iBrandTextField.isUserInteractionEnabled = false
        } else {
            iBrandTextField.isUserInteractionEnabled = true
        }
        
        cell.quantityTextField.text = "\(itmMO.quantity)"
        
        if(itmMO.comment != nil) {
            cell.commentTextField.text = "\(itmMO.comment!)"
        }
        
        cell.customerItemEditViewController = self
        cell.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        cell.quantityTextField.inputAccessoryView = toolbar
        
        cell.nameTextField.delegate = self
        cell.brandTextField.delegate = self
        cell.commentTextField.delegate = self
    
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        let header = customerItemTableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! CustomerItemSectionHeaderView
        
        let imageFile = imageMOStructArray[section].imageMO.imageFile!
        
        header.itemImageButton.setBackgroundImage(UIImage(data: imageFile as Data), for: .normal)
        header.itemImageButton.tag = section
        header.itemImageButton.addTarget(self, action: #selector(chooseImage(sender:)), for: .touchUpInside)
        
        header.itemImageButton.clipsToBounds = true
        header.itemImageButton.layer.cornerRadius = 5
        
        header.addItemButton.tag = section
        header.addItemButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)

        header.deleteImageButton.tag = section
        header.deleteImageButton.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
        
        header.contentView.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 130
    }
    
    //MARK: - Custom Cell Functions
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField) {
    }
    
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
           
            let itm = imageMOStructArray[indexPath.section].itemMOStructArray[indexPath.row].itemMO
                
            switch textField.tag {
            case 1: if(itm.itemType!.itemTypeName!.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.itemType!.itemTypeName!.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.updatedUser = Utils.shared.getUser()
                        itm.updatedDatetime = Date()
                    }
            
            case 2: if(Int16(textField.text!) != nil && itm.quantity != Int16(textField.text!)!) {
                        itm.quantity = Int16(textField.text!)!
                        itm.updatedUser = Utils.shared.getUser()
                        itm.updatedDatetime = Date()
                    }
                
            case 3: if(itm.itemType!.itemTypeBrand!.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.itemType!.itemTypeBrand!.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.updatedUser = Utils.shared.getUser()
                        itm.updatedDatetime = Date()
                    }
                
            case 5: if(itm.comment != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.comment = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.updatedUser = Utils.shared.getUser()
                        itm.updatedDatetime = Date()
                    }
            default: print("Error")
            }
        }
    }
    
    //MARK: - Helper Functions
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func chooseImage(sender:UIButton) {
        
        currentImageSection = sender.tag
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 1
        
        bs_presentImagePickerController(vc, animated: true,
        select: { (asset: PHAsset) -> Void in
            
        }, deselect: { (asset: PHAsset) -> Void in
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            
        }, finish: { (assets: [PHAsset]) -> Void in
            let header = self.customerItemTableView.headerView(forSection: self.currentImageSection) as! CustomerItemSectionHeaderView
            header.itemImageButton.setBackgroundImage(Utils.shared.getAssetThumbnail(assets[0]), for: .normal)
            
            self.imageMOStructArray[self.currentImageSection].imageMO.imageFile = Utils.shared.getAssetThumbnail(assets[0]).pngData()!
            
            self.imageMOStructArray[self.currentImageSection].imageMO.updatedUser = Utils.shared.getUser()
            self.imageMOStructArray[self.currentImageSection].imageMO.updatedDatetime = Date()
            
            self.currentImageSection = -1
            
        }, completion: nil)
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        
        let itmTypeNameMO = ItemTypeNameMO(context: context)
        itmTypeNameMO.name = ""
        let itmTypeBrandMO = ItemTypeBrandMO(context: context)
        itmTypeBrandMO.name = ""
        let itemTypeMO = ItemTypeMO(context: context)
        itemTypeMO.itemTypeBrand = itmTypeBrandMO
        itemTypeMO.itemTypeName = itmTypeNameMO
        
        let newItemMO = ItemMO(context: context)
        newItemMO.itemType = itemTypeMO
        newItemMO.quantity = 1
        newItemMO.createdUser = Utils.shared.getUser()
        newItemMO.createdDatetime = Date()
        newItemMO.updatedUser = Utils.shared.getUser()
        newItemMO.updatedDatetime = Date()
        
        newItemMO.image = imageMOStructArray[sender.tag].imageMO
        newItemMO.customer = customerMO
        newItemMO.shipping = shippingMO
        
        imageMOStructArray[sender.tag].itemMOStructArray.insert(ItemMOStruct(itemMO: newItemMO, status: "new"), at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionFlipFromLeft,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            let context = appDelegate.persistentContainer.viewContext
            context.delete(imageMOStructArray[deletionIndexPath.section].itemMOStructArray[deletionIndexPath.row].itemMO)
            
            imageMOStructArray[deletionIndexPath.section].itemMOStructArray.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .left)
        }
    }
    
    @objc func deleteImage(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(imageMOStructArray[sender.tag].imageMO)
        for itmMOStruct in imageMOStructArray[sender.tag].itemMOStructArray {
            context.delete(itmMOStruct.itemMO)
        }
        imageMOStructArray.remove(at: sender.tag)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCurlUp,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setItemNameData(_ sectionIndex: Int, _ rowIndex: Int, _ name: String) {
        imageMOStructArray[sectionIndex].itemMOStructArray[rowIndex].itemMO.itemType!.itemTypeName!.name = name
    }
    
    func setItemBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ name: String) {
        imageMOStructArray[sectionIndex].itemMOStructArray[rowIndex].itemMO.itemType!.itemTypeBrand!.name = name
    }
    
    func itemValueIsValid() -> Bool {
        if(imageMOStructArray.count > 0) {
            for imgMOStruct in imageMOStructArray {
                if(imgMOStruct.itemMOStructArray.count > 0) {
                    for itmMOStruct in imgMOStruct.itemMOStructArray {
                        if(itmMOStruct.itemMO.itemType!.itemTypeName!.name == "" ||
                            itmMOStruct.itemMO.itemType!.itemTypeBrand!.name == "") {
                            return false
                        }
                    }
                }
            }
        }
        
        return true
    }
}
