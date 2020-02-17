//
//  ShippingInfoViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-09-08.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ShippingInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var shippingDateTextField: UITextField!
    @IBOutlet weak var shippingStatusTextField: UITextField!
    @IBOutlet weak var shippingCityTextField: UITextField!
    @IBOutlet weak var shippingFeeNationalTextField: UITextField!
    @IBOutlet weak var shippingFeeInternationalTextField: UITextField!
    @IBOutlet weak var shippingDepositTextField: UITextField!
    @IBOutlet weak var shippingCommentTextField: UITextField!
    
    @IBOutlet weak var shippingScrollView: UIScrollView!
    @IBOutlet weak var shippingBoxQuantityTextField: UITextField!
    @IBAction func unwind(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        var errorMsg = ""
        
        let sCity = shippingCityTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sDate = shippingDateTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sStatus = shippingStatusTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sComment = shippingCommentTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sFeeNational = shippingFeeNationalTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sFeeInternational = shippingFeeInternationalTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sDeposit = shippingDepositTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let sBoxQuantity = shippingBoxQuantityTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if sDate == "" {
            errorMsg += "请填写日期\n"
        } else {
            if (dateFormatter.date(from: sDate)) == nil {
                errorMsg += "请填写正确日期格式\n"
            }
        }
        
        if sCity == "" {
            errorMsg += "请填写城市\n"
        }
        
        if(sFeeNational != "") {
            if (formatter.number(from: sFeeNational) as? NSDecimalNumber) == nil {
                errorMsg += "请填写正确国内运费\n"
            }
        }
        
        if(sFeeInternational != "") {
            if (formatter.number(from: sFeeInternational) as? NSDecimalNumber) == nil {
                errorMsg += "请填写正确国际运费\n"
            }
        }
        
        if(sDeposit != "") {
            if (formatter.number(from: sDeposit) as? NSDecimalNumber) == nil {
                errorMsg += "请填写正确押金\n"
            }
        }
        
        if(errorMsg != "") {
            let alertController = UIAlertController(title: "请填写正确数据", message: errorMsg, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        
        } else {
            
            if shipping == nil {
                shipping = Shipping(city: sCity, shippingDate: dateFormatter.date(from: sDate)!)
            } else {
                shipping!.city = sCity
                shipping!.shippingDate = dateFormatter.date(from: sDate)!
            }
            
            if(sFeeNational != "") {
                shipping!.feeNational = (formatter.number(from: sFeeNational) as! NSDecimalNumber)
            }
            
            if(sFeeInternational != "") {
                shipping!.feeInternational = (formatter.number(from: sFeeInternational) as! NSDecimalNumber)
            }
            
            if(sDeposit != "") {
                shipping!.deposit = (formatter.number(from: sDeposit) as! NSDecimalNumber)
            }
            
            if(sStatus != "") {
                shipping!.status = sStatus
            }
            
            if(sBoxQuantity != "") {
                shipping!.boxQuantity = sBoxQuantity
            }
            
            if(sComment != "") {
                shipping!.comment = sComment
            }
            
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
            shippingCityTextField.text = "\(shipping!.city)"
            
            if(shipping!.status != nil) {
                shippingStatusTextField.text = "\(shipping!.status!)"
            }
            
            if(shipping!.feeNational != nil) {
                shippingFeeNationalTextField.text = "\(shipping!.feeNational!)"
            }
            
            if(shipping!.feeInternational != nil) {
                shippingFeeInternationalTextField.text = "\(shipping!.feeInternational!)"
            }
            
            if(shipping!.deposit != nil) {
                shippingDepositTextField.text = "\(shipping!.deposit!)"
            }
            
            if(shipping!.comment != nil) {
                shippingCommentTextField.text = "\(shipping!.comment!)"
            }
            
            if(shipping!.boxQuantity != nil) {
                shippingBoxQuantityTextField.text = shipping!.boxQuantity
            }
        }
        
        showDatePicker()
        setupTextFields()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        startObservingKeyboardEvents()
    }
    
    //MARK: - Helper Functions
    private func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
        selector:#selector(keyboardWillShow),
        name:UIResponder.keyboardWillShowNotification,
        object:nil)
        NotificationCenter.default.addObserver(self,
        selector:#selector(keyboardWillHide),
        name:UIResponder.keyboardWillHideNotification,
        object:nil)
    }

    private func stopObservingKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
      if let userInfo = notification.userInfo {
        if let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            shippingScrollView.contentInset = contentInset
            shippingScrollView.scrollIndicatorInsets = contentInset
            shippingScrollView.contentOffset = CGPoint(x: shippingScrollView.contentOffset.x, y: 0 + keyboardSize.height)
        }
      }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        
        shippingScrollView.contentInset = contentInset
        shippingScrollView.scrollIndicatorInsets = contentInset
        shippingScrollView.contentOffset = CGPoint(x: shippingScrollView.contentOffset.x, y: 0)
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupTextFields() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        shippingFeeNationalTextField.inputAccessoryView = toolbar
        shippingFeeInternationalTextField.inputAccessoryView = toolbar
        shippingDepositTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
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
