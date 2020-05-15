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

class ImageItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CustomerTextFieldDelegate, ItemTypeNameTextFieldDelegate, ItemTypeBrandTextFieldDelegate {
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
                self.imageMO!.imageFile = Utils.shared.getAssetThumbnail(assets[0]).pngData()!
                
            }, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
        let context = appDelegate.persistentContainer.viewContext
        context.rollback()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCustomer(_ sender: Any) {
        self.view.endEditing(true)
        
        let context = self.appDelegate.persistentContainer.viewContext
        let customerMO = CustomerMO(context: context)
        customerMO.shipping = shippingMO
        
        let cusMOStruct = CustomerMOStruct(customerMO: customerMO, itemMOArray: [])
        customerMOStructArray.insert(cusMOStruct, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @IBAction func saveImageItemButton(_ sender: Any) {
        self.view.endEditing(true)
        
        if (!itemValueIsValid()) {
            let alertController = UIAlertController(title: "请填写正确数据", message: "请填物品信息", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else {
            appDelegate.saveContext()
            
            if(imageItemViewController != nil) {
                imageItemViewController!.updateImage(customerMOStructArray)
            } else {
                shippingDetailViewController.updateImage()
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var imageMO: ImageMO?
    var shippingMO: ShippingMO!
    var customerMOStructArray: [CustomerMOStruct] = []
    var shippingDetailViewController: ShippingDetailViewController!
    var imageItemViewController: ImageItemViewController?
    var activeField: UITextField?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        customerItemTableView.backgroundColor = UIColor.white
        customerItemTableView.keyboardDismissMode = .onDrag
        
        let nib = UINib(nibName: "ImageItemHeader", bundle: nil)
        customerItemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "imageSectionHeader")
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        if(imageMO == nil) {
            let context = self.appDelegate.persistentContainer.viewContext
            imageMO = ImageMO(context: context)
            imageMO!.shipping = shippingMO!
            imageMO!.imageFile = UIImage(named: "test")!.pngData()
        } else {
            itemImageButton.setBackgroundImage(UIImage(data: imageMO!.imageFile! as Data), for: .normal)
            itemImageButton.clipsToBounds = true
            itemImageButton.layer.cornerRadius = 5
            
            var cusFound = false
            if(shippingMO.items != nil) {
               for itm in shippingMO.items! {
                   let itmMO = itm as! ItemMO
                   
                   if(itmMO.image === imageMO) {
                       let cusMO = itmMO.customer!
                       cusFound = false
                       
                       for var cusMOStruct in customerMOStructArray {
                           if(cusMO === cusMOStruct.customerMO) {
                               cusMOStruct.itemMOArray.append(itmMO)
                               cusFound = true
                               break
                           }
                       }
                       
                       if(cusFound == false) {
                           customerMOStructArray.append(CustomerMOStruct(customerMO: cusMO, itemMOArray: [itmMO]))
                       }
                   }
               }
            }
        }
//        startObservingKeyboardEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        stopObservingKeyboardEvents()
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return customerMOStructArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemMOArray = customerMOStructArray[section].itemMOArray
        return itemMOArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemEditTableViewCell
        
        let itmMO = customerMOStructArray[indexPath.section].itemMOArray[indexPath.row]
        
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
        
        cell.imageItemEditViewController = self
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
        
        let header = customerItemTableView.dequeueReusableHeaderFooterView(withIdentifier: "imageSectionHeader") as! ImageItemSectionHeaderView
        
        let cNameTextField = header.customerNameTextField as! CustomerSearchTextField
        cNameTextField.text = customerMOStructArray[section].customerMO.name
        
        cNameTextField.tag = section
        cNameTextField.addTarget(self, action: #selector(updateCustomerName(sender:)), for: .editingDidEnd)
        cNameTextField.delegate = self
        cNameTextField.customerTextFieldDelegate = self
        cNameTextField.sectionIndex = section
        
        header.addItemButton.tag = section
        header.addItemButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)

        header.deleteCustomerButton.tag = section
        header.deleteCustomerButton.addTarget(self, action: #selector(deleteCustomer(sender:)), for: .touchUpInside)
        
        header.contentView.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 103
    }
    
    //MARK: - Custom Cell Functions
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
    }
    
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
           
            let itm = customerMOStructArray[indexPath.section].itemMOArray[indexPath.row]
                
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
        var cus = customerMOStructArray[idx].customerMO
        if(cus != customerMO) {
            cus = customerMO
            cus.updatedDatetime = Date()
            cus.updatedUser = Utils.shared.getUser()
        }
    }
    
    func setItemTypeBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeBrandMO: ItemTypeBrandMO) {
        let item = customerMOStructArray[sectionIndex].itemMOArray[rowIndex]
        if(item.itemType!.itemTypeBrand != itemTypeBrandMO) {
            item.itemType!.itemTypeBrand = itemTypeBrandMO
            item.updatedDatetime = Date()
            item.updatedUser = Utils.shared.getUser()
        }
    }
    
    func setItemTypeNameData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeNameMO: ItemTypeNameMO) {
        let item = customerMOStructArray[sectionIndex].itemMOArray[rowIndex]
        if(item.itemType!.itemTypeName != itemTypeNameMO) {
            item.itemType!.itemTypeName = itemTypeNameMO
            item.updatedDatetime = Date()
            item.updatedUser = Utils.shared.getUser()
        }
    }
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            var itemMOArray = customerMOStructArray[deletionIndexPath.section].itemMOArray
            let itmMO = itemMOArray[deletionIndexPath.row]

            let context = self.appDelegate.persistentContainer.viewContext
            context.delete(itmMO)

            itemMOArray.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    private func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
        selector:#selector(keyboardWillShow),
        name:UIResponder.keyboardWillShowNotification,
        object:nil)
        NotificationCenter.default.addObserver(self,
        selector:#selector(keyboardWillHide),
        name:UIResponder.keyboardWillHideNotification,
        object:nil)
    }

    private func stopObservingKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)

        self.customerItemTableView.contentInset = contentInsets
        self.customerItemTableView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.customerItemTableView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.customerItemTableView.contentInset = contentInsets
        self.customerItemTableView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func updateCustomerName(sender:UIButton) {
        self.view.endEditing(true)
        
        let header = customerItemTableView.headerView(forSection: sender.tag) as! ImageItemSectionHeaderView
        let customerMO = customerMOStructArray[sender.tag].customerMO
        
        customerMO.name = header.customerNameTextField.text!
        customerMO.updatedDatetime = Date()
        customerMO.updatedUser = Utils.shared.getUser()
        
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = self.appDelegate.persistentContainer.viewContext
        
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
        
        newItemMO.customer = customerMOStructArray[sender.tag].customerMO
        newItemMO.image = imageMO
        
        customerMOStructArray[sender.tag].itemMOArray.append(newItemMO)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCurlDown,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    @objc func deleteCustomer(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = self.appDelegate.persistentContainer.viewContext
        context.delete(customerMOStructArray[sender.tag].customerMO)
        for itmMO in customerMOStructArray[sender.tag].itemMOArray {
            context.delete(itmMO)
        }
        customerMOStructArray.remove(at: sender.tag)
        
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
