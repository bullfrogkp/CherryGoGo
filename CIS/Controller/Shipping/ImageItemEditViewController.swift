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
    
    func setItemTypeBrandData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeBrandMO: ItemTypeBrandMO) {
        let item = newImage.customers![sectionIndex].items![rowIndex]
        if(item.itemType!.itemTypeBrand.itemTypeBrandMO != itemTypeBrandMO) {
            item.itemType!.itemTypeBrand.name = itemTypeBrandMO.name!
            item.changed = true
        }
    }
    
    func setItemTypeNameData(_ sectionIndex: Int, _ rowIndex: Int, _ itemTypeNameMO: ItemTypeNameMO) {
        let item = newImage.customers![sectionIndex].items![rowIndex]
        if(item.itemType!.itemTypeName.itemTypeNameMO != itemTypeNameMO) {
            item.itemType!.itemTypeName.name = itemTypeNameMO.name!
            item.changed = true
        }
    }
    
    func setCustomerData(_ idx: Int, _ customerMO: CustomerMO) {
        let cus = newImage.customers![idx]
        if(cus.name != customerMO.name) {
            cus.name = customerMO.name!
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
    
    var imageMO: ImageMO?
    var shippingMO: ShippingMO?
    var customerMOStructArray: [CustomerMOStruct] = []
    var indexPath: IndexPath?
    var shippingDetailViewController: ShippingDetailViewController!
    var imageItemViewController: ImageItemViewController?
    var newImage = Image(name: "test")
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
        }
        
        let customerMOSet = imageMO!.customers?.filter{($0 as! CustomerMO).shipping === imageMO!.shipping}
        let customerMOArray = Array(customerMOSet!) as! [CustomerMO]
        
        for cusMO in customerMOArray {
            let itemMOSet = cusMO.items?.filter{($0 as! ItemMO).shipping ===  imageMO!.shipping && ($0 as! ItemMO).image === imageMO}
            let itemMOArray = Array(itemMOSet!) as! [ItemMO]
            let cusMOStruct = CustomerMOStruct(customerMO: cusMO, itemMOArray: itemMOArray)
            customerMOStructArray!.append(cusMOStruct)
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
        let itemMOArray = customerMOStructArray[section].itemMOArray
        return itemMOArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemEditTableViewCell
        
        let itmMO = customerMOStructArray![indexPath.section].itemMOArray[indexPath.row]
        
        cell.imageItemEditViewController = self
        
        let iNameTextField = cell.nameTextField as! ItemTypeSearchTextField
        iNameTextField.text = "\(item.itemType!.itemTypeName.name)"
        iNameTextField.itemTypeNameTextFieldDelegate = self
        iNameTextField.sectionIndex = indexPath.section
        iNameTextField.rowIndex = indexPath.row
        
        let iBrandTextField = cell.brandTextField as! ItemTypeBrandSearchTextField
        iBrandTextField.text = "\(item.itemType!.itemTypeBrand.name)"
        iBrandTextField.itemTypeBrandTextFieldDelegate = self
        iBrandTextField.sectionIndex = indexPath.section
        iBrandTextField.rowIndex = indexPath.row
        
        cell.quantityTextField.text = "\(item.quantity!)"
        
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
        
        cell.nameTextField.delegate = self
        cell.brandTextField.delegate = self
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
            case 1: if(itm.itemType!.itemTypeName.name != textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                itm.itemType!.itemTypeName.name = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                itm.itemType!.itemTypeMO = nil
                itm.itemType!.itemTypeName.itemTypeNameMO = nil
                itm.changed = true
            }
            
            case 2: if(itm.quantity != Int16(textField.text!)!) {
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
        let itmTypeName = ItemTypeName(name: "")
        let itmTypeBrand = ItemTypeBrand(name: "")
        itm.itemType = ItemType(itemTypeName: itmTypeName, itemTypeBrand: itmTypeBrand)
        itm.quantity = 1
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