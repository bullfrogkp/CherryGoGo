//
//  CustomerAddressTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-06.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerAddressTableViewController: UITableViewController {
    
    var customerMO: CustomerMO!
    var addressArray: [AddressMO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(customerMO.addresses != nil) {
            addressArray = customerMO.addresses!.allObjects as! [AddressMO]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addressArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressId", for: indexPath) as! CustomerAddressTableViewCell

        let addrMO = addressArray[indexPath.row]
        
        if(addrMO.unit != nil) {
            cell.streetLabel.text = "\(addrMO.unit!) \(addrMO.street!)"
        } else {
            cell.streetLabel.text = addrMO.street
        }
        
        cell.cityLabel.text = addrMO.city
        cell.postalCodeLabel.text = addrMO.postalCode
        cell.countryLabel.text = addrMO.country
        cell.provinceLabel.text = addrMO.province

        return cell
    }

    func updateAddress() {
        addressArray = customerMO.addresses!.allObjects as! [AddressMO]
        tableView.reloadData()
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAddress" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let naviView: UINavigationController = segue.destination as!  UINavigationController
                let destinationView: CustomerEditAddressTableViewController = naviView.viewControllers[0] as! CustomerEditAddressTableViewController
                
                destinationView.customerMO = customerMO
                destinationView.addressMO = addressArray[indexPath.row]
                destinationView.indexPath = indexPath
                destinationView.customerAddressTableViewController = self
            }
        } else if segue.identifier == "addAddress" {
            let naviView: UINavigationController = segue.destination as!  UINavigationController
            let destinationView: CustomerEditAddressTableViewController = naviView.viewControllers[0] as! CustomerEditAddressTableViewController
            
            destinationView.customerMO = customerMO
            destinationView.customerAddressTableViewController = self
        }
    }
}
