//
//  CustomerItemViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class CustomerItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerItemTableView: SelfSizedTableView!
    
    @IBAction func deleteCustomerButton(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "操真的删除吗?", preferredStyle: .actionSheet)
        
        // Add actions to the menu
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let checkInAction = UIAlertAction(title: "删除　", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            let context = self.appDelegate.persistentContainer.viewContext
            let itemMOsToDelete = self.customerMO.items?.filter{($0 as! ItemMO).shipping === self.shippingMO} as! [ItemMO]
            let imageMOsToRemove = self.customerMO.images?.filter{($0 as! ImageMO).shipping === self.shippingMO} as! [ImageMO]
            
            for imgMO in imageMOsToRemove {
                self.customerMO.removeFromImages(imgMO)
                imgMO.removeFromCustomers(self.customerMO)
            }
            
            for itmMO in itemMOsToDelete {
               context.delete(itmMO)
            }
            self.shippingMO.removeFromCustomers(self.customerMO)
            self.appDelegate.saveContext()
            
            self.shippingDetailViewController.updateShippingDetail()
            
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(checkInAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }
    
    var customerMO: CustomerMO!
    var shippingMO: ShippingMO!
    var imageMOStructArray: [ImageMOStruct] = []
    var imageMODict: [ImageMO:Int] = [:]
    var indexPath: IndexPath!
    var shippingDetailViewController: ShippingDetailViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        customerItemTableView.backgroundColor = UIColor.white
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        customerNameLabel.text = customerMO.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(ImageItemViewController.editData))
        
        loadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemTableViewCell
        
        let itmMO = imageMOStructArray[indexPath.section].itemMOStructArray[indexPath.row].itemMO
        
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

        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width - 16, height: 110))

        headerView.backgroundColor = UIColor.white

        let itemImageView: UIImageView = {

            let imageFile = imageMOStructArray[section].imageMO.imageFile!

            let image = UIImage(data: imageFile as Data)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 90, height: 90)

            imageView.layer.cornerRadius = 5.0
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)

            return imageView
        }()

        headerView.addSubview(itemImageView)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    //MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCustomerItem" {
            let naviController : UINavigationController = segue.destination as! UINavigationController
            let destinationController: CustomerItemEditViewController = naviController.viewControllers[0] as! CustomerItemEditViewController
            destinationController.customerMO = customerMO
            destinationController.shippingMO = shippingMO
            destinationController.customerItemViewController = self
            destinationController.shippingDetailViewController = shippingDetailViewController
        }
    }
    //MARK: - Helper Functions
    @objc func editData() {
        self.performSegue(withIdentifier: "editCustomerItem", sender: self)
    }
    
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
        imageMOStructArray.removeAll()
        imageMODict.removeAll()
        
        if(customerMO.images != nil) {
            for img in customerMO.images! {
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
    
    func updateCustomerMO() {
        loadData()
        customerItemTableView.reloadData()
    }
}
