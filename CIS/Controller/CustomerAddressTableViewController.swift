//
//  CustomerAddressTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-06.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerAddressTableViewController: UITableViewController {
    
    var customer: CustomerMO!
    var addressArray: [AddressMO] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(customer.addresses != nil) {
            addressArray = customer.addresses!.allObjects as! [AddressMO]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customer.addresses?.count ?? 0
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
