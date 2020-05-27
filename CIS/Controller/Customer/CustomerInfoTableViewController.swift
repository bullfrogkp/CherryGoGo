//
//  CustomerInfoTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-06.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerInfoTableViewController: UITableViewController {

    var customerMO: CustomerMO!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var wechatLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var inStockTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = customerMO.name
        phoneLabel.text = customerMO.phone
        wechatLabel.text = customerMO.wechat
        commentLabel.text = customerMO.comment
        if(customerMO.inStock == true) {
            inStockTableViewCell.isHidden = false
        } else {
            inStockTableViewCell.isHidden = true
        }
    }
    
    func updateCustomer(_ cus: CustomerMO) {
        nameLabel.text = cus.name
        phoneLabel.text = cus.phone
        wechatLabel.text = cus.wechat
        commentLabel.text = cus.comment
        if(cus.inStock == true) {
            inStockTableViewCell.isHidden = false
        } else {
            inStockTableViewCell.isHidden = true
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let destinationController = navController.topViewController as! CustomerInfoEditTableViewController
        
        destinationController.customerMO = customerMO
        destinationController.customerInfoTableViewController = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "返回", style: .plain, target: nil, action: nil)
    }
}
