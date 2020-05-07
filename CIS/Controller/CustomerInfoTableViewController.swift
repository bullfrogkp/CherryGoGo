//
//  CustomerInfoTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-06.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerInfoTableViewController: UITableViewController {

    var customer: CustomerMO!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var wechatLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = customer.name
        phoneLabel.text = customer.phone
        wechatLabel.text = customer.wechat
        commentLabel.text = customer.comment
    }
    
    func updateCustomer(_ cus: CustomerMO) {
        nameLabel.text = cus.name
        phoneLabel.text = cus.phone
        wechatLabel.text = cus.wechat
        commentLabel.text = cus.comment
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let destinationController = navController.topViewController as! CustomerInfoEditTableViewController
        
        destinationController.customer = customer
        destinationController.customerInfoTableViewController = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "返回", style: .plain, target: nil, action: nil)
    }
}
