//
//  ShippingInfoViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-09-08.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ShippingInfoViewController: UIViewController {

    @IBOutlet weak var shippingDateTextField: UITextField!
    @IBOutlet weak var shippingStatusTextField: UITextField!
    @IBOutlet weak var shippingCityTextField: UITextField!
    @IBOutlet weak var shippingFeeNationalTextField: UITextField!
    @IBOutlet weak var shippingFeeInternationalTextField: UITextField!
    @IBOutlet weak var shippingDepositTextField: UITextField!
    @IBOutlet weak var shippingCommentTextField: UITextField!
    
    @IBAction func unwind(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        var errorMsg = ""
        
        if shippingDateTextField.text == "" {
            let alertController = UIAlertController(title: "必填项目", message: "请填写日期", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if shipping == nil {
            shipping = Shipping()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let shippingDate = dateFormatter.date(from: shippingDateTextField.text!) {
            shipping!.shippingDate = shippingDate
        } else {
            errorMsg += "请填写正确日期格式\n"
        }
        
        shipping!.status = shippingStatusTextField.text!
        shipping!.city = shippingCityTextField.text!
        shipping!.comment = shippingCommentTextField.text!
        
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        if let formattedNumber = formatter.number(from: shippingFeeNationalTextField.text!) as? NSDecimalNumber  {
            shipping!.feeNational = formattedNumber as NSDecimalNumber
        } else if(shippingFeeNationalTextField.text != ""){
            errorMsg += "请填写正确国内运费\n"
        }
        
        if let formattedNumber = formatter.number(from: shippingFeeInternationalTextField.text!) as? NSDecimalNumber  {
            shipping!.feeInternational = formattedNumber as NSDecimalNumber
        } else if(shippingFeeInternationalTextField.text != "") {
            errorMsg += "请填写正确国际运费\n"
        }
        
        if let formattedNumber = formatter.number(from: shippingDepositTextField.text!) as? NSDecimalNumber  {
            shipping!.deposit = formattedNumber as NSDecimalNumber
        } else if(shippingDepositTextField.text != "") {
            errorMsg += "请填写正确押金\n"
        }
        
        if(errorMsg != "") {
            let alertController = UIAlertController(title: "请填写正确数据", message: errorMsg, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        
        } else {
            if(shippingListTableViewController != nil) {
                shippingListTableViewController!.addShipping(shipping!)
            } else {
                shippingDetailViewController!.updateShipping(shipping!)
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    var shipping: Shipping?
    var shippingDetailViewController: ShippingDetailViewController?
    var shippingListTableViewController: ShippingListTableViewController?
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if shipping != nil {
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            
            shippingDateTextField.text = dateFormatterPrint.string(from: shipping!.shippingDate)
            shippingStatusTextField.text = "\(shipping!.status)"
            shippingCityTextField.text = "\(shipping!.city)"
            shippingFeeNationalTextField.text = "\(shipping!.feeNational)"
            shippingFeeInternationalTextField.text = "\(shipping!.feeInternational)"
            shippingDepositTextField.text = "\(shipping!.deposit)"
            shippingCommentTextField.text = "\(shipping!.comment)"
        }   else {
            shippingDateTextField.text = ""
            shippingStatusTextField.text = ""
            shippingCityTextField.text = ""
            shippingFeeNationalTextField.text = ""
            shippingFeeInternationalTextField.text = ""
            shippingDepositTextField.text = ""
            shippingCommentTextField.text = ""
        }
        
        showDatePicker()
    }
    
    //MARK: - Helper Functions
    func showDatePicker(){
       //Formate Date
        let loc = Locale(identifier: "zh")
        datePicker.locale = loc
       datePicker.datePickerMode = .date

      //ToolBar
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
     let cancelButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)

     shippingDateTextField.inputAccessoryView = toolbar
     shippingDateTextField.inputView = datePicker

    }

     @objc func donedatePicker(){

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      shippingDateTextField.text = formatter.string(from: datePicker.date)
      self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
       self.view.endEditing(true)
     }
}
