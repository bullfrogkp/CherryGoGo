//
//  CustomerEditAddressTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-08.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerEditAddressTableViewController: UITableViewController {

    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        customerAddressTableViewController!.deleteAddress(indexPath!)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let address = Address(street: streetTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), city: cityTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), province: provinceTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), postalCode: postalCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), country: countryTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if(unitTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            address.unit = unitTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if(addressMO != nil) {
            address.addressMO = addressMO!
            customerAddressTableViewController.updateAddress(address, indexPath: indexPath!)
        } else {
            customerAddressTableViewController.addAddress(address)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var addressMO: AddressMO?
    var indexPath: IndexPath?
    var customerAddressTableViewController: CustomerAddressTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteButton.isHidden = true
        
        if(addressMO != nil) {
            unitTextField.text = addressMO!.unit
            streetTextField.text = addressMO!.street
            cityTextField.text = addressMO!.city
            provinceTextField.text = addressMO!.province
            countryTextField.text = addressMO!.country
            postalCodeTextField.text = addressMO!.postalCode
            deleteButton.isHidden = false
        }
    }

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
