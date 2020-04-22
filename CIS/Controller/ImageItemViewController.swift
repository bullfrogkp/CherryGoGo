//
//  ImageItemViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-20.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import UIKit

class ImageItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var customerItemTableView: SelfSizedTableView!
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageView = tapGestureRecognizer.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func deleteItemImageButton(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "操真的删除吗?", preferredStyle: .actionSheet)
        
        // Add actions to the menu
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let checkInAction = UIAlertAction(title: "删除　", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
            self.shippingDetailViewController.deleteImageByIndex(self.imageIndex)
            
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(checkInAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }
    
    var image: Image!
    var items: [Item]!
    var imageIndex: Int!
    var shippingDetailViewController: ShippingDetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customerItemTableView.delegate = self
        customerItemTableView.dataSource = self
        customerItemTableView.layoutMargins = UIEdgeInsets.zero
        customerItemTableView.separatorInset = UIEdgeInsets.zero
        
        if(image.customers != nil) {
            for cus in image.customers! {
                if(cus.items != nil) {
                    cus.items!.removeAll()
                }
            }
        }
        
        for itm in items {
            if(image.customers != nil) {
                for cus in image.customers! {
                    if(itm.customer === cus) {
                        if(cus.items == nil) {
                            cus.items = []
                        }
                        cus.items!.append(itm)
                        break
                    }
                }
            }
        }
        
        itemImageView.image = UIImage(data: image.imageFile as Data)!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editData))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: - TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return image.customers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return image.customers?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemId", for: indexPath) as! ImageItemTableViewCell
        
        let item = image.customers![indexPath.section].items![indexPath.row]
        
        cell.nameLabel.text = item.itemType!.name
        cell.quantityLabel.text = "\(item.quantity!)"
        
//        if(item.priceSold != nil) {
//            cell.priceSoldLabel.text = "\(item.priceSold!)"
//        } else {
//            cell.priceSoldLabel.text = ""
//        }
//        
//        if(item.priceBought != nil) {
//            cell.priceBoughtLabel.text = "\(item.priceBought!)"
//        } else {
//            cell.priceBoughtLabel.text = ""
//        }
//        
//        if(item.comment != nil) {
//            cell.descriptionTextView.text = "\(item.comment!)"
//        } else {
//            cell.descriptionTextView.text = ""
//        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = Utils.shared.hexStringToUIColor(hex: "#F7F7F7")
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let customerLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21))
            label.text = image.customers![section].name
            
            return label
        }()
        
        headerView.addSubview(customerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - Navigation Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editImageItem" {
            let naviController : UINavigationController = segue.destination as! UINavigationController
            let destinationController: ImageItemEditViewController = naviController.viewControllers[0] as! ImageItemEditViewController
            destinationController.image = image
            destinationController.imageIndex = imageIndex
            destinationController.shippingDetailViewController = shippingDetailViewController
            destinationController.imageItemViewController = self
        }
    }
    
    @objc func editData() {
        self.performSegue(withIdentifier: "editImageItem", sender: self)
    }
}
