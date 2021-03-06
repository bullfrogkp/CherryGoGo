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
    @IBOutlet weak var shippingBoxQuantityTextField: UITextField!
    @IBOutlet weak var shippingScrollView: UIScrollView!
    
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
            if shippingMO == nil {
                let context = self.appDelegate.persistentContainer.viewContext
                shippingMO = ShippingMO(context: context)
                shippingMO!.createdDatetime = Date()
                shippingMO!.createdUser = Utils.shared.getUser()
            }

            shippingMO!.updatedDatetime = Date()
            shippingMO!.updatedUser = Utils.shared.getUser()
            
            shippingMO!.city = sCity
            shippingMO!.shippingDate = dateFormatter.date(from: sDate)!
            
            if(sFeeNational != "") {
                shippingMO!.feeNational = (formatter.number(from: sFeeNational) as! NSDecimalNumber)
            }
            
            if(sFeeInternational != "") {
                shippingMO!.feeInternational = (formatter.number(from: sFeeInternational) as! NSDecimalNumber)
            }
            
            if(sDeposit != "") {
                shippingMO!.deposit = (formatter.number(from: sDeposit) as! NSDecimalNumber)
            }
            
            if(sStatus != "") {
                shippingMO!.status = sStatus
            }
            
            if(sBoxQuantity != "") {
                shippingMO!.boxQuantity = sBoxQuantity
            }
            
            if(sComment != "") {
                shippingMO!.comment = sComment
            }
            
            appDelegate.saveContext()
            
            if(shippingListTableViewController != nil) {
                shippingListTableViewController!.addShipping(shippingMO!)
            } else {
                shippingDetailViewController!.updateShipping()
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    var shippingMO: ShippingMO?
    var shippingDetailViewController: ShippingDetailViewController?
    var shippingListTableViewController: ShippingListTableViewController?
    let datePicker = UIDatePicker()
    var activeField: UITextField?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if shippingMO != nil {
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            
            shippingDateTextField.text = dateFormatterPrint.string(from: shippingMO!.shippingDate!)
            shippingCityTextField.text = shippingMO!.city
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            
            if(shippingMO!.status != nil) {
                shippingStatusTextField.text = "\(shippingMO!.status!)"
            }
            
            if(shippingMO!.feeNational != nil) {
                shippingFeeNationalTextField.text = "\(formatter.string(from: shippingMO!.feeNational!)!)"
            }
            if(shippingMO!.feeInternational != nil) {
                shippingFeeInternationalTextField.text = "\(formatter.string(from: shippingMO!.feeInternational!)!)"
            }
            if(shippingMO!.deposit != nil) {
                shippingDepositTextField.text = "\(formatter.string(from: shippingMO!.deposit!)!)"
            }
            
            if(shippingMO!.comment != nil) {
                shippingCommentTextField.text = "\(shippingMO!.comment!)"
            }
            
            if(shippingMO!.boxQuantity != nil) {
                shippingBoxQuantityTextField.text = shippingMO!.boxQuantity
            }
        }
        
        showDatePicker()
        setupTextFields()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        startObservingKeyboardEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopObservingKeyboardEvents()
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

    @objc func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.shippingScrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 20, right: 0.0)

        self.shippingScrollView.contentInset = contentInsets
        self.shippingScrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.shippingScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -(keyboardSize!.height + 20), right: 0.0)
        self.shippingScrollView.contentInset = contentInsets
        self.shippingScrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.shippingScrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
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
