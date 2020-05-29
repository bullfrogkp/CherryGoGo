//
//  CustomerInfoEditTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-07.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class CustomerInfoEditTableViewController: UITableViewController {

    var customerMO: CustomerMO!
    var customerInfoTableViewController: CustomerInfoTableViewController!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var wechatTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var inStockSwitch: UISwitch!
    
    @IBAction func saveCustomer(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        customerMO.name = nameTextField.text
        customerMO.phone = phoneTextField.text
        customerMO.wechat = wechatTextField.text
        customerMO.comment = commentTextField.text
        customerMO.inStock = inStockSwitch.isOn
        
        do {
            try context.save()
        } catch {
            print("Error while saving items: \(error)")
        }
        
        customerInfoTableViewController.updateCustomer(customerMO)
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelEdit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.text = customerMO.name
        phoneTextField.text = customerMO.phone
        wechatTextField.text = customerMO.wechat
        commentTextField.text = customerMO.comment
        inStockSwitch.isOn = customerMO.inStock
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    /*
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
