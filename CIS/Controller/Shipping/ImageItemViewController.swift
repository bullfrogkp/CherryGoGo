//
//  ImageItemViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-20.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ImageItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var customerItemTableView: SelfSizedTableView!
    
    @IBAction func deleteItemImageButton(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "操真的删除吗?", preferredStyle: .actionSheet)
        
        // Add actions to the menu
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let checkInAction = UIAlertAction(title: "删除　", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            let context = self.appDelegate.persistentContainer.viewContext
            let itemMOsToDelete = self.imageMO.items?.filter{($0 as! ItemMO).shipping === self.imageMO.shipping} as! [ItemMO]
            for itmMO in itemMOsToDelete {
               context.delete(itmMO)
            }
            context.delete(self.imageMO)
            self.appDelegate.saveContext()
            
            self.shippingDetailViewController.updateShippingDetail()
            
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(checkInAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }
    
    var imageMO: ImageMO!
    var shippingMO: ShippingMO!
    var customerMOStructArray: [CustomerMOStruct] = []
    var customerMODict: [CustomerMO:Int] = [:]
    var indexPath: IndexPath!
    var shippingDetailViewController: ShippingDetailViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        itemImageView.image = UIImage(data: imageMO.imageFile! as Data)!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editData))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
        
        loadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemTableViewCell
        
        let itmMO = customerMOStructArray[indexPath.section].itemMOArray[indexPath.row]
        
        cell.nameLabel.text = itmMO.itemType!.itemTypeName!.name
        cell.brandLabel.text = itmMO.itemType!.itemTypeBrand!.name
        cell.quantityLabel.text = "\(itmMO.quantity)"

        if(itmMO.comment != nil) {
            cell.commentLabel.text = "\(itmMO.comment!)"
        } else {
            cell.commentLabel.text = ""
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let customerLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21))
            label.text = customerMOStructArray[section].customerMO.name
            
            return label
        }()
        
        headerView.addSubview(customerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editImageItem" {
            let naviController : UINavigationController = segue.destination as! UINavigationController
            let destinationController: ImageItemEditViewController = naviController.viewControllers[0] as! ImageItemEditViewController
            destinationController.shippingMO = shippingMO
            destinationController.imageMO = imageMO
            destinationController.imageItemViewController = self
            destinationController.shippingDetailViewController = shippingDetailViewController
        }
    }
    
    @objc func editData() {
        self.performSegue(withIdentifier: "editImageItem", sender: self)
    }
    
    //MARK: - Helper Functions
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageView = tapGestureRecognizer.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func loadData() {
        customerMOStructArray.removeAll()
        customerMODict.removeAll()
        if(imageMO.customers != nil) {
            for cus in imageMO.customers! {
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
                    customerMOStructArray.append(CustomerMOStruct(customerMO: cusMO, itemMOArray: [], status: "old", oriName: cusMO.name!))
                    customerMODict[cusMO] = customerMOStructArray.count - 1
                }
            }
        
            if(shippingMO.items != nil) {
                for itm in shippingMO.items! {
                    let itmMO = itm as! ItemMO
                    
                    if(itmMO.image === imageMO) {
                        let cusMO = itmMO.customer!
                        let idx = customerMODict[cusMO]!
                        customerMOStructArray[idx].itemMOArray.append(itmMO)
                    }
                }
            }
        }
    }
    
    func updateImageMO() {
        loadData()
        customerItemTableView.reloadData()
    }
}
