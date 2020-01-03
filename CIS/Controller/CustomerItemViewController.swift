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
        
        for img in customer.images {
            img.items.removeAll()
        }
        
        for itm in items {
            for img in customer.images {
                if(itm.image === img) {
                    img.items.append(itm)
                    break
                }
            }
        }
        
        customerNameLabel.text = customer.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(ImageItemViewController.editData))
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return customer.images.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customer.images[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerItemId", for: indexPath) as! CustomerItemTableViewCell
        
        let item = customer.images[indexPath.section].items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.quantityLabel.text = "\(item.quantity)"
        cell.priceSoldLabel.text = "\(item.priceSold)"
        cell.priceBoughtLabel.text = "\(item.priceBought)"
        cell.descriptionTextView.text = "\(item.comment)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width - 16, height: 115))
        
        headerView.backgroundColor = UIColor.white
        
        let itemImageView: UIImageView = {
            let image = UIImage(data: customer.images[section].imageFile as Data)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            imageView.layer.cornerRadius = 5.0
            imageView.layer.borderWidth = 1
            imageView.contentMode = .scaleAspectFit
            
            return imageView
        }()
        
        headerView.addSubview(itemImageView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 115
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
}
