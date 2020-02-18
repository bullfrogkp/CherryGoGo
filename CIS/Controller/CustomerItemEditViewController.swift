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

class CustomerItemEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var customerItemTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let image = Image(name: "test")
        image.customers = [newCustomer]
        
        if(newCustomer.images == nil) {
            newCustomer.images = []
        }
        newCustomer.images!.insert(image, at: 0)
        
        customerItemTableView.reloadData()
    }
    
    @IBAction func saveCustomerItem(_ sender: Any) {
        self.view.endEditing(true)
        
        newCustomer.name = customerNameTextField.text!
        
        if(customer == nil) {
            shippingDetailViewController.addCustomer(newCustomer)
        } else {
            shippingDetailViewController.updateCustomer(newCustomer, customerIndex!)
            
            customerItemViewController!.customer = newCustomer
            customerItemViewController!.customerNameLabel.text = customerNameTextField.text!
            customerItemViewController!.customerItemTableView.reloadData()
        }
        
        shippingDetailViewController.customerItemTableView.reloadData()
        shippingDetailViewController.imageCollectionView.reloadData()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var customer: Customer?
    var customerIndex: Int?
    var shippingDetailViewController: ShippingDetailViewController!
    var customerItemViewController: CustomerItemViewController?
    var newCustomer = Customer(name: "")
    var currentImageSection = -1
    
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
        
        if(customer != nil) {
            newCustomer.name = customer!.name
            newCustomer.phone = customer!.phone
            newCustomer.comment = customer!.comment
            newCustomer.wechat = customer!.wechat
            
            if(customer!.images != nil) {
                for img in customer!.images! {
                    let newImg = Image(imageFile: img.imageFile)
                    
                    if(img.name != nil) {
                        newImg.name = img.name!
                    }
                    newImg.customers = [newCustomer]
                    
                    if(img.items != nil) {
                        for itm in img.items! {
                            let newItm = Item(name: itm.name, quantity: itm.quantity)
                            newItm.customer = newCustomer
                            if(itm.comment != nil) {
                                newItm.comment = itm.comment
                            }
                            
                            if(itm.priceBought != nil) {
                                newItm.priceBought = itm.priceBought
                            }
                            
                            if(itm.priceSold != nil) {
                                newItm.priceSold = itm.priceSold
                            }
                            
                            newItm.image = newImg
                            
                            if(newImg.items == nil) {
                                newImg.items = []
                            }
                            newImg.items!.append(newItm)
                        }
                    }
                    
                    if(newCustomer.images == nil) {
                        newCustomer.images = []
                    }
                    newCustomer.images!.append(newImg)
                    
                    img.newImage = newImg
                }
            }
        }
        
        customerNameTextField.text = newCustomer.name
        customerNameTextField.delegate = self
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return newCustomer.images?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newCustomer.images?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemEditTableViewCell
        
        let item = newCustomer.images![indexPath.section].items![indexPath.row]
        
        cell.nameTextField.text = item.name
        cell.quantityTextField.text = "\(item.quantity)"
        
        if(item.priceSold != nil) {
            cell.priceSoldTextField.text = "\(item.priceSold!)"
        }
        
        if(item.priceBought != nil) {
            cell.priceBoughtTextField.text = "\(item.priceBought!)"
        }
        
        if(item.comment != nil) {
            cell.commentTextField.text = "\(item.comment!)"
        }
        
        cell.customerItemEditViewController = self
        cell.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        cell.quantityTextField.inputAccessoryView = toolbar
        cell.priceBoughtTextField.inputAccessoryView = toolbar
        cell.priceSoldTextField.inputAccessoryView = toolbar
        
        cell.nameTextField.delegate = self
        cell.commentTextField.delegate = self
    
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        let header = customerItemTableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! CustomerItemSectionHeaderView
        
        header.itemImageButton.setBackgroundImage(UIImage(data: newCustomer.images![section].imageFile as Data), for: .normal)
        header.itemImageButton.tag = section
        header.itemImageButton.addTarget(self, action: #selector(chooseImage(sender:)), for: .touchUpInside)
        
        header.itemImageButton.clipsToBounds = true
        header.itemImageButton.layer.cornerRadius = 5
        
        header.addItemButton.tag = section
        header.addItemButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)

        header.deleteImageButton.tag = section
        header.deleteImageButton.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 130
    }
    
    func deleteCell(cell: UITableViewCell) {
        self.view.endEditing(true)
        if let deletionIndexPath = customerItemTableView.indexPath(for: cell) {
            
//            for (idx, itm) in newCustomer.items!.enumerated() {
//                if(itm === newCustomer.images![deletionIndexPath.section].items![deletionIndexPath.row]) {
//                    newCustomer.items!.remove(at: idx)
//                    break
//                }
//            }
            
            newCustomer.images![deletionIndexPath.section].items!.remove(at: deletionIndexPath.row)
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
            case 1: itm.name = textField.text!
            case 2: itm.quantity = Int16(textField.text!)!
            case 3: itm.priceBought = NSDecimalNumber(string: textField.text!)
            case 4: itm.priceSold = NSDecimalNumber(string: textField.text!)
            case 5: itm.comment = textField.text!
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
            self.currentImageSection = -1
            
        }, completion: nil)
    }
    
    @objc func addItem(sender:UIButton)
    {
        self.view.endEditing(true)
        
        let itm = Item(name: "", quantity: 1)
        itm.image = newCustomer.images![sender.tag]
        itm.customer = newCustomer
        
        if(newCustomer.images![sender.tag].items == nil) {
            newCustomer.images![sender.tag].items = []
        }
        newCustomer.images![sender.tag].items!.insert(itm, at: 0)
        
        customerItemTableView.reloadData()
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
        
        customerItemTableView.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let header = customerItemTableView.headerView(forSection: currentImageSection) as! CustomerItemSectionHeaderView
            
            header.itemImageButton.setBackgroundImage(selectedImage, for: .normal)
            
            newCustomer.images![currentImageSection].imageFile = selectedImage.pngData()!
        }

        currentImageSection = -1
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
