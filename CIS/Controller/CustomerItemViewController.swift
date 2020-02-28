//
//  CustomerItemViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-14.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

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
            
            self.shippingDetailViewController.deleteCustomerByIndex(rowIndex: self.customerIndex)
            
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(checkInAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }
    
    var items:[Item]!
    var customerIndex: Int!
    var shippingDetailViewController: ShippingDetailViewController!
    var customer: Customer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        
        customerItemTableView.backgroundColor = UIColor.white
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        if(customer.images != nil) {
            for img in customer.images! {
                if(img.items != nil) {
                    img.items!.removeAll()
                }
            }
        }
        
        for itm in items {
            if(customer.images != nil) {
                for img in customer.images! {
                    if(itm.image === img) {
                        if(img.items == nil) {
                            img.items = []
                        }
                        img.items!.append(itm)
                        break
                    }
                }
            }
        }
        
        customerNameLabel.text = customer.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(ImageItemViewController.editData))
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return customer.images?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customer.images?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemTableViewCell
        
        let item = customer.images![indexPath.section].items![indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.quantityLabel.text = "\(item.quantity)"
//        
//        if(item.priceSold != nil) {
//            cell.priceSoldLabel.text = "\(item.priceSold!)"
//        } else {
//            cell.priceSoldLabel.text = ""
//        }
//
//        if(item.priceBought != nil) {
//            cell.priceBoughtLabel.text = "\(item.priceBought!)"
//        } else {
//            cell.priceBoughtLabel.text = ""
//        }
//
        if(item.comment != nil) {
            cell.commentLabel.text = "\(item.comment!)"
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
            let image = UIImage(data: customer.images![section].imageFile as Data)
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
            destinationController.customer = customer
            destinationController.customerIndex = customerIndex
            destinationController.shippingDetailViewController = shippingDetailViewController
            destinationController.customerItemViewController = self
        }
    }
    
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
}
