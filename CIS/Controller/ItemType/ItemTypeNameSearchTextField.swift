//
//  ItemTypeSearchTextField.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-20.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class ItemTypeSearchTextField: UITextField{
    
    var dataList : [ItemTypeNameMO] = [ItemTypeNameMO]()
    var resultsList : [SearchItemTypeName] = [SearchItemTypeName]()
    var tableView: UITableView?
    var itemTextFieldDelegate: ItemTextFieldDelegate?
    var sectionIndex: Int?
    var rowIndex: Int?

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // Connecting the new element to the parent view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()

    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        self.addTarget(self, action: #selector(ItemTypeSearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(ItemTypeSearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(ItemTypeSearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(ItemTypeSearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }


    override open func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()

    }


    //////////////////////////////////////////////////////////////////////////////
    // Text Field related methods
    //////////////////////////////////////////////////////////////////////////////

    @objc open func textFieldDidChange(){
        print("Text changed ...")
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }

    @objc open func textFieldDidBeginEditing() {
        print("Begin Editing")
    }

    @objc open func textFieldDidEndEditing() {
        print("End editing")

    }

    @objc open func textFieldDidEndEditingOnExit() {
        print("End on Exit")
    }

    //////////////////////////////////////////////////////////////////////////////
    // Data Handling methods
    //////////////////////////////////////////////////////////////////////////////


    // MARK: CoreData manipulation methods

    // Don't need this function in this case
    func saveItems() {
        print("Saving items")
        do {
            try context.save()
        } catch {
            print("Error while saving items: \(error)")
        }
    }

    func loadItems(withRequest request : NSFetchRequest<ItemTypeNameMO>) {
        print("loading items")
        do {
            dataList = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
    }


    // MARK: Filtering methods

    fileprivate func filter() {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", self.text!)
        let request : NSFetchRequest<ItemTypeNameMO> = ItemTypeNameMO.fetchRequest()
        request.predicate = predicate

        loadItems(withRequest : request)

        resultsList = []

        for i in 0 ..< dataList.count {

            let item = SearchItemTypeName(typeName: dataList[i].name!)

            item.itemTypeNameMO = dataList[i]
            
            let itemTypeNameFilterRange = (item.typeName as NSString).range(of: text!, options: .caseInsensitive)

            if itemTypeNameFilterRange.location != NSNotFound {
                item.attributedItemTypeName = NSMutableAttributedString(string: item.typeName)
                
                item.attributedItemTypeName!.setAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: itemTypeNameFilterRange)

                resultsList.append(item)
            }
        }
        tableView?.reloadData()
    }
}

extension ItemTypeSearchTextField: UITableViewDelegate, UITableViewDataSource {


    //////////////////////////////////////////////////////////////////////////////
    // Table View related methods
    //////////////////////////////////////////////////////////////////////////////


    // MARK: TableView creation and updating

    // Create SearchTableview
    func buildSearchTableView() {

        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemTypeSearchTextFieldCell")
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)

        } else {
            print("tableView created")
            tableView = UITableView(frame: CGRect.zero)
        }

        updateSearchTableView()
    }

    // Updating SearchtableView
    func updateSearchTableView() {

        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = 0
            tableHeight = tableView.contentSize.height

            // Set a bottom margin of 10p
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }

            // Set tableView frame
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)

            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })

            //Setting tableView style
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = UIColor.white
            tableView.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#e8e8e8")
            //tableView.alwaysBounceVertical = false

            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }

            tableView.reloadData()
        }
    }

    // MARK: TableViewDataSource methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(resultsList.count)
        return resultsList.count
    }

    // MARK: TableViewDelegate methods

    //Adding rows in the tableview with the data from dataList

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTypeSearchTextFieldCell", for: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.attributedText = resultsList[indexPath.row].getFormatedText()
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
        self.text = resultsList[indexPath.row].itemTypeNameMO!.name!
        itemTextFieldDelegate!.setItemNameData(sectionIndex!, rowIndex!, self.text!)
        tableView.isHidden = true
        self.endEditing(true)
    }
}
