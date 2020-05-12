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
    
    func setCustomerData(_ idx: Int, _ customerMO: CustomerMO) {
        newCustomer.name = customerMO.name!
    }
    
    func setItemTypeBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeBrandMO: ItemTypeBrandMO) {
        let item = newCustomer.images![sectionIndex].items![rowIndex]
        if(item.itemType!.itemTypeBrand.itemTypeBrandMO != itemTypeBrandMO) {
            item.itemType!.itemTypeBrand.name = itemTypeBrandMO.name!
            item.changed = true
        }
    }
    
    func setItemTypeNameData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeNameMO: ItemTypeNameMO) {
        let item = newCustomer.images![sectionIndex].items![rowIndex]
        if(item.itemType!.itemTypeName.itemTypeNameMO != itemTypeNameMO) {
            item.itemType!.itemTypeName.name = itemTypeNameMO.name!
            item.changed = true
        }
    }

    @IBOutlet weak var customerNameTextField: CustomerSearchTextField!
    @IBOutlet weak var customerItemTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let image = Image(name: "test")
        image.changed = true
        image.customers = [newCustomer]
        
        if(newCustomer.images == nil) {
            newCustomer.images = []
        }
        newCustomer.images!.insert(image, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @IBAction func saveCustomerItem(_ sender: Any) {
        self.view.endEditing(true)
        
        newCustomer.name = customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(newCustomer.name == "") {
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
            if(customer == nil) {
                shippingDetailViewController.addCustomer(newCustomer)
            } else {
                shippingDetailViewController.updateCustomer(newCustomer, customerIndex!)
                
                customerItemViewController!.customer = newCustomer
                customerItemViewController!.customerNameLabel.text = customerNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                customerItemViewController!.customerItemTableView.reloadData()
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var customerMO: CustomerMO?
    var imageMOStructArray: [ImageMOStruct]?
    var indexPath: IndexPath?
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
        
        customerNameTextField.text = customerMO?.name ?? ""
        customerNameTextField.delegate = self
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageMOStructArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemMOArray = imageMOStructArray?[section].itemMOArray
        return itemMOArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemEditTableViewCell
        
        let itmMO = imageMOStructArray![indexPath.section].itemMOArray[indexPath.row]
        
        let iNameTextField = cell.nameTextField as! ItemTypeSearchTextField
        iNameTextField.text = "\(itmMO.itemType!.itemTypeName!.name!)"
        iNameTextField.itemTypeNameTextFieldDelegate = self
        iNameTextField.sectionIndex = indexPath.section
        iNameTextField.rowIndex = indexPath.row
        
        let iBrandTextField = cell.brandTextField as! ItemTypeBrandSearchTextField
        iBrandTextField.text = "\(itmMO.itemType!.itemTypeBrand!.name!)"
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
        
        let imageFile = imageMOStructArray![section].imageMO.imageFile!
        
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
            
            var itemMOArray = imageMOStructArray![deletionIndexPath.section].itemMOArray
            let itmMO = itemMOArray[deletionIndexPath.row]
            
            let context = self.appDelegate.persistentContainer.viewContext
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
           
            let itm = newCustomer.images![(indexPath.section)].items![indexPath.row]
                
            switch textField.tag {
            case 1: if(itm.itemType!.itemTypeName.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.itemType!.itemTypeName.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.changed = true
                    }
            
            case 2: if(Int16(textField.text!) != nil && itm.quantity != Int16(textField.text!)!) {
                        itm.quantity = Int16(textField.text!)!
                        itm.changed = true
                    }
                
            case 3: if(itm.itemType!.itemTypeBrand.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.itemType!.itemTypeBrand.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.changed = true
                    }
                
            case 5: if(itm.comment != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.comment = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.changed = true
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
            self.newCustomer.images![self.currentImageSection].imageFile = Utils.shared.getAssetThumbnail(assets[0]).pngData()!
            self.newCustomer.images![self.currentImageSection].changed = true
            self.currentImageSection = -1
            
        }, completion: nil)
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let itm = Item()
        let itmTypeName = ItemTypeName(name: "")
        let itmTypeBrand = ItemTypeBrand(name: "")
        itm.itemType = ItemType(itemTypeName: itmTypeName, itemTypeBrand: itmTypeBrand)
        itm.quantity = 1
        itm.comment = ""
        itm.changed = true
        itm.image = newCustomer.images![sender.tag]
        itm.customer = newCustomer
        
        if(newCustomer.images![sender.tag].items == nil) {
            newCustomer.images![sender.tag].items = []
        }
        newCustomer.images![sender.tag].items!.insert(itm, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @objc func deleteImage(sender:UIButton)
    {
        self.view.endEditing(true)
        
        if(newCustomer.images![sender.tag].items != nil) {
            for dItem in newCustomer.images![sender.tag].items! {
                if(newCustomer.items != nil) {
                    for (idx, itm) in newCustomer.items!.enumerated() {
                        if(itm === dItem) {
                            newCustomer.items!.remove(at: idx)
                            break
                        }
                    }
                }
            }
        }
        
        newCustomer.images!.remove(at: sender.tag)
        
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
        if(newCustomer.images != nil) {
            for img in newCustomer.images! {
                if(img.items != nil) {
                    for itm in img.items! {
                        if(itm.itemType!.itemTypeName.name == "" ||
                        itm.itemType!.itemTypeBrand.name == "") {
                            return false
                        }
                    }
                }
            }
        }
        
        return true
    }
}
