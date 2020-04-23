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

class ImageItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CustomerTextFieldDelegate, ItemTextFieldDelegate {
    
    func setItemData(_ sectionIndex: Int, _ rowIndex: Int, _ val: String, _ itemTypeMO: ItemTypeMO) {
        let item = newImage.customers![sectionIndex].items![rowIndex]
        if(item.itemType?.name != val) {
            item.itemType = ItemType(name: itemTypeMO.name!, brand: itemTypeMO.brand!)
            item.itemType!.itemTypeMO = itemTypeMO
            item.changed = true
        }
    }
    
    func setCustomerData(_ idx: Int, _ val: String, _ customerMO: CustomerMO) {
        let cus = newImage.customers![idx]
        if(cus.name != val) {
            cus.name = val
            cus.customerMO = customerMO
            cus.changed = true
        }
    }
    
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
            if(newImage.customers != nil) {
                for (idx,cus) in newImage.customers!.enumerated() {
                    let header = customerItemTableView.headerView(forSection:idx) as! ImageItemSectionHeaderView
                    
                    if (cus.name != header.customerNameTextField.text!) {
                        cus.name = header.customerNameTextField.text!
                        cus.changed = true
                    }
                    
                }
            }
            shippingDetailViewController.addImage(newImage)
        } else {
            shippingDetailViewController.updateImage(newImage, imageIndex!)
            
            imageItemViewController!.image = newImage
            imageItemViewController!.itemImageView.image = UIImage(data: newImage.imageFile as Data)
            imageItemViewController!.customerItemTableView.reloadData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCustomer(_ sender: Any) {
        self.view.endEditing(true)
        
        let customer = Customer(name: "")
        customer.changed = true
        customer.images = [newImage]
        if(newImage.customers == nil) {
            newImage.customers = []
        }
        newImage.customers!.insert(customer, at: 0)
            
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
    
    var image: Image?
    var imageIndex: Int?
    var shippingDetailViewController: ShippingDetailViewController!
    var imageItemViewController: ImageItemViewController?
    var newImage = Image(name: "test")
    var activeField: UITextField?
    
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
        
        if(image != nil) {
            newImage.name = image!.name
            newImage.imageFile = image!.imageFile
            newImage.changed = false
            
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
                    newCus.createdDatetime = cus.createdDatetime
                    newCus.createdUser = cus.createdUser
                    newCus.updatedDatetime = cus.updatedDatetime
                    newCus.updatedUser = cus.updatedUser
                    newCus.changed = false
                    
                    if(cus.items != nil) {
                        for itm in cus.items! {
                            let newItm = Item(itemType: itm.itemType!, quantity: itm.quantity!)
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
                            
                            newItm.createdDatetime = itm.createdDatetime
                            newItm.createdUser = itm.createdUser
                            newItm.updatedDatetime = itm.updatedDatetime
                            newItm.updatedUser = itm.updatedUser
                            newItm.changed = false
                            
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
//        startObservingKeyboardEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        stopObservingKeyboardEvents()
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
        
        cell.imageItemEditViewController = self
        
        let iNameTextField = cell.nameTextField as! ItemTypeSearchTextField
        iNameTextField.text = item.itemType!.name
        iNameTextField.itemTextFieldDelegate = self
        iNameTextField.sectionIndex = indexPath.section
        iNameTextField.rowIndex = indexPath.row
        
        cell.quantityTextField.text = "\(item.quantity!)"
        /*
        if(item.priceSold != nil) {
            cell.priceSoldTextField.text = "\(item.priceSold!)"
        }
        
        if(item.priceBought != nil) {
            cell.priceBoughtTextField.text = "\(item.priceBought!)"
        }
        */
        
        if(item.comment != nil) {
            cell.commentTextField.text = "\(item.comment!)"
        }
        
        cell.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        cell.quantityTextField.inputAccessoryView = toolbar
        //cell.priceBoughtTextField.inputAccessoryView = toolbar
        //cell.priceSoldTextField.inputAccessoryView = toolbar
        
        cell.nameTextField.delegate = self
        cell.commentTextField.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let header = customerItemTableView.dequeueReusableHeaderFooterView(withIdentifier: "imageSectionHeader") as! ImageItemSectionHeaderView
        
        let cNameTextField = header.customerNameTextField as! CustomerSearchTextField
        cNameTextField.text = newImage.customers![section].name
        
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
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
//            if(newImage.items != nil) {
//                for (idx, itm) in newImage.items!.enumerated() {
//                    if(itm === newImage.customers![deletionIndexPath.section].items![deletionIndexPath.row]) {
//                        newImage.items!.remove(at: idx)
//                        break
//                    }
//                }
//            }
            
            newImage.customers![deletionIndexPath.section].items!.remove(at: deletionIndexPath.row)
            customerItemTableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    //MARK: - Custom Cell Functions
    func cell(_ cell: CustomerItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
    }
    
    func cell(_ cell: ImageItemEditTableViewCell, didUpdateTextField textField: UITextField) {
        
        if let indexPath = customerItemTableView.indexPath(for: cell) {
           
            let itm = newImage.customers![(indexPath.section)].items![indexPath.row]
                
            switch textField.tag {
            case 1: if(itm.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.changed = true
                    }
            
            case 2: if(itm.quantity != Int16(textField.text!)!) {
                        itm.quantity = Int16(textField.text!)!
                        itm.changed = true
                    }
//            case 3: if(itm.priceBought != NSDecimalNumber(string: textField.text!)) {
//                        itm.priceBought = NSDecimalNumber(string: textField.text!)
//                        itm.changed = true
//                    }
//            case 4: if(itm.priceSold != NSDecimalNumber(string: textField.text!)) {
//                        itm.priceSold = NSDecimalNumber(string: textField.text!)
//                        itm.changed = true
//                    }
            case 5: if(itm.comment != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        itm.comment = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        itm.changed = true
                    }
            default: print("Error")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        newImage.customers![sender.tag].name = header.customerNameTextField.text!
        newImage.customers![sender.tag].changed = true
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let itm = Item()
        itm.comment = ""
        itm.customer = newImage.customers![sender.tag]
        itm.changed = true
        itm.image = newImage
        
        if(newImage.customers![sender.tag].items == nil) {
            newImage.customers![sender.tag].items = []
        }
        newImage.customers![sender.tag].items!.insert(itm, at: 0)
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
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
        
        UIView.transition(with: customerItemTableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.customerItemTableView.reloadData() })
    }
}
