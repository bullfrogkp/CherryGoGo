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

class ImageItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ItemTextFieldDelegate, CustomerTextFieldDelegate {
    
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
                self.imageMO!.updatedUser = Utils.shared.getUser()
                self.imageMO!.updatedDatetime = Date()
                
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
        shippingMO.addToCustomers(customerMO)
        customerMO.addToShippings(shippingMO)
        customerMO.createdUser = Utils.shared.getUser()
        customerMO.createdDatetime = Date()
        customerMO.updatedUser = Utils.shared.getUser()
        customerMO.updatedDatetime = Date()
        customerMO.addToImages(imageMO!)
        imageMO!.addToCustomers(customerMO)
        
        let cusMOStruct = CustomerMOStruct(customerMO: customerMO, itemMOStructArray: [], status: "new")
        customerMOStructArray.insert(cusMOStruct, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCurlDown,
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
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            if(customerMOStructArray.count > 0) {
                for cusMOStruct in customerMOStructArray {
                    let cusMO = cusMOStruct.customerMO
                    
                    if(cusMOStruct.status == "new") {
                        let existingCustomer = Utils.shared.getCustomerMO(name: cusMO.name!)
                        
                        if(existingCustomer != nil) {
                            shippingMO.addToCustomers(existingCustomer!)
                            existingCustomer!.addToShippings(shippingMO)
                            imageMO!.addToCustomers(existingCustomer!)
                            existingCustomer!.addToImages(imageMO!)
                            
                            imageMO!.removeFromCustomers(cusMO)
                            cusMO.removeFromImages(imageMO!)
                            shippingMO.removeFromCustomers(cusMO)
                            cusMO.removeFromShippings(shippingMO)
                            
                            for itmMOStruct in cusMOStruct.itemMOStructArray {
                                itmMOStruct.itemMO.customer = existingCustomer!
                            }
                            
                            context.delete(cusMO)
                        } 
                    }
                }
            }
            
            if(customerMOStructArray.count > 0) {
                for cusMOStruct in customerMOStructArray {
                    for itmMOStruct in cusMOStruct.itemMOStructArray {
                        if(itmMOStruct.status == "new") {
                            let itmMO = itmMOStruct.itemMO
                            let existingItemTypeMO = Utils.shared.getItemTypeMO(name: itmMO.itemType!.itemTypeName!.name!, brand: itmMO.itemType!.itemTypeBrand!.name!)
                            if(existingItemTypeMO != nil) {
                                context.delete(itmMO.itemType!.itemTypeName!)
                                context.delete(itmMO.itemType!.itemTypeBrand!)
                                context.delete(itmMO.itemType!)
                                itmMO.itemType = existingItemTypeMO
                            } else {
                                var currentItemTypeNameMO = itmMO.itemType!.itemTypeName!
                                let existingItemTypeNameMO = Utils.shared.getItemTypeNameMO(name: currentItemTypeNameMO.name!)
                                if(existingItemTypeNameMO != nil) {
                                    context.delete(currentItemTypeNameMO)
                                    currentItemTypeNameMO = existingItemTypeNameMO!
                                }
                                
                                var currentItemTypeBrandMO = itmMO.itemType!.itemTypeBrand!
                                let existingItemTypeBrandMO = Utils.shared.getItemTypeBrandMO(brand: currentItemTypeBrandMO.name!)
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
            
            if(imageItemViewController != nil) {
                imageItemViewController!.updateImageMO()
            }
            
            shippingDetailViewController.updateShippingDetail()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var imageMO: ImageMO?
    var shippingMO: ShippingMO!
    var customerMOStructArray: [CustomerMOStruct] = []
    var customerMODict: [CustomerMO:Int] = [:]
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
            imageMO!.createdUser = Utils.shared.getUser()
            imageMO!.createdDatetime = Date()
            imageMO!.updatedUser = Utils.shared.getUser()
            imageMO!.updatedDatetime = Date()
        } else {
            if(imageMO!.customers != nil) {
                for cus in imageMO!.customers! {
                    let cusMO = cus as! CustomerMO
                    var cusFound = false
                   
                    for (idx,cusStruct) in customerMOStructArray.enumerated() {
                        if(cusMO === cusStruct.customerMO) {
                            customerMODict[cusMO] = idx
                            cusFound = true
                            break
                        }
                    }
                   
                    if(cusFound == false) {
                        customerMOStructArray.append(CustomerMOStruct(customerMO: cusMO, itemMOStructArray: [], status: "old"))
                        customerMODict[cusMO] = customerMOStructArray.count - 1
                    }
                }
            
                if(shippingMO.items != nil) {
                    for itm in shippingMO.items! {
                        let itmMO = itm as! ItemMO
                        
                        if(itmMO.image === imageMO) {
                            let cusMO = itmMO.customer!
                            let idx = customerMODict[cusMO]!
                            customerMOStructArray[idx].itemMOStructArray.append(ItemMOStruct(itemMO: itmMO, status: "old"))
                        }
                    }
                }
            }
        }
        
        itemImageButton.setBackgroundImage(UIImage(data: imageMO!.imageFile! as Data), for: .normal)
        itemImageButton.clipsToBounds = true
        itemImageButton.layer.cornerRadius = 5
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
        let itemMOStructArray = customerMOStructArray[section].itemMOStructArray
        return itemMOStructArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemEditTableViewCell
        
        let itmMO = customerMOStructArray[indexPath.section].itemMOStructArray[indexPath.row].itemMO
        
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
        
        if(customerMOStructArray[section].customerMO.name != "") {
            cNameTextField.isUserInteractionEnabled = false
        } else {
            cNameTextField.isUserInteractionEnabled = true
        }
        
        cNameTextField.tag = section
        cNameTextField.addTarget(self, action: #selector(updateCustomerName(sender:)), for: .editingDidEnd)
        cNameTextField.sectionIndex = section
        cNameTextField.customerTextFieldDelegate = self
        
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
           
            let itm = customerMOStructArray[indexPath.section].itemMOStructArray[indexPath.row].itemMO
                
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
        customerMO.pinyin = customerMO.name!.getCapitalLetter()
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
        newItemMO.shipping = shippingMO
        
        customerMOStructArray[sender.tag].itemMOStructArray.insert(ItemMOStruct(itemMO: newItemMO, status: "new"), at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionFlipFromLeft,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            let context = appDelegate.persistentContainer.viewContext
            context.delete(customerMOStructArray[deletionIndexPath.section].itemMOStructArray[deletionIndexPath.row].itemMO)
            
            customerMOStructArray[deletionIndexPath.section].itemMOStructArray.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .left)
        }
    }
    
    @objc func deleteCustomer(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let context = self.appDelegate.persistentContainer.viewContext
        let cusMO = customerMOStructArray[sender.tag].customerMO
        imageMO!.removeFromCustomers(cusMO)
        cusMO.removeFromImages(imageMO!)
        for itmMOStruct in customerMOStructArray[sender.tag].itemMOStructArray {
            context.delete(itmMOStruct.itemMO)
        }
        customerMOStructArray.remove(at: sender.tag)
        
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
        customerMOStructArray[sectionIndex].itemMOStructArray[rowIndex].itemMO.itemType!.itemTypeName!.name = name
    }
    
    func setItemBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ name: String) {
        customerMOStructArray[sectionIndex].itemMOStructArray[rowIndex].itemMO.itemType!.itemTypeBrand!.name = name
    }
    
    func setCustomerNameData(_ sectionIndex: Int, _ name: String) {
        customerMOStructArray[sectionIndex].customerMO.name = name
    }
    
    func itemValueIsValid() -> Bool {
        if(customerMOStructArray.count > 0) {
            for cusMOStruct in customerMOStructArray {
                if(cusMOStruct.itemMOStructArray.count > 0) {
                    for itmMOStruct in cusMOStruct.itemMOStructArray {
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
    
    func addStockItem(_ itemMO: ItemMO) {
        self.view.endEditing(true)
        
        let context = appDelegate.persistentContainer.viewContext
        
        var imgFound = false
        var itmFound = false
        
        for (idx,imgStruct) in imageMOStructArray.enumerated() {
            if(itemMO.image === imgStruct.imageMO) {
                imageMODict[itemMO.image!] = idx
                imgFound = true
                break
            }
        }

        if(imgFound == false) {
            let newItemMO = ItemMO(context: context)
            newItemMO.itemType = itemMO.itemType
            newItemMO.quantity = 1
            newItemMO.createdUser = Utils.shared.getUser()
            newItemMO.createdDatetime = Date()
            newItemMO.updatedUser = Utils.shared.getUser()
            newItemMO.updatedDatetime = Date()
            
            newItemMO.image = itemMO.image
            newItemMO.customer = customerMO
            newItemMO.shipping = shippingMO
            
            newItemMO.parentItem = itemMO
            itemMO.addToChildItems(newItemMO)
            
            imageMOStructArray.append(ImageMOStruct(imageMO: newItemMO.image!, itemMOStructArray: [], status: "old"))
            imageMODict[newItemMO.image!] = imageMOStructArray.count - 1
        } else {
            let idx = imageMODict[itemMO.image!]!
            for itmMOStruct in imageMOStructArray[idx].itemMOStructArray {
                if(itmMOStruct.itemMO.itemType == itemMO.itemType) {
                    itmFound = true
                    break
                }
            }
            
            if(itmFound == false) {
                let newItemMO = ItemMO(context: context)
                newItemMO.itemType = itemMO.itemType
                newItemMO.quantity = 1
                newItemMO.createdUser = Utils.shared.getUser()
                newItemMO.createdDatetime = Date()
                newItemMO.updatedUser = Utils.shared.getUser()
                newItemMO.updatedDatetime = Date()
                
                newItemMO.image = itemMO.image
                newItemMO.customer = customerMO
                newItemMO.shipping = shippingMO
                newItemMO.parentItem = itemMO
                itemMO.addToChildItems(newItemMO)
                
                imageMOStructArray[idx].itemMOStructArray.append(ItemMOStruct(itemMO: newItemMO, status: "new"))
            } else {
                print("Item found")
            }
        }
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionFlipFromLeft,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    //MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInStockContact" {
            let naviController : UINavigationController = segue.destination as! UINavigationController
            let destinationController: InStockContactTableViewController = naviController.viewControllers[0] as! InStockContactTableViewController
            destinationController.imageItemEditViewController = self
        }
    }
}
