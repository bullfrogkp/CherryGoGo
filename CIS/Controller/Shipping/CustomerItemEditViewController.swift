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

class CustomerItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ItemTypeNameTextFieldDelegate, ItemTypeBrandTextFieldDelegate, CustomerTextFieldDelegate {
    @IBOutlet weak var customerNameTextField: CustomerSearchTextField!
    @IBOutlet weak var customerItemTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        let context = appDelegate.persistentContainer.viewContext
        context.reset()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: Any) {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        let imageMO = ImageMO(context: context)
        imageMO.shipping = customerMO!.shipping
        imageMO.imageFile = UIImage(named: "test")!.pngData()!
        
        let imgMOStruct = ImageMOStruct(imageMO: imageMO, itemMOArray: [])
        imageMOStructArray.insert(imgMOStruct, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @IBAction func saveCustomerItem(_ sender: Any) {
        self.view.endEditing(true)
        
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
            customerMO!.name = customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            appDelegate.saveContext()
            
            if(customerItemViewController != nil) {
                customerItemViewController!.updateCustomer(imageMOStructArray)
            } else {
                shippingDetailViewController.updateCustomer()
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var customerMO: CustomerMO?
    var shippingMO: ShippingMO?
    var imageMOStructArray: [ImageMOStruct] = []
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
        
        customerNameTextField.sectionIndex = 0
        customerNameTextField.customerTextFieldDelegate = self
        customerNameTextField.delegate = self
        
        if(customerMO == nil) {
            let context = appDelegate.persistentContainer.viewContext
            customerMO = CustomerMO(context: context)
            customerMO!.shipping = shippingMO!
        } else {
            customerNameTextField.text = customerMO!.name
            
            if(customerMO!.images != nil) {
                let imageMOSet = customerMO!.images!.filter{($0 as! ImageMO).shipping === customerMO!.shipping}
                if(imageMOSet.count != 0) {
                    let imageMOArray = Array(imageMOSet) as! [ImageMO]
                    
                    for imgMO in imageMOArray {
                        var itemMOArray: [ItemMO] = []
                        if(imgMO.items != nil) {
                            let itemMOSet = imgMO.items!.filter{($0 as! ItemMO).shipping ===  customerMO!.shipping && ($0 as! ItemMO).customer === customerMO!}
                            if(itemMOSet.count != 0) {
                                itemMOArray = Array(itemMOSet) as! [ItemMO]
                            }
                        }
                        let imgMOStruct = ImageMOStruct(imageMO: imgMO, itemMOArray: itemMOArray)
                        imageMOStructArray.append(imgMOStruct)
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
        let itemMOArray = imageMOStructArray[section].itemMOArray
        return itemMOArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemEditTableViewCell
        
        let itmMO = imageMOStructArray[indexPath.section].itemMOArray[indexPath.row]
        
        let iNameTextField = cell.nameTextField as! ItemTypeSearchTextField
        if(itmMO.itemType!.itemTypeName!.name != nil) {
            iNameTextField.text = "\(itmMO.itemType!.itemTypeName!.name!)"
        }
        iNameTextField.itemTypeNameTextFieldDelegate = self
        iNameTextField.sectionIndex = indexPath.section
        iNameTextField.rowIndex = indexPath.row
        
        let iBrandTextField = cell.brandTextField as! ItemTypeBrandSearchTextField
        if(itmMO.itemType!.itemTypeBrand!.name != nil) {
            iBrandTextField.text = "\(itmMO.itemType!.itemTypeBrand!.name!)"
        }
        iBrandTextField.itemTypeBrandTextFieldDelegate = self
        iBrandTextField.sectionIndex = indexPath.section
        iBrandTextField.rowIndex = indexPath.row
        
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
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            
            var itemMOArray = imageMOStructArray[deletionIndexPath.section].itemMOArray
            let itmMO = itemMOArray[deletionIndexPath.row]
            
            let context = appDelegate.persistentContainer.viewContext
            context.delete(itmMO)
            
            itemMOArray.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    //MARK: - Custom Cell Functions
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField) {
    }
    
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
           
            let itm = imageMOStructArray[indexPath.section].itemMOArray[indexPath.row]
                
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
    func setCustomerData(_ idx: Int, _ customerMO: CustomerMO) {
        self.customerMO = customerMO
    }
    
    func setItemTypeBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeBrandMO: ItemTypeBrandMO) {
        let itemMO = imageMOStructArray[sectionIndex].itemMOArray[rowIndex]
        if(itemMO.itemType!.itemTypeBrand != itemTypeBrandMO) {
            itemMO.itemType!.itemTypeBrand = itemTypeBrandMO
            itemMO.updatedUser = Utils.shared.getUser()
            itemMO.updatedDatetime = Date()
        }
    }
    
    func setItemTypeNameData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeNameMO: ItemTypeNameMO) {
        let itemMO = imageMOStructArray[sectionIndex].itemMOArray[rowIndex]
        if(itemMO.itemType!.itemTypeName != itemTypeNameMO) {
            itemMO.itemType!.itemTypeName = itemTypeNameMO
            itemMO.updatedUser = Utils.shared.getUser()
            itemMO.updatedDatetime = Date()
        }
    }
    
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
        let itmTypeBrandMO = ItemTypeBrandMO(context: context)
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
        
        imageMOStructArray[sender.tag].itemMOArray.insert(newItemMO, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCurlDown,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @objc func deleteImage(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(imageMOStructArray[sender.tag].imageMO)
        for itmMO in imageMOStructArray[sender.tag].itemMOArray {
            context.delete(itmMO)
        }
        imageMOStructArray.remove(at: sender.tag)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func itemValueIsValid() -> Bool {
//        if(newCustomer.images != nil) {
//            for img in newCustomer.images! {
//                if(img.items != nil) {
//                    for itm in img.items! {
//                        if(itm.itemType!.itemTypeName.name == "" ||
//                        itm.itemType!.itemTypeBrand.name == "") {
//                            return false
//                        }
//                    }
//                }
//            }
//        }
        
        return true
    }
}
